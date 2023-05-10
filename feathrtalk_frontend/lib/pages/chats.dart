import 'package:feathrtalk_frontend/providers/websocket_provider.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage();

  @override
  _ChatsPageState createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  final Key childKey = UniqueKey(); // Create a Key object
  final List<OnlineUser> _users = [];
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
    final websocketProvider = Provider.of<WebsocketProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Active Chats'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: websocketProvider.userDataService.contacts.keys.length,
              itemBuilder: (context, index) {
                String key = websocketProvider.userDataService.contacts.keys
                    .toList()[index];
                PublicUser user =
                    websocketProvider.userDataService.contacts[key]!;
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xff1A1B1E),
                  ),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      ListTile(
                        leading: CircleAvatar(),
                        title: Text(user.name),
                        subtitle: Text(user.bio),
                      ),
                      Row(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          // children: <Widget>[
                          //   TextButton(
                          //     child: const Text('BUY TICKETS'),
                          //     onPressed: () {/* ... */},
                          //   ),
                          //   const SizedBox(width: 8),
                          //   TextButton(
                          //     child: const Text('LISTEN'),
                          //     onPressed: () {/* ... */},
                          //   ),
                          //   const SizedBox(width: 8),
                          // ],
                          ),
                    ],
                  ),

                  // return ListTile(
                  //   title: Text(user.name),
                  //   onTap: () {
                  //     print("contact pressed");
                  //     // _onChatPressed(
                  //     //   context,
                  //     //   _users[index],
                  //     // ); // _sendMessage(_chats[index].uuid);
                  //   },
                );
              },
            ),
          ),
        ],
      ),
    );
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
