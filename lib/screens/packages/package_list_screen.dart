// lib/screens/packages/package_list_screen.dart

import 'package:flutter/material.dart';
import 'package:hajj_umrah_mobile_app/screens/packages/package_details_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hajj_umrah_mobile_app/providers/package_notifier.dart';
import 'package:hajj_umrah_mobile_app/providers/auth_notifier.dart';
import 'package:hajj_umrah_mobile_app/models/package.dart';


class PackageListScreen extends StatefulWidget {
  const PackageListScreen({super.key});

  @override
  State<PackageListScreen> createState() => _PackageListScreenState();
}

class _PackageListScreenState extends State<PackageListScreen> {
  @override
  void initState() {
    super.initState();
    // جلب الباقات عند تهيئة الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = context.read<AuthNotifier>();
      context.read<PackageNotifier>().fetchPackages(authNotifier.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final packageNotifier = context.watch<PackageNotifier>(); // للاستماع إلى تغييرات الباقات

    return Scaffold(
      appBar: AppBar(
        title: const Text('باقات الحج والعمرة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
      ),
      body: packageNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : packageNotifier.errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                packageNotifier.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  final authNotifier = context.read<AuthNotifier>();
                  packageNotifier.fetchPackages(authNotifier.token);
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ),
        ),
      )
          : packageNotifier.packages.isEmpty
          ? const Center(
        child: Text(
          'لا توجد باقات متاحة حالياً.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: packageNotifier.packages.length,
        itemBuilder: (context, index) {
          final package = packageNotifier.packages[index];
          // return Card(
          //   margin: const EdgeInsets.symmetric(vertical: 8.0),
          //   elevation: 4.0,
          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   child: Padding(
          //     padding: const EdgeInsets.all(16.0),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           package.name,
          //           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          //         ),
          //         const SizedBox(height: 8.0),
          //         Text(
          //           package.description ?? 'لا يوجد وصف.',
          //           style: const TextStyle(fontSize: 14, color: Colors.grey),
          //         ),
          //         const Divider(),
          //         Row(
          //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //           children: [
          //             _buildInfoChip(Icons.calendar_today, package.type),
          //             _buildInfoChip(Icons.date_range, '${package.numberOfDays} أيام'),
          //             _buildInfoChip(Icons.attach_money, 'SR ${package.pricePerPerson.toStringAsFixed(2)}'),
          //             _buildInfoChip(Icons.event_seat, '${package.availableSeats} مقاعد'),
          //           ],
          //         ),
          //         const SizedBox(height: 10.0),
          //         if (package.includes != null && package.includes!.isNotEmpty)
          //           _buildFeaturesList('يشمل:', package.includes!),
          //         if (package.excludes != null && package.excludes!.isNotEmpty)
          //           _buildFeaturesList('لا يشمل:', package.excludes!),
          //         const SizedBox(height: 10),
          //         Align(
          //           alignment: Alignment.centerLeft,
          //           child: ElevatedButton(
          //             onPressed: () {
          //               // TODO: Navigate to Package Detail Screen
          //               print('View details for ${package.name}');
          //             },
          //             child: const Text('عرض التفاصيل'),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // );
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // لتحسين الشكل
            child: InkWell( // يجعل البطاقة قابلة للنقر
              onTap: () {
                // الانتقال إلى شاشة تفاصيل الباقة
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PackageDetailsScreen(package: package),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8.0),
                    Text(package.description?? 'لا يوجد وصف', maxLines: 2, overflow: TextOverflow.ellipsis), // عرض جزء من الوصف
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('السعر: ${package.pricePerPerson.toStringAsFixed(2)} SR', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                        Text('المدة: ${package.numberOfDays} أيام'),
                      ],
                    ),
                    const SizedBox(height: 5.0),
                    Text('تاريخ البدء: ${DateFormat('yyyy-MM-dd').format(package.startDate)}'),
                    Text('تاريخ الانتهاء: ${DateFormat('yyyy-MM-dd').format(package.endDate)}'),
                  ],
                ),
              ),
            ),
          );

        },
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      backgroundColor: Colors.blue.shade50,
    );
  }

  Widget _buildFeaturesList(String title, List<String> features) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Wrap(
          spacing: 6.0,
          runSpacing: 4.0,
          children: features.map((feature) => Chip(label: Text(feature))).toList(),
        ),
      ],
    );
  }
}