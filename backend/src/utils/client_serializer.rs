use serde::Serialize;


#[derive(Serialize)]
pub struct ClientUser{
    pub id: String,
    pub name: String
}
