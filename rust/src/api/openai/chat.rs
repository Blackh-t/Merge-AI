use async_openai_wasm::config::OpenAIConfig;
use async_openai_wasm::{
    types::{
        ChatCompletionRequestAssistantMessageArgs, ChatCompletionRequestMessage,
        ChatCompletionRequestSystemMessageArgs, ChatCompletionRequestUserMessageArgs,
        CreateChatCompletionRequestArgs,
    },
    Client,
};

use crate::api::openai::http_handler::*;
use std::error::Error;

async fn openai(input: Vec<(String, String)>) -> Result<String, Box<dyn Error>> {
    // Create request
    let chat_histories = msg_convertion(input);
    let request = CreateChatCompletionRequestArgs::default()
        .max_tokens(512u32)
        .model("gpt-3.5-turbo")
        .messages(chat_histories)
        .build()?;

    // OpenAI Auth
    let config = OpenAIConfig::new()
        .with_api_key(fetch_request().await)
        .with_api_base("https://api.openai.com/v1/");

    // Fetch response
    let client = Client::with_config(config);
    let response = client.chat().create(request).await?;
    let msg = response.choices[0].clone();

    Ok(msg.clone().message.content.unwrap())
}

fn msg_convertion(contents: Vec<(String, String)>) -> Vec<ChatCompletionRequestMessage> {
    let messages_content = contents; //vec![("system", "You are a helpful assistant."), ("user", inpux)];

    // Konverter til ChatCompletionRequestMessage
    let messages: Vec<ChatCompletionRequestMessage> = messages_content
        .into_iter()
        .map(|(role, content)| match role.trim() {
            "system" => ChatCompletionRequestSystemMessageArgs::default()
                .content(content)
                .build()
                .unwrap()
                .into(),
            "assistant" => ChatCompletionRequestAssistantMessageArgs::default()
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
    messages
}

pub async fn chat(input: Vec<(String, String)>) -> String {
    match openai(input).await {
        Ok(msg) => format!("{}", msg),
        Err(e) => format!("OpenAI: {}", e),
    }
}
