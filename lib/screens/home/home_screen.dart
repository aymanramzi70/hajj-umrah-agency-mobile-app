// lib/screens/home/home_screen.dart
// lib/screens/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
import 'package:hajj_umrah_mobile_app/screens/profile/customer_profile_screen.dart'; // استيراد شاشة الملف الشخصي
import 'package:hajj_umrah_mobile_app/screens/contact_us/contact_us_screen.dart'; // استيراد شاشة تواصل معنا


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الرئيسية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              final String? error = await authNotifier.logout();
              if (error == null) {
                // GoRouter will redirect automatically
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(error)),
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'مرحباً بك، ${authNotifier.userName ?? 'عميلنا العزيز'}!',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                authNotifier.userEmail ?? '',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // زر لعرض باقات الحج والعمرة
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home/packages');
                },
                icon: const Icon(Icons.card_travel, size: 28),
                label: const Text('عرض باقات الحج والعمرة', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // زر لعرض حجوزاتي
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home/my-bookings');
                },
                icon: const Icon(Icons.airplane_ticket, size: 28),
                label: const Text('عرض حجوزاتي', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.blueGrey,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 20),
              // زر لعرض الملف الشخصي
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home/profile'); // التنقل إلى مسار الملف الشخصي
                },
                icon: const Icon(Icons.person, size: 28),
                label: const Text('ملفي الشخصي', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.deepPurple, // لون مميز
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  context.go('/home/contact-us'); // التنقل إلى مسار تواصل معنا
                },
                icon: const Icon(Icons.support_agent, size: 28),
                label: const Text('تواصل معنا', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60),
                  backgroundColor: Colors.orange, // لون مميز
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
// import 'package:hajj_umrah_mobile_app/screens/packages/package_list_screen.dart'; // استيراد شاشة الباقات
//
//
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final authNotifier = context.watch<AuthNotifier>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('الرئيسية', style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.blue,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () async {
//               final String? error = await authNotifier.logout();
//               if (error == null) {
//                 // GoRouter will redirect automatically
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text(error)),
//                 );
//               }
//             },
//           ),
//         ],
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'مرحباً بك، ${authNotifier.userName ?? 'عميلنا العزيز'}!',
//                 style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//                 textAlign: TextAlign.center,
//               ),
//               Text(
//                 authNotifier.userEmail ?? '',
//                 style: const TextStyle(fontSize: 16, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 40),
//               // زر لعرض الباقات
//               ElevatedButton.icon(
//                 onPressed: () {
//                   context.go('/home/packages'); // التنقل إلى مسار الباقات
//                 },
//                 icon: const Icon(Icons.card_travel, size: 28),
//                 label: const Text('عرض باقات الحج والعمرة', style: TextStyle(fontSize: 18)),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 60), // زر أكبر
//                   backgroundColor: Colors.green, // لون مختلف
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               // زر لعرض حجوزاتي (سيتم تفعيله لاحقًا)
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // TODO: Navigate to My Bookings Screen
//                   print('My Bookings Pressed');
//                   context.go('/home/my-bookings'); // التنقل إلى مسار حجوزاتي
//                 },
//                 icon: const Icon(Icons.airplane_ticket, size: 28),
//                 label: const Text('عرض حجوزاتي', style: TextStyle(fontSize: 18)),
//                 style: ElevatedButton.styleFrom(
//                   minimumSize: const Size(double.infinity, 60),
//                   backgroundColor: Colors.blueGrey,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                   padding: const EdgeInsets.symmetric(vertical: 15),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
