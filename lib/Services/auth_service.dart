import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  void _checkRole() async {
    try {
      // Kullanıcı adını SharedPreferences'tan al
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? username = prefs.getString('username');

      if (username != null) {
        // Kullanıcı rolünü doğrudan veritabanından veya API'den al
        final userRole = await _getUserRole(username);

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
        // Kullanıcı adı yoksa, giriş sayfasına yönlendir
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      // Hata durumunda kullanıcıyı giriş sayfasına yönlendir
      print('Error checking user role: $e'); // Hata mesajını konsola yazdır
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _handleUndefinedRole() {
    // Tanımlanmamış bir rol durumunda yapılacak işlemler
    // Örneğin, kullanıcıyı bir hata sayfasına yönlendirebilirsiniz
    Navigator.pushReplacementNamed(context, '/error'); // Hata sayfası
  }

  Future<String> _getUserRole(String username) async {
    // Kullanıcı adının boş olup olmadığını kontrol et
    if (username.isEmpty) {
      throw Exception('Kullanıcı adı boş olamaz');
    }

    try {
      // Kullanıcı rolünü almak için API çağrısı yapın
      final uri = Uri.parse(
        '${kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000'}/getUserRole?username=$username',
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('role')) {
          return responseData['role']; // 'role' alanını döndür
        } else {
          throw Exception('Rol bilgisi bulunamadı');
        }
      } else {
        throw Exception('Rol alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      // Hata durumunda daha fazla bilgi verin
      throw Exception('Hata: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Uygulama yükleniyor mesajı
    return Scaffold(
      body: Center(
        child: Text('Yükleniyor...'),
      ),
    );
  }
}
