use crate::chat::{chat_server::ChatServer, chat_connection::ChatConnection};
use actix::Addr;
use actix_web::{get, web::Data, web::Path, web::Payload, Error, HttpResponse, HttpRequest};
use actix_web_actors::ws;
use uuid::Uuid;

#[get("/chat/{user_name}")]
pub async fn connect_user(
    req: HttpRequest, 
    stream: Payload,
    Path(user_id) : Path<Uuid>,
    srv: Data<Addr<ChatServer>>,
) -> Result<HttpResponse, Error> {
    // let user_id = Uuid::new_v4();

    println!("{:?}", user_id);

    let chat = ChatConnection::new(
        user_id,
        srv.get_ref().clone()
    );
    
    let chat = ChatConnection::new(
        user_id, 
        srv.get_ref().clone()
    );
    let resp = ws::start(chat, &req, stream)?;
    Ok(resp)
    // Ok(resp)
}