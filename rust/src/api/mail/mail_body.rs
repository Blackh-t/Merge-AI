use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
struct DistinationMail {
    to: Vec<String>,
}

#[derive(Deserialize, Serialize)]
struct SRCMail<'a> {
    email: &'a str,
}

#[derive(Deserialize, Serialize)]
struct MailContent<'a> {
    #[serde(rename = "type")]
    content_type: &'a str,
    value: &'a str,
}

#[derive(Deserialize, Serialize)]
pub struct MailBox<'a> {
    personalizations: Vec<DistinationMail>,
    from: SRCMail<'a>,
    subject: &'a str,
    ontent: MailContent<'a>,
}
