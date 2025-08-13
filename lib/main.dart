// lib/main.dart

import 'package:flutter/material.dart';
import 'package:hajj_umrah_mobile_app/screens/bookings/my_bookings_screen.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:hajj_umrah_mobile_app/screens/auth/login_screen.dart';
import 'package:hajj_umrah_mobile_app/screens/auth/register_screen.dart';
import 'package:hajj_umrah_mobile_app/screens/home/home_screen.dart';
import 'package:hajj_umrah_mobile_app/screens/packages/package_list_screen.dart'; // شاشة الباقات الجديدة
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
import 'package:hajj_umrah_mobile_app/providers/package_notifier.dart'; // استيراد PackageNotifier
import 'package:hajj_umrah_mobile_app/providers/booking_notifier.dart';
import 'package:hajj_umrah_mobile_app/screens/profile/customer_profile_screen.dart';
import 'package:hajj_umrah_mobile_app/screens/contact_us/contact_us_screen.dart'; // شاشة تواصل معنا الجديدة
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // هذا الملف سيتم إنشاؤه في الخطوة التالية
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_stripe/flutter_stripe.dart'; // استيراد Stripe
import 'package:hajj_umrah_mobile_app/utils/constants.dart'; // لعنوان API
import 'package:hajj_umrah_mobile_app/screens/payment/payment_screen.dart'; // شاشة الدفع الجديدة

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("Handling a background message: ${message.messageId}");
}
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Stripe.publishableKey = ApiConstants.stripePublishableKey;
  await Stripe.instance.applySettings();
  runApp(
    MultiProvider( // نستخدم MultiProvider لتوفير أكثر من Provider
      providers: [
        ChangeNotifierProvider(create: (context) => AuthNotifier()),
        ChangeNotifierProvider(create: (context) => PackageNotifier()), // توفير PackageNotifier
        ChangeNotifierProvider(create: (context) => BookingNotifier()), // توفير BookingNotifier
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: context.read<AuthNotifier>(),
      redirect: (context, state) {
        final authNotifier = context.read<AuthNotifier>();
        final isAuthenticated = authNotifier.isAuthenticated;

        final bool isLoggingIn = state.uri.path == '/';
        final bool isRegistering = state.uri.path == '/register';

        if (!isAuthenticated && !isLoggingIn && !isRegistering) {
          return '/';
        }
        if (isAuthenticated && (isLoggingIn || isRegistering)) {
          return '/home';
        }
        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'packages', // مسار فرعي لـ /home/packages
              builder: (context, state) => const PackageListScreen(),
            ),
            GoRoute(
              path: 'my-bookings', // مسار حجوزاتي
              builder: (context, state) => const MyBookingsScreen(),
            ),
            GoRoute(
              path: 'profile', // مسار الملف الشخصي
              builder: (context, state) => const CustomerProfileScreen(),
            ),
            GoRoute(
              path: 'contact-us', // مسار تواصل معنا
              builder: (context, state) => const ContactUsScreen(),
            ),
            // يمكن إضافة مسارات فرعية أخرى هنا للحجوزات، الملف الشخصي، إلخ
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'وكالة الحج والعمرة',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Cairo',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Cairo'),
          bodyMedium: TextStyle(fontFamily: 'Cairo'),
          titleLarge: TextStyle(fontFamily: 'Cairo'),
        ),
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      locale: const Locale('ar', ''),
      routerConfig: _router,
    );
  }
}
// // lib/main.dart
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:go_router/go_router.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
//
// import 'package:hajj_umrah_mobile_app/screens/auth/login_screen.dart';
// import 'package:hajj_umrah_mobile_app/screens/auth/register_screen.dart';
// import 'package:hajj_umrah_mobile_app/screens/home/home_screen.dart';
// import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart'; // استيراد AuthNotifier
//
// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (context) => AuthNotifier(), // توفير AuthNotifier لكل التطبيق
//       child: const MyApp(),
//     ),
//   );
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   late final GoRouter _router;
//
//   @override
//   void initState() {
//     super.initState();
//     // تهيئة GoRouter هنا
//     _router = GoRouter(
//       initialLocation: '/',
//       refreshListenable: context.read<AuthNotifier>(), // GoRouter سيستمع إلى التغييرات في AuthNotifier
//       redirect: (context, state) {
//         final authNotifier = context.read<AuthNotifier>();
//         final isAuthenticated = authNotifier.isAuthenticated;
//
//         // مسارات المصادقة (تسجيل الدخول والتسجيل)
//         final bool isLoggingIn = state.uri.path == '/';
//         final bool isRegistering = state.uri.path == '/register';
//
//         // إذا كان المستخدم غير مصادق ويحاول الوصول إلى مسار محمي، أعد توجيهه لصفحة تسجيل الدخول
//         if (!isAuthenticated && !isLoggingIn && !isRegistering) {
//           return '/';
//         }
//         // إذا كان المستخدم مصادقًا ويحاول الوصول إلى صفحة تسجيل الدخول أو التسجيل، أعد توجيهه للصفحة الرئيسية
//         if (isAuthenticated && (isLoggingIn || isRegistering)) {
//           return '/home';
//         }
//         // لا يوجد إعادة توجيه
//         return null;
//       },
//       routes: [
//         GoRoute(
//           path: '/',
//           builder: (context, state) => const LoginScreen(),
//         ),
//         GoRoute(
//           path: '/register',
//           builder: (context, state) => const RegisterScreen(),
//         ),
//         GoRoute(
//           path: '/home',
//           builder: (context, state) => const HomeScreen(),
//         ),
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp.router(
//       title: 'وكالة الحج والعمرة',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Cairo', // يمكن إضافة خط عربي هنا
//         textTheme: const TextTheme(
//           bodyLarge: TextStyle(fontFamily: 'Cairo'),
//           bodyMedium: TextStyle(fontFamily: 'Cairo'),
//           titleLarge: TextStyle(fontFamily: 'Cairo'),
//         ),
//       ),
//       debugShowCheckedModeBanner: false,
//       // إعدادات الـ localization
//       localizationsDelegates: const [
//         GlobalMaterialLocalizations.delegate,
//         GlobalWidgetsLocalizations.delegate,
//         GlobalCupertinoLocalizations.delegate,
//       ],
//       supportedLocales: const [
//         Locale('ar', ''),
//         Locale('en', ''),
//       ],
//       locale: const Locale('ar', ''), // تعيين اللغة الافتراضية للعربية
//       routerConfig: _router, // استخدام GoRouter
//     );
//   }
// }
