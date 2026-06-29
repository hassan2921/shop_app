import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/wishlist_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Product product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int? _selectedSize;
  Color? _selectedColor;

  void _addToCart() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size!')),
      );
      return;
    }
    ref.read(cartProvider.notifier).addItem(CartItem(
          product: widget.product,
          size: _selectedSize!,
          color: _selectedColor,
        ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final wishlist = ref.watch(wishlistProvider);
    final isWishlisted = wishlist.any((w) => w.id == p.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        actions: [
          IconButton(
            icon: Icon(
              isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: isWishlisted ? Colors.red : null,
            ),
            onPressed: () =>
                ref.read(wishlistProvider.notifier).toggle(p),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(p.title,
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const SizedBox(height: 16),
            Hero(
              tag: 'product-${p.id}',
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Image.asset(p.imageUrl, height: 250),
              ),
            ),
            if (p.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Text(
                  p.description,
                  style: TextStyle(
                      color: Colors.grey[600], fontSize: 15, height: 1.5),
                ),
              ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(245, 247, 249, 1),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '\$${p.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (p.colors.isNotEmpty) ...[
                    const Text('Color',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: p.colors.length,
                        itemBuilder: (context, i) {
                          final color = p.colors[i];
                          final selected = _selectedColor == color;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedColor = color),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: selected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: selected ? 3 : 1,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Text('Size',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  if (p.sizes.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      children: p.sizes.map((size) {
                        final selected = _selectedSize == size;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSize = size),
                          child: Chip(
                            label: Text('$size'),
                            backgroundColor: selected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text('No sizes available'),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                      ),
                      child: const Text('Add To Cart',
                          style: TextStyle(
                              color: Colors.black, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
