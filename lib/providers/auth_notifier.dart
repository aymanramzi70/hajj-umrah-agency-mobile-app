// lib/providers/auth_notifier.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hajj_umrah_mobile_app/utils/constants.dart';
import 'package:go_router/go_router.dart';
import 'package:hajj_umrah_mobile_app/models/customer.dart'; // استيراد Customer Model
import 'package:firebase_messaging/firebase_messaging.dart'; // إضافة Firebase Messaging
import 'package:flutter_local_notifications/flutter_local_notifications.dart'; // للإشعارات المحلية (سنستخدمها لاحقًا)


class AuthNotifier extends ChangeNotifier {


// ... (داخل كلاس AuthNotifier) ...

// تهيئة Flutter Local Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// دالة لتهيئة الإشعارات الفورية
  Future<void> initializePushNotifications() async {
    // طلب إذن الإشعارات من المستخدم
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('User granted permission: ${settings.authorizationStatus}');

    // تهيئة الإشعارات المحلية (لعرض الإشعارات عندما يكون التطبيق في المقدمة)
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // أيقونة التطبيق
    final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
      onDidReceiveLocalNotification: (id, title, body, payload) async {
        // Handle notification when app is in foreground on iOS
      },
    );
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap
        print('Notification tapped: ${response.payload}');
      },
    );


    // الحصول على رمز الجهاز
    String? token = await FirebaseMessaging.instance.getToken();
    print("Firebase Messaging Token: $token");

    if (token != null && isAuthenticated) {
      // إرسال الرمز إلى الـ API في Laravel
      await sendDeviceTokenToLaravel(token);
    }

    // الاستماع للإشعارات عندما يكون التطبيق في المقدمة
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        // عرض الإشعار باستخدام flutter_local_notifications
        flutterLocalNotificationsPlugin.show(
          message.notification.hashCode,
          message.notification!.title,
          message.notification!.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'hajj_umrah_channel', // يجب أن يكون نفس معرف القناة في Laravel
              'Hajj Umrah Notifications',
              channelDescription: 'قناة الإشعارات الخاصة بتطبيق الحج والعمرة',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: false,
            ),
          ),
          payload: message.data['payload'], // يمكنك تمرير بيانات إضافية
        );
      }
    });

    // الاستماع للإشعارات عندما يتم النقر عليها من الخلفية/الإنهاء
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      // يمكنك هنا توجيه المستخدم إلى شاشة معينة بناءً على بيانات الإشعار
      // GoRouter.of(context).go('/some-route');
    });

    // معالجة الإشعارات عندما يكون التطبيق مغلقًا تمامًا (Background messages)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

// دالة لمعالجة الإشعارات في الخلفية (يجب أن تكون دالة على مستوى أعلى)
  @pragma('vm:entry-point')
  Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(); // تأكد من تهيئة Firebase في الخلفية
    print("Handling a background message: ${message.messageId}");
    // يمكنك هنا معالجة البيانات أو حفظها محليًا
  }

// دالة لإرسال رمز الجهاز إلى الـ API في Laravel
  Future<String?> sendDeviceTokenToLaravel(String token) async {
    if (_token == null) return 'لم يتم المصادقة. لا يمكن إرسال رمز الجهاز.';

    final String apiUrl = '${ApiConstants.baseUrl}/user/save-device-token'; // مسار جديد في Laravel
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(<String, String>{
          'device_token': token,
        }),
      );

      if (response.statusCode == 200) {
        print('Device token sent to Laravel successfully.');
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        print('Failed to send device token: ${errorData['message']}');
        return errorData['message'] ?? 'فشل إرسال رمز الجهاز إلى الخادم.';
      }
    } catch (e) {
      print('Error sending device token: $e');
      return 'حدث خطأ في الاتصال لإرسال رمز الجهاز: $e';
    }
  }
  String? _token;
  String? _userName;
  String? _userEmail;
  Customer? _customerProfile; // إضافة ملف تعريف العميل

  bool get isAuthenticated => _token != null;
  String? get token => _token;
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  Customer? get customerProfile => _customerProfile; // getter لملف العميل

  AuthNotifier() {
    _loadTokenAndProfile(); // تحديث التحميل ليشمل الملف الشخصي
  }

  Future<void> _loadTokenAndProfile() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _customerProfile = null;
    // يمكن تحميل الملف الشخصي هنا أيضاً إذا تم تخزينه
    // For now, we will fetch it separately when needed in the profile screen
    // notifyListeners();
    if (_token != null) {
      await fetchCustomerProfile(); // Fetch profile if already authenticated
      // استدعاء تهيئة الإشعارات هنا إذا كان المستخدم مسجل الدخول
      await initializePushNotifications();
    }
    notifyListeners();
  }

  // ... (دالة login تبقى كما هي) ...
  Future<String?> login(String email, String password) async {
    final String apiUrl = '${ApiConstants.baseUrl}/login';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'device_name': 'mobile_app_flutter',
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _userName = responseData['user']['name'];
        _userEmail = responseData['user']['email'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);

        // بمجرد تسجيل الدخول، قم بجلب الملف الشخصي للعميل
        await fetchCustomerProfile(); // استدعاء لجلب الملف الشخصي بعد تسجيل الدخول
        await initializePushNotifications();
        notifyListeners();
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.';
      }
    } catch (e) {
      return 'حدث خطأ في الاتصال: $e';
    }
  }

  // ... (دالة register تبقى كما هي، مع تحديث لاستدعاء fetchCustomerProfile) ...
  Future<String?> register(String name, String email, String password, String passwordConfirmation, String phoneNumber, String firstName, String lastName) async {
    final String apiUrl = '${ApiConstants.baseUrl}/register';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'phone_number': phoneNumber,
          'first_name': firstName,
          'last_name': lastName,
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _token = responseData['token'];
        _userName = responseData['user']['name'];
        _userEmail = responseData['user']['email'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        await prefs.setString('user_name', _userName!);
        await prefs.setString('user_email', _userEmail!);

        // بعد التسجيل بنجاح، قم بجلب الملف الشخصي للعميل
        await fetchCustomerProfile(); // استدعاء لجلب الملف الشخصي بعد التسجيل
        await initializePushNotifications();
        notifyListeners();
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        if (errorData['errors'] != null) {
          String errors = '';
          errorData['errors'].forEach((key, value) {
            errors += '${value[0]}\n';
          });
          return errors.trim();
        }
        return errorData['message'] ?? 'فشل إنشاء الحساب.';
      }
    } catch (e) {
      return 'حدث خطأ في الاتصال: $e';
    }
  }

  // ... (دالة logout) ...
  Future<String?> logout() async {
    if (_token == null) return null;

    final String apiUrl = '${ApiConstants.baseUrl}/logout';
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('auth_token');
        await prefs.remove('user_name');
        await prefs.remove('user_email');
        _token = null;
        _userName = null;
        _userEmail = null;
        _customerProfile = null; // مسح بيانات الملف الشخصي عند تسجيل الخروج
        notifyListeners();
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'فشل تسجيل الخروج.';
      }
    } catch (e) {
      return 'حدث خطأ في الاتصال: $e';
    }
  }


  // دالة جديدة لجلب الملف الشخصي للعميل
  Future<String?> fetchCustomerProfile() async {
    if (_token == null) return 'لم يتم المصادقة. لا يمكن جلب الملف الشخصي.';

    final String apiUrl = '${ApiConstants.baseUrl}/user/customer-profile';
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _customerProfile = Customer.fromJson(responseData['customer']);
        notifyListeners(); // إعلام المستمعين بتحديث الملف الشخصي
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        return errorData['message'] ?? 'فشل جلب الملف الشخصي للعميل.';
      }
    } catch (e) {
      return 'حدث خطأ في الاتصال لجلب الملف الشخصي: $e';
    }
  }

  // دالة جديدة لتحديث الملف الشخصي للعميل
  Future<String?> updateCustomerProfile(Map<String, dynamic> customerData) async {
    if (_token == null) return 'لم يتم المصادقة. لا يمكن تحديث الملف الشخصي.';

    final String apiUrl = '${ApiConstants.baseUrl}/user/customer-profile';
    try {
      final response = await http.put( // استخدام PUT للتحديث
        Uri.parse(apiUrl),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode(customerData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        _customerProfile = Customer.fromJson(responseData['customer']); // تحديث الملف الشخصي بعد التحديث
        notifyListeners();
        return null;
      } else {
        final errorData = jsonDecode(response.body);
        if (errorData['errors'] != null) {
          String errors = '';
          errorData['errors'].forEach((key, value) {
            errors += '${value[0]}\n';
          });
          return errors.trim();
        }
        return errorData['message'] ?? 'فشل تحديث الملف الشخصي للعميل.';
      }
    } catch (e) {
      return 'حدث خطأ في الاتصال لتحديث الملف الشخصي: $e';
    }
  }
}
// lib/providers/auth_notifier.dart

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:hajj_umrah_mobile_app/utils/constants.dart';
// import 'package:go_router/go_router.dart'; // لاستخدامه في إعادة التوجيه
// import 'package:hajj_umrah_mobile_app/models/customer.dart';
// class AuthNotifier extends ChangeNotifier {
//   String? _token;
//   String? _userName;
//   String? _userEmail;
//   Customer? _customerProfile;
//
//   bool get isAuthenticated => _token != null;
//   String? get token => _token;
//   String? get userName => _userName;
//   String? get userEmail => _userEmail;
//   Customer? get customerProfile => _customerProfile;
//
//   // تهيئة: تحميل التوكن من الذاكرة المحلية عند بدء التطبيق
//   AuthNotifier() {
//     _loadTokenAndProfile();
//   }
//
//   Future<void> _loadTokenAndProfile() async {
//     final prefs = await SharedPreferences.getInstance();
//     _token = prefs.getString('auth_token');
//     _userName = prefs.getString('user_name');
//     _userEmail = prefs.getString('user_email');
//     notifyListeners(); // إعلام المستمعين بحالة المصادقة الأولية
//   }
//
//   Future<String?> login(String email, String password) async {
//     final String apiUrl = '${ApiConstants.baseUrl}/login';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(<String, String>{
//           'email': email,
//           'password': password,
//           'device_name': 'mobile_app_flutter',
//         }),
//       );
//
//       if (response.statusCode == 200) {
//         final responseData = jsonDecode(response.body);
//         _token = responseData['token'];
//         _userName = responseData['user']['name'];
//         _userEmail = responseData['user']['email'];
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('auth_token', _token!);
//         await prefs.setString('user_name', _userName!);
//         await prefs.setString('user_email', _userEmail!);
//
//         notifyListeners(); // إعلام المستمعين بنجاح تسجيل الدخول
//         return null; // لا يوجد خطأ
//       } else {
//         final errorData = jsonDecode(response.body);
//         return errorData['message'] ?? 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.';
//       }
//     } catch (e) {
//       return 'حدث خطأ في الاتصال: $e';
//     }
//   }
//
//   Future<String?> logout() async {
//     if (_token == null) return null; // Already logged out
//
//     final String apiUrl = '${ApiConstants.baseUrl}/logout';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//           'Authorization': 'Bearer $_token', // إرسال التوكن لـ API Logout
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.remove('auth_token');
//         await prefs.remove('user_name');
//         await prefs.remove('user_email');
//         _token = null;
//         _userName = null;
//         _userEmail = null;
//         notifyListeners(); // إعلام المستمعين بتسجيل الخروج
//         return null;
//       } else {
//         final errorData = jsonDecode(response.body);
//         return errorData['message'] ?? 'فشل تسجيل الخروج.';
//       }
//     } catch (e) {
//       return 'حدث خطأ في الاتصال: $e';
//     }
//   }
//
//   // TODO: Add register method here later once Laravel API is ready
//   // Future<String?> register(String name, String email, String password, String confirmPassword) async {
//   //   // Placeholder for future registration logic
//   //   await Future.delayed(const Duration(seconds: 1)); // Simulate API call
//   //   if (email == 'existing@example.com') {
//   //     return 'هذا البريد الإلكتروني مسجل بالفعل.';
//   //   }
//   //   // If registration is successful, you might want to automatically log them in
//   //   // or redirect to login. For now, it just simulates.
//   //   return null; // No error
//   // }
// // ... (داخل كلاس AuthNotifier) ...
//
//   Future<String?> register(String name, String email, String password, String passwordConfirmation, String phoneNumber, String firstName, String lastName) async {
//     final String apiUrl = '${ApiConstants.baseUrl}/register';
//     try {
//       final response = await http.post(
//         Uri.parse(apiUrl),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Accept': 'application/json',
//         },
//         body: jsonEncode(<String, String>{
//           'name': name,
//           'email': email,
//           'password': password,
//           'password_confirmation': passwordConfirmation, // يجب أن يتطابق مع 'confirmed' في Laravel
//           'phone_number': phoneNumber,
//           'first_name': firstName,
//           'last_name': lastName,
//         }),
//       );
//
//       if (response.statusCode == 201) { // 201 Created
//         final responseData = jsonDecode(response.body);
//         _token = responseData['token'];
//         _userName = responseData['user']['name'];
//         _userEmail = responseData['user']['email'];
//
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setString('auth_token', _token!);
//         await prefs.setString('user_name', _userName!);
//         await prefs.setString('user_email', _userEmail!);
//
//         notifyListeners(); // إعلام المستمعين بنجاح التسجيل وتسجيل الدخول
//         return null; // لا يوجد خطأ
//       } else {
//         final errorData = jsonDecode(response.body);
//         // التعامل مع أخطاء التحقق من صحة البيانات من Laravel
//         if (errorData['errors'] != null) {
//           String errors = '';
//           errorData['errors'].forEach((key, value) {
//             errors += '${value[0]}\n'; // عرض أول خطأ لكل حقل
//           });
//           return errors.trim();
//         }
//         return errorData['message'] ?? 'فشل إنشاء الحساب.';
//       }
//     } catch (e) {
//       return 'حدث خطأ في الاتصال: $e';
//     }
//   }
// // ... (بقية الكلاس) ...
// }