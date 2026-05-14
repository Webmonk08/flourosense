import 'package:flutter/material.dart';
import 'package:fluorosense/services/auth_service.dart';
import 'auth_screen.dart';
import 'user_classification_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Show splash for at least 2 seconds for a smooth UX
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if a token exists in storage
    final hasToken = await _authService.isLoggedIn();

    if (hasToken) {
      // Token exists — validate it against the server
      final isValid = await _authService.validateToken();

      if (!mounted) return;

      if (isValid) {
        // Token is valid, skip login and go straight to the app
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => UserClassificationScreen(),
        ));
        return;
      }
    }

    // No token or invalid token — go to login
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => AuthScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.ac_unit, size: 100, color: Color(0xFF008080)), // Placeholder icon
            SizedBox(height: 20),
            Text(
              'FluoroSense',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF008080),
              ),
            ),
            Text(
              'Your Personal Dental Health Companion',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
