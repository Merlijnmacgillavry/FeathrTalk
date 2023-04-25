import 'package:feathrtalk_frontend/services/http_service.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import '../pages/login.dart';

class AuthProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  late UserCredentials _credentials;
  late UserTokens _tokens = UserTokens();

  bool get loggedIn => _tokens.isValidAT;

  bool get refreshValid => _tokens.isValidRT;

  UserCredentials get credentials => _credentials;

  Future<UserTokens> login(UserCredentials uc) async {
    Map<String, dynamic> body = {"email": uc.email, "password": uc.hash};
    try {
      Map response = await _httpService.login(body);
      _tokens = UserTokens.fromJson(response);
      _credentials = uc;
      return _tokens;
    } catch (e) {
      rethrow;
    }
  }
}

class UserTokens {
  late String accessToken;
  late String refreshToken;

  UserTokens() {
    accessToken = "";
    refreshToken = "";
  }

  UserTokens.fromJson(Map json) {
    this.accessToken = json['accessToken'];
    this.refreshToken = json['refreshToken'];
  }

  bool get isValidAT {
    return isExpired(this.accessToken);
  }

  bool get isValidRT {
    return isExpired(this.refreshToken);
  }

  bool isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        // Invalid token
        return true;
      }

      final payload = parts[1];
      final decoded = base64Url.decode(payload);
      final payloadMap = json.decode(utf8.decode(decoded));

      final exp = payloadMap['exp'];
      if (exp is int) {
        final now = DateTime.now().millisecondsSinceEpoch ~/
            1000; // Current time in seconds
        return exp < now; // Check if expiration time is before current time
      } else {
        // 'exp' claim is not an integer, so the JWT is considered expired
        return true;
      }
    } catch (_) {
      // Exception occurred, so the JWT is considered expired
      return true;
    }
  }
}

class UserCredentials {
  late String email;
  late String password;

  UserCredentials(String email, String password) {
    print(email);
    this.email = email;
    this.password = password;
  }

  String get hash {
    List<int> passwordBytes = utf8.encode(this.password);

    // Create a SHA256 hash object
    Digest digest = sha256.convert(passwordBytes);

    // Convert the hash bytes to a hexadecimal string
    String hashedPassword = digest.toString();
    print(hashedPassword);
    return hashedPassword;
  }
}
