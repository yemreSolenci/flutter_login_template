import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/list_container.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Services/api_service.dart'; // API servisinizi ekleyin
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  Device? selectedDevice;
  List<Device> devices = [];
  List<Map<String, dynamic>> deviceData = [];

  final apiService = ApiService();

  @override
  void initState() {
    super.initState();
    fetchUserDevices();
  }

  Future<int> getUserId(String? username) async {
    if (username != null && username.isNotEmpty) {
      try {
        int id = await apiService.getUserId(username);
        if (id > 0) {
          return id;
        } else {
          throw Exception('ID bilgisi bulunamadı');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Kullanıcı ID alınırken hata oluştu: $e');
        }
        rethrow;
      }
    }
    return 0;
  }

  void fetchDeviceData(Device? selectedDevice) async {
    if (selectedDevice == null) {
      print('Seçilen cihaz yok.');
      return;
    }

    try {
      // API'den verileri çekerken, doğru türde bir veri döndüğünden emin olun
      List<Map<String, dynamic>> data =
          await apiService.fetchDeviceData(selectedDevice.id);

      setState(() {
        // Önceki verileri temizle
        deviceData.clear();

        // Seçilen cihazın verilerini almak için
        if (data.isNotEmpty) {
          // Verileri tarih bilgisine göre sıralama (en yeni veriler en üstte olacak şekilde)
          data.sort((a, b) {
            DateTime dateA = DateTime.parse(a['timestamp']);
            DateTime dateB = DateTime.parse(b['timestamp']);
            return dateB.compareTo(dateA); // b - a yaparak azalan sıralama
          });

          deviceData = data; // Doğrudan atama yapıyoruz
        } else {
          print('Seçilen cihaz için veri bulunamadı.');
        }
      });
    } catch (e) {
      print('Cihaz verileri alınırken hata oluştu: $e');
    }
  }

  void fetchUserDevices() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    int userId = await getUserId(username) ?? 0;

    try {
      devices = await apiService.fetchUserDevices(userId);
      setState(() {});
    } catch (e) {
      if (kDebugMode) {
        print('Cihazlar alınırken hata oluştu: $e');
      }
      // Hata mesajı gösterme
      rethrow;
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
                    userRole: 'user',
                    height: 177,
                    devices: devices,
                    selectedDevice: selectedDevice,
                    onDeviceSelected: (device) {
                      setState(() {
                        selectedDevice = device;
                        deviceData.clear(); // Önceki verileri temizle
                        fetchDeviceData(
                            selectedDevice); // Yeni cihaz verilerini al
                      });
                    },
                  )
                : const Text('Hiç cihaz bulunamadı'),
            if (selectedDevice != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        selectedDevice!.name?.isNotEmpty == true
                            ? selectedDevice!.name!
                            : 'İsimsiz ID: ${selectedDevice!.id}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (deviceData.isNotEmpty)
                        Expanded(
                          child: SingleChildScrollView(
                            child: DataTable(
                              columns: const [
                                DataColumn(label: Text('Zaman')),
                                DataColumn(label: Text('Değişken')),
                                DataColumn(label: Text('Değer')),
                              ],
                              rows: deviceData.map((data) {
                                return DataRow(cells: [
                                  DataCell(
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          DateFormat('     HH:mm\ndd/MM/yyyy')
                                              .format(DateTime.parse(
                                                  data['timestamp'])),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  DataCell(
                                    Center(child: Text(data['variable'])),
                                  ),
                                  DataCell(Center(
                                    child: Text(data['value'].toString()),
                                  )), // Değer float olduğu için toString() ile metne çeviriyoruz
                                ]);
                              }).toList(),
                            ),
                          ),
                        )
                      else
                        const Text('Seçilen cihaz için veri bulunamadı.'),
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
