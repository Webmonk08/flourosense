import 'package:fluorosense/services/api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<bool> signIn(String email, String password) async {
    try {
      await _apiService.login(email, password);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _apiService.register(email, password);
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<void> signOut() async {
    await _apiService.logout();
  }

  /// Checks if a token exists in storage.
  /// Returns true if a token is found, false otherwise.
  Future<bool> isLoggedIn() async {
    return await _apiService.hasToken();
  }

  /// Validates the stored token by making a request to the server.
  /// Returns true if the token is still valid, false otherwise.
  /// If the token is invalid/expired, it is automatically cleared.
  Future<bool> validateToken() async {
    try {
      await _apiService.getUserProfile();
      return true;
    } catch (e) {
      // Token is invalid or expired — clear it
      await _apiService.logout();
      return false;
    }
  }
}