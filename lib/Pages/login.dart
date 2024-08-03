import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/text_field_container.dart';
import 'package:flutter_login_template/Pages/sign_up.dart';
import 'package:flutter_login_template/Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_login_template/Services/encryption_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final _formKey = GlobalKey<FormState>();

  final _conUserName = TextEditingController();
  final _conPassword = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  bool isVisible = false;
  bool isLoading = false; // Yüklenme durumu değişkeni

  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkLoginStatus(); // Giriş durumunu kontrol et
    _loadCredentials(); // Kullanıcı adı ve şifreyi yükle
  }

  @override
  void dispose() {
    _controller.dispose();
    _conUserName.dispose();
    _conPassword.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void login() async {
    setState(() {
      isLoading = true; // Yüklenme durumunu başlat
    });

    // Giriş işlemi sırasında yüklenme animasyonu göster
    try {
      final success = await apiService.login(
          _conUserName.text.trim(), _conPassword.text.trim(), context);
      if (success) {
        if (kDebugMode) {
          print('Giriş başarılı.');
        }
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', _conUserName.text.trim());
        await prefs.setString(
            'password',
            EncryptionService().encryptPassword(
                _conPassword.text.trim())); // Şifreyi şifrelenmiş olarak sakla
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        if (kDebugMode) {
          print('Giriş başarısız.');
        }
      }
    } finally {
      setState(() {
        isLoading = false; // Yüklenme durumunu durdur
      });
    }
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      bool isServerActive = await apiService.checkServerStatus(context);
      if (isServerActive) {
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        if (kDebugMode) {
          print('Sunucu aktif değil.');
        }
      }
    }
  }

  void _loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');

    if (username != null) {
      _conUserName.text = username; // Kullanıcı adını yükle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Giriş',
                    style: TextStyle(
                      fontSize: 40.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Kullanıcı adı alanı
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: TextFieldContainer(
                      child: TextFormField(
                        controller: _conUserName,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Lütfen kullanıcı adınızı girin';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          border: InputBorder.none,
                          hintText: 'Kullanıcı adı',
                        ),
                        onFieldSubmitted: (value) {
                          // Parola alanına geç
                          FocusScope.of(context)
                              .requestFocus(_passwordFocusNode);
                        },
                      ),
                    ),
                  ),

                  // Parola alanı
                  Container(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: TextFieldContainer(
                      child: TextFormField(
                        controller: _conPassword,
                        focusNode: _passwordFocusNode,
                        obscureText: !isVisible,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Lütfen parolanızı girin';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          icon: const Icon(Icons.lock),
                          border: InputBorder.none,
                          hintText: 'Parola',
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                isVisible =
                                    !isVisible; // Parola görünürlüğünü değiştirme
                              });
                            },
                            icon: Icon(
                              isVisible
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        onFieldSubmitted: (value) {
                          // Login butonuna bas
                          if (_formKey.currentState!.validate()) {
                            login();
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16.0),

                  // Login button
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: ElevatedButton(
                      onPressed: isLoading // Yüklenme durumu kontrolü
                          ? null // Yüklenme durumunda butonu devre dışı bırak
                          : () {
                              if (_formKey.currentState!.validate()) {
                                login();
                              }
                            },
                      child: isLoading // Yüklenme durumu kontrolü
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Giriş Yap'),
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Sign Up button
                  Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: ElevatedButton(
                      onPressed:
                          isLoading // Yüklenme durumunda butonu devre dışı bırak
                              ? null
                              : () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const SignUpPage()),
                                  ),
                      child: const Text('Kayıt Ol'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
