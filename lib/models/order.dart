import 'package:flutter/material.dart';

class OrderItem {
  final String productId;
  final String title;
  final String imageUrl;
  final double price;
  final int size;
  final Color? color;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.size,
    this.color,
    required this.quantity,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as String,
        title: json['title'] as String,
        imageUrl: json['imageUrl'] as String,
        price: (json['price'] as num).toDouble(),
        size: json['size'] as int,
        color: json['color'] != null ? Color(json['color'] as int) : null,
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'imageUrl': imageUrl,
        'price': price,
        'size': size,
        'color': color?.toARGB32(),
        'quantity': quantity,
      };
}

class Order {
  final String id;
  final List<OrderItem> items;
  final double total;
  final String status;
  final DateTime createdAt;
  // Populated by admin routes only.
  final String? userName;
  final String? userEmail;

  const Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.userName,
    this.userEmail,
  });

  Order copyWith({String? status}) => Order(
        id: id,
        items: items,
        total: total,
        status: status ?? this.status,
        createdAt: createdAt,
        userName: userName,
        userEmail: userEmail,
      );

  factory Order.fromJson(Map<String, dynamic> json) {
    String? userName;
    String? userEmail;
    final rawUserId = json['userId'];
    if (rawUserId is Map) {
      userName = rawUserId['name'] as String?;
      userEmail = rawUserId['email'] as String?;
    }
    return Order(
      id: (json['_id'] ?? json['id']) as String,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      userName: userName,
      userEmail: userEmail,
    );
  }
}
