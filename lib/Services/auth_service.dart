import 'package:flutter/material.dart';

class AuthService extends StatefulWidget {
  const AuthService({super.key});

  @override
  _AuthServiceState createState() => _AuthServiceState();
}

class _AuthServiceState extends State<AuthService> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkRole();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _checkRole() {
    //  TODO: Role Check from Database
    // Using `context` is safe here as it's within a state class
    if (!true) {
      Navigator.pushReplacementNamed(context, '/uDashb');
    } else {
      Navigator.pushReplacementNamed(context, '/aDashb');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Implement your build method
    return Scaffold(
      body: Center(
        child: Text('Yükleniyor...'),
      ),
    );
  }
}
