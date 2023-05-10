import 'package:feathrtalk_frontend/providers/websocket_provider.dart';
import 'package:flutter/material.dart';

import '../pages/chats.dart';

class ChatProvider with ChangeNotifier {
  Map<String, List<Message>> _messages = {};

  Map<String, List<Message>> get messages => _messages;

  List<Message> getUserMessages(OnlineUser user) {
    return _messages[user.uuid] ?? [];
  }

  void addOrMakeMessage(String key, Message m) {
    if (!_messages.containsKey(key)) {
      _messages[key] = [m];
    } else {
      _messages[key]?.add(m);
    }
    notifyListeners();
  }
}
