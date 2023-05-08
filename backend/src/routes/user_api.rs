use std::str::FromStr;

use crate::{models::user_model::{User}, repository::mongodb_repo::MongoRepo};
use actix_web::{
    post,
    web::{Data, Json, Path},
    HttpResponse, HttpRequest,
};
use mongodb::bson::oid::ObjectId;
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateUserBody {
    name: String,
    bio: String,
    profile_image: String
}

#[post("/user/{user_id}")]
pub async fn create_user(Path(user_id): Path<String>,db: Data<MongoRepo>, new_user: Json<CreateUserBody>) -> HttpResponse {
    let data = User {
        id: Some(ObjectId::from_str(&user_id).unwrap()),
        bio: new_user.bio.to_owned(),
        profile_image: new_user.profile_image.to_owned(),
        name: new_user.name.to_owned(),
        blocks: Vec::<ObjectId>::new(),
        chats: Vec::<ObjectId>::new(),
        contacts: Vec::<ObjectId>::new(),
        friend_requests: Vec::<ObjectId>::new(),
    };
    println!("{:?}",&new_user);
    let user_detail = db.create_user(data);
    match user_detail {
        Ok(user) => HttpResponse::Ok().json(user),
        Err(err) => HttpResponse::InternalServerError().body(err.to_string()),
    }
}