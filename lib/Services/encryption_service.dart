import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionService {
  // Şifreleme anahtarı ve IV
  final key = encrypt.Key.fromUtf8(
      '16charSecretKey!'); // 16 karakter uzunluğunda bir anahtar
  final iv = encrypt.IV.fromLength(16); // IV uzunluğu 16 byte

  // Parolayı şifrele
  String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(password, iv: iv);
    return encrypted.base64; // Şifrelenmiş parolayı base64 formatında döndür
  }

  // Parolayı şifre çöz
  String decryptPassword(String encryptedPassword) {
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted; // Şifrelenmiş parolayı çöz
  }
}
