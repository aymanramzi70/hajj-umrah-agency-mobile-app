// lib/models/agent.dart (هذا ملف جديد أو تحديث له)

class Agent {
  final int id;
  final String companyName;
  final String contactPerson;
  final String email;
  final String? phoneNumber;
  final String? address;
  final String? licenseNumber;
  final double commissionRate;
  final String status;

  Agent({
    required this.id,
    required this.companyName,
    required this.contactPerson,
    required this.email,
    this.phoneNumber,
    this.address,
    this.licenseNumber,
    required this.commissionRate,
    required this.status,
  });

  factory Agent.fromJson(Map<String, dynamic> json) {
    return Agent(
      id: json['id'],
      companyName: json['company_name'],
      contactPerson: json['contact_person'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      address: json['address'],
      licenseNumber: json['license_number'],
      commissionRate: double.parse(json['commission_rate'].toString()),
      status: json['status'],
    );
  }
}