import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

part "user_tokens.g.dart";

@JsonSerializable(explicitToJson: true)
class UserTokens {
  late String accessToken;
  late String refreshToken;

  UserTokens() {
    accessToken = "";
    refreshToken = "";
  }

  factory UserTokens.fromJson(Map<String, dynamic> json) =>
      _$UserTokensFromJson(json);

  Map<String, dynamic> toJson() => _$UserTokensToJson(this);

  bool get isValidAT {
    return !isExpired(this.accessToken);
  }

  bool get hasTokens {
    return accessToken != "" && refreshToken != "";
  }

  bool get isValidRT {
    return !isExpired(this.refreshToken);
  }

  bool isExpired(String token) {
    try {
      final parts = token.split('.');
      final jwt = JWT.decode(token);
      final payload = jwt.payload;
      final exp = payload['exp'];
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
