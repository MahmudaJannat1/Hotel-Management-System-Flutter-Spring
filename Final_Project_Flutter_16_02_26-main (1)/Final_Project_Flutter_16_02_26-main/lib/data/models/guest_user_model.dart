// GuestUser মডেল আপডেট করুন
class GuestUser {
  final int id;
  final String name;
  final String email;
  final String password;  // ✅ password field যোগ করুন
  final String phone;
  final String? address;
  final bool isLoggedIn;

  GuestUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    this.address,
    this.isLoggedIn = false,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'id': id,  // ✅ সবসময় id include করুন

      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'isLoggedIn': isLoggedIn ? 1 : 0,
    };

    // // 🔴 id শুধু তখনই যোগ করুন যখন 0 এর বেশি
    // if (id > 0) {
    //   map['id'] = id;
    // }
    print('📦 GuestUser.toMap(): $map');  // এই print টা দেখতে হবে

    return map;
  }


  factory GuestUser.fromMap(Map<String, dynamic> map) {
    return GuestUser(
      id: map['id'] ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',  // ✅ password যোগ করুন
      phone: map['phone'] ?? '',
      address: map['address'],
      isLoggedIn: map['isLoggedIn'] == 1,
    );
  }
}