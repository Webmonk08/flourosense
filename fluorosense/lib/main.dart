import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fluorosense/screens/splash_screen.dart';
import 'package:fluorosense/screens/auth_screen.dart';
import 'package:fluorosense/screens/user_classification_screen.dart';
import 'package:fluorosense/screens/maternal_child_form_screen.dart';
import 'package:fluorosense/screens/general_user_form_screen.dart';
import 'package:fluorosense/screens/camera_screen.dart';
import 'package:fluorosense/screens/register_screen.dart';
import 'package:fluorosense/screens/profile_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => null, // Placeholder for a real provider
      child: MaterialApp(
        title: 'FluoroSense',
        theme: ThemeData(
          primaryColor: Color(0xFF008080),
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: Color(0xFF008080),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF008080),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
        home: SplashScreen(),
        routes: {
          '/auth': (context) => AuthScreen(),
          '/register': (context) => RegisterScreen(),
          '/user-classification': (context) => UserClassificationScreen(),
          '/maternal-child-form': (context) => MaternalChildFormScreen(),
          '/general-user-form': (context) => GeneralUserFormScreen(),
          '/camera': (context) => ImageSelectionScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }
}