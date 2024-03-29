
use std::collections::HashMap;

use actix::{prelude::{Message, Recipient}, Addr};
use serde::{Serialize, Serializer};
use uuid::Uuid;

use super::{text_chat::ChatContentType, chat_connection::ChatConnection, chat_server::ConnectionInfo};

//WsConn responds to this to pipe it through to the actual client
#[derive(Message, Debug)]
#[rtype(result = "()")]
pub struct ChatMessage(pub String);

#[derive(Message)]
#[rtype(result = "()")]
pub struct Connect {
    pub addr: Recipient<ClientActorMessage>,
    pub id: Uuid,
    pub name: String,
    pub g_addr: Addr<ChatConnection>
}

//WsConn sends this to a lobby to say "take me out please"
#[derive(Message)]
#[rtype(result = "()")]
pub struct Disconnect {
    pub id: Uuid,
}

//client sends this to the lobby for the lobby to echo out.
#[derive(Message, Clone, Serialize)]
#[rtype(result = "()")]
pub struct ClientActorMessage {
    pub sender: Uuid,
    pub msg: String,
    pub recipient: Uuid,
    pub messageType: ChatContentType,
}


#[derive(Message, Clone, Debug)]
#[rtype(result = "()")]
pub struct OnlineUsers {
    pub users: HashMap<Uuid, ConnectionInfo>
}

#[derive(Message, Clone, Serialize)]
#[rtype(result = "()")]
pub struct ConnectMessage {
    pub uuid: Uuid,
    pub name: String,
}

