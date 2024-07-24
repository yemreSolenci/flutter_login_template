import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/tFieldContainer.dart';
import 'package:flutter_login_template/Pages/sign_up.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _checkLoginStatus(); // Giriş durumunu kontrol et
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
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Simulate a login process
    Future.delayed(const Duration(seconds: 2), () async {
      Navigator.pop(context);
      if (_conUserName.text == 'test' && _conPassword.text == 'password') {
        // Giriş başarılı, durumu sakla
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    });
  }

  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');

    if (isLoggedIn == true) {
      // Kullanıcı zaten giriş yapmış, otomatik yönlendirme
      Navigator.pushReplacementNamed(context, '/auth');
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
                  TextFieldContainer(
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
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                    ),
                  ),

                  // Parola alanı
                  TextFieldContainer(
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
                            isVisible ? Icons.visibility_off : Icons.visibility,
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

                  const SizedBox(height: 16.0),

                  // Login button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        login();
                      }
                    },
                    child: const Text('Giriş Yap'),
                  ),
                  const SizedBox(height: 16.0),

                  // Sign Up button
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    ),
                    child: const Text('Kayıt Ol'),
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
