// import 'package:feathrtalk_frontend/providers/chat_provider.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'chats.dart';

// class ChatPage extends StatefulWidget {
//   final OnlineUser user;
//   final Function(OnlineUser, String) sendMessage;

//   const ChatPage({
//     required this.user,
//     required this.sendMessage,
//   });

//   @override
//   _ChatPageState createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   final _messageController = TextEditingController();

//   void _sendMessage(String message) {
//     widget.sendMessage(widget.user, message);
//   }

//   @override
//   Widget build(BuildContext context) {
//     late List<Message> _messages =
//         context.watch<ChatProvider>().getUserMessages(widget.user);
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Chat with ${widget.user.name}'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: ListView.builder(
//               itemCount: _messages.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text(_messages[index].name),
//                   subtitle: Text(_messages[index].msg),
//                 );
//               },
//             ),
//           ),
//           Divider(height: 1),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Row(
//               children: <Widget>[
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     decoration: InputDecoration(
//                       border: OutlineInputBorder(),
//                       labelText: 'Type your message',
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 16),
//                 ElevatedButton(
//                   onPressed: () {
//                     final message = _messageController.text;
//                     if (message.isNotEmpty) {
//                       _sendMessage(message);
//                       _messageController.clear();
//                     }
//                   },
//                   child: Text('Send'),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
