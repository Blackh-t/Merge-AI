use super::{error::SGClienResult, mail_body::MailBox};
use reqwest::{
    self,
    header::{HeaderMap, HeaderValue, AUTHORIZATION, CONTENT_TYPE},
    Response,
};
static API_URL: &str = "https://api.sendgrid.com/api/mail.send.json?";

#[derive(Clone, Debug)]
pub struct SendGridClient {
    api_key: String,
    host: String,
    client: reqwest::Client,
}

impl SendGridClient {
    pub fn new<S: Into<String>>(key: S) -> SendGridClient {
        // Build HTTP-request
        let builder = reqwest::ClientBuilder::new();
        let client = builder.build().unwrap();
        // Init SG-Client
        SendGridClient {
            api_key: key.into(),
            host: API_URL.to_string(),
            client,
        }
    }

    pub fn sets_host<S: Into<String>>(&mut self, api_url: S) {
        self.host = api_url.into()
    }

    pub async fn send(&self, mail_body: MailBox<'_>) -> SGClienResult<Response> {
        let reps = self
            .client
            .post(self.host.clone())
            .headers(self.headers().await?)
            .body("")
            .send()
            .await?;

        Ok(reps)
    }

    async fn headers(&self) -> SGClienResult<HeaderMap> {
        let mut headers = HeaderMap::new();
        headers.insert(
            AUTHORIZATION,
            HeaderValue::from_str(&format!("Bearer {}", self.api_key.clone()))?,
        );
        headers.insert(CONTENT_TYPE, HeaderValue::from_static("application/json"));
        Ok(headers)
    }
}
