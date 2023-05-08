use serde::{Deserialize, Serialize};
use uuid::Uuid;

#[derive(Debug, Deserialize)]
pub struct ChatContent {
    recipient: String,
    content: String,
    messageType: ChatContentType,
}
impl ChatContent{
    pub fn get_content(&self) -> String {
        self.content.to_string()
    }
    pub fn get_recipient(&self) -> 
    String {
        self.recipient.to_owned()
    }
    pub fn get_message_type(&self) -> ChatContentType{
        self.messageType.clone()
    }
}

#[derive(Debug, Deserialize, Clone, Serialize)]
pub enum ChatContentType {
    Private,
    Group,
    FriendRequestSend,
    FriendRequestAccepted,
    FriendRequestRejected
}