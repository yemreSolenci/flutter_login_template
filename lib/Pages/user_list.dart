import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/list_container.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:flutter_login_template/Pages/edit_item.dart';

class UserListPage extends StatelessWidget {
  final List<User> users;

  const UserListPage({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Kullanıcılar'),
      ),
      body: UserListContainer(
        height: MediaQuery.of(context).size.height,
        userRole: 'admin',
        users: users,
        selectedUser: null,
        onUserSelected: (user) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => UserEditPage(user: user)),
          );
        },
      ),
    );
  }
}
