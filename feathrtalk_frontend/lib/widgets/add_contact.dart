import 'dart:io';

import 'package:feathrtalk_frontend/pages/home.dart';
import 'package:feathrtalk_frontend/pages/onboarding.dart';
import 'package:feathrtalk_frontend/pages/register.dart';
import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/providers/notification_provider.dart';
import 'package:feathrtalk_frontend/services/http_service.dart';
import 'package:feathrtalk_frontend/widgets/notifications.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_credentials.dart';
import '../providers/websocket_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class AddContactPage extends StatefulWidget {
  @override
  _AddContactState createState() => _AddContactState();
}

class _AddContactState extends State<AddContactPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void _onLoginButtonPressed(UserCredentials credentials) async {
    context.read<AuthProvider>().login(credentials).then((value) {
      context.read<WebsocketProvider>().connectToWebSocket();
      context.read<NotificationProvider>().alert(
          "Successfully logged in! With accessToken: ${value.tokens.accessToken} and refreshToken${value.tokens.refreshToken} and id${value.id} ");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((e) {
      _emailController.clear();
      _passwordController.clear();
      context.read<NotificationProvider>().alert(e.toString());
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool validate(String x) {
    List<String> list = x.split("-");
    if (list.length <= 2) {
      print(list);
      if (list.length == 2) {
        return true;
      }
      if (list.length == 1 && x.length == 24) {
        return true;
      }
    }
    return false;
  }

  void sendFriendRequest(WebsocketProvider provider) {}

  @override
  Widget build(BuildContext context) {
    AuthProvider _authProvider = context.read<AuthProvider>();
    WebsocketProvider _websocketProvider = context.read<WebsocketProvider>();
    HttpService _httpService = HttpService();

    String _code = "";

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    return Container(
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
      child: Form(
        key: _formKey,
        child: Center(
          child: Card(
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(32.0),
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrImageView(
                      data: _authProvider.id,
                      foregroundColor: Color(0xFF47C8FF),
                    ),
                    Text(
                      "${_websocketProvider.userDataService.name}-${_websocketProvider.userDataService.id.substring(0, 5)}",
                      style: Theme.of(context).textTheme.caption,
                      textAlign: TextAlign.center,
                    ),
                    _gap(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "Add contact",
                        style: Theme.of(context).textTheme.headline5,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        "Scan the other persons code or paste it in",
                        style: Theme.of(context).textTheme.caption,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _gap(),
                    TextFormField(
                      validator: (value) {
                        // add email validation
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        if (!validate(value)) {
                          return 'Please enter a valid code';
                        }
                        setState(() {
                          _code = value;
                        });
                        return null;
                      },
                      onEditingComplete: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          /// do something
                          _httpService.findUser(
                              _code, _authProvider.tokens.accessToken);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'e.g.: Batman-22335',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.code),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _gap() => const SizedBox(height: 16);
}
