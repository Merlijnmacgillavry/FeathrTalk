// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

// void main() => runApp(ChatApp());

// class ChatApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Chat App',
//       home: ChatHomePage(),
//     );
//   }
// }

// class ChatHomePage extends StatefulWidget {
//   @override
//   _ChatHomePageState createState() => _ChatHomePageState();
// }

// class _ChatHomePageState extends State<ChatHomePage> {
//   final TextEditingController _nameController = TextEditingController();
//   final List<Chat> _chats = [];
//   late WebSocketChannel _socketChannel;

//   @override
//   void initState() {
//     super.initState();
//     _connectToWebSocket();
//   }

//   @override
//   void dispose() {
//     _socketChannel.sink.close();
//     super.dispose();
//   }

//   void _connectToWebSocket() {
//     String name = _nameController.text;
//     if (name.isNotEmpty) {
//       _socketChannel =
//           IOWebSocketChannel.connect('ws://192.168.0.101:8080/chat/$name');
//       _socketChannel.stream.listen((data) {
//         // Handle received data from WebSocket
//         setState(() {
//           // Parse received data as List of chats
//           List<dynamic> chatData = jsonDecode(data);
//           _chats.clear();
//           for (var chat in chatData) {
//             _chats.add(Chat(uuid: chat['uuid'], name: chat['name']));
//           }
//         });
//       });
//     }
//   }

//   void _sendMessage(String uuid) {
//     // Send message to WebSocket using UUID
//     if (_socketChannel != null && _socketChannel.sink != null) {
//       _socketChannel.sink.add(uuid);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Active Chats'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _nameController,
//               decoration: InputDecoration(
//                 labelText: 'Enter Name',
//               ),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: _connectToWebSocket,
//             child: Text('Start Chat'),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: _chats.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_chats[index].name),
//                   onTap: () {
//                     _sendMessage(_chats[index].uuid);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class Chat {
//   final String uuid;
//   final String name;

//   Chat({required this.uuid, required this.name});
// }
import 'dart:convert';
import 'dart:core';

import 'package:feathrtalk_frontend/providers/chat_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pages/welcome_page.dart';

void main() {
  runApp(MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: ChatApp()));
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      home: WelcomePage(),
    );
  }
}

class ChatHomePage extends StatefulWidget {
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {
  final _nameController = TextEditingController();
  WebSocketChannel? _channel;
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  void _connectToWebSocket() {
    final name = _nameController.text;
    if (name.isNotEmpty) {
      final url = 'ws://192.168.0.101:8080/chat/$name';
      _channel = IOWebSocketChannel.connect(Uri.parse(url));
      _channel?.stream.listen((data) {
        final chats = json.decode(data);
        setState(() {
          _chats = List<Map<String, dynamic>>.from(chats);
        });
      });
    }
  }

  void _sendMessage(String uuid, String message) {
    final data = json.encode({'uuid': uuid, 'message': message});
    _channel?.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Chat App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your name',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _connectToWebSocket,
              child: Text('Start Chat'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (BuildContext context, int index) {
                  final chat = _chats[index];
                  final uuid = chat['uuid'];
                  final name = chat['name'];
                  return ListTile(
                    title: Text(name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatPage(uuid: uuid, name: name),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatPage extends StatefulWidget {
  final String uuid;
  final String name;

  const ChatPage({required this.uuid, required this.name});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  WebSocketChannel? _channel;
  List<String> _messages = [];

  // @override
  // void initState() {
  //   super.initState();
  //   final url = 'ws://192.168.0.101:8080/chat/${widget.uuid}';
  //   _channel = IOWebSocketChannel.connect(Uri.parse(url));
  //   _channel?.stream.listen((data) {
  //     final message = json.decode(data)['message'];
  //     setState(() {
  //       _messages.add(message);
  //     });
  //   });
  // }

  @override
  void dispose() {
    _messageController.dispose();
    _channel?.sink.close();
    super.dispose();
  }

  void _sendMessage(String message) {
    final data = json.encode({'uuid': widget.uuid, 'message': message});
    _channel?.sink.add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.name}'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Divider(height: 1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Type your message',
                    ),
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    final message = _messageController.text;
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _messageController.clear();
                    }
                  },
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  late String recipient;
  late String content;
  late String messageType;

  ChatMessage(String recipient, String content, String messageType) {
    this.recipient;
    this.content;
    this.messageType;
  }
}
