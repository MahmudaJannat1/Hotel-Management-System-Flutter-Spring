class StaffUser {
  final int id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String phone;
  final String? address;
  final bool isLoggedIn;

  StaffUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.phone,
    this.address,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'phone': phone,
      'address': address,
      'isLoggedIn': isLoggedIn ? 1 : 0,
    };
    if (id > 0) {
      map['id'] = id;
    }
    return map;
  }

  factory StaffUser.fromMap(Map<String, dynamic> map) {
    return StaffUser(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
      isLoggedIn: map['isLoggedIn'] == 1,
    );
  }
}