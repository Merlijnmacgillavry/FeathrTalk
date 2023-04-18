use std::collections::{HashMap, HashSet};
use actix_web::client::Client;
use uuid::Uuid;
use actix::{prelude::{Actor, Context, Handler, Recipient}, Addr};
use crate::chat::chat_message::{ChatMessage};

use super::{chat_message::{ClientActorMessage, Connect, Disconnect}, chat_connection::ChatConnection};
type Socket = Recipient<ClientActorMessage>;


#[derive(Debug)]
pub struct ChatServer {
    clients: HashMap<Uuid, Socket>
}

impl Default for ChatServer {
    fn default() -> ChatServer {
        ChatServer { clients: HashMap::new() }
    }
}

impl ChatServer {
    fn send_message(&self, message: ClientActorMessage){
        println!("Sending message {:?}, to: {:?}", message.msg, message.recipient);
        // for client in &self.clients{
        //     println!("{:?}", client)
        // }
        let message_copy = message.clone();
        let success = self.clients
            .get(&message.recipient)
            .unwrap()
            .do_send(message);
        match success {
            Ok(_) => {
                println!("Succesfully send message!");
                self.clients.get(&message_copy.sender)
                .unwrap()
                .do_send(message_copy).unwrap();
            },
            Err(_) => {
                println!("Failed to send message!");
                self.clients.get(&message_copy.sender)
                .unwrap()
                .do_send(message_copy).unwrap();
            }
        }

    }
    // fn send_result(&self, message: ClientActorMessage){

    // }
}

impl Handler<Connect> for ChatServer {
    type Result = ();

    fn handle(&mut self, msg: Connect, _: &mut Context<Self>)  {
        println!("Adding user: {:?} to connected users!", msg.id);
        // let res = self.clients
        //     .insert(msg.id);
        self.clients.insert(
            msg.id, 
            msg.addr
        );
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


impl Actor for ChatServer {
    type Context = Context<Self>;
}

impl Handler<ClientActorMessage> for ChatServer {
    type Result = ();

    fn handle(&mut self, msg: ClientActorMessage, _: &mut Context<Self>) -> Self::Result {
        println!("{:?}",msg.msg);
        println!("Current clients: {:?}", self.clients);
        self.send_message(msg);
        // if msg.msg.starts_with("\\w") {
        //     if let Some(id_to) = msg.msg.split(' ').collect::<Vec<&str>>().get(1) {
        //         self.send_message(&msg.msg, &Uuid::parse_str(id_to).unwrap());
        //     }
        // } else {
        //     self.rooms.get(&msg.room_id).unwrap().iter().for_each(|client| self.send_message(&msg.msg, client));
        // }
    }
}