// lib/screens/bookings/my_bookings_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hajj_umrah_mobile_app/providers/booking_notifier.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
import 'package:hajj_umrah_mobile_app/models/booking.dart';
import 'package:intl/intl.dart'; // لإدارة تنسيق التواريخ
import 'package:hajj_umrah_mobile_app/screens/payment/payment_screen.dart'; // استيراد شاشة الدفع

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  @override
  void initState() {
    super.initState();

    // جلب حجوزات العميل عند تهيئة الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = context.read<AuthNotifier>();
      context.read<BookingNotifier>().fetchMyBookings(authNotifier.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookingNotifier = context.watch<BookingNotifier>(); // للاستماع إلى تغييرات الحجوزات

    return Scaffold(
      appBar: AppBar(
        title: const Text('حجوزاتي', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: bookingNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : bookingNotifier.errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                bookingNotifier.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final authNotifier = context.read<AuthNotifier>();
                  bookingNotifier.fetchMyBookings(authNotifier.token);
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      )
          : bookingNotifier.bookings.isEmpty
          ? const Center(
        child: Text(
          'لم تقم بأي حجوزات بعد.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: bookingNotifier.bookings.length,
        itemBuilder: (context, index) {
          final booking = bookingNotifier.bookings[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'كود الحجز: ${booking.bookingCode}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'الباقة: ${booking.package.name}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    'عدد الأشخاص: ${booking.numberOfPeople}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const Divider(height: 20, thickness: 1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip('حالة الحجز', booking.bookingStatus),
                      _buildStatusChip('حالة الدفع', booking.paymentStatus),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('المبلغ الكلي: ${booking.totalPrice.toStringAsFixed(2)} SR'),
                      Text('المدفوع: ${booking.paidAmount.toStringAsFixed(2)} SR'),
                      Text('المتبقي: ${booking.remainingAmount.toStringAsFixed(2)} SR'),
                    ],
                  ),
                  // زر الدفع يظهر فقط إذا كان هناك مبلغ متبقي
                  if (booking.remainingAmount > 0) ...[
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push( // استخدام Navigator.push للانتقال مع تمرير البيانات
                          context,
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              bookingId: booking.id,
                              amount: booking.remainingAmount,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.credit_card, color: Colors.white),
                      label: const Text('ادفع الآن', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent, // لون الزر
                        minimumSize: const Size(double.infinity, 45),
                      ),
                    ),
                  ],

                  if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                    const SizedBox(height: 10.0),
                    Text('ملاحظات: ${booking.notes!}'),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'تاريخ الحجز: ${DateFormat('yyyy-MM-dd').format(booking.createdAt)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    Color color;
    String text;
    switch (status) {
      case 'pending':
        color = Colors.blue.shade100;
        text = 'قيد الانتظار';
        break;
      case 'confirmed':
        color = Colors.green.shade100;
        text = 'مؤكد';
        break;
      case 'canceled':
        color = Colors.red.shade100;
        text = 'ملغي';
        break;
      case 'completed':
        color = Colors.purple.shade100;
        text = 'مكتمل';
        break;
      case 'partial':
        color = Colors.orange.shade100;
        text = 'مدفوع جزئياً';
        break;
      case 'paid':
        color = Colors.green.shade100;
        text = 'مدفوع';
        break;
      case 'refunded':
        color = Colors.red.shade100;
        text = 'مسترد';
        break;
      default:
        color = Colors.grey.shade100;
        text = status;
    }
    return Chip(
      label: Text('$label: $text', style: TextStyle(color: Colors.grey.shade800)),
      backgroundColor: color,
    );
  }
}