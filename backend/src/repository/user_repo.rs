
use core::fmt;
use std::{str::FromStr, fmt::format, error::Error as stdError};

use mongodb::{error::Error, results::{InsertOneResult, UpdateResult}, bson::{doc,  oid::ObjectId, Document, self}};
use crate::models::user_model::{User, UserComplete};

use super::mongodb_repo::MongoRepo;


impl MongoRepo {
    pub fn create_user(&self, new_user: User) -> Result<InsertOneResult, Error> {
        let new_doc = new_user;
        println!("{:?}", new_doc);
        let user = self
            .users
            .insert_one(new_doc, None);
        match user {
            Ok(u) => {
                println!("{:?}", u);
                Ok(u)
            }
            Err(e) => {
                println!("{:?}", e);
                Err(e)
            }
        }
    }
    pub fn get_complete_user(&self, id: &String) -> Result<UserComplete, UserNotFoundError>{
        let user = self.find_user(id);
        match user {
            Ok(u)=>{
                let friend_requests = self.get_friend_requests_of_user(u.clone()).unwrap();
                Ok(u.complete(friend_requests))
            }
            Err(e)=>{
                Err(e)
            }
        }

    }

    pub fn find_user(&self, id: &String) -> Result<User, UserNotFoundError>{
        println!("{}", id);
        let id = ObjectId::from_str(id);
        match &id {
            Ok(i) => {
                println!("{:?}",i);
            }
            Err(e) => {
                println!("{:?}", e);
            }
        }
        let filter= doc! {"_id": id.ok()};
        let user = self
        .users
        .find_one(Some(filter), None).unwrap();
        match user{
            Some(u) => {Ok(u)}
            None => {Err(UserNotFoundError)}
        }
        
    }
}

#[derive(Debug, Clone)]
pub struct UserNotFoundError;

impl stdError for UserNotFoundError{}

// Generation of an error is completely separate from how it is displayed.
// There's no need to be concerned about cluttering complex logic with the display style.
//
// Note that we don't store any extra info about the errors. This means we can't state
// which string failed to parse without modifying our types to carry that information.
impl fmt::Display for UserNotFoundError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "User does not exist!")
    }
}