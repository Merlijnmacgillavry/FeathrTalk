import 'dart:convert';

import 'package:feathrtalk_frontend/providers/auth_provider.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_data.dart';

Future<void> saveUserData(UserDataService obj) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Convert MyClass object to a JSON string
  String jsonString = json.encode(obj.toJson());

  // Save the JSON string to shared preferences
  await prefs.setString('userDataService', jsonString);
}

Future<void> saveLoginData(LoginData obj) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // Convert MyClass object to a JSON string
  String jsonString = json.encode(obj.toJson());

  // Save the JSON string to shared preferences
  await prefs.setString('loginData', jsonString);
}

// Retrieve an instance of MyClass from shared preferences
Future<UserDataService?> loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonString = prefs.getString('userDataService');

  // If the key doesn't exist, return null
  if (jsonString == null) return null;

  // Convert the JSON string to an object
  Map<String, dynamic> json = await jsonDecode(jsonString);
  UserDataService obj = UserDataService.fromJson(json);
  return obj;
}

Future<LoginData?> loadLoginData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  // Retrieve the JSON string from shared preferences
  String? jsonString = prefs.getString('loginData');

  // If the key doesn't exist, return null
  if (jsonString == null) return null;

  // Convert the JSON string to an object
  Map<String, dynamic> json = await jsonDecode(jsonString);
  LoginData obj = LoginData.fromJson(json);
  return obj;
}
