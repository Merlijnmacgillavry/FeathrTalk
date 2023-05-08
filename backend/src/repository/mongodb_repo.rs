use std::env;
    extern crate dotenv;
    use dotenv::dotenv;

    use mongodb::{
        bson::{extjson::de::Error},
        results::{ InsertOneResult},
        sync::{
            Client,
            Collection
        },
    };
    use crate::models::{user_model::User, friend_request_model::FriendRequest, message_model::Message};
    use crate::models::chat_model::Chat;

    #[derive(Debug)]
    pub struct MongoRepo {
        pub users: Collection<User>,
        pub chats: Collection<Chat>,
        pub friend_requests: Collection<FriendRequest>,
        pub messages: Collection<Message>
    }

    impl MongoRepo {
        pub fn init() -> Self {
            dotenv().ok();
            let uri = match env::var("MONGOURI") {
                Ok(v) => v.to_string(),
                Err(_) => format!("Error loading env variable"),
            };
            let client = Client::with_uri_str(uri).unwrap();
            let db = client.database("feathrTalkDB");
            let users: Collection<User> = db.collection("User");
            let chats: Collection<Chat> = db.collection( "Chat");
            let messages: Collection<Message> = db.collection("Message");
            let friend_requests: Collection<FriendRequest> = db.collection( "FriendRequest");

            MongoRepo { users, chats, messages,friend_requests }
        }

        
    }