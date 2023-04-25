import 'package:feathrtalk_frontend/pages/onboarding.dart';
import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/providers/notification_provider.dart';
import 'package:feathrtalk_frontend/widgets/notifications.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'chats.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;
  void _onLoginButtonPressed(BuildContext context) async {
    UserCredentials credentials =
        UserCredentials(_emailController.text, _passwordController.text);
    context.read<AuthProvider>().login(credentials).then((value) {
      context.read<NotificationProvider>().alert(
          "Successfully logged in! With accessToken: ${value.accessToken} and refreshToken${value.refreshToken}");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Onboarding()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Flutter Chat App'),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your name',
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              obscureText: !_passwordVisible,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter your password',
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _onLoginButtonPressed(context),
              child: Text('Login'),
            ),
            NotificationWidget(),
          ],
        ),
      ),
    );
  }
}
