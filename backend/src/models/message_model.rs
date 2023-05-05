use mongodb::bson::oid::ObjectId;
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Message{
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub content: String,
    pub status: MessageStatus,
    pub sender: ObjectId,
    pub files: Vec<String>,
}
#[derive(Debug, Serialize, Deserialize)]
pub enum MessageStatus {
    Send, Received, Read
}