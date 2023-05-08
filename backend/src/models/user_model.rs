use actix::Message;
use mongodb::bson::{oid::ObjectId, self};
use serde::{Serialize, Deserialize};
use chrono::{DateTime, Utc};

use super::friend_request_model::FriendRequest;


#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct User {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub name: String,
    pub bio: String,
    pub profile_image: String,
    pub chats: Vec<ObjectId>,
    // #[serde(flatten)]
    pub contacts: Vec<ObjectId>,
    pub friend_requests: Vec<ObjectId>,
    pub blocks: Vec<ObjectId>,
    // pub created_at: Option<DateTime<Utc>>,
    // #[serde(default = "Utc::now")]
    // #[serde_as(as = "DateTime<Utc>")]
    // pub updated_at: Option<DateTime<Utc>>,
}
impl User{
    pub fn complete(&self, friend_requests: Vec::<FriendRequest>) -> UserComplete{
        UserComplete { id: self.id.to_owned(), 
            name: self.name.to_owned(), 
            bio: self.bio.to_owned(), 
            profile_image: self.profile_image.to_owned(), 
            chats: self.chats.to_owned(), 
            contacts: self.contacts.to_owned(), 
            friend_requests: friend_requests.to_owned(),
            blocks: self.blocks.to_owned()
         }

    } 
}
#[derive(Debug, Serialize, Deserialize, Message)]
#[rtype(result = "()")]
pub struct UserComplete {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub name: String,
    pub bio: String,
    pub profile_image: String,
    pub chats: Vec<ObjectId>,
    // #[serde(flatten)]
    pub contacts: Vec<ObjectId>,
    pub friend_requests: Vec<FriendRequest>,
    pub blocks: Vec<ObjectId>,
}
