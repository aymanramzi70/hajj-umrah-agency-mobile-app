// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // استيراد Provider
import 'package:go_router/go_router.dart'; // لاستخدام GoRouter
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart'; // استيراد AuthNotifier
// HomeScreen لم تعد مستوردة مباشرة لأن GoRouter يتعامل معها

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authNotifier = context.read<AuthNotifier>();
      final String? error = await authNotifier.login(
        _emailController.text,
        _passwordController.text,
      );

      if (error == null) {
        // Login successful, GoRouter will handle navigation
        // context.go('/home'); // GoRouter will redirect automatically via redirect in main.dart
      } else {
        setState(() {
          _errorMessage = error;
        });
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول', style: TextStyle(color: Colors.white)), backgroundColor: Colors.blue),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/logo.png',
                  height: 150,
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'الرجاء إدخال بريد إلكتروني صالح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال كلمة المرور';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    context.go('/register'); // استخدام GoRouter للتنقل
                  },
                  child: const Text('ليس لديك حساب؟ سجل الآن', style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// // lib/screens/auth/login_screen.dart
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:hajj_umrah_mobile_app/utils/constants.dart'; // تأكد من المسار الصحيح
// import 'package:hajj_umrah_mobile_app/screens/home/home_screen.dart'; // سننشئ هذه الشاشة لاحقًا
// import 'package:hajj_umrah_mobile_app/screens/auth/register_screen.dart'; // شاشة التسجيل
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   bool _isLoading = false;
//   String? _errorMessage;
//
//   Future<void> _login() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = null;
//       });
//
//       final String apiUrl = '${ApiConstants.baseUrl}/login';
//       try {
//         final response = await http.post(
//           Uri.parse(apiUrl),
//           headers: <String, String>{
//             'Content-Type': 'application/json; charset=UTF-8',
//             'Accept': 'application/json', // Laravel expects this
//           },
//           body: jsonEncode(<String, String>{
//             'email': _emailController.text,
//             'password': _passwordController.text,
//             'device_name': 'mobile_app_flutter', // اسم الجهاز
//           }),
//         );
//
//         if (response.statusCode == 200) {
//           final responseData = jsonDecode(response.body);
//           // Handle successful login: save token, navigate to home
//           print('Login successful: ${responseData['token']}');
//           // TODO: Save token securely (e.g., using shared_preferences or flutter_secure_storage)
//           // For now, just navigate
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const HomeScreen()),
//           );
//         } else {
//           final errorData = jsonDecode(response.body);
//           setState(() {
//             _errorMessage = errorData['message'] ?? 'فشل تسجيل الدخول. يرجى التحقق من بياناتك.';
//           });
//           print('Login failed: ${response.statusCode} - ${response.body}');
//         }
//       } catch (e) {
//         setState(() {
//           _errorMessage = 'حدث خطأ في الاتصال: $e';
//         });
//         print('Error during login: $e');
//       } finally {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('تسجيل الدخول')),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: <Widget>[
//                 Image.asset(
//                   'assets/logo.png', // تأكد من إضافة شعار في مجلد assets
//                   height: 150,
//                 ),
//                 const SizedBox(height: 30),
//                 TextFormField(
//                   controller: _emailController,
//                   decoration: const InputDecoration(
//                     labelText: 'البريد الإلكتروني',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.email),
//                   ),
//                   keyboardType: TextInputType.emailAddress,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال البريد الإلكتروني';
//                     }
//                     if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                       return 'الرجاء إدخال بريد إلكتروني صالح';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 15),
//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: true,
//                   decoration: const InputDecoration(
//                     labelText: 'كلمة المرور',
//                     border: OutlineInputBorder(),
//                     prefixIcon: Icon(Icons.lock),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'الرجاء إدخال كلمة المرور';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 if (_errorMessage != null)
//                   Text(
//                     _errorMessage!,
//                     style: const TextStyle(color: Colors.red, fontSize: 14),
//                     textAlign: TextAlign.center,
//                   ),
//                 const SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: _isLoading ? null : _login,
//                   style: ElevatedButton.styleFrom(
//                     minimumSize: const Size(double.infinity, 50), // زر بعرض كامل
//                     backgroundColor: Colors.blue, // لون الزر
//                     foregroundColor: Colors.white, // لون النص
//                   ),
//                   child: _isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text('تسجيل الدخول', style: TextStyle(fontSize: 18)),
//                 ),
//                 const SizedBox(height: 10),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const RegisterScreen()),
//                     );
//                   },
//                   child: const Text('ليس لديك حساب؟ سجل الآن', style: TextStyle(fontSize: 16)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }