use mongodb::bson::oid::ObjectId;
use serde::{Serialize, Deserialize};

use super::message_model::Message;

#[derive(Debug, Serialize, Deserialize)]
pub struct Chat {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub participants: Vec<ObjectId>,
    pub messages: Vec<Message>,
    pub chat_type: ChatType,
    pub name: Option<String>,
    pub description: Option<String>,
    pub chat_image: Option<String>
}

#[derive(Debug, Serialize, Deserialize)]
pub enum ChatType{
    Private,
    Group
}