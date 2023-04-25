import 'dart:async';
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  String _message = '';

  void alert(String message) {
    _message = message;
    notifyListeners();

    // Start a timer to clear the message after a certain duration
    Timer _timer = Timer(Duration(seconds: 5), () {
      _message = '';
      notifyListeners();
    });
  }

  String get message => _message;
}
