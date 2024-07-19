import 'package:flutter/material.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: logout
              Navigator.of(context).pushReplacementNamed('/');
            },
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: const Center(
        child: Text('User Dashboard'),
      ),
    );
  }
}
