import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'chat.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';

class ChatsPage extends StatefulWidget {
  final String name;

  const ChatsPage({required this.name});

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final Key childKey = UniqueKey(); // Create a Key object

  WebSocketChannel? _channel;
  Map<String, List<Message>> _messages = {};

  final List<User> _users = [];
  late User _me;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  User findUserById(String uuid) {
    User res = _users[0];
    for (User user in _users) {
      if (user.uuid == uuid) {
        res = user;
      }
    }
    return res;
  }

  void _handleMessage(String message) {
    List<String> splitM = _splitMessage(message);
    if (splitM.length >= 2) {
      String type = splitM[0];
      String data = splitM[1];

      switch (type) {
        case "ONLINEUSERS":
          {
            setState(() {
              // Parse received data as List of chats
              List<dynamic> userData = jsonDecode(data);
              _users.clear();
              for (var user in userData) {
                _users.add(User(uuid: user['uuid'], name: user['name']));
              }
            });
          }
          break;
        case "CHATMESSAGE":
          {
            final messageData = json.decode(data);
            if (messageData.containsKey('msg') &&
                messageData.containsKey('messageType') &&
                messageData.containsKey('sender') &&
                messageData.containsKey('recipient')) {
              String msg = messageData['msg'];
              String sender = messageData['sender'];
              String recipient = messageData['recipient'];
              String messageType = messageData['messageType'];
              // if(message.sender)
              if (_me.name.isNotEmpty && _me.uuid.isNotEmpty) {
                User user = _me;
                String senderName = _me.name;
                if (sender == _me.uuid) {
                  user = findUserById(recipient);
                } else {
                  user = findUserById(sender);
                  senderName = user.name;
                }
                print(
                    "Received Message:\nSender:${sender},\nReceiver:${recipient},\nMessage:${msg}");
                print(" Found user: ${user.uuid},${user.name}");
                Message m =
                    Message(senderName, sender, recipient, msg, messageType);

                context.read<ChatProvider>().addOrMakeMessage(user.uuid, m);
              }
            }
          }
          break;
        case "CONNECT":
          {
            final connectData = json.decode(data);
            setState(() {
              _me = User(uuid: connectData['uuid'], name: connectData['name']);
            });
          }
          break;
        default:
          {
            print("Default...");
          }
          break;
      }
    }
  }

  List<String> _splitMessage(String s) {
    int idx = s.indexOf(":");
    return [s.substring(0, idx).trim(), s.substring(idx + 1).trim()];
  }

  void _connectToWebSocket() {
    String name = widget.name;
    if (name.isNotEmpty) {
      final url = 'ws://192.168.0.101:8080/chat/$name';
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _channel?.stream.listen((data) {
        _handleMessage(data);
      });
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  void sendMessage(User user, String message) {
    final data = json.encode(
      {"recipient": user.uuid, "content": message, "messageType": "Private"},
    );
    _channel?.sink.add(data);
  }

  void _onChatPressed(BuildContext context, User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatPage(
          user: user,
          sendMessage: sendMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Chats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_users[index].name),
                  onTap: () {
                    _onChatPressed(
                      context,
                      _users[index],
                    ); // _sendMessage(_chats[index].uuid);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class User {
  final String uuid;
  final String name;

  User({required this.uuid, required this.name});
}

class Message {
  final String name;
  final String messageType;
  final String sender;
  final String recipient;
  final String msg;

  Message(this.name, this.sender, this.recipient, this.msg, this.messageType);
}
