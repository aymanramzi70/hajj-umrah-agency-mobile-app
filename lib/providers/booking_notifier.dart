// lib/providers/booking_notifier.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajj_umrah_mobile_app/utils/constants.dart';
import 'package:hajj_umrah_mobile_app/models/booking.dart'; // استيراد Booking Model

class BookingNotifier extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyBookings(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (token == null) {
      _errorMessage = 'لم يتم المصادقة. يرجى تسجيل الدخول.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final String apiUrl = '${ApiConstants.baseUrl}/my-bookings'; // المسار الجديد
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> bookingsJson = responseData['bookings'];
        _bookings = bookingsJson.map((json) => Booking.fromJson(json)).toList();
      } else if (response.statusCode == 404) {
        _errorMessage = jsonDecode(response.body)['message'] ?? 'لا توجد حجوزات لهذا العميل.';
        _bookings = []; // تأكد من تفريغ القائمة إذا لم يتم العثور على حجوزات
      }
      else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'فشل جلب الحجوزات.';
        print('Failed to load bookings: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال: $e';
      print('Error fetching bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}