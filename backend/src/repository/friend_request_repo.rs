use std::str::FromStr;

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
        let res2 = self.users.find_one_and_update(filter, update, None); 
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