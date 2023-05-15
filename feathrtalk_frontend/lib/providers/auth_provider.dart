import 'dart:developer';

import 'package:feathrtalk_frontend/services/http_service.dart';
import 'package:feathrtalk_frontend/services/shared_preferences.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:flutter/material.dart';

import '../models/login_data.dart';
import '../models/user_credentials.dart';
import '../models/user_tokens.dart';
import '../pages/login.dart';

class AuthProvider extends ChangeNotifier {
  final HttpService _httpService = HttpService();
  late UserCredentials _credentials;
  late UserTokens _tokens = UserTokens();
  late String _id = "";

  AuthProvider() {
    loadLoginData().then((data) {
      if (data != null) {
        _tokens = data.tokens;
        _id = data.id;
      }
      notifyListeners();
    });
  }
  bool get hasTokens => _tokens.hasTokens;

  bool get hasValidAccessToken => _tokens.isValidAT;

  bool get hasValidRefreshToken => _tokens.isValidRT;

  String get id => _id;

  UserTokens get tokens => _tokens;

  UserCredentials get credentials => _credentials;

  Future<LoginData> login(UserCredentials uc) async {
    Map<String, dynamic> body = {"email": uc.email, "password": uc.hash};
    try {
      Map<String, dynamic> response = await _httpService.login(body);
      UserTokens _tokens = UserTokens.fromJson(response);
      String _id = response['id'];
      _credentials = uc;
      LoginData ld = LoginData(_tokens, _id);
      saveLoginData(ld);
      return ld;
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginData> refresh() async {
    Map<String, dynamic> body = {"refreshToken": _tokens.refreshToken};
    try {
      Map<String, dynamic> response = await _httpService.refresh(body);
      _tokens = UserTokens.fromJson(response);
      _id = response['id'];
      LoginData ld = LoginData(_tokens, _id);
      saveLoginData(ld);
      print(ld.toJson());
      return ld;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<LoginData> register(UserCredentials uc) async {
    Map<String, dynamic> body = {"email": uc.email, "password": uc.hash};
    try {
      Map<String, dynamic> response = await _httpService.register(body);
      print(response);
      return await login(uc);
    } catch (e) {
      rethrow;
    }
  }

  Future<LoginData> addUser(PublicUser publicUser, UserCredentials uc) async {
    Map<String, dynamic> body = {
      "name": publicUser.name,
      "profile_image": publicUser.profileImage,
      "bio": publicUser.bio
    };
    String id = _id;
    try {
      LoginData loginData = await register(uc);

      try {
        Map<String, dynamic> response =
            await _httpService.addUser(body, loginData);
        _id = loginData.id;
        _tokens = loginData.tokens;
        return loginData;
      } catch (e) {
        rethrow;
      }
    } catch (e) {
      rethrow;
    }
  }
}
