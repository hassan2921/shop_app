import 'package:flutter/material.dart';
import 'package:shop_app/utils/product_image.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String image;
  final Color backgroundColor;
  final String? heroTag;
  final String? category;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.backgroundColor,
    this.heroTag,
    this.category,
    this.isWishlisted = false,
    this.onWishlistTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (category != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54),
                  ),
                ),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text('\$${price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 5),
              Center(
                child: heroTag != null
                    ? Hero(tag: heroTag!, child: productImage(image, height: 175))
                    : productImage(image, height: 175),
              ),
            ],
          ),
          if (onWishlistTap != null)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: onWishlistTap,
                child: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                  color: isWishlisted ? Colors.red : Colors.grey,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
