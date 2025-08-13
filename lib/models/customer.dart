// lib/models/customer.dart

class Customer {
  final int id;
  final String firstName;
  final String lastName;
  final String? email; // قد يكون null في الـ API
  final String phoneNumber;
  final String? nationalId; // قد يكون null
  final String? passportNumber; // قد يكون null
  final DateTime? dateOfBirth; // قد يكون null
  final String? gender; // قد يكون null
  final String? address; // قد يكون null
  final int? userId; // الربط الجديد مع Users
  // final int? sourceBranchId; // يمكن إبقائه إذا كنت لا تزال تستخدمه

  Customer({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.phoneNumber,
    this.nationalId,
    this.passportNumber,
    this.dateOfBirth,
    this.gender,
    this.address,
    this.userId, // إضافة حقل user_id
    // this.sourceBranchId,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      nationalId: json['national_id'],
      passportNumber: json['passport_number'],
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
      gender: json['gender'],
      address: json['address'],
      userId: json['user_id'], // تحويل user_id
      // sourceBranchId: json['source_branch_id'],
    );
  }
}
// // lib/models/customer.dart (هذا ملف جديد أو تحديث له)
//
// class Customer {
//   final int id;
//   final String firstName;
//   final String lastName;
//   final String? email;
//   final String phoneNumber;
//   final String? nationalId;
//   final String? passportNumber;
//   final DateTime? dateOfBirth;
//   final String? gender;
//   final String? address;
//   // final int? sourceBranchId; // يمكن إضافته إذا لزم الأمر
//
//   Customer({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     this.email,
//     required this.phoneNumber,
//     this.nationalId,
//     this.passportNumber,
//     this.dateOfBirth,
//     this.gender,
//     this.address,
//     // this.sourceBranchId,
//   });
//
//   factory Customer.fromJson(Map<String, dynamic> json) {
//     return Customer(
//       id: json['id'],
//       firstName: json['first_name'],
//       lastName: json['last_name'],
//       email: json['email'],
//       phoneNumber: json['phone_number'],
//       nationalId: json['national_id'],
//       passportNumber: json['passport_number'],
//       dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth']) : null,
//       gender: json['gender'],
//       address: json['address'],
//       // sourceBranchId: json['source_branch_id'],
//     );
//   }
// }