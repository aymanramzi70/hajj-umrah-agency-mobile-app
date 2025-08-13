// lib/screens/contact_us/contact_us_screen.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // لاستخدام الروابط الخارجية

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  // دالة مساعدة لفتح الروابط
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'لا يمكن فتح الرابط $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تواصل معنا', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // شعار الوكالة أو صورة رمزية
            Image.asset(
              'assets/logo.png', // تأكد من وجود شعار في مجلد assets
              height: 120,
            ),
            const SizedBox(height: 20),
            const Text(
              'نحن هنا لخدمتك! لا تتردد في التواصل معنا لأي استفسارات أو مساعدة.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // معلومات الاتصال
            _buildContactCard(
              icon: Icons.phone,
              title: 'اتصل بنا',
              subtitle: '+967 770 123 456', // استبدل برقم هاتفك الحقيقي
              onTap: () => _launchURL('tel:+967770123456'),
            ),
            _buildContactCard(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              subtitle: 'info@youragency.com', // استبدل ببريدك الإلكتروني الحقيقي
              onTap: () => _launchURL('mailto:info@youragency.com?subject=استفسار من تطبيق الحج والعمرة'),
            ),
            _buildContactCard(
              icon: Icons.language,
              title: 'الموقع الإلكتروني',
              subtitle: 'www.youragency.com', // استبدل بموقعك الإلكتروني الحقيقي
              onTap: () => _launchURL('https://www.youragency.com'),
            ),
            _buildContactCard(
              icon: Icons.location_on,
              title: 'عنوان المكتب',
              subtitle: 'صنعاء، شارع الزبيري، مبنى رقم 123', // استبدل بعنوان مكتبك الحقيقي
              // onTap: () => _launchURL('https://maps.google.com/?q=صنعاء، شارع الزبيري'), // يمكن إضافة رابط خرائط
            ),

            const SizedBox(height: 30),
            const Text(
              'تابعنا على وسائل التواصل الاجتماعي:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialMediaIcon(
                  icon: Icons.facebook, // يمكنك استخدام أيقونات مخصصة لوسائل التواصل الاجتماعي
                  onTap: () => _launchURL('https://www.facebook.com/youragency'), // رابط فيسبوك
                ),
                const SizedBox(width: 20),
                _buildSocialMediaIcon(
                  icon: Icons.camera_alt, // أيقونة بديلة لإنستغرام
                  onTap: () => _launchURL('https://www.instagram.com/youragency'), // رابط إنستغرام
                ),
                const SizedBox(width: 20),
                _buildSocialMediaIcon(
                  icon: Icons.business, // أيقونة بديلة لتويتر/X
                  onTap: () => _launchURL('https://twitter.com/youragency'), // رابط تويتر/X
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              'ساعات العمل: الأحد - الخميس، 9 صباحًا - 5 مساءً',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 18) : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildSocialMediaIcon({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.blue[100],
        child: Icon(icon, color: Colors.blue, size: 30),
      ),
    );
  }
}