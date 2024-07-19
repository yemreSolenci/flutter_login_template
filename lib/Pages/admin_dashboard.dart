import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: logout
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: Icon(Icons.logout, color: Colors.grey[200]),
          )
        ],
      ),
      body: const Center(
        child: Text('Admin Dashboard'),
      ),
    );
  }
}
