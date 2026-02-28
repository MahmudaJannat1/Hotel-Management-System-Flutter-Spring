class Department {
  final int id;
  final String name;
  final String? description;
  final String? headOfDepartment;
  final int? headEmployeeId;
  final String? headEmployeeName;
  final String? location;
  final String? contactNumber;
  final String? email;
  final int totalEmployees;
  final bool isActive;
  final int? hotelId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Department({
    required this.id,
    required this.name,
    this.description,
    this.headOfDepartment,
    this.headEmployeeId,
    this.headEmployeeName,
    this.location,
    this.contactNumber,
    this.email,
    required this.totalEmployees,
    required this.isActive,
    this.hotelId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      headOfDepartment: json['headOfDepartment'],
      headEmployeeId: json['headEmployeeId'],
      headEmployeeName: json['headEmployeeName'],
      location: json['location'],
      contactNumber: json['contactNumber'],
      email: json['email'],
      totalEmployees: json['totalEmployees'] ?? 0,
      isActive: json['isActive'] ?? true,
      hotelId: json['hotelId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }
}