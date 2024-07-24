import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/listContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final List<String> devices = [
    'Cihaz 1',
    'Cihaz 2',
    'Cihaz 3',
    'Cihaz 4',
    'Cihaz 5',
    'Cihaz 6',
    'Cihaz 7',
    'Cihaz 8',
    'Cihaz 9',
    'Cihaz 10',
    'Cihaz 11',
    'Cihaz 12',
  ];
  final List<String> users = [
    'Kullanıcı 1',
    'Kullanıcı 2',
    'Kullanıcı 3',
    'Kullanıcı 4',
    'Kullanıcı 5',
    'Kullanıcı 6',
    'Kullanıcı 7',
    'Kullanıcı 8',
    'Kullanıcı 9',
    'Kullanıcı 10',
  ];

  String? selectedDevice;
  String? selectedUser;

  Future<void> logout(BuildContext context) async {
    // Remove the login status from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');

    // Navigate to the login page
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: Icon(Icons.logout, color: Colors.grey[200]),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 10),
            const Text('Cihazlar', style: TextStyle(fontSize: 20)),
            ListContainer(
              items: devices,
              selectedItem: selectedDevice,
              onItemSelected: (item) {
                setState(() {
                  selectedDevice = item;
                  selectedUser = null;
                });
              },
            ),
            const SizedBox(height: 30),
            const Text('Kullanıcılar', style: TextStyle(fontSize: 20)),
            ListContainer(
              items: users,
              selectedItem: selectedUser,
              onItemSelected: (item) {
                setState(() {
                  selectedUser = item;
                  selectedDevice = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
