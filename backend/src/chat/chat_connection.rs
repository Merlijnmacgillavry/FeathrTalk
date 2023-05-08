use actix::{Actor, Addr, Running, StreamHandler, WrapFuture, ActorFuture, ContextFutureSpawner, fut, ActorContext};
use actix::{AsyncContext, Handler};
use actix_web_actors::ws;
use uuid::Uuid;
use crate::chat::messages::{ClientActorMessage, Connect};
use crate::chat::chat_server::ChatServer;
use crate::chat::text_chat::ChatContent;
use crate::models::friend_request_model::FriendRequest;
use crate::models::user_model::UserComplete;
use crate::utils::client_serializer::ClientUser;

use actix_web_actors::ws::Message::Text;

use super::messages::{ChatMessage, Disconnect, OnlineUsers, ConnectMessage};
use super::text_chat::ChatContentType;

#[derive(Debug)]
pub struct ChatConnection {
    id: String,
    server_addr: Addr<ChatServer>,
    name: String
}
impl ChatConnection {
    pub fn new(id: String, server_addr: Addr<ChatServer>, name: String) -> ChatConnection{
        ChatConnection { id, server_addr,name }
    }
}

impl Actor for ChatConnection {
    type Context = ws::WebsocketContext<Self>;

    fn started(&mut self, ctx: &mut Self::Context){
        println!("Started chat connection:\n\r{:?}", self);
        let addr = ctx.address();
        let addr2 = addr.clone();
        // println!("Address is: {:?}", addr);
        self.server_addr
            .do_send(Connect{
                id: self.id.clone(),
                name: self.name.clone(), 
                addr: addr.recipient() ,
                g_addr: addr2
            });
        
    }
    fn stopping(&mut self, ctx: &mut Self::Context) -> Running {
        println!("Stopping chat connection:\n\r{:?}", self);
        self.server_addr.do_send(Disconnect {id: self.id.to_owned()});
        let addr = ctx.address();
        let addr2 = addr.clone();
        self.server_addr
            .do_send(Connect{
                id: self.id.clone(),
                name: self.name.clone(), 
                addr: addr.recipient() , 
                g_addr: addr2
            });
        Running::Stop
    }
}

impl StreamHandler<Result<ws::Message, ws::ProtocolError>> for ChatConnection {
    fn handle(&mut self, msg: Result<ws::Message, ws::ProtocolError>, ctx: &mut Self::Context) {
        match msg {
            Ok(ws::Message::Ping(msg)) => {
                // self.hb = Instant::now();
                ctx.pong(&msg);
            }
            Ok(ws::Message::Pong(_)) => {
                // self.hb = Instant::now();
            }
            Ok(ws::Message::Binary(bin)) => ctx.binary(bin),
            Ok(ws::Message::Close(reason)) => {
                ctx.close(reason);
                ctx.stop();
            }
            Ok(ws::Message::Continuation(_)) => {
                ctx.stop();
            }
            Ok(ws::Message::Nop) => (),
            Ok(Text(chat_content)) => 
            {
                // println!("Received string {:?}", &chat_content);
                match serde_json::from_str::<ChatContent>(&chat_content)  {
                    Ok(content) => {
                        println!("Valid chat message: {:?} \n", content);
                        self.server_addr.do_send(ClientActorMessage{
                            sender: self.id.to_owned(),
                            msg: content.get_content(),
                            recipient: content.get_recipient(),
                            messageType: content.get_message_type()
                        })
                    }
                    _ => {
                        println!("Invalid chat message");
                    }
                    
                }
        },
            Err(e) => panic!("{}",e),
        }
    }
}

impl Handler<OnlineUsers> for ChatConnection {
    type Result = ();

    fn handle(&mut self, msg: OnlineUsers, ctx: &mut Self::Context) {
        println!("Writing message:\n\r{:?}", msg);
        let mut user_list = Vec::<ClientUser>::new();
        for (uuid, info) in msg.users{
            let user = ClientUser{
                uuid: uuid.to_string(),
                name: info.name
            };
            user_list.push(user);
        }
        ctx.text("ONLINEUSERS:".to_owned()+&serde_json::to_string(&user_list).unwrap())
        
    }
}

impl Handler<UserComplete> for ChatConnection {
    type Result = ();

    fn handle(&mut self, msg: UserComplete, ctx: &mut Self::Context) {
        println!("Writing message:\n\r{:?}", msg);
        ctx.text("USERINFO:".to_owned()+&serde_json::to_string(&msg).unwrap())
        
    }
}

impl Handler<ClientActorMessage> for ChatConnection {
    type Result =();

    fn handle(&mut self, msg: ClientActorMessage, ctx: &mut Self::Context){
        let mut header = "CHATMESSAGE"; 
        match msg.messageType {
            ChatContentType::Private => {header = "PRIVATE_CHAT_MESSAGE";}
            ChatContentType::Group => {header = "GROUP_CHAT_MESSAGE";}
            ChatContentType::FriendRequestSend => {header = "FRIEND_REQUEST_SEND";}
            ChatContentType::FriendRequestAccepted => {header = "FRIEND_REQUEST_ACCEPTED";}
            ChatContentType::FriendRequestRejected => {header = "FRIEND_REQUEST_REJECTED";}
        }
        ctx.text(header.to_owned()+"\n"+&serde_json::to_string(&msg).unwrap())
    }
}
impl Handler<ConnectMessage> for ChatConnection {
    type Result =();

    fn handle(&mut self, msg: ConnectMessage, ctx: &mut Self::Context){
        ctx.text("CONNECT:".to_owned()+&serde_json::to_string(&msg).unwrap())
    }
}


