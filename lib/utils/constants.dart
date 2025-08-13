// lib/utils/constants.dart

class ApiConstants {
  // تأكد أن هذا العنوان هو عنوان خادم Laravel الخاص بك
  // إذا كنت تستخدم المحاكي، تأكد من استخدام عنوان IP الخاص بالجهاز المضيف (Host PC) أو 10.0.2.2 لـ Android Emulator
  // مثال: إذا كان Laravel يعمل على http://127.0.0.1:8000
  // static const String baseUrl = 'http://10.0.2.2:8000/api'; // لـ Android Emulator
  static const String baseUrl = 'http://192.168.8.27:8000/api';
  // static const String baseUrl = 'http://localhost:8000/api'; // لـ iOS Simulator أو الويب
  static const String stripePublishableKey = 'pk_test_51RqgWA9Ve2T1Kpu6fpEpS2MOc8maeRTDKJuVzEMD3IWYaSErQ4q9Hl3xtJA59EyAZmPGsJJGFNSeIcacF1ac2zPg004i7Y5JcC';
}