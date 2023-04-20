use serde::Serialize;


#[derive(Serialize)]
pub struct ClientUser{
    pub uuid: String,
    pub name: String
}
