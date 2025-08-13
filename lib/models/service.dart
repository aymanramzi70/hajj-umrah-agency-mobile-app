// lib/models/service.dart

class Service {
  final int id;
  final String name;
  final String description;
  final String type; // مثلاً: 'accommodation', 'flight', 'transport', 'other'
  final double? price; // قد يكون للخدمة سعر خاص بها

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    this.price,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'],
      price: json['price'] != null ? double.parse(json['price'].toString()) : null,
    );
  }
}