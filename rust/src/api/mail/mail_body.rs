use serde::{Deserialize, Serialize};

#[derive(Deserialize, Serialize)]
struct DistinationMail<'a> {
    to: &'a str,
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
    personalizations: Vec<DistinationMail<'a>>,
    from: SRCMail<'a>,
    subject: Option<&'a str>,
    content: MailContent<'a>,
}

impl<'x> MailBox<'x> {
    pub fn new() -> Self {
        MailBox {
            personalizations: Vec::new(),
            from: SRCMail { email: "" },
            subject: None,
            content: MailContent {
                content_type: "text/plain",
                value: "",
            },
        }
    }

    /// Distination E-Mail Adresses
    /// - Add one at the time.
    ///
    /// # Exemple
    /// ```rs
    /// mail.to("info@merge.ai")
    ///     .to("...")
    /// ```
    pub fn to(&mut self, email: &'x str) {
        self.personalizations.push(DistinationMail { to: email })
    }
    pub fn from(&mut self, email: &'x str) {
        self.from.email = email
    }
    pub fn subject(&mut self, sub: &'x str) {
        self.subject = Some(sub)
    }
    pub fn content(&mut self, text: &'x str) {
        self.content.value = text
    }
}
