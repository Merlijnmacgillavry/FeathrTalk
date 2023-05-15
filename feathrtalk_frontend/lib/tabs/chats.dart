import 'package:feathrtalk_frontend/providers/websocket_provider.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/contact_card.dart';

class Chats extends StatefulWidget {
  const Chats();

  @override
  _ChatsState createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final Key childKey = UniqueKey(); // Create a Key object
  // late OnlineUser _me;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // _channel?.sink.close();
    super.dispose();
  }

  // void sendMessage(OnlineUser user, String message) {
  //   final data = json.encode(
  //     {"recipient": user.uuid, "content": message, "messageType": "Private"},
  //   );
  //   _channel?.sink.add(data);
  // }

  // void _onChatPressed(BuildContext context, OnlineUser user) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => ChatPage(
  //         user: user,
  //         sendMessage: sendMessage,
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class Message {
  final String name;
  final String messageType;
  final String sender;
  final String recipient;
  final String msg;
  Message(this.name, this.sender, this.recipient, this.msg, this.messageType);
}
