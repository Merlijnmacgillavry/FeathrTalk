use std::collections::{HashMap, HashSet};
use actix_web::client::Client;
use futures::{FutureExt};
use mongodb::bson::{oid::ObjectId, doc};
use uuid::Uuid;
use actix::{prelude::{Actor, Context, Handler, Recipient, SendError}, Addr, ResponseFuture};

use crate::{chat::{messages::{OnlineUsers, ConnectMessage}, text_chat::ChatContentType}, repository::mongodb_repo::MongoRepo, models::{friend_request_model::FriendRequest, user_model::UserComplete}};

use super::{messages::{ClientActorMessage, Connect, Disconnect}, chat_connection::ChatConnection};
type Socket = Recipient<ClientActorMessage>;
// type Socket = Addr<ChatConnection>;


#[derive(Debug)]
pub struct ChatServer {
    clients: HashMap<String, ConnectionInfo>,
    db: MongoRepo
}

impl ChatServer {
    pub async fn new() -> ChatServer {
        let db = MongoRepo::init();
        ChatServer { clients: HashMap::new(), db }
    }
}


#[derive(Debug, Clone)]
pub struct ConnectionInfo {
    pub socket: Socket, pub name: String, pub addr: Addr<ChatConnection>
}

impl ChatServer {
    fn send_message_to_recipient(&self, msg: ClientActorMessage) -> Result<(), SendError<ClientActorMessage>>{
        println!("Sending message to recipient: {:?}", &msg.recipient);
        self.clients
            .get(&msg.recipient)
            .unwrap()
            .socket
            .do_send(msg)
    }
    fn send_message_confimation_to_sender(&self, msg: ClientActorMessage) -> Result<(), SendError<ClientActorMessage>>{
        println!("Sending message to sender: {:?}", &msg.sender);
        self.clients.get(&msg.sender)
                .unwrap()
                .socket
                .do_send(msg)
    }
    
    fn send_message(&self, msg: ClientActorMessage) {
        let msg_copy = msg.clone();
        let success_to_recipient = self.send_message_to_recipient(msg);
        let success_to_sender = self.send_message_confimation_to_sender(msg_copy);
        match success_to_recipient {
            Ok(_) => {
                println!("Succesfully send message to recipient!");
            },
            Err(_) => {
                println!("Failed to send message to recipient!");
            }
        }
        match success_to_sender {
            Ok(_) => {
                println!("Succesfully send message to sender!");
            },
            Err(_) => {
                println!("Failed to send message to sender!");
            }
        }
    }    
    fn send_chat_message(&self, msg: ClientActorMessage){
        println!("Sending message {:?}, to: {:?}", msg.msg, msg.recipient);
        self.send_message(msg);
    }
    fn send_group_message(&self, msg: ClientActorMessage){
        println!("Sending message {:?}, to: {:?}", msg.msg, msg.recipient);
        self.send_message(msg);
    }

    fn send_user_info(&self, id: &String){
        let user = self.db.get_complete_user(id).unwrap();
        let addr = &self.clients.get(id).unwrap().addr;
        addr.do_send(user);
    }
    fn accept_friend_request(&self, msg: ClientActorMessage){

    }

    fn send_friend_request(&self, msg: ClientActorMessage){
        let client_online = &self.clients.contains_key(&msg.recipient);
        println!("checking if client is online {:?}", client_online);
        println!("Sending friend request {:?}, to: {:?}", msg.msg, msg.recipient);
        let mut message = msg.clone();
        let mut message_copy = msg.clone();
        let fr_id = ObjectId::new();
        message_copy.msg = fr_id.to_string();
        message.msg = fr_id.to_string();

        let new_friend_request= FriendRequest{
            id: Some(fr_id),
            sender: message.sender.to_string(),
            receiver: message.recipient.to_string(),
            accepted: false,
            rejected: false
        };
        let res = self.db.create_friend_request(new_friend_request);
        
        match res {
            Ok(fr) => {
                println!("{:?}", fr);
            }
            Err(_) =>{
                println!("could not save fr in db");
            }
        }

        // println!("{:?}", res);
        self.send_message(msg)
    }
}




impl Actor for ChatServer {
    type Context = Context<Self>;
}

impl Handler<ClientActorMessage> for ChatServer {
    type Result = ();

    fn handle(&mut self, msg: ClientActorMessage, _: &mut Context<Self>) -> Self::Result {
        // println!("{:?}",msg.msg);
        println!("Current clients: {:?}", self.clients);
            match msg.messageType{
                ChatContentType::Private => {self.send_chat_message(msg);}
                ChatContentType::Group => {self.send_group_message(msg);}
                ChatContentType::FriendRequestSend => {
                    self.send_friend_request(msg);
    
                }
                ChatContentType::FriendRequestAccepted => {
                    self.send_friend_request(msg);
    
                }
                ChatContentType::FriendRequestRejected => {
                    self.send_friend_request(msg);
    
                }
            }
       
        
        // if msg.msg.starts_with("\\w") {
        //     if let Some(id_to) = msg.msg.split(' ').collect::<Vec<&str>>().get(1) {
        //         self.send_message(&msg.msg, &Uuid::parse_str(id_to).unwrap());
        //     }
        // } else {
        //     self.rooms.get(&msg.room_id).unwrap().iter().for_each(|client| self.send_message(&msg.msg, client));
        // }
    }
}

impl Handler<Connect> for ChatServer {
    type Result = ();

    fn handle(&mut self, msg: Connect, _: &mut Context<Self>)  {
        println!("Adding user: {:?}, with id: {:?} to connected users!", msg.name, msg.id);
        // let res = self.clients
        //     .insert(msg.id);
        let san = ConnectionInfo{
            name: msg.name.clone(),
            socket: msg.addr.clone(), 
            addr: msg.g_addr.clone()
        };
        self.clients.insert(
            msg.id.to_owned(), 
            san
        );
        
        msg.g_addr.do_send(ConnectMessage{
            id: msg.id.to_owned(),
            name: msg.name
        });
        let user = self.db.get_complete_user(&msg.id).unwrap();
        msg.g_addr.do_send(user);

        let mut users = Vec::<&ConnectionInfo>::new();
        for (key, info) in &self.clients{
            info.addr.do_send(OnlineUsers{
                users: self.clients.clone()
            })
        }

    }
}
impl Handler<Disconnect> for ChatServer {
    type Result = ();

    fn handle(&mut self, msg: Disconnect, _: &mut Context<Self>)  {
        println!("Removing user: {:?} from connected users!", msg.id);
        let res = self.clients
            .remove(&msg.id);
    }
}
