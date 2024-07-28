import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'encryption_service.dart';
import 'dart:async'; // TimeoutException için gerekli

class ApiService {
  final String baseUrl =
      kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  final EncryptionService encryptionService = EncryptionService();
  final http.Client client = http.Client();

  // Timeout süresi
  final Duration timeoutDuration = Duration(seconds: 10);

  Future<bool> checkServerStatus(BuildContext context) async {
    try {
      final response = await http.get(
          Uri.parse('$baseUrl/health')); // Sağlık kontrolü için bir endpoint
      if (response.statusCode == 200) {
        return true; // Sunucu aktif
      } else {
        showSnackBarMessage('Hata: Sunucuya bağlanılamadı', context);
        return false; // Sunucu aktif değil
      }
    } catch (e) {
      print('Hata: $e');
      return false; // Sunucuya erişim sağlanamadı
    }
  }

  Future<User> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Kullanıcı güncellenirken hata oluştu');
    }
  }

  Future<Device> updateDevice(Device device) async {
    final response = await http.put(
      Uri.parse('$baseUrl/devices/${device.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(device.toJson()),
    );

    if (response.statusCode == 200) {
      return Device.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Cihaz güncellenirken hata oluştu');
    }
  }

  Future<List<User>> fetchUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((user) => User.fromJson(user)).toList();
      } else {
        throw Exception('Kullanıcılar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  Future<List<Device>> fetchDevices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/devices'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((device) => Device.fromJson(device)).toList();
      } else {
        throw Exception('Cihazlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  // Kullanıcı kaydı
  Future<String> register(String username, String password,
      {String role = 'user',
      String? firstName,
      String? lastName,
      String? city,
      required BuildContext context}) async {
    try {
      final encryptedPassword = encryptionService.encryptPassword(password);
      final response = await client
          .post(
            Uri.parse('$baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'username': username,
              'password': encryptedPassword,
              'role': role,
              'first_Name': firstName, // İlk adı ekle
              'last_Name': lastName, // Soyadı ekle
              'city': city // Şehri ekle
            }),
          )
          .timeout(timeoutDuration);

      if (response.statusCode == 201) {
        // Kayıt başarılı
        final responseData = json.decode(response.body);
        showSnackBarMessage(
            'Kayıt başarılı: ${responseData['message']}', context,
            backgroundColor: Colors.green);
        return 'ok';
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);
        showSnackBarMessage(
            'Kayıt hatası: Kullanıcı adı zaten kayıtlı!', context);
        return 'username_exists';
      } else {
        // Hata durumunda yanıtı kontrol edin
        final responseData = json.decode(response.body);
        showSnackBarMessage(
            'Kayıt hatası: ${responseData['message']}', context);
        return 'server error';
      }
    } on TimeoutException catch (_) {
      // Timeout durumunda özel mesaj
      showSnackBarMessage(
          'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.', context);
      return 'timeout';
    } catch (e) {
      // Diğer hata durumlarını yakalayın
      showSnackBarMessage('Bir hata oluştu: $e', context);
      return 'error';
    }
  }

  // Kullanıcı girişi
  Future<bool> login(
      String username, String password, BuildContext context) async {
    try {
      final response = await client
          .post(
            Uri.parse('$baseUrl/login'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(timeoutDuration); // Timeout süresi ekle

      if (response.statusCode == 200) {
        // Yanıtı JSON formatında çözümleyin
        final responseData = json.decode(response.body);
        return true;
      } else if (response.statusCode == 403) {
        showSnackBarMessage('Giriş hatası: Kullanıcı aktif değil!', context);
        return false;
      } else {
        // Hata durumunda yanıtı kontrol edin
        final responseData = json.decode(response.body);
        showSnackBarMessage(
            'Giriş hatası: ${responseData['message']}', context);
        return false;
      }
    } on TimeoutException catch (_) {
      // Timeout durumunda özel mesaj
      showSnackBarMessage(
          'Bağlantı zaman aşımına uğradı. Lütfen tekrar deneyin.', context);
      return false;
    } catch (e) {
      // Diğer hata durumlarını yakalayın
      showSnackBarMessage('Bir hata oluştu: $e', context);
      return false;
    }
  }

  // Kullanıcının cihazlarını getiren metot
  Future<List<Device>> fetchUserDevices(int userId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/users/$userId/devices'));

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((device) => Device.fromJson(device)).toList();
      } else {
        throw Exception('Cihazlar alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
    }
  }

  void showSnackBarMessage(String message, BuildContext context,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
