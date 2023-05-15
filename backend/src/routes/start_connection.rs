use std::str::FromStr;

use crate::{chat::{chat_server::ChatServer, chat_connection::ChatConnection}, repository::mongodb_repo::MongoRepo};
use actix::{Addr, Response};
use actix_web::{get, web::Data, web::Path, web::Payload, Error, HttpResponse, HttpRequest, http::{header::ContentType, StatusCode}};
use actix_web_actors::ws;
use uuid::Uuid;

#[get("health_check")]
pub async fn health_check(
    _req: HttpRequest, 
    _stream: Payload,
) -> HttpResponse {
    println!("health_check");
    HttpResponse::Ok().status(StatusCode::OK)
        .body("Server is alive and reachable!")
}

#[get("/chat/{user_id}")]
pub async fn connect_user(
    req: HttpRequest, 
    stream: Payload,
    Path(user_id) : Path<String>,
    db: Data<MongoRepo>,
    srv: Data<Addr<ChatServer>>,
) -> Result<HttpResponse, Error> {
    // let user_id = Uuid::new_v4();
    // println!("{user_name}");
    let user = db.find_user(&user_id);
    match user{
        Ok(u) => {
            let chat = ChatConnection::new(
                user_id,
                srv.get_ref().clone(),
                u.name
            );
            
            let resp = ws::start(chat, &req, stream)?;
            // println!("{:?}", resp);
            Ok(resp)
        }
        Err(e) => {
           Ok(HttpResponse::NotFound().body("User not found!"))
        }
    }

    
    // Ok(resp)
}