import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/text_field_container.dart';
import 'package:flutter_login_template/Services/api_service.dart';

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

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;
  bool isLoading = false; // Yükleme durumu değişkeni

  final apiService = ApiService();

  @override
  void dispose() {
    _conFirstName.dispose();
    _conLastName.dispose();
    _conUserName.dispose();
    _conCity.dispose();
    _conPassword.dispose();
    _conConfirmPassword.dispose();
    super.dispose();
  }

  void signUp() async {
    setState(() {
      isLoading = true; // Yükleme durumunu başlat
    });

    if (_formKey.currentState!.validate()) {
      try {
        final success = await apiService.register(
          _conUserName.text.trim(),
          _conPassword.text.trim(),
          firstName: _conFirstName.text.trim(),
          lastName: _conLastName.text.trim(),
          city: _conCity.text.trim(),
          context: context,
        );

        if (success == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Kayıt olundu!')),
          );
          Navigator.pushReplacementNamed(context, '/'); // Anasayfaya yönlendir
        } else {
          // Kayıt başarısız oldu
        }
      } catch (e) {
        // Hata durumunu yakalayın
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bir hata oluştu: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          isLoading = false; // Yükleme durumunu durdur
        });
      }
    } else {
      setState(() {
        isLoading = false; // Hatalı form durumunda yükleme durumu durdur
      });
    }
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
                  // İlk isim alanı
                  _buildTextField(
                    controller: _conFirstName,
                    label: 'İsim',
                    hintText: 'İsim',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen isminizi giriniz';
                      }
                      return null;
                    },
                  ),

                  // Soyisim alanı
                  _buildTextField(
                    controller: _conLastName,
                    label: 'Soyisim',
                    hintText: 'Soyisim',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen soyisminizi giriniz';
                      }
                      return null;
                    },
                  ),

                  // Kullanıcı adı alanı
                  _buildTextField(
                    controller: _conUserName,
                    label: 'Kullanıcı Adı',
                    hintText: 'Kullanıcı Adı',
                    icon: Icons.person,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen kullanıcı adınızı giriniz';
                      }
                      return null;
                    },
                  ),

                  // Şehir alanı
                  _buildTextField(
                    controller: _conCity,
                    label: 'Şehir',
                    hintText: 'Şehir',
                    icon: Icons.location_city,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Lütfen şehrinizi giriniz';
                      }
                      return null;
                    },
                  ),

                  // Parola alanı
                  _buildPasswordField(
                    controller: _conPassword,
                    label: 'Parola',
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
                  ),

                  // Parola (Tekrar) alanı
                  _buildPasswordField(
                    controller: _conConfirmPassword,
                    label: 'Parola (Tekrar)',
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
                  ),

                  const SizedBox(height: 16.0),

                  // Kayıt Ol butonu
                  ElevatedButton(
                    onPressed: isLoading // Yüklenme durumu kontrolü
                        ? null // Yükleme durumunda butonu devre dışı bırak
                        : signUp,
                    child: isLoading // Yüklenme durumu kontrolü
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text('Kayıt Ol'),
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
    required String label,
    required String hintText,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        validator: validator,
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
    required String label,
    required String hintText,
    required bool isVisible,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFieldContainer(
      child: TextFormField(
        controller: controller,
        obscureText: !isVisible,
        validator: validator,
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
}
