import 'dart:developer';
import 'dart:io';

import 'package:feathrtalk_frontend/pages/home.dart';
import 'package:feathrtalk_frontend/pages/onboarding.dart';
import 'package:feathrtalk_frontend/pages/register.dart';
import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/providers/notification_provider.dart';
import 'package:feathrtalk_frontend/widgets/notifications.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user_credentials.dart';
import '../providers/websocket_provider.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  void _onLoginButtonPressed(UserCredentials credentials) async {
    context.read<AuthProvider>().login(credentials).then((value) {
      log("here");
      context.read<WebsocketProvider>().connectToWebSocket();
      context.read<NotificationProvider>().alert(
          "Successfully logged in! With accessToken: ${value.tokens.accessToken} and refreshToken${value.tokens.refreshToken} and id${value.id} ");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    }).catchError((e) {
      log("error");
      log(e.toString());
      // _emailController.clear();
      // _passwordController.clear();
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

  @override
  Widget build(BuildContext context) {
    bool _isPasswordVisible = false;
    bool _isConfirmPasswordVisible = false;

    String _password = "";
    String _confirmPassword = "";
    String _email = "";

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // return Scaffold(
    //   // appBar: AppBar(
    //   //   title: Text('Flutter Chat App'),
    //   // ),
    //   body: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.center,
    //       children: <Widget>[
    //         TextField(
    //           controller: _emailController,
    //           decoration: InputDecoration(
    //             border: OutlineInputBorder(),
    //             labelText: 'Enter your name',
    //           ),
    //         ),
    //         SizedBox(height: 20),
    //         TextField(
    //           controller: _passwordController,
    //           obscureText: !_passwordVisible,
    //           decoration: InputDecoration(
    //             border: OutlineInputBorder(),
    //             labelText: 'Enter your password',
    //             suffixIcon: IconButton(
    //               icon: Icon(
    //                 _passwordVisible ? Icons.visibility_off : Icons.visibility,
    //               ),
    //               onPressed: _togglePasswordVisibility,
    //             ),
    //           ),
    //         ),
    //         SizedBox(height: 20),
    //         ElevatedButton(
    //           onPressed: () => _onLoginButtonPressed(context),
    //           child: Text('Login'),
    //         ),
    //         NotificationWidget(),
    //       ],
    //     ),
    //   ),
    // );
    return Scaffold(
      body: Container(
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
                      Image.asset(
                        "lib/assets/Rectangle 2.png",
                        height: 100,
                      ),
                      _gap(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Welcome to FeathrTalk!",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Enter your email and password to sign in.",
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

                          bool emailValid = RegExp(
                                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value);
                          if (!emailValid) {
                            return 'Please enter a valid email';
                          }
                          setState(() {
                            _email = value;
                          });
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      _gap(),
                      TextFormField(
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }

                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          setState(() {
                            _password = value;
                          });
                          return null;
                        },
                        obscureText: !_isPasswordVisible,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                            )),
                      ),
                      _gap(),
                      Text.rich(
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(fontSize: 12),
                          children: <TextSpan>[
                            TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => RegisterPage(),
                                      ),
                                    );
                                  }),
                            // can add more TextSpans here...
                          ],
                        ),
                      ),
                      _gap(),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff1A1B1E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              /// do something
                              UserCredentials uc =
                                  UserCredentials(_email, _password);
                              _onLoginButtonPressed(uc);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
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
