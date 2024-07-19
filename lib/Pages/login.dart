import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/tFieldContainer.dart';
import 'package:flutter_login_template/Pages/sign_up.dart';

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
  }

  @override
  void dispose() {
    _controller.dispose();
    _conUserName.dispose();
    _conPassword.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void login() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Simulate a login process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
      if (_conUserName.text == 'test' && _conPassword.text == 'password') {
        Navigator.pushReplacementNamed(context, '/auth');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    });
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
                  // Kullanıcı adı alanı
                  TextFieldContainer(
                    child: TextFormField(
                      controller: _conUserName,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.person),
                        border: InputBorder.none,
                        hintText: 'Username',
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        icon: const Icon(Icons.lock),
                        border: InputBorder.none,
                        hintText: 'Password',
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
                    child: const Text('Login'),
                  ),
                  const SizedBox(height: 16.0),

                  // Sign Up button
                  ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpPage()),
                    ),
                    child: const Text('Sign Up'),
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
