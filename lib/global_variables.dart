import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';

final List<Product> products = [
  const Product(
    id: '0',
    title: "Men's Nike Shoes",
    price: 44.52,
    imageUrl: 'assets/images/shoes_1.png',
    company: 'Nike',
    sizes: [9, 10, 11, 12],
    colors: [Colors.black, Colors.white, Color(0xFF4CAF50)],
    description:
        'Iconic Nike design with superior cushioning and breathable mesh upper. Perfect for everyday wear and light athletic activities.',
  ),
  const Product(
    id: '1',
    title: 'Adidas Shoes',
    price: 20.12,
    imageUrl: 'assets/images/shoes_2.png',
    company: 'Adidas',
    sizes: [9, 10, 12],
    colors: [Color(0xFF2196F3), Colors.black, Color(0xFFFF5722)],
    description:
        'Classic Adidas style with responsive Boost technology. Lightweight construction ensures all-day comfort.',
  ),
  const Product(
    id: '2',
    title: "Bata Women's Shoes",
    price: 28.95,
    imageUrl: 'assets/images/shoes_3.png',
    company: 'Bata',
    sizes: [8, 9, 10],
    colors: [Color(0xFFE91E63), Color(0xFF9C27B0), Colors.white],
    description:
        "Elegant Bata women's footwear combining style and comfort. Durable sole with premium finishing.",
  ),
  const Product(
    id: '3',
    title: 'Jordan Shoes',
    price: 420.69,
    imageUrl: 'assets/images/shoes_4.png',
    company: 'Nike',
    sizes: [8, 9, 10],
    colors: [Colors.red, Colors.black, Color(0xFFFFEB3B)],
    description:
        'Premium Air Jordan silhouette with iconic colorway. Genuine leather upper with Air-Sole cushioning unit.',
  ),
];
