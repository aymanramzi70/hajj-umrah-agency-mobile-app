// lib/models/package.dart

// تأكد من عدم وجود أي استيرادات غير مستخدمة هنا
// import 'package:hajj_umrah_mobile_app/models/service.dart'; // إذا لم تكن تستخدم Services حالياً

class Package {
  final int id;
  final String name;
  final String? description; // جعل الوصف قابلاً للـ null
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final double pricePerPerson;
  final double? agentPricePerPerson; // جعل السعر للوكيل قابلاً للـ null
  final int numberOfDays;
  final int availableSeats;
  final String status;
  final List<String>? includes; // جعل includes قابلاً للـ null
  final List<String>? excludes; // جعل excludes قابلاً للـ null

  Package({
    required this.id,
    required this.name,
    this.description, // يمكن أن يكون null
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.pricePerPerson,
    this.agentPricePerPerson, // يمكن أن يكون null
    required this.numberOfDays,
    required this.availableSeats,
    required this.status,
    this.includes, // يمكن أن يكون null
    this.excludes, // يمكن أن يكون null
  });

  factory Package.fromJson(Map<String, dynamic> json) {
    // التعامل مع الحقول التي قد تكون null بشكل آمن
    List<String>? parsedIncludes;
    if (json['includes'] != null && json['includes'] is List) {
      parsedIncludes = List<String>.from(json['includes'].map((x) => x.toString()));
    }

    List<String>? parsedExcludes;
    if (json['excludes'] != null && json['excludes'] is List) {
      parsedExcludes = List<String>.from(json['excludes'].map((x) => x.toString()));
    }

    // ملاحظة: DateTime.parse() يمكن أن يرمي خطأ إذا كانت القيمة null أو غير صالحة.
    // تأكد أن 'start_date' و 'end_date' لا تأتي بـ null من الـ API.
    // إذا كانت محتملة أن تكون null في الـ API، يجب جعلها DateTime? والتحقق:
    // startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,

    return Package(
      id: json['id'],
      name: json['name'],
      description: json['description'], // هذا الحقل يمكن أن يكون null من الـ API
      type: json['type'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      pricePerPerson: double.parse(json['price_per_person'].toString()),
      agentPricePerPerson: json['agent_price_per_person'] != null
          ? double.parse(json['agent_price_per_person'].toString())
          : null, // تحويل آمن
      numberOfDays: json['number_of_days'],
      availableSeats: json['available_seats'],
      status: json['status'],
      includes: parsedIncludes, // استخدام القائمة المحللة الآمنة
      excludes: parsedExcludes, // استخدام القائمة المحللة الآمنة
    );
  }
}
//
// // lib/models/package.dart
//
// import 'package:hajj_umrah_mobile_app/models/service.dart'; // استيراد Service Model
//
// class Package {
//   final int id;
//   final String name;
//   final String description;
//   final DateTime startDate;
//   final DateTime endDate;
//   final int durationDays;
//   final double price;
//   final int maxPeople;
//   final String status;
//   final String? notes;
//   final List<Service>? services; // إضافة قائمة الخدمات
//
//   Package({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.startDate,
//     required this.endDate,
//     required this.durationDays,
//     required this.price,
//     required this.maxPeople,
//     required this.status,
//     this.notes,
//     this.services, // يجب أن يكون اختياريًا
//   });
//
//   factory Package.fromJson(Map<String, dynamic> json) {
//     var servicesList = json['services'] as List?;
//     List<Service>? parsedServices;
//     if (servicesList != null) {
//       parsedServices = servicesList.map((i) => Service.fromJson(i)).toList();
//     }
//
//     return Package(
//       id: json['id'],
//       name: json['name'],
//       description: json['description'],
//       startDate: DateTime.parse(json['start_date']),
//       endDate: DateTime.parse(json['end_date']),
//       durationDays: json['duration_days'],
//       price: double.parse(json['price'].toString()),
//       maxPeople: json['max_people'],
//       status: json['status'],
//       notes: json['notes'],
//       services: parsedServices, // تعيين الخدمات المحللة
//     );
//   }
// }
// // // lib/models/package.dart
// //
// // class Package {
// //   final int id;
// //   final String name;
// //   final String? description;
// //   final String type;
// //   final DateTime startDate;
// //   final DateTime endDate;
// //   final double pricePerPerson;
// //   final double? agentPricePerPerson;
// //   final int numberOfDays;
// //   final int availableSeats;
// //   final String status;
// //   final List<String>? includes;
// //   final List<String>? excludes;
// //
// //   Package({
// //     required this.id,
// //     required this.name,
// //     this.description,
// //     required this.type,
// //     required this.startDate,
// //     required this.endDate,
// //     required this.pricePerPerson,
// //     this.agentPricePerPerson,
// //     required this.numberOfDays,
// //     required this.availableSeats,
// //     required this.status,
// //     this.includes,
// //     this.excludes,
// //   });
// //
// //   factory Package.fromJson(Map<String, dynamic> json) {
// //     return Package(
// //       id: json['id'],
// //       name: json['name'],
// //       description: json['description'],
// //       type: json['type'],
// //       startDate: DateTime.parse(json['start_date']),
// //       endDate: DateTime.parse(json['end_date']),
// //       pricePerPerson: double.parse(json['price_per_person'].toString()),
// //       agentPricePerPerson: json['agent_price_per_person'] != null
// //           ? double.parse(json['agent_price_per_person'].toString())
// //           : null,
// //       numberOfDays: json['number_of_days'],
// //       availableSeats: json['available_seats'],
// //       status: json['status'],
// //       // JSON columns are already decoded to List<dynamic> by Dart's jsonDecode
// //       includes: json['includes'] != null
// //           ? List<String>.from(json['includes'])
// //           : null,
// //       excludes: json['excludes'] != null
// //           ? List<String>.from(json['excludes'])
// //           : null,
// //     );
// //   }
// // }