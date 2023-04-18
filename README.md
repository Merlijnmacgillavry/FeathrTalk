# FeathrTalk
 A real-time end-to-end encrypted Chat app made with Flutter and Rust

## Backend (Rust)
Run ```cargo run``` to start websocket server on port 8080;

Start two tabs of websocket connections from the browser:
1.  A: ```ws://localhost:8080/chat/8fab6cdb-2096-4de9-a064-a5a166d26c19```
2.  B:```ws://localhost:8080/chat/dbb67a39-a723-4bf5-a272-29742451e4e0```

Send the following message from 1 & 2:
```
{
  "recipient": "dbb67a39-a723-4bf5-a272-29742451e4e0",
  "content": "Hello A!, I'm B",
  "messageType": "Private"
}
```
```
{
  "recipient": "8fab6cdb-2096-4de9-a064-a5a166d26c19",
  "content": "Hello world2!",
  "messageType": "Group"
}
```
