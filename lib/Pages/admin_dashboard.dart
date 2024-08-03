import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/list_container.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:flutter_login_template/Pages/device_data.dart';
import 'package:flutter_login_template/Pages/device_list.dart';
import 'package:flutter_login_template/Pages/edit_item.dart';
import 'package:flutter_login_template/Pages/user_list.dart';
import 'package:flutter_login_template/Services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<User> users = [];
  User? selectedUser;

  List<Device> devices = [];
  Device? selectedDevice;

  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchDevices();
    fetchUsers();
  }

  Future<void> logout(BuildContext context) async {
    // Remove the login status from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to the login page
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await apiService.fetchUsers();
      setState(() {
        users = fetchedUsers;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Hata: $e');
      } // Hata mesajını konsola yazdır
    }
  }

  Future<void> fetchDevices() async {
    try {
      final fetchedDevices = await apiService.fetchDevices();
      setState(() {
        devices = fetchedDevices;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Hata: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                // Drawer'ı aç
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Menü',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.devices),
              title: const Text('Cihazlar'),
              onTap: () {
                Navigator.pop(context); // Popup menüyü kapat
                setState(() {
                  selectedDevice = null;
                  selectedUser = null;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DeviceListPage(devices: devices),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Kullanıcılar'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  selectedDevice = null;
                  selectedUser = null;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserListPage(users: users),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Çıkış Yap'),
              onTap: () {
                logout(context);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Cihazlar',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            devices.isNotEmpty
                ? DeviceListContainer(
                    userRole: 'admin',
                    devices: devices,
                    selectedDevice: selectedDevice,
                    onDeviceSelected: (device) {
                      setState(() {
                        selectedDevice = device;
                        selectedUser = null;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) =>
                                DeviceDataPage(device: device)),
                      );
                    },
                  )
                : const Text('Hiç cihaz bulunamadı'),
            const SizedBox(height: 30),
            const Text(
              'Kullanıcılar',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            users.isNotEmpty
                ? UserListContainer(
                    userRole: 'admin',
                    users: users,
                    selectedUser: selectedUser,
                    onUserSelected: (user) {
                      setState(() {
                        selectedUser = user;
                        selectedDevice = null;
                      });
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => UserEditPage(user: user),
                        ),
                      );
                    },
                  )
                : const Text(
                    'Hiç kullanıcı bulunamadı'), // Kullanıcı yoksa mesaj
          ],
        ),
      ),
    );
  }
}
