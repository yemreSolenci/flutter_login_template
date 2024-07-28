import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/tFieldContainer.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:flutter_login_template/Services/api_service.dart';

final apiService =
    ApiService();

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late TextEditingController _idController;
  late TextEditingController _usernameController;
  late String _selectedRole; // Seçilen rol
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  bool _isActive = true; // Kullanıcının aktif olup olmadığını belirten değişken

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.user.id.toString());
    _usernameController = TextEditingController(text: widget.user.username);
    _selectedRole = widget.user.role; // Rolü başlangıçta ayarla
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _cityController = TextEditingController(text: widget.user.city);
    _isActive = widget.user.isActive; // Kullanıcının aktif durumunu ayarla
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcı Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'ID'),
                controller: _idController,
                enabled: false,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Kullanıcı Adı'),
                controller: _usernameController,
              ),
            ),
            TextFieldContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Rol',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Theme.of(context).primaryColor.withOpacity(0.2),
                      border: Border.all(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.6)),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedRole,
                      isExpanded: true,
                      underline: SizedBox(),
                      items: <String>['user', 'admin'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child:
                              Text(value == 'user' ? 'Kullanıcı' : 'Yönetici'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedRole = newValue!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Ad'),
                controller: _firstNameController,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Soyad'),
                controller: _lastNameController,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Şehir'),
                controller: _cityController,
              ),
            ),
            // Aktif durumu için Switch ekliyoruz
            SwitchListTile(
              title: const Text('Aktif'),
              value: _isActive,
              onChanged: (bool value) {
                setState(() {
                  _isActive = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Kullanıcı düzenleme işlemleri
                final user = User(
                  id: int.parse(_idController.text),
                  username: _usernameController.text,
                  role: _selectedRole,
                  isActive: _isActive,
                  firstName: _firstNameController.text,
                  lastName: _lastNameController.text,
                  city: _cityController.text,
                );

                try {
                  // API çağrısını yap
                  final response = await apiService.updateUser(user);
                  if (response != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Kullanıcı başarıyla güncellendi')),
                    );
                    Navigator.pop(context); // Kaydettikten sonra geri dön
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Kullanıcı güncellenirken hata: $e')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}

class DeviceEditPage extends StatefulWidget {
  final Device device;

  const DeviceEditPage({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceEditPageState createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  late TextEditingController _deviceIdController;
  late TextEditingController _deviceNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _lastConnectionController;

  @override
  void initState() {
    super.initState();
    _deviceIdController =
        TextEditingController(text: widget.device.id.toString());
    _deviceNameController = TextEditingController(text: widget.device.name);
    _startTimeController = TextEditingController(
        text: widget.device.startTime != null
            ? widget.device.startTime!.toIso8601String()
            : '');
    _lastConnectionController = TextEditingController(
        text: widget.device.lastConnection != null
            ? widget.device.lastConnection!.toIso8601String()
            : '');
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _startTimeController.dispose();
    _lastConnectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Düzenle'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'ID'),
                controller: _deviceIdController,
                enabled: false,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Cihaz Adı'),
                controller: _deviceNameController,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Başlangıç Zamanı'),
                controller: _startTimeController,
                enabled: false,
              ),
            ),
            TextFieldContainer(
              child: TextField(
                decoration: InputDecoration(labelText: 'Son Bağlantı Zamanı'),
                controller: _lastConnectionController,
                enabled: false,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Cihaz düzenleme işlemleri
                final device = Device(
                  id: int.parse(_deviceIdController.text),
                  name: _deviceNameController.text,
                  startTime: DateTime.parse(_startTimeController.text),
                  lastConnection:
                      DateTime.parse(_lastConnectionController.text),
                );

                try {
                  // API çağrısını yap
                  final response = await apiService
                      .updateDevice(device); // updateDevice metodunu çağır
                  if (response != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Cihaz başarıyla güncellendi')),
                    );
                    Navigator.pop(context); // Kaydettikten sonra geri dön
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Cihaz güncellenirken hata: $e')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
