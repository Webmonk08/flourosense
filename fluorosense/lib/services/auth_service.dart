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

  // You can add a method to check for a stored token
  // to see if the user is already logged in at app startup.
  // Future<bool> isLoggedIn() async { ... }
}