import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String _baseUrl = "http://127.0.0.1:8000"; // Your FastAPI server address
  
  // Configure storage once for all platforms
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    webOptions: WebOptions(dbName: 'FluoroSense', publicKey: 'access_token'),
  );

  Future<String?> _getToken() async {
    return await _storage.read(key: "access_token");
  }

  Future<void> _saveToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  Future<void> _deleteToken() async {
    await _storage.delete(key: "access_token");
  }

  /// Returns true if an auth token exists in storage.
  Future<bool> hasToken() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
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
      await _saveToken(data['access_token']);
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
    await _deleteToken();
  }

  // --- Profile Management ---

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/users/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> updateData) async {
    final token = await _getToken();
    final response = await http.put(
      Uri.parse("$_baseUrl/users/me"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(updateData),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  // --- History ---

  Future<List<dynamic>> getReports() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse("$_baseUrl/reports/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load reports');
    }
  }

  // --- Main App Logic ---

  Future<Map<String, dynamic>> submitReport({
    required List<int> imageBytes,
    required String fileName,
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

    // Add image file from bytes
    request.files.add(
      http.MultipartFile.fromBytes(
        'image_file',
        imageBytes,
        filename: fileName,
      ),
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
