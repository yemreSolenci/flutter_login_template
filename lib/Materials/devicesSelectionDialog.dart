import 'package:flutter/material.dart';
import 'package:flutter_login_template/Model/device.dart';

class DeviceSelectionDialog extends StatefulWidget {
  final List<Device> allDevices;
  final List<Device> assignedDevices;

  const DeviceSelectionDialog({
    Key? key,
    required this.allDevices,
    required this.assignedDevices,
  }) : super(key: key);

  @override
  _DeviceSelectionDialogState createState() => _DeviceSelectionDialogState();
}

class _DeviceSelectionDialogState extends State<DeviceSelectionDialog> {
  late List<Device> _availableDevices;
  late List<Device> _selectedDevices;

  @override
  void initState() {
    super.initState();
    // Mevcut atanmış cihazları hariç tutarak kullanılabilir cihazları oluştur
    _availableDevices = widget.allDevices.where((device) {
      return !widget.assignedDevices
          .any((assignedDevice) => assignedDevice.id == device.id);
    }).toList();
    // Seçilen cihazları atanmış cihazlardan kopyala
    _selectedDevices = List.from(widget.assignedDevices);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cihaz Seç'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Atanmış cihazları listele
            ...widget.assignedDevices.map((device) {
              return ListTile(
                title: Text(
                  '${device.name?.isNotEmpty == true ? device.name : 'İsimsiz'} (ID: ${device.id})',
                ),
                trailing: const Icon(Icons.check, color: Colors.green),
              );
            }).toList(),
            const Divider(),
            // Kullanılabilir cihazları listele
            ..._availableDevices.map((device) {
              final isSelected = _selectedDevices.contains(device);
              return CheckboxListTile(
                title: Text(
                  '${device.name?.isNotEmpty == true ? device.name : 'İsimsiz'} (ID: ${device.id})',
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value ?? false) {
                      _selectedDevices.add(device);
                    } else {
                      _selectedDevices.remove(device);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_selectedDevices);
          },
          child: const Text('Tamam'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('İptal'),
        ),
      ],
    );
  }
}
