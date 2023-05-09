use core::fmt;
use std::{str::FromStr, error::Error as stdError};

use futures::Future;
use mongodb::{results::{InsertOneResult, UpdateResult}, bson::{extjson::de::Error, doc, Bson, oid::ObjectId}};

use crate::models::{user_model::{User}, friend_request_model::FriendRequest};

use super::mongodb_repo::MongoRepo;


impl MongoRepo {
    pub fn create_friend_request(&self, new_friend_request: FriendRequest) -> Result<InsertOneResult, Error> {
        let new_doc = new_friend_request.clone();
        let friend_request = self
            .friend_requests
            .insert_one(new_doc, None)
            .ok()
            .expect("Error creating friend request");
        
        let filter = doc! {"_id": ObjectId::from_str(&new_friend_request.sender).unwrap()};
        let update = doc! {"$push": {"friend_requests": &friend_request.inserted_id}};
        let update_sender = self.users.find_one_and_update(filter, update, None);
        let filter = doc! {"_id": ObjectId::from_str(&new_friend_request.receiver).unwrap()};
        let update = doc! {"$push": {"friend_requests": &friend_request.inserted_id}};
        let update_receiver = self.users.find_one_and_update(filter, update, None); 
        // let add_to_user = self.users.update_one(query, update, options)
        Ok(friend_request)
    }
    pub fn get_friend_requests_of_user(&self, user: User) -> Result<Vec<FriendRequest>, Error> {
        let mut frs = Vec::<FriendRequest>::new();
        for friend_request_id in user.friend_requests.iter() {
            let filter = doc! {"_id": friend_request_id};
            let friend_request = self.friend_requests.find_one(Some(filter), None);
            match friend_request {
                Ok(fr) => {
                    match fr{
                        Some(f) => {
                            frs.push(f);
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
        Ok(frs)
    }
    pub fn accept_friend_request(&self, id: &String) -> Result<FriendRequest, FriendRequestNotFoundError> {
        let id = ObjectId::from_str(id);
        match &id {
            Ok(i) => {
                println!("{:?}",i);
            }
            Err(e) => {
                println!("{:?}", e);
            }
        }
        



        let filter = doc! {"_id": id.ok()}; 
        let update = doc! {"$set": {"accepted": true}};
        let updated_friend_request = self.friend_requests.find_one_and_update(filter, update, None);
        match updated_friend_request {
            Ok(fr) => {
                match fr {
                    Some(f) => {
                        let filter = doc! {"_id": ObjectId::from_str(&f.sender).unwrap()};
                        let update = doc! {"$push": {"contacts": &f.receiver}};
                        let update_sender = self.users.find_one_and_update(filter, update, None);

                        let filter = doc! {"_id": ObjectId::from_str(&f.receiver).unwrap()};
                        let update = doc! {"$push": {"contacts": &f.sender}};
                        let update_receiver = self.users.find_one_and_update(filter, update, None);
                        Ok(f)
                    }
                    None =>{
                        println!("here");
                        Err(FriendRequestNotFoundError)
                    }
                }
            }
            Err(e) => {
                println!("{:?}", e);
                Err(FriendRequestNotFoundError)
            }
        }
    }
    // pub fn accept_friend_request(&self, )

 
    // pub fn find_friend_request(&self, id: &String) -> Result<FriendRequest, FriendRequestNotFoundError>{
    //     println!("{}", id);
    //     let id = ObjectId::from_str(id);
    //     match &id {
    //         Ok(i) => {
    //             println!("{:?}",i);
    //         }
    //         Err(e) => {
    //             println!("{:?}", e);
    //         }
    //     }
    //     let filter= doc! {"_id": id.ok()};
    //     let user = self
    //     .users
    //     .find_one(Some(filter), None).unwrap();
    //     match user{
    //         Some(u) => {Ok(u)}
    //         None => {Err(UserNotFoundError)}
    //     }
        
    // }
    // pub fn get_friend_requests(&self, id: String) -> Result<FindResult, Error> {
    //     let friend_requests = self.friend_requests.find(filter, options)
    // }
}

#[derive(Debug, Clone)]
pub struct FriendRequestNotFoundError;

impl stdError for FriendRequestNotFoundError{}

// Generation of an error is completely separate from how it is displayed.
// There's no need to be concerned about cluttering complex logic with the display style.
//
// Note that we don't store any extra info about the errors. This means we can't state
// which string failed to parse without modifying our types to carry that information.
impl fmt::Display for FriendRequestNotFoundError {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "Friend Request does not exist!")
    }
}

