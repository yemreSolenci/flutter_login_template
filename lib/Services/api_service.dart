import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'encryption_service.dart';
import 'dart:async';

class ApiService {
  final String baseUrl =
      'http://${kIsWeb ? 'localhost' : '10.0.2.2'}:3000'; //  'http://192.168.74.38:3000';
  final EncryptionService encryptionService = EncryptionService();
  final http.Client client = http.Client();

  // Timeout süresi
  final Duration timeoutDuration = const Duration(seconds: 10);

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
      if (kDebugMode) {
        if (kDebugMode) {
          print('Hata: $e');
        }
      }
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

  Future<String> getUserRole(String username) async {
    try {
      // Kullanıcı rolünü almak için API çağrısı yapın
      final uri = Uri.parse(
        '$baseUrl/getUserRole?username=$username',
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

  Future<int> getUserId(String username) async {
    try {
      final uri = Uri.parse('$baseUrl/getUserID?username=$username');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData.containsKey('id')) {
          return responseData['id'];
        } else {
          throw Exception('ID bilgisi bulunamadı');
        }
      } else {
        throw Exception('ID alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
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

  Future<List<Map<String, dynamic>>> fetchDeviceData(int deviceId) async {
    try {
      final uri = Uri.parse('$baseUrl/deviceData?deviceId=$deviceId');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // API'den gelen veriyi ayrıştır
        List<Map<String, dynamic>> data =
            List<Map<String, dynamic>>.from(json.decode(response.body));
        return data;
      } else {
        throw Exception('Veri alınamadı: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Hata: $e');
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

  // Kullanıcıya cihaz atama
  Future<void> assignDevicesToUser(int userId, List<Device> devices) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/devices'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(devices.map((device) => device.toJson()).toList()),
    );

    if (response.statusCode != 200) {
      throw Exception('Cihazlar kullanıcıya atanamadı');
    }
  }

// Kullanıcıdan cihaz kaldırma
  Future<void> removeDeviceFromUser(int userId, int deviceId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$userId/devices/$deviceId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Cihaz kullanıcıdan kaldırılamadı');
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
