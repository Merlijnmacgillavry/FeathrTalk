use mongodb::bson::{oid::ObjectId, self, doc};
use serde::{Serialize, Deserialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct FriendRequest {
    #[serde(rename = "_id", skip_serializing_if = "Option::is_none")]
    pub id: Option<ObjectId>,
    pub sender: String,
    pub receiver: String,
    pub accepted: bool,
    pub rejected: bool,
}
impl FriendRequest {
    pub fn accept(&mut self) {
        self.accepted = true;
    }
    pub fn reject(&mut self) {
        self.accepted = true;
    }
}
impl From<FriendRequest> for bson::Bson {
    fn from(request: FriendRequest) -> bson::Bson {
        let doc = doc! {
            "_id": request.id,
            "sender": request.sender,
            "recipient": request.receiver,
            "accepted": request.accepted,
            "rejected": request.rejected
        };
        bson::Bson::Document(doc)
    }
}

#[cfg(test)]
mod tests {
    use mongodb::bson::oid::ObjectId;

    use super::FriendRequest;



    #[test]
    fn create_friend_request(){
        let fr_id = ObjectId::new();
        let fr = FriendRequest{
            id: Some(fr_id),
            sender: String::new(),
            receiver: String::new(),
            accepted: false,
            rejected: false
        };
        assert_eq!(fr.id.unwrap(),fr_id)
    }
    #[test]
    fn accept_friend_request(){
        let fr_id = ObjectId::new();
        let mut fr = FriendRequest{
            id: Some(fr_id),
            sender: String::new(),
            receiver: String::new(),
            accepted: false,
            rejected: false
        };
        fr.accept();
        assert_eq!(fr.accepted,true)
    }
    #[test]
    fn reject_friend_request(){
        let fr_id = ObjectId::new();
        let mut fr = FriendRequest{
            id: Some(fr_id),
            sender:String::new(),
            receiver: String::new(),
            accepted: false,
            rejected: false
        };
        fr.reject();
        assert_eq!(fr.accepted,true)
    }
    
}