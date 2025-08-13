// lib/models/user.dart (هذا ملف جديد أو تحديث له)

class User {
  final int id;
  final String name;
  final String email;
  final String? phoneNumber;
  final int? branchId; // قد لا تحتاج لعرض هذا في تطبيق العميل
  final String? role; // قد لا تحتاج لعرض هذا في تطبيق العميل

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.branchId,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      branchId: json['branch_id'],
      role: json['role'],
    );
  }
}