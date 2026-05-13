import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String _baseUrl = "http://127.0.0.1:8000"; // Your FastAPI server address
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: "access_token");
  }

  // --- Authentication ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/token"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": email, "password": password},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await _storage.write(key: "access_token", value: data['access_token']);
      return data;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await http.post(
      Uri.parse("$_baseUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: json.encode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
  
  Future<void> logout() async {
    await _storage.delete(key: "access_token");
  }

  // --- Main App Logic ---

  Future<Map<String, dynamic>> submitReport({
    required File image,
    required Map<String, String> formData,
  }) async {
    final token = await _getToken();
    if (token == null) {
      throw Exception("Not authenticated");
    }

    var request = http.MultipartRequest('POST', Uri.parse("$_baseUrl/report"));
    
    // Add headers
    request.headers['Authorization'] = 'Bearer $token';

    // Add form data
    request.fields.addAll(formData);

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath('image_file', image.path),
    );

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit report: ${response.body}');
    }
  }
}
