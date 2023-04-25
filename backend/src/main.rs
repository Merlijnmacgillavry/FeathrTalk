mod chat;
mod routes;
use actix::Actor;
use actix_web::web::Payload;
use actix_web::{HttpResponse, web, HttpRequest};
use actix_web::{App, HttpServer};
mod utils;
use chat::{
    messages::ChatMessage, 
    chat_server::ChatServer,
};
use routes::start_connection::connect_user as start_connection_route;
use routes::start_connection::health_check as health_check_route;

async fn default_route(_req: HttpRequest, 
    _stream: Payload) ->  HttpResponse {
        let requested_url = _req.uri().to_string();
        HttpResponse::Ok()
    .body(format!("404 Not Found: Requested resource: {} not found", requested_url))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    
    let chat_server = ChatServer::default().start(); //create and spin up a lobby
    println!("{:?}", chat_server);
    HttpServer::new(move || {
        App::new()
            .service(start_connection_route) //. rename with "as" import or naming conflict
            .service(health_check_route)
            .default_service(web::route().to(default_route))
            // .service(start_user_connection)
            .data(chat_server.clone()) //register the lobby
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}