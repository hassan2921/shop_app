import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final double price;
  final String image;
  final Color backgroundColor;
  final String? heroTag;
  final bool isWishlisted;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.backgroundColor,
    this.heroTag,
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
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 5),
              Text('\$${price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 5),
              Center(
                child: heroTag != null
                    ? Hero(
                        tag: heroTag!,
                        child: Image.asset(image, height: 175),
                      )
                    : Image.asset(image, height: 175),
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
