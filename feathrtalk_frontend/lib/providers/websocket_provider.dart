import 'dart:convert';
import 'dart:developer';

import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/services/shared_preferences.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebsocketProvider with ChangeNotifier {
  WebSocketChannel? _channel;
  bool isConnected = false;
  final AuthProvider _authProvider;
  List<OnlineUser> onlineUsers = [];
  UserDataService userDataService = UserDataService();
  WebsocketProvider(this._authProvider) {
    _authProvider;
    loadUserData().then((data) {
      if (data != null) {
        userDataService = data;
      }
      notifyListeners();
    });
  }

  void connectToWebSocket() {
    if (!isConnected) {
      String id = _authProvider.id;
      String url = 'ws://192.168.0.101:3000/api/FeathrTalk/chat/$id';
      Map<String, dynamic> headers = {
        'Authorization': _authProvider.tokens.accessToken
      };
      try {
        print(headers);
        _channel = IOWebSocketChannel.connect(Uri.parse(url), headers: headers);
        isConnected = true;
        _channel?.stream.listen((data) {
          _handleMessage(data);
        });
      } catch (e) {
        log("websocket error: ");
        log(e.toString());
      }
    } else {
      print("websocket already connected");
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  List<String> _splitMessage(String s) {
    int idx = s.indexOf(":");
    return [s.substring(0, idx).trim(), s.substring(idx + 1).trim()];
  }

  void _handleMessage(String message) {
    print(message);
    List<String> splitM = _splitMessage(message);
    if (splitM.length >= 2) {
      String type = splitM[0];
      String data = splitM[1];
      switch (type) {
        case "ONLINEUSERS":
          {
            handleOnlineUsers(data);
          }
          break;
        case "USERINFO":
          {
            handleUserInfo(data);
          }
          break;
        case "CHATMESSAGE":
          {
            // final messageData = json.decode(data);
            // if (messageData.containsKey('msg') &&
            //     messageData.containsKey('messageType') &&
            //     messageData.containsKey('sender') &&
            //     messageData.containsKey('recipient')) {
            //   String msg = messageData['msg'];
            //   String sender = messageData['sender'];
            //   String recipient = messageData['recipient'];
            //   String messageType = messageData['messageType'];
            //   // if(message.sender)
            //   if (_me.name.isNotEmpty && _me.uuid.isNotEmpty) {
            //     User user = _me;
            //     String senderName = _me.name;
            //     if (sender == _me.uuid) {
            //       user = findUserById(recipient);
            //     } else {
            //       user = findUserById(sender);
            //       senderName = user.name;
            //     }
            //     print(
            //         "Received Message:\nSender:${sender},\nReceiver:${recipient},\nMessage:${msg}");
            //     print(" Found user: ${user.uuid},${user.name}");
            //     Message m =
            //         Message(senderName, sender, recipient, msg, messageType);

            //     context.read<ChatProvider>().addOrMakeMessage(user.uuid, m);
            //   }
            // }
          }
          break;
        case "CONNECT":
          {
            // final connectData = json.decode(data);
            // setState(() {
            //   _me = User(uuid: connectData['uuid'], name: connectData['name']);
            // });
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

  void handleOnlineUsers(String data) {
    onlineUsers.clear();
    List<dynamic> onlineUserData = jsonDecode(data);
    for (var user in onlineUserData) {
      onlineUsers.add(OnlineUser(uuid: user['id'], name: user['name']));
      notifyListeners();
    }
  }

  void handleUserInfo(String data) {
    Map<String, dynamic> rawUserData = jsonDecode(data);
    userDataService.setUserData(rawUserData);
    saveUserData(userDataService);
    notifyListeners();
  }
}

class OnlineUser {
  final String uuid;
  final String name;

  OnlineUser({required this.uuid, required this.name});
}
