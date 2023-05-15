import 'dart:convert';
import 'dart:developer';
import 'package:feathrtalk_frontend/models/login_data.dart';
import 'package:feathrtalk_frontend/models/user_credentials.dart';
import 'package:feathrtalk_frontend/services/user_data_service.dart';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = '192.168.0.101:3000';
  static const String baseUrlProd = '192.168.0.101:3000';

  Future<Map<String, dynamic>> getData(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch data');
    }
  }

  // Future<Map<String, dynamic>> sendFriendRequest(String code) async {
  //   final response = await http.get(Uri.parse('$baseUrl/posts/$id'));
  //   if (response.statusCode == 200) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to fetch data');
  //   }
  // }

  Future<List<dynamic>> findUser(String code, String token) async {
    print(code);
    final response = await http.get(
        Uri.parse('http://$baseUrl/api/FeathrTalk/search_user/$code'),
        headers: {'Content-Type': 'application/json', 'Authorization': token});
    if (response.statusCode == 200) {
      print(json.decode(json.encode(response.body)));
      return json.decode(response.body);
    } else {
      print(json.decode(json.encode(response.body)));
      throw Exception('Failed to fetch data');
    }
  }

  // Post request example
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
          Uri.parse('http://$baseUrl/auth/login/FeathrTalk'),
          body: json.encode(data),
          headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(json.decode(response.body)['error']);
      }
    } catch (e) {
      log("error http request");
      log(e.toString());
      rethrow;
    }
  }

  // Post request example
  Future<Map<String, dynamic>> refresh(Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse('http://$baseUrl/auth/refresh-token/feathrtalk'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse('http://$baseUrl/auth/register/feathrtalk'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  Future<Map<String, dynamic>> search_contact(Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse('http://$baseUrl/auth/register/feathrtalk'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(json.decode(response.body)['error']);
    }
  }

  Future<Map<String, dynamic>> addUser(
      Map<String, dynamic> data, LoginData loginData) async {
    String id = loginData.id;
    print("id: " + id);
    final response = await http.post(
        Uri.parse("http://$baseUrl/api/FeathrTalk/user/$id"),
        body: json.encode(data),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': loginData.tokens.accessToken
        });
    if (response.statusCode == 201 || response.statusCode == 200) {
      print(response);
      return json.decode(response.body);
    } else {
      print("gaaat verkeerd");
      print(response.body);
      throw Exception(json.decode(response.body)['error']);
    }
  }

  // // Post request example
  // Future<Map<String, dynamic>> postData(Map<String, dynamic> data) async {
  //   final response = await http.post(Uri.parse('$baseUrl/posts'),
  //       body: json.encode(data), headers: {'Content-Type': 'application/json'});
  //   if (response.statusCode == 201) {
  //     return json.decode(response.body);
  //   } else {
  //     throw Exception('Failed to post data');
  //   }
  // }

  // Put request example
  Future<Map<String, dynamic>> updateData(
      int id, Map<String, dynamic> data) async {
    final response = await http.put(Uri.parse('$baseUrl/posts/$id'),
        body: json.encode(data), headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update data');
    }
  }

  // Delete request example
  Future<void> deleteData(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete data');
    }
  }
}
