
use core::fmt;
use std::{str::FromStr, fmt::format, error::Error as stdError};

use mongodb::{error::{Error, ErrorKind}, results::{InsertOneResult, UpdateResult}, bson::{doc,  oid::ObjectId, Document, self, Bson}};
use crate::models::user_model::{User, UserComplete, UserPublic};

use super::mongodb_repo::MongoRepo;


impl MongoRepo {
    pub fn create_user(&self, new_user: User) -> Result<InsertOneResult, Error> {
        let new_doc = new_user;
        // println!("{:?}", new_doc);
        let user = self
            .users
            .insert_one(new_doc, None);
        match user {
            Ok(u) => {
                // println!("{:?}", u);
                Ok(u)
            }
            Err(e) => {
                // println!("{:?}", e);
                Err(e)
            }
        }
    }
    pub fn get_complete_user(&self, id: &String) -> Result<UserComplete, UserNotFoundError>{
        let user = self.find_user(id);
        match user {
            Ok(u)=>{
                let friend_requests = self.get_friend_requests_of_user(u.clone()).unwrap();
                let contacts = self.get_contacts_of_user(u.clone()).unwrap();
                Ok(u.to_complete(friend_requests, contacts))
            }
            Err(e)=>{
                Err(e)
            }
        }

    }

    pub fn get_contacts_of_user(&self, user: User) -> Result<Vec<UserPublic>, Error> {
        let mut contacts = Vec::<UserPublic>::new();
        for contact_id in user.contacts.iter() {
            let filter = doc! {"_id": contact_id};
            let contact = self.users.find_one(Some(filter), None);
            match contact {
                Ok(fr) => {
                    match fr{
                        Some(f) => {
                            contacts.push(f.to_public() );
                        }
                        None => {
                            println!("Request not found by id {:?}", fr);
                        }
                    }
                }
                Err(e) => {
                    print!("{:?}",e);
                }
            }
        }
        Ok(contacts)
    }
    pub fn search_user(&self, query: &String) -> Result<Vec<UserPublic>, Error> {
        let parts: Vec<&str> = query.split("-").collect();
        let mut result = Vec::new();
        if parts.len()!=2 {
            let user = self.find_user(query);
            match user {
                Ok(u)=>  {
                    result.push(u.to_public());
                    return Ok(result)
                }
                Err(e) => ()
            }
            // return Err(Error::custom("Invalid Usercode."));
        }else{
            let name = parts[0];
            let code = parts[1];
            // let name = format!("/^{}", name);
            let filter = doc! {"name": name};
            let cursor = self.users.find(filter, None)?;
            
            for doc in cursor {
                match doc {
                    Ok(u)=>{
                        println!("{:?}",&u.id);
                        let id = u.id.unwrap();
                        if id.to_string().starts_with(code){
                            result.push(u.to_public());
                        }
                    }
                    Err(e) => println!("{:?}",e)
                };
                // let user: User = bson::from_bson(Bson::Document(doc))?;
                
            }
            
        }
        Ok(result)
    }

    pub fn find_user(&self, id: &String) -> Result<User, UserNotFoundError>{
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