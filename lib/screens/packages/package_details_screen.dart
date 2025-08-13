// lib/screens/packages/package_details_screen.dart

import 'package:flutter/material.dart';
import 'package:hajj_umrah_mobile_app/models/package.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // استيراد Provider
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:hajj_umrah_mobile_app/utils/constants.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
import 'package:hajj_umrah_mobile_app/screens/payment/payment_screen.dart';
import 'package:go_router/go_router.dart';

class PackageDetailsScreen extends StatefulWidget {
  final Package package;

  const PackageDetailsScreen({super.key, required this.package});

  @override
  State<PackageDetailsScreen> createState() => _PackageDetailsScreenState();
}

class _PackageDetailsScreenState extends State<PackageDetailsScreen> {
  int _numberOfPeople = 1; // عدد الأشخاص الافتراضي
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _bookNow() async {
    if (_numberOfPeople <= 0 || _numberOfPeople > widget.package.availableSeats) {
      setState(() {
        _errorMessage = 'الرجاء إدخال عدد صالح للأشخاص (بين 1 و ${widget.package.availableSeats}).';
      });
      return;
    }

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

    final String apiUrl = '${ApiConstants.baseUrl}/customer/bookings';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authNotifier.token}',
        },
        body: jsonEncode(<String, dynamic>{
          'package_id': widget.package.id,
          'number_of_people': _numberOfPeople,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final int bookingId = responseData['booking']['id'];
        final double remainingAmount = double.parse(responseData['remaining_amount'].toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحجز بنجاح! يتم التوجيه للدفع...')),
        );

        // التوجيه إلى شاشة الدفع
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              bookingId: bookingId,
              amount: remainingAmount,
            ),
          ),
        );

      } else {
        final errorData = jsonDecode(response.body);
        setState(() {
          _errorMessage = errorData['message'] ?? 'فشل إنشاء الحجز.';
        });
        print('Booking failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ في الاتصال: $e';
      });
      print('Error during booking: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.package.name, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.package.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              widget.package.description ?? 'لا يوجد وصف متاح لهذه الباقة.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 30, thickness: 1),

            _buildDetailRow(
              Icons.calendar_today,
              'تاريخ البدء:',
              DateFormat('yyyy-MM-dd').format(widget.package.startDate),
            ),
            _buildDetailRow(
              Icons.calendar_today,
              'تاريخ الانتهاء:',
              DateFormat('yyyy-MM-dd').format(widget.package.endDate),
            ),
            _buildDetailRow(
              Icons.access_time,
              'عدد الأيام:',
              '${widget.package.numberOfDays} أيام',
            ),
            _buildDetailRow(
              Icons.attach_money,
              'السعر للشخص:',
              '${widget.package.pricePerPerson.toStringAsFixed(2)} SR',
              isPrice: true,
            ),
            // if (widget.package.agentPricePerPerson != null)
            //   _buildDetailRow(
            //     Icons.monetization_on,
            //     'السعر للوكيل:',
            //     '${widget.package.agentPricePerPerson!.toStringAsFixed(2)} SR',
            //     isPrice: true,
            //   ),
            _buildDetailRow(
              Icons.event_seat,
              'المقاعد المتاحة:',
              widget.package.availableSeats.toString(),
            ),
            _buildDetailRow(
              Icons.check_circle_outline,
              'الحالة:',
              widget.package.status == 'active' ? 'نشطة' : (widget.package.status == 'full' ? 'ممتلئة' : 'أرشيفية'),
              statusColor: widget.package.status == 'active' ? Colors.green : (widget.package.status == 'full' ? Colors.orange : Colors.grey),
            ),

            const Divider(height: 30, thickness: 1),

            if (widget.package.includes != null && widget.package.includes!.isNotEmpty) ...[
              Text(
                'الخدمات المضمنة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.package.includes!.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const Divider(height: 30, thickness: 1),
            ],

            if (widget.package.excludes != null && widget.package.excludes!.isNotEmpty) ...[
              Text(
                'الخدمات غير المضمنة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.package.excludes!.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cancel, color: Colors.red[700], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          feature,
                          style: const TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
              const Divider(height: 30, thickness: 1),
            ],

            if (widget.package.description != null && widget.package.description!.isNotEmpty) ...[
              Text(
                'ملاحظات الباقة:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
              ),
              const SizedBox(height: 10),
              Text(
                widget.package.description!,
                style: const TextStyle(fontSize: 15),
              ),
            ],
            const SizedBox(height: 30),

            // قسم اختيار عدد الأشخاص وزر الحجز
            if (widget.package.status == 'active' && widget.package.availableSeats > 0) ...[
              Row(
                children: [
                  const Text('عدد الأشخاص: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: DropdownButton<int>(
                      value: _numberOfPeople,
                      onChanged: (int? newValue) {
                        setState(() {
                          _numberOfPeople = newValue!;
                        });
                      },
                      items: List.generate(widget.package.availableSeats, (index) => index + 1)
                          .map<DropdownMenuItem<int>>((int value) {
                        return DropdownMenuItem<int>(
                          value: value,
                          child: Text('$value'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _bookNow,
                icon: _isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.shopping_cart, color: Colors.white),
                label: Text(
                  _isLoading ? 'جاري الحجز...' : 'احجز الآن',
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ] else if (widget.package.status == 'full') ...[
              const Center(
                child: Text(
                  'الباقة ممتلئة حالياً.',
                  style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold),
                ),
              )
            ] else ...[
              const Center(
                child: Text(
                  'الباقة غير متاحة للحجز حالياً.',
                  style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {Color? statusColor, bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: statusColor ?? (isPrice ? Colors.deepOrange : Colors.black54),
                    fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
// lib/screens/packages/package_details_screen.dart

// import 'package:flutter/material.dart';
// import 'package:hajj_umrah_mobile_app/models/package.dart'; // استيراد Package Model
// import 'package:intl/intl.dart'; // لتنسيق التواريخ
// import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart'; // للحصول على التوكن
// import 'package:http/http.dart' as http; // للقيام بطلب API
// import 'dart:convert'; // لتحويل JSON
// import 'package:hajj_umrah_mobile_app/utils/constants.dart'; // لعنوان API
// import 'package:hajj_umrah_mobile_app/screens/payment/payment_screen.dart'; // لشاشة الدفع
// import 'package:go_router/go_router.dart'; // لإعادة التوجيه بعد الحجز
//
// // ... بقية الاستيرادات ...
// class PackageDetailsScreen extends StatelessWidget {
//   final Package package; // الباقة التي سيتم عرض تفاصيلها
//
//   const PackageDetailsScreen({super.key, required this.package});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(package.name, style: const TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // صورة الباقة (إذا كانت متوفرة)
//             // Image.network(package.imageUrl ?? 'https://via.placeholder.com/150', fit: BoxFit.cover),
//             // const SizedBox(height: 16),
//
//             Text(
//               package.name,
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               package.description ?? 'لا يوجد وصف متاح لهذه الباقة.', // التعامل مع الوصف الذي قد يكون null
//               style: const TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const Divider(height: 30, thickness: 1),
//
//             _buildDetailRow(
//               Icons.calendar_today,
//               'تاريخ البدء:',
//               DateFormat('yyyy-MM-dd').format(package.startDate),
//             ),
//             _buildDetailRow(
//               Icons.calendar_today,
//               'تاريخ الانتهاء:',
//               DateFormat('yyyy-MM-dd').format(package.endDate),
//             ),
//             _buildDetailRow(
//               Icons.access_time,
//               'عدد الأيام:',
//               '${package.numberOfDays} أيام', // تم تغيير durationDays إلى numberOfDays
//             ),
//             _buildDetailRow(
//               Icons.attach_money, // أيقونة للسعر
//               'السعر للشخص:',
//               '${package.pricePerPerson.toStringAsFixed(2)} SR', // تم تغيير price إلى pricePerPerson
//               isPrice: true,
//             ),
//             if (package.agentPricePerPerson != null) // عرض سعر الوكيل إذا كان موجوداً
//               _buildDetailRow(
//                 Icons.monetization_on,
//                 'السعر للوكيل:',
//                 '${package.agentPricePerPerson!.toStringAsFixed(2)} SR',
//                 isPrice: true,
//               ),
//             _buildDetailRow(
//               Icons.event_seat, // أيقونة للمقاعد المتاحة
//               'المقاعد المتاحة:',
//               package.availableSeats.toString(), // تم تغيير maxPeople إلى availableSeats
//             ),
//             _buildDetailRow(
//               Icons.check_circle_outline,
//               'الحالة:',
//               package.status == 'active' ? 'نشطة' : (package.status == 'full' ? 'ممتلئة' : 'أرشيفية'),
//               statusColor: package.status == 'active' ? Colors.green : (package.status == 'full' ? Colors.orange : Colors.grey),
//             ),
//
//             const Divider(height: 30, thickness: 1),
//
//             // قسم الخدمات المضمنة (باستخدام includes)
//             if (package.includes != null && package.includes!.isNotEmpty) ...[
//               Text(
//                 'الخدمات المضمنة:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//               ),
//               const SizedBox(height: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: package.includes!.map((feature) => Padding( // تم تغيير services إلى includes
//                   padding: const EdgeInsets.only(bottom: 4.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green[700], size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           feature, // استخدام feature مباشرة
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )).toList(),
//               ),
//               const Divider(height: 30, thickness: 1),
//             ],
//
//             // قسم الخدمات غير المضمنة (باستخدام excludes)
//             if (package.excludes != null && package.excludes!.isNotEmpty) ...[
//               Text(
//                 'الخدمات غير المضمنة:',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//               ),
//               const SizedBox(height: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: package.excludes!.map((feature) => Padding( // تم تغيير services إلى excludes
//                   padding: const EdgeInsets.only(bottom: 4.0),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Icon(Icons.cancel, color: Colors.red[700], size: 20), // أيقونة مختلفة
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           feature, // استخدام feature مباشرة
//                           style: const TextStyle(fontSize: 15),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )).toList(),
//               ),
//               const Divider(height: 30, thickness: 1),
//             ],
//
//             // قسم الملاحظات (إذا كانت موجودة)
//             if (package.description != null && package.description!.isNotEmpty) ...[ // استخدام حقل description بدلاً من notes
//               Text(
//                 'ملاحظات الباقة:', // تسمية ملاحظات الباقة
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[800]),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 package.description!, // استخدام description مباشرة
//                 style: const TextStyle(fontSize: 15),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(IconData icon, String label, String value, {Color? statusColor, bool isPrice = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: Colors.blue[700], size: 24),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   value,
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: statusColor ?? (isPrice ? Colors.deepOrange : Colors.black54),
//                     fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
