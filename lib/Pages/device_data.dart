import 'package:flutter/material.dart';
import 'package:flutter_login_template/Services/api_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_login_template/Model/device.dart';

class DeviceDataPage extends StatefulWidget {
  final Device device;
  DeviceDataPage({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  State<DeviceDataPage> createState() => _DeviceDataPageState();
}

class _DeviceDataPageState extends State<DeviceDataPage> {
  // Seçilen cihazı tutan değişken
  List<Map<String, dynamic>> deviceData = [];

  final ApiService apiService = ApiService();

  void fetchDeviceData(Device? selectedDevice) async {
    if (selectedDevice == null) {
      print('Seçilen cihaz yok.');
      return;
    }

    try {
      List<Map<String, dynamic>> data =
          await apiService.fetchDeviceData(selectedDevice.id);

      setState(() {
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

  @override
  void initState() {
    super.initState();

    fetchDeviceData(widget.device);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.device.name ?? 'Cihaz'} Verileri'), // Cihaz adı ile başlık
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Text(
                'Cihaz ID: ${widget.device.id}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat('     HH:mm\ndd/MM/yyyy').format(
                                      DateTime.parse(data['timestamp'])),
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
    );
  }
}
