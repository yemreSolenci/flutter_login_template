class User {
  final int id;
  final String username;
  final String role;
  final bool isActive; // boolean olarak tanımladık
  final String? firstName;
  final String? lastName;
  final String? city;

  User({
    required this.id,
    required this.username,
    required this.role,
    required this.isActive,
    this.firstName,
    this.lastName,
    this.city,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      isActive: json['is_active'] ==
          1, // Veritabanında 1 veya 0 olarak döndüğü için boolean'a çeviriyoruz
      firstName: json['first_Name'],
      lastName: json['last_Name'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'is_active': isActive ? 1 : 0, // Boolean'ı 1 veya 0 olarak döndür
      'first_Name': firstName,
      'last_Name': lastName,
      'city': city,
    };
  }
}
