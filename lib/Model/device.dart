class Device {
  final int id;
  final String? name;
  final DateTime? startTime; // Cihazın başlangıç zamanı
  final DateTime? lastConnection; // Cihazın son bağlantı zamanı

  Device({
    required this.id,
    this.name,
    this.startTime,
    this.lastConnection,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'],
      name: json['name'],
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'])
          : null,
      lastConnection: json['last_connection'] != null
          ? DateTime.parse(json['last_connection'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'start_time':
          startTime?.toIso8601String(), // DateTime'ı ISO 8601 formatına çevir
      'last_connection': lastConnection
          ?.toIso8601String(), // DateTime'ı ISO 8601 formatına çevir
    };
  }
}
