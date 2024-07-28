import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/listContainer.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Services/api_service.dart'; // API servisinizi ekleyin
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Device? selectedDevice;
  List<Device> devices = [];
  Map<Device, List<Map<String, String>>> deviceData = {};

  final apiService =
      ApiService();

  @override
  void initState() {
    super.initState();
    fetchUserDevices();
  }

  Future<void> fetchUserDevices() async {
    // Kullanıcı ID'sini SharedPreferences'dan al
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('userId') ?? 0; // Kullanıcı ID'sini alın

    try {
      devices = await apiService.fetchUserDevices(userId);
      setState(() {});
    } catch (e) {
      print('Cihazlar alınırken hata oluştu: $e');
      // Hata mesajı gösterme
    }
  }

  Future<void> logout(BuildContext context) async {
    // Remove the login status from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);

    // Navigate to the login page
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: () => logout(context),
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            const SizedBox(height: 30),
            const Text('Cihazlar', style: TextStyle(fontSize: 20)),
            devices.isNotEmpty
                ? DeviceListContainer(
                    height: 128,
                    devices: devices,
                    selectedDevice: selectedDevice,
                    onDeviceSelected: (device) {
                      setState(() {
                        selectedDevice = device;
                      });
                    },
                  )
                : const Text('Hiç cihaz bulunamadı'),
            if (selectedDevice != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        selectedDevice?.name?.isNotEmpty == true
                            ? selectedDevice!.name!
                            : 'İsimsiz',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text('Zaman')),
                              DataColumn(label: Text('Değişken')),
                              DataColumn(label: Text('Değer')),
                            ],
                            rows: deviceData[selectedDevice]!.map((data) {
                              return DataRow(cells: [
                                DataCell(Text(data['zaman']!)),
                                DataCell(Text(data['değişken']!)),
                                DataCell(Text(data['değer']!)),
                              ]);
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
