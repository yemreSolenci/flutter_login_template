import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/listContainer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final List<String> devices = [
    'Cihaz 1',
    'Cihaz 2',
  ];

  String? selectedDevice;

  // Örnek veriler
  final Map<String, List<Map<String, dynamic>>> deviceData = {
    'Cihaz 1': [
      {'zaman': '2024-07-23 10:00', 'değişken': 'Sıcaklık', 'değer': '25°C'},
      {'zaman': '2024-07-23 10:05', 'değişken': 'Nem', 'değer': '60%'},
    ],
    'Cihaz 2': [
      {'zaman': '2024-07-23 10:10', 'değişken': 'Sıcaklık', 'değer': '22°C'},
      {'zaman': '2024-07-23 10:15', 'değişken': 'Nem', 'değer': '55%'},
      {'zaman': '2024-07-23 10:20', 'değişken': 'Basınç', 'değer': '1013 hPa'},
      {'zaman': '2024-07-23 10:25', 'değişken': 'Işık', 'değer': '300 Lux'},
      {'zaman': '2024-07-23 10:30', 'değişken': 'Sıcaklık', 'değer': '21°C'},
      {'zaman': '2024-07-23 10:20', 'değişken': 'Basınç', 'değer': '1013 hPa'},
      {'zaman': '2024-07-23 10:25', 'değişken': 'Işık', 'değer': '300 Lux'},
      {'zaman': '2024-07-23 10:30', 'değişken': 'Sıcaklık', 'değer': '21°C'},
      {'zaman': '2024-07-23 10:20', 'değişken': 'Basınç', 'değer': '1013 hPa'},
      {'zaman': '2024-07-23 10:25', 'değişken': 'Işık', 'değer': '300 Lux'},
      {'zaman': '2024-07-23 10:30', 'değişken': 'Sıcaklık', 'değer': '21°C'},
    ],
  };

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
            ListContainer(
              height: 128,
              items: devices,
              selectedItem: selectedDevice,
              onItemSelected: (item) {
                setState(() {
                  selectedDevice = item;
                });
              },
            ),
            if (selectedDevice != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text(
                        '$selectedDevice',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          child: DataTable(
                            horizontalMargin:
                                16, // Sütun başlıkları ve hücreler arası boşluk
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
