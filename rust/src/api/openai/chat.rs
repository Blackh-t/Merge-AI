use async_openai_wasm::config::OpenAIConfig;
use async_openai_wasm::{
    types::{
        ChatCompletionRequestAssistantMessageArgs, ChatCompletionRequestMessage,
        ChatCompletionRequestSystemMessageArgs, ChatCompletionRequestUserMessageArgs,
        CreateChatCompletionRequestArgs,
    },
    Client,
};
use reqwest;
use std::error::Error;

async fn get() -> Result<String, Box<dyn Error>> {
    let response = reqwest::get(url).await?;
    let body = response.text().await?;
    Ok(body)
}

async fn fetch_request() -> String {
    match get().await {
        Ok(msg) => format!("{}", msg),
        Err(e) => e.to_string(),
    }
}

static API_BASE: &str = "https://api.openai.com/v1/";
async fn openai(input: String) -> Result<String, Box<dyn Error>> {
    let a = fetch_request().await;
    let config = OpenAIConfig::new().with_api_key(a);
    let config = if API_BASE != "..." {
        config.with_api_base(API_BASE)
    } else {
        config
    };

    // Definer innholdet i meldingene
    let inpux: &str = input.trim();
    let messages_content = vec![("system", "You are a helpful assistant."), ("user", inpux)];

    // Konverter til ChatCompletionRequestMessage
    let messages: Vec<ChatCompletionRequestMessage> = messages_content
        .into_iter()
        .map(|(role, content)| match role {
            "system" => ChatCompletionRequestSystemMessageArgs::default()
                .content(content)
                .build()
                .unwrap()
                .into(),
            "user" => ChatCompletionRequestUserMessageArgs::default()
                .content(content)
                .build()
                .unwrap()
                .into(),
            _ => panic!("Unknown role"),
        })
        .collect();

    // Bygg forespørselen ved å bruke `messages`
    let request = CreateChatCompletionRequestArgs::default()
        .max_tokens(512u32)
        .model("gpt-3.5-turbo")
        .messages(messages) // Bruk `Vec` her
        .build()?;
    let client = Client::with_config(config);
    let response = client.chat().create(request).await?;
    let msg = response.choices[0].clone();

    Ok(msg.clone().message.content.unwrap())
}

pub async fn chat(input: String) -> String {
    match openai(input).await {
        Ok(msg) => format!("{}", msg),
        Err(e) => format!("Test failed with error: {}", e),
    }
}
