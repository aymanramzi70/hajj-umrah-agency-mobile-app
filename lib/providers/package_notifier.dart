// lib/providers/package_notifier.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajj_umrah_mobile_app/utils/constants.dart';
import 'package:hajj_umrah_mobile_app/models/package.dart'; // استيراد Package Model

class PackageNotifier extends ChangeNotifier {
  List<Package> _packages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Package> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPackages(String? token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (token == null) {
      _errorMessage = 'لم يتم المصادقة. يرجى تسجيل الدخول.';
      _isLoading = false;
      notifyListeners();
      return;
    }

    final String apiUrl = '${ApiConstants.baseUrl}/packages';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // إرسال توكن المصادقة
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // البيانات الفعلية للباقات هي داخل مفتاح 'packages'
        final List<dynamic> packagesJson = responseData['packages'];
        _packages = packagesJson.map((json) => Package.fromJson(json)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'فشل جلب الباقات.';
        print('Failed to load packages: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال: $e';
      print('Error fetching packages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}