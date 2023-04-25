import 'dart:convert';
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

  // Post request example
  Future<Map<String, dynamic>> login(Map<String, dynamic> data) async {
    final response = await http.post(
        Uri.parse('http://$baseUrl/auth/login/feathrtalk'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'});
    if (response.statusCode == 201 || response.statusCode == 200) {
      return json.decode(response.body);
    } else {
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
