// lib/screens/payment/payment_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajj_umrah_mobile_app/utils/constants.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart'; // للحصول على التوكن
import 'package:go_router/go_router.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final double amount; // المبلغ المستحق للدفع

  const PaymentScreen({super.key, required this.bookingId, required this.amount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String? _clientSecret;
  String? _paymentIntentId;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _createPaymentIntent();
  }

  Future<void> _createPaymentIntent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.token == null) {
      setState(() {
        _errorMessage = 'لم يتم المصادقة. يرجى تسجيل الدخول.';
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = '${ApiConstants.baseUrl}/payments/create-intent';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authNotifier.token}',
        },
        body: jsonEncode(<String, dynamic>{
          'booking_id': widget.bookingId,
          'amount': widget.amount,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _clientSecret = responseData['clientSecret'];
        _paymentIntentId = responseData['paymentIntentId'];
        print('Payment Intent Created: $_paymentIntentId');
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'فشل إنشاء نية الدفع.';
        print('Failed to create payment intent: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      _errorMessage = 'حدث خطأ في الاتصال: $e';
      print('Error creating payment intent: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initiatePayment() async {
    if (_clientSecret == null) {
      setState(() => _errorMessage = 'خطأ: لم يتم إنشاء نية الدفع.');
      return;
    }

    try {
      // تهيئة شاشة الدفع
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: _clientSecret!,
          merchantDisplayName: 'وكالة الحج والعمرة', // اسم وكالتك
          // currencyCode: 'USD', // يجب أن يتطابق مع العملة في Backend
          allowsDelayedPaymentMethods: true,
        ),
      );

      // عرض شاشة الدفع
      await Stripe.instance.presentPaymentSheet();

      // إذا تم الدفع بنجاح، أرسل تأكيدًا إلى الخادم
      await _confirmPaymentOnServer();

    } on StripeException catch (e) {
      setState(() {
        if (e.error.code == FailureCode.Canceled) {
          _errorMessage = 'تم إلغاء عملية الدفع.';
        } else {
          _errorMessage = 'حدث خطأ أثناء عملية الدفع: ${e.error.message}';
        }
      });
      print('Stripe Error: ${e.error.message}');
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ غير متوقع: $e');
      print('General payment error: $e');
    }
  }

  Future<void> _confirmPaymentOnServer() async {
    setState(() => _isLoading = true);

    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.token == null) {
      setState(() {
        _errorMessage = 'لم يتم المصادقة. لا يمكن تأكيد الدفع.';
        _isLoading = false;
      });
      return;
    }

    final String apiUrl = '${ApiConstants.baseUrl}/payments/confirm';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authNotifier.token}',
        },
        body: jsonEncode(<String, dynamic>{
          'payment_intent_id': _paymentIntentId!,
          'booking_id': widget.bookingId,
          'amount': widget.amount, // المبلغ الذي تم دفعه
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم الدفع بنجاح وتحديث الحجز!')),
        );
        // العودة إلى شاشة حجوزاتي بعد الدفع الناجح
        context.pop();
      } else {
        final errorData = jsonDecode(response.body);
        setState(() => _errorMessage = errorData['message'] ?? 'فشل تأكيد الدفع على الخادم.');
        print('Failed to confirm payment on server: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'حدث خطأ في الاتصال لتأكيد الدفع: $e');
      print('Error confirming payment on server: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الدفع', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'المبلغ المستحق للدفع: ${widget.amount.toStringAsFixed(2)} SR',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : _clientSecret != null
                  ? ElevatedButton.icon(
                onPressed: _initiatePayment,
                icon: const Icon(Icons.payment, color: Colors.white),
                label: const Text('ادفع الآن', style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              )
                  : ElevatedButton.icon(
                onPressed: _createPaymentIntent,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text('إعادة محاولة الدفع', style: TextStyle(fontSize: 20, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}