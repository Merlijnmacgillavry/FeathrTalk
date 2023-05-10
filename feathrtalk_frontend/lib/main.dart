import 'dart:convert';
import 'dart:core';

import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/providers/chat_provider.dart';
import 'package:feathrtalk_frontend/providers/notification_provider.dart';
import 'package:feathrtalk_frontend/providers/websocket_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'pages/welcome_page.dart';

void main() async {
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (context) => ChatProvider()),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => NotificationProvider()),
    ChangeNotifierProxyProvider<AuthProvider, WebsocketProvider>(
      update: (context, auth, websocket) => WebsocketProvider(auth),
      create: (BuildContext context) => WebsocketProvider(AuthProvider()),
    ),
  ], child: ChatApp()));
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chat App',
      home: MediaQuery(
        data: const MediaQueryData(),
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.transparent,
                image: DecorationImage(
                  repeat: ImageRepeat.repeat,
                  image: AssetImage(
                    'lib/assets/webb-dark.png',
                  ),
                ),
              ),
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
            ),
            WelcomePage()
          ],
        ),
      ),
      theme: ThemeData(
        // Set the default brightness to light
        brightness: Brightness.light,
        // Add other theme properties such as primaryColor, accentColor, etc.
      ),
      darkTheme: ThemeData(
        // Set the default brightness to dark
        brightness: Brightness.dark,

        // Add other theme properties for dark mode
      ),
      themeMode: ThemeMode.system, // or ThemeMode.light, ThemeMode.dark
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
