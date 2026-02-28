class Employee {
  final int id;
  final String employeeId;
  final int? userId;
  final String? username;

  // Department
  final int? departmentId;
  final String? departmentName;

  final String position;
  final DateTime joiningDate;
  final DateTime? contractEndDate;
  final String employmentType; // FULL_TIME, PART_TIME, CONTRACT, INTERN
  final String employmentStatus; // ACTIVE, ON_LEAVE, TERMINATED, RESIGNED

  // Salary
  final double basicSalary;
  final double? houseRent;
  final double? medicalAllowance;
  final double? conveyanceAllowance;
  final double? otherAllowances;
  final double totalSalary;

  // Personal
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? alternativePhone;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? maritalStatus;
  final String? nationality;

  // Identification
  final String? nidNumber;
  final String? passportNumber;
  final String? drivingLicense;

  // Bank
  final String? bankName;
  final String? bankAccountNo;
  final String? bankBranch;
  final String? routingNo;

  // Other
  final String? qualification;
  final String? experience;
  final String? skills;
  final String? profileImageUrl;
  final int? shiftId;
  final String? reportingTo;
  final int? reportingManagerId;
  final String? bloodGroup;
  final String? religion;
  final String? remarks;

  final bool isActive;
  final int? hotelId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Employee({
    required this.id,
    required this.employeeId,
    this.userId,
    this.username,
    this.departmentId,
    this.departmentName,
    required this.position,
    required this.joiningDate,
    this.contractEndDate,
    required this.employmentType,
    required this.employmentStatus,
    required this.basicSalary,
    this.houseRent,
    this.medicalAllowance,
    this.conveyanceAllowance,
    this.otherAllowances,
    required this.totalSalary,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.alternativePhone,
    this.emergencyContact,
    this.emergencyPhone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
    this.nationality,
    this.nidNumber,
    this.passportNumber,
    this.drivingLicense,
    this.bankName,
    this.bankAccountNo,
    this.bankBranch,
    this.routingNo,
    this.qualification,
    this.experience,
    this.skills,
    this.profileImageUrl,
    this.shiftId,
    this.reportingTo,
    this.reportingManagerId,
    this.bloodGroup,
    this.religion,
    this.remarks,
    required this.isActive,
    this.hotelId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? 0,
      employeeId: json['employeeId'] ?? '',
      userId: json['userId'],
      username: json['username'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      position: json['position'] ?? '',
      joiningDate: json['joiningDate'] != null
          ? DateTime.parse(json['joiningDate'])
          : DateTime.now(),
      contractEndDate: json['contractEndDate'] != null
          ? DateTime.parse(json['contractEndDate'])
          : null,
      employmentType: json['employmentType'] ?? 'FULL_TIME',
      employmentStatus: json['employmentStatus'] ?? 'ACTIVE',
      basicSalary: (json['basicSalary'] ?? 0).toDouble(),
      houseRent: json['houseRent']?.toDouble(),
      medicalAllowance: json['medicalAllowance']?.toDouble(),
      conveyanceAllowance: json['conveyanceAllowance']?.toDouble(),
      otherAllowances: json['otherAllowances']?.toDouble(),
      totalSalary: (json['totalSalary'] ?? 0).toDouble(),
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      alternativePhone: json['alternativePhone'],
      emergencyContact: json['emergencyContact'],
      emergencyPhone: json['emergencyPhone'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      nationality: json['nationality'],
      nidNumber: json['nidNumber'],
      passportNumber: json['passportNumber'],
      drivingLicense: json['drivingLicense'],
      bankName: json['bankName'],
      bankAccountNo: json['bankAccountNo'],
      bankBranch: json['bankBranch'],
      routingNo: json['routingNo'],
      qualification: json['qualification'],
      experience: json['experience'],
      skills: json['skills'],
      profileImageUrl: json['profileImageUrl'],
      shiftId: json['shiftId'],
      reportingTo: json['reportingTo'],
      reportingManagerId: json['reportingManagerId'],
      bloodGroup: json['bloodGroup'],
      religion: json['religion'],
      remarks: json['remarks'],
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'userId': userId,
      'departmentId': departmentId,
      'position': position,
      'joiningDate': joiningDate.toIso8601String().split('T')[0],
      'contractEndDate': contractEndDate?.toIso8601String().split('T')[0],
      'employmentType': employmentType,
      'employmentStatus': employmentStatus,
      'basicSalary': basicSalary,
      'houseRent': houseRent,
      'medicalAllowance': medicalAllowance,
      'conveyanceAllowance': conveyanceAllowance,
      'otherAllowances': otherAllowances,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'alternativePhone': alternativePhone,
      'emergencyContact': emergencyContact,
      'emergencyPhone': emergencyPhone,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'maritalStatus': maritalStatus,
      'nationality': nationality,
      'nidNumber': nidNumber,
      'passportNumber': passportNumber,
      'drivingLicense': drivingLicense,
      'bankName': bankName,
      'bankAccountNo': bankAccountNo,
      'bankBranch': bankBranch,
      'routingNo': routingNo,
      'qualification': qualification,
      'experience': experience,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
      'shiftId': shiftId,
      'reportingTo': reportingTo,
      'reportingManagerId': reportingManagerId,
      'bloodGroup': bloodGroup,
      'religion': religion,
      'remarks': remarks,
      'isActive': isActive,
      'hotelId': hotelId,
    };
  }

  String get fullName => '$firstName $lastName';
  int get age => dateOfBirth != null
      ? DateTime.now().year - dateOfBirth!.year
      : 0;
}