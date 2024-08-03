import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/list_container.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Pages/device_data.dart';

class DeviceListPage extends StatelessWidget {
  final List<Device> devices;

  const DeviceListPage({super.key, required this.devices});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tüm Cihazlar'),
      ),
      body: DeviceListContainer(
        height: MediaQuery.of(context).size.height,
        userRole: 'admin',
        devices: devices,
        selectedDevice: null,
        onDeviceSelected: (device) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DeviceDataPage(device: device),
            ),
          );
        },
      ),
    );
  }
}
