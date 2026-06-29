import 'package:flutter/material.dart';
import 'package:shop_app/models/product.dart';

class CartItem {
  final Product product;
  final int size;
  final Color? color;
  final int quantity;

  const CartItem({
    required this.product,
    required this.size,
    this.color,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) => CartItem(
        product: product,
        size: size,
        color: color,
        quantity: quantity ?? this.quantity,
      );

  // Two cart lines are the same if they share product id, size, and color.
  @override
  bool operator ==(Object other) =>
      other is CartItem &&
      other.product.id == product.id &&
      other.size == size &&
      other.color?.toARGB32() == color?.toARGB32();

  @override
  int get hashCode => Object.hash(product.id, size, color?.toARGB32());

  Map<String, dynamic> toJson() => {
        'productId': product.id,
        'productTitle': product.title,
        'productPrice': product.price,
        'productImageUrl': product.imageUrl,
        'productCompany': product.company,
        'productSizes': product.sizes,
        'productColors': product.colors.map((c) => c.toARGB32()).toList(),
        'productDescription': product.description,
        'size': size,
        'color': color?.toARGB32(),
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    final product = Product(
      id: json['productId'] as String,
      title: json['productTitle'] as String,
      price: (json['productPrice'] as num).toDouble(),
      imageUrl: json['productImageUrl'] as String,
      company: json['productCompany'] as String,
      sizes: (json['productSizes'] as List<dynamic>)
          .map((e) => e as int)
          .toList(),
      colors: (json['productColors'] as List<dynamic>? ?? [])
          .map((e) => Color(e as int))
          .toList(),
      description: json['productDescription'] as String? ?? '',
    );
    return CartItem(
      product: product,
      size: json['size'] as int,
      color: json['color'] != null ? Color(json['color'] as int) : null,
      quantity: json['quantity'] as int? ?? 1,
    );
  }
}
