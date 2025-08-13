// lib/models/booking.dart

import 'package:hajj_umrah_mobile_app/models/package.dart'; // استيراد Package Model
import 'package:hajj_umrah_mobile_app/models/customer.dart'; // استيراد Customer Model
import 'package:hajj_umrah_mobile_app/models/agent.dart'; // استيراد Agent Model
import 'package:hajj_umrah_mobile_app/models/user.dart'; // استيراد User Model (لمن قام بالحجز)

class Booking {
  final int id;
  final String bookingCode;
  final Package package; // الحجز مرتبط بباقة
  final Customer? customer; // يمكن أن يكون عميل مباشر
  final Agent? agent; // أو وكيل
  final User bookedByUser; // الموظف الذي قام بالحجز
  final int numberOfPeople;
  final double totalPrice;
  final double paidAmount;
  final double remainingAmount;
  final String paymentStatus;
  final String bookingStatus;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Booking({
    required this.id,
    required this.bookingCode,
    required this.package,
    this.customer,
    this.agent,
    required this.bookedByUser,
    required this.numberOfPeople,
    required this.totalPrice,
    required this.paidAmount,
    required this.remainingAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      bookingCode: json['booking_code'],
      package: Package.fromJson(json['package']), // تحويل بيانات الباقة إلى Package Model
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      agent: json['agent'] != null ? Agent.fromJson(json['agent']) : null,
      bookedByUser: User.fromJson(json['booked_by_user']), // تحويل بيانات المستخدم
      numberOfPeople: json['number_of_people'],
      totalPrice: double.parse(json['total_price'].toString()),
      paidAmount: double.parse(json['paid_amount'].toString()),
      remainingAmount: double.parse(json['remaining_amount'].toString()),
      paymentStatus: json['payment_status'],
      bookingStatus: json['booking_status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}