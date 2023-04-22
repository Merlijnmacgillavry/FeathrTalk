use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct ChatContent {
    recipient: Uuid,
    content: String,
    messageType: ChatContentType,
}
impl ChatContent{
    pub fn getContent(&self) -> String {
        self.content.to_string()
    }
    pub fn getRecipient(&self) -> Uuid {
        self.recipient
    }
    pub fn getMessageType(&self) -> ChatContentType{
        self.messageType.clone()
    }
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub enum ChatContentType {
    Private,
    Group,
}