import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login_template/Materials/devicesSelectionDialog.dart';
import 'package:flutter_login_template/Materials/textFieldContainer.dart';
import 'package:flutter_login_template/Model/device.dart';
import 'package:flutter_login_template/Model/user.dart';
import 'package:flutter_login_template/Services/api_service.dart';

final apiService = ApiService();

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({Key? key, required this.user}) : super(key: key);

  @override
  _UserEditPageState createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  late TextEditingController _idController;
  late TextEditingController _usernameController;
  late String _selectedRole; // Selected role
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _cityController;
  bool _isActive = true; // Indicates if the user is active

  late List<Device> _availableDevices = [];
  late List<Device> _assignedDevicesOriginal =
      []; // Original assigned devices from the database
  late List<Device> _assignedDevicesCurrent =
      []; // Current assigned devices for editing
  List<Device> _devicesToRemove = []; // List to hold devices to be removed
  int _maxDeviceCount = 2;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.user.id.toString());
    _usernameController = TextEditingController(text: widget.user.username);
    _selectedRole = widget.user.role; // Set the initial role
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);
    _cityController = TextEditingController(text: widget.user.city);
    _isActive = widget.user.isActive; // Set the user's active status

    _fetchAvailableDevices();
    _fetchAssignedDevices();
  }

  @override
  void dispose() {
    _idController.dispose();
    _usernameController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // Fetch available devices for the user
  Future<void> _fetchAvailableDevices() async {
    try {
      final devices = await apiService.fetchDevices();
      setState(() {
        _availableDevices = devices;
      });
    } catch (e) {
      setState(() {
        _availableDevices = [];
      });
    }
  }

  // Fetch assigned devices for the user
  Future<void> _fetchAssignedDevices() async {
    try {
      final devices = await apiService.fetchUserDevices(widget.user.id);
      setState(() {
        _assignedDevicesOriginal = devices; // Save original assigned devices
        _assignedDevicesCurrent = List.from(devices); // Copy for editing
      });
    } catch (e) {
      setState(() {
        _assignedDevicesOriginal = [];
        _assignedDevicesCurrent = [];
      });
    }
  }

  Future<void> _showDeviceSelectionDialog() async {
    final selectedDevices = await showDialog<List<Device>>(
      context: context,
      builder: (BuildContext context) {
        return DeviceSelectionDialog(
          allDevices: _availableDevices,
          assignedDevices: _assignedDevicesCurrent,
        );
      },
    );

    if (selectedDevices != null) {
      setState(() {
        _assignedDevicesCurrent =
            selectedDevices; // Update current assigned devices
      });
    }
  }

  // Assign devices to the user
  Future<void> _assignDevicesToUser() async {
    try {
      await apiService.assignDevicesToUser(
          widget.user.id, _assignedDevicesCurrent);
      showSnackBarMessage('Devices assigned to the user', context,
          backgroundColor: Colors.green);
      if (_devicesToRemove.isNotEmpty && _assignedDevicesCurrent.isNotEmpty) {
        //if have same device, delete from _devicesToRemove list
        for (var device in _assignedDevicesCurrent) {
          _devicesToRemove
              .removeWhere((removalDevice) => removalDevice.id == device.id);
        }
      }
    } catch (e) {
      showSnackBarMessage('Device assignment failed', context);
    }
  }

  // Remove devices from the user
  Future<void> _removeDevicesFromUser() async {
    try {
      // Remove devices that are in _devicesToRemove from _assignedDevicesCurrent
      for (var device in _devicesToRemove) {
        await apiService.removeDeviceFromUser(widget.user.id, device.id);
      }
      setState(() {
        _assignedDevicesCurrent.removeWhere((device) =>
            _devicesToRemove.contains(device)); // Remove from current list
        _devicesToRemove.clear(); // Clear the list of devices to remove
      });
      showSnackBarMessage('Devices removed from the user', context,
          backgroundColor: Colors.green);
    } catch (e) {
      showSnackBarMessage('Device removal failed', context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'ID'),
                      controller: _idController,
                      enabled: false,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Username'),
                      controller: _usernameController,
                    ),
                  ),
                  TextFieldContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Role',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.0),
                            color:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            border: Border.all(
                                color: Theme.of(context)
                                    .primaryColor
                                    .withOpacity(0.6)),
                          ),
                          child: DropdownButton<String>(
                            value: _selectedRole,
                            isExpanded: true,
                            underline: SizedBox(),
                            items:
                                <String>['user', 'admin'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value == 'user' ? 'User' : 'Admin'),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedRole = newValue!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'First Name'),
                      controller: _firstNameController,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Last Name'),
                      controller: _lastNameController,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'City'),
                      controller: _cityController,
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: _isActive,
                    onChanged: (bool value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFieldContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Devices',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            ..._assignedDevicesCurrent.map((device) => Chip(
                                  label: Text(
                                    '${device.name?.isNotEmpty == true ? device.name : 'Unnamed'} (ID: ${device.id})',
                                  ),
                                  onDeleted: () {
                                    // Add device to removal list
                                    setState(() {
                                      _devicesToRemove.add(device);
                                      _assignedDevicesCurrent.remove(device);
                                    });
                                  },
                                )),
                            if (_assignedDevicesCurrent.length <
                                _maxDeviceCount)
                              ChoiceChip(
                                label: const Text('Add Device'),
                                selected: false,
                                onSelected: (bool selected) {
                                  if (selected) {
                                    // Show device selection dialog
                                    _showDeviceSelectionDialog();
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });

                      // User update operations
                      final user = User(
                        id: int.parse(_idController.text),
                        username: _usernameController.text,
                        role: _selectedRole,
                        isActive: _isActive,
                        firstName: _firstNameController.text,
                        lastName: _lastNameController.text,
                        city: _cityController.text,
                      );

                      try {
                        // Update user information
                        final response = await apiService.updateUser(user);
                        if (response != null) {
                          // Save device assignments
                          await _assignDevicesToUser();
                          // Save device removals
                          await _removeDevicesFromUser();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('User updated successfully')),
                          );
                          Navigator.pop(context); // Go back after saving
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error updating user: $e')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }

  void showSnackBarMessage(String message, BuildContext context,
      {Color backgroundColor = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }
}

//        Cihaz Düzenleme Sayfası

class DeviceEditPage extends StatefulWidget {
  final Device device;

  const DeviceEditPage({Key? key, required this.device}) : super(key: key);

  @override
  _DeviceEditPageState createState() => _DeviceEditPageState();
}

class _DeviceEditPageState extends State<DeviceEditPage> {
  late TextEditingController _deviceIdController;
  late TextEditingController _deviceNameController;
  late TextEditingController _startTimeController;
  late TextEditingController _lastConnectionController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _deviceIdController =
        TextEditingController(text: widget.device.id.toString());
    _deviceNameController = TextEditingController(text: widget.device.name);
    _startTimeController = TextEditingController(
        text: widget.device.startTime != null
            ? widget.device.startTime!.toIso8601String()
            : '');
    _lastConnectionController = TextEditingController(
        text: widget.device.lastConnection != null
            ? widget.device.lastConnection!.toIso8601String()
            : '');
  }

  @override
  void dispose() {
    _deviceIdController.dispose();
    _deviceNameController.dispose();
    _startTimeController.dispose();
    _lastConnectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cihaz Düzenle'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'ID'),
                      controller: _deviceIdController,
                      enabled: false,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration: InputDecoration(labelText: 'Cihaz Adı'),
                      controller: _deviceNameController,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: 'Başlangıç Zamanı'),
                      controller: _startTimeController,
                      enabled: false,
                    ),
                  ),
                  TextFieldContainer(
                    child: TextField(
                      decoration:
                          InputDecoration(labelText: 'Son Bağlantı Zamanı'),
                      controller: _lastConnectionController,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      // Cihaz düzenleme işlemleri
                      final device = Device(
                        id: int.parse(_deviceIdController.text),
                        name: _deviceNameController.text,
                        startTime: DateTime.parse(_startTimeController.text),
                        lastConnection:
                            DateTime.parse(_lastConnectionController.text),
                      );

                      try {
                        // API çağrısını yap
                        final response = await apiService.updateDevice(
                            device); // updateDevice metodunu çağır
                        if (response != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Cihaz başarıyla güncellendi')),
                          );
                          Navigator.pop(context); // Kaydettikten sonra geri dön
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Cihaz güncellenirken hata: $e')),
                        );
                      } finally {
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ),
    );
  }
}
