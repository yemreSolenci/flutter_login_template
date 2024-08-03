import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends StatefulWidget {
  const AuthService({super.key});

  @override
  _AuthServiceState createState() => _AuthServiceState();
}

class _AuthServiceState extends State<AuthService> {
  final apiService = ApiService();

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

  void _checkRole() async {
    try {
      // Kullanıcı adını SharedPreferences'tan al
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      if (username?.isNotEmpty == true) {
        final userRole = await apiService.getUserRole(username!);

        // Kullanıcı rolüne göre yönlendirme
        if (userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/aDashb'); // Admin dashboard
        } else if (userRole == 'user') {
          Navigator.pushReplacementNamed(context, '/uDashb'); // User dashboard
        } else {
          // Tanımlanmamış bir rol durumunda
          _handleUndefinedRole();
        }
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Hata durumunda kullanıcıyı giriş sayfasına yönlendir
      if (kDebugMode) {
        print('Error checking user role: $e');
      } // Hata mesajını konsola yazdır
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _handleUndefinedRole() {
    // Tanımlanmamış bir rol durumunda yapılacak işlemler
    // Örneğin, kullanıcıyı bir hata sayfasına yönlendirebilirsiniz
    Navigator.pushReplacementNamed(context, '/error'); // Hata sayfası
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama yükleniyor mesajı
    return const Scaffold(
      body: Center(
        child: Text('Yükleniyor...'),
      ),
    );
  }
}
