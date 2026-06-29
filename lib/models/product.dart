import 'package:flutter/material.dart';

class Product {
  final String id;
  final String title;
  final double price;
  final String imageUrl;
  final String company;
  final List<int> sizes;
  final List<Color> colors;
  final String description;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.company,
    required this.sizes,
    this.colors = const [],
    this.description = '',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String,
      company: json['company'] as String,
      sizes: (json['sizes'] as List<dynamic>).map((e) => e as int).toList(),
      colors: (json['colors'] as List<dynamic>? ?? [])
          .map((e) => Color(e as int))
          .toList(),
      description: json['description'] as String? ?? '',
    );
  }
}
