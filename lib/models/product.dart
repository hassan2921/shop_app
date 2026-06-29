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
}
