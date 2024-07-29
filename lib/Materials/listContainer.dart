import 'package:flutter/material.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';

class UserListContainer extends StatelessWidget {
  final List<User> users;
  final User? selectedUser;
  final ValueChanged<User> onUserSelected;
  final double? height;

  const UserListContainer({
    Key? key,
    required this.users,
    required this.selectedUser,
    required this.onUserSelected,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerHeight =
        height ?? MediaQuery.of(context).size.height * 0.35;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(100),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: selectedUser == user
                    ? Theme.of(context)
                        .primaryColor
                        .withOpacity(0.8) // Seçilen öğe rengi
                    : Theme.of(context)
                        .primaryColor
                        .withOpacity(0.3), // Diğer öğeler
                border: Border.all(
                  color: Colors.grey, // Kenar rengi
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10), // Köşe yarıçapı
              ),
              child: ListTile(
                title: Text(user.username),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${user.id}'),
                    Row(
                      children: [
                        Text('Rol: ${user.role}    '),
                        Text('Aktif: ${user.isActive ? "Evet" : "Hayır"}'),
                      ],
                    ),
                  ],
                ),
                onTap: () => onUserSelected(user),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DeviceListContainer extends StatelessWidget {
  final List<Device> devices;
  final Device? selectedDevice;
  final ValueChanged<Device> onDeviceSelected;
  final double? height;

  const DeviceListContainer({
    Key? key,
    required this.devices,
    required this.selectedDevice,
    required this.onDeviceSelected,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double containerHeight =
        height ?? MediaQuery.of(context).size.height * 0.35;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border.all(
          color: Theme.of(context).primaryColor.withAlpha(100),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(15),
      ),
      margin: const EdgeInsets.only(left: 25, right: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return Container(
              margin:
                  const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
              decoration: BoxDecoration(
                color: selectedDevice == device
                    ? Theme.of(context)
                        .primaryColor
                        .withOpacity(0.8) // Seçilen öğe rengi
                    : Theme.of(context)
                        .primaryColor
                        .withOpacity(0.3), // Diğer öğeler
                border: Border.all(
                  color: Colors.grey, // Kenar rengi
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10), // Köşe yarıçapı
              ),
              child: ListTile(
                title: Text(device.name ?? 'İsimsiz'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ID: ${device.id}'),
                    Text(
                        'Son Bağlantı: ${device.lastConnection?.toString() ?? 'Hiç'}'),
                  ],
                ),
                onTap: () => onDeviceSelected(device),
              ),
            );
          },
        ),
      ),
    );
  }
}
