import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:feathrtalk_frontend/pages/home.dart';
import 'package:feathrtalk_frontend/pages/login.dart';
import 'package:feathrtalk_frontend/pages/register.dart';
import 'package:feathrtalk_frontend/providers/websocket_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';

class Entry extends StatefulWidget {
  const Entry({super.key});

  @override
  State<Entry> createState() => _EntryState();
}

class _EntryState extends State<Entry> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final websocketProvider = Provider.of<WebsocketProvider>(context);

    void handleEntry() {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => RegisterPage()),
      // );
      print("handling entry...");
      if (authProvider.hasTokens) {
        if (authProvider.hasValidAccessToken) {
          print("has valid access token");
          websocketProvider.connectToWebSocket();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          if (authProvider.hasValidRefreshToken) {
            print("has valid refresh token");
            authProvider.refresh().then((value) {
              websocketProvider.connectToWebSocket();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
            });
          } else {
            print("has not valid refresh token");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          }
        }
      } else {
        print("Does not have tokens.");
        SharedPreferences.getInstance().then(
          (prefs) {
            prefs.clear();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RegisterPage(),
              ),
            );
          },
        );
      }
    }

    return Scaffold(
      body: Container(
        // width: double.infinity,
        // height: double.infinity,
        // color: Colors.red,
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xff47C8FF),
            Color(0xff9747FF),
          ],
        )
            // repeat: ImageRepeat.repeat,
            ),

        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'FeathrTalk',
                  textStyle: const TextStyle(
                    fontSize: 64.0,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 250),
                ),
              ],
              totalRepeatCount: 1,
              pause: const Duration(milliseconds: 1000),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
              onFinished: () {
                handleEntry();
              },
            ),
            Text(
              "hasTokens: " + authProvider.hasTokens.toString(),
            ),
            Text("validAT: " + authProvider.hasValidAccessToken.toString()),
            Text("validRT: " + authProvider.hasValidRefreshToken.toString()),
          ],
        )),
      ),
    );
  }
}
