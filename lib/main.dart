import 'package:flutter/material.dart';
import 'package:flutter_login_template/Pages/admin_dashboard.dart';
import 'package:flutter_login_template/Pages/login.dart';
import 'package:flutter_login_template/Pages/sign_up.dart';
import 'package:flutter_login_template/Pages/user_dashboard.dart';
import 'package:flutter_login_template/Services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

const Color seedColor = Colors.green;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          primary: seedColor,
          secondary: Colors.blue, // Vurgulayıcı renk
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 16), // bodyText1
          bodyMedium:
              TextStyle(color: Colors.black54, fontSize: 14), // bodyText2
          headlineLarge: TextStyle(
              color: seedColor,
              fontSize: 24,
              fontWeight: FontWeight.bold), // headline1
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            fixedSize: Size(MediaQuery.of(context).size.width * 0.8, 55.0),
            backgroundColor: seedColor, // Buton arka plan rengi
            foregroundColor: Colors.white, // Buton üzerindeki yazı rengi
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.transparent,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.grey),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: seedColor,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 24,
          ),
        ),
        scaffoldBackgroundColor: Colors.grey[300],
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/auth': (context) => const AuthService(),
        '/uDashb': (context) => const UserDashboard(),
        '/aDashb': (context) => const AdminDashboard(),
      },
      home: const LoginPage(),
    );
  }
}
