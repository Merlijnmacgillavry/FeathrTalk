use actix::{Actor, Addr, Running, StreamHandler, WrapFuture, ActorFuture, ContextFutureSpawner, fut, ActorContext};
use actix::{AsyncContext, Handler};
use actix_web_actors::ws;
use uuid::Uuid;
use crate::chat::messages::{ClientActorMessage, Connect};
use crate::chat::chat_server::ChatServer;
use crate::chat::text_chat::ChatContent;
use crate::utils::client_serializer::ClientUser;

use actix_web_actors::ws::Message::Text;

use super::messages::{ChatMessage, Disconnect, OnlineUsers, ConnectMessage};

#[derive(Debug)]
pub struct ChatConnection {
    id: Uuid,
    server_addr: Addr<ChatServer>,
    name: String
}
impl ChatConnection {
    pub fn new(id: Uuid, server_addr: Addr<ChatServer>, name: String) -> ChatConnection{
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
        self.server_addr.do_send(Disconnect {id: self.id});
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
                println!("Received string {:?}", &chat_content);
                match serde_json::from_str::<ChatContent>(&chat_content)  {
                    Ok(content) => {
                        println!("Valid chat message: {:?}", content);
                        self.server_addr.do_send(ClientActorMessage{
                            sender: self.id,
                            msg: content.getContent(),
                            recipient: content.getRecipient(),
                            messageType: content.getMessageType()
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
impl Handler<ClientActorMessage> for ChatConnection {
    type Result =();

    fn handle(&mut self, msg: ClientActorMessage, ctx: &mut Self::Context){
        ctx.text("CHATMESSAGE:".to_owned()+&serde_json::to_string(&msg).unwrap())
    }
}
impl Handler<ConnectMessage> for ChatConnection {
    type Result =();

    fn handle(&mut self, msg: ConnectMessage, ctx: &mut Self::Context){
        ctx.text("CONNECT:".to_owned()+&serde_json::to_string(&msg).unwrap())
    }
}


