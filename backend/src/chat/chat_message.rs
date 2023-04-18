
use actix::prelude::{Message, Recipient};
use uuid::Uuid;

use super::text_chat::ChatContentType;

//WsConn responds to this to pipe it through to the actual client
#[derive(Message, Debug)]
#[rtype(result = "()")]
pub struct ChatMessage(pub String);

#[derive(Message)]
#[rtype(result = "()")]
pub struct Connect {
    pub addr: Recipient<ClientActorMessage>,
    pub id: Uuid,
}

//WsConn sends this to a lobby to say "take me out please"
#[derive(Message)]
#[rtype(result = "()")]
pub struct Disconnect {
    pub id: Uuid,
}

//client sends this to the lobby for the lobby to echo out.
#[derive(Message, Clone)]
#[rtype(result = "()")]
pub struct ClientActorMessage {
    pub sender: Uuid,
    pub msg: String,
    pub recipient: Uuid,
    pub messageType: ChatContentType,
}

