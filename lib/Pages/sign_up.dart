import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/tFieldContainer.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _conFirstName = TextEditingController();
  final _conLastName = TextEditingController();
  final _conUserName = TextEditingController();
  final _conCity = TextEditingController();
  final _conPassword = TextEditingController();
  final _conConfirmPassword = TextEditingController();

  final FocusNode _firstNameFocusNode = FocusNode();
  final FocusNode _lastNameFocusNode = FocusNode();
  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _cityFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _conFirstName.dispose();
    _conLastName.dispose();
    _conUserName.dispose();
    _conCity.dispose();
    _conPassword.dispose();
    _conConfirmPassword.dispose();
    _firstNameFocusNode.dispose();
    _lastNameFocusNode.dispose();
    _userNameFocusNode.dispose();
    _cityFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kayıt Ol'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
                    controller: _conFirstName,
                    focusNode: _firstNameFocusNode,
                    hintText: 'İsim',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen isminizi giriniz';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_lastNameFocusNode);
                    },
                  ),
                  _buildTextField(
                    controller: _conLastName,
                    focusNode: _lastNameFocusNode,
                    hintText: 'Soyisim',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen soyisminizi giriniz';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_userNameFocusNode);
                    },
                  ),
                  _buildTextField(
                    controller: _conUserName,
                    focusNode: _userNameFocusNode,
                    hintText: 'Kullanıcı Adı',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen kullanıcı adınızı giriniz';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_cityFocusNode);
                    },
                  ),
                  _buildTextField(
                    controller: _conCity,
                    focusNode: _cityFocusNode,
                    hintText: 'Şehir',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen şehrinizi giriniz';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context).requestFocus(_passwordFocusNode);
                    },
                  ),
                  _buildPasswordField(
                    controller: _conPassword,
                    focusNode: _passwordFocusNode,
                    hintText: 'Parola',
                    isVisible: isPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen parolanızı giriniz';
                      }
                      if (value.length < 6) {
                        return 'Parola en az 6 karakter olmalıdır';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      FocusScope.of(context)
                          .requestFocus(_confirmPasswordFocusNode);
                    },
                  ),
                  _buildPasswordField(
                    controller: _conConfirmPassword,
                    focusNode: _confirmPasswordFocusNode,
                    hintText: 'Parola (Tekrar)',
                    isVisible: isConfirmPasswordVisible,
                    onToggleVisibility: () {
                      setState(() {
                        isConfirmPasswordVisible = !isConfirmPasswordVisible;
                      });
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen parolanızı tekrar giriniz';
                      }
                      if (value != _conPassword.text) {
                        return 'Parolalar aynı olmalıdır';
                      }
                      return null;
                    },
                    onFieldSubmitted: (value) {
                      if (_formKey.currentState!.validate()) {
                        signUp();
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        signUp();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(MediaQuery.of(context).size.width, 55.0),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
    required Function(String) onFieldSubmitted,
    required FocusNode focusNode,
  }) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          icon: Icon(icon),
          border: InputBorder.none,
          hintText: hintText,
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
    required Function(String) onFieldSubmitted,
    required FocusNode focusNode,
  }) {
    return Container(
      margin: const EdgeInsets.all(8.0),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Theme.of(context).primaryColor.withOpacity(0.2),
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        obscureText: !isVisible,
        onFieldSubmitted: onFieldSubmitted,
        decoration: InputDecoration(
          icon: const Icon(Icons.lock),
          border: InputBorder.none,
          hintText: hintText,
          suffixIcon: IconButton(
            onPressed: onToggleVisibility,
            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
          ),
        ),
      ),
    );
  }

  void signUp() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // Simulate a sign-up process
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);

      // Here you can add your sign-up logic, e.g., API call
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt olundu!')),
      );
      Navigator.pushReplacementNamed(
          context, '/'); // Redirect to home after sign up
    });
  }
}
