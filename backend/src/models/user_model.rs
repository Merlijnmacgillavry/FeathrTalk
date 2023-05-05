use mongodb::bson::{oid::ObjectId, self};
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};


#[derive(Debug, Serialize, Deserialize)]
pub struct User {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub name: String,
    pub bio: String,
    pub profile_image: String,
    pub chats: Vec<ObjectId>,
    pub status: UserNetworkStatus,
    pub contacts: Vec<ObjectId>,
    pub friend_requests: Vec<ObjectId>,
    pub blocks: Vec<ObjectId>,
    // pub created_at: Option<DateTime<Utc>>,
    // #[serde(default = "Utc::now")]
    // #[serde_as(as = "DateTime<Utc>")]
    // pub updated_at: Option<DateTime<Utc>>,
}

#[derive(Debug, Serialize, Deserialize)]
pub enum UserNetworkStatus {
    Online,
    Offline
}
