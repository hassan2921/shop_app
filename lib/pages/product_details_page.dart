import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/providers/cart_provider.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final Map<String, Object?> product;
  const ProductDetailsPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  int selectedSize = 0;

  void onTap() {
    if (selectedSize != 0) {
      ref.read(cartProvider.notifier).addProduct({
        'id': widget.product['id'] ?? '',
        'title': widget.product['title'] ?? 'Unknown',
        'price': _getPrice(),
        'imageUrl': widget.product['imageUrl'] ?? '',
        'company': widget.product['company'] ?? '',
        'size': selectedSize,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a size!')));
    }
  }

  double _getPrice() {
    final price = widget.product['price'];
    if (price is int) return price.toDouble();
    if (price is double) return price;
    if (price is String) return double.tryParse(price) ?? 0.0;
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.product['title'] as String? ?? 'No title';
    final imageUrl = widget.product['imageUrl'] as String? ?? '';
    final sizes = (widget.product['sizes'] as List<int>?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const Spacer(),
          if (imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(imageUrl, height: 250),
            )
          else
            const Icon(Icons.image_not_supported, size: 150),
          const Spacer(flex: 2),
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(245, 247, 249, 1),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${_getPrice()}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 10),
                if (sizes.isNotEmpty)
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: sizes.length,
                      itemBuilder: (context, index) {
                        final size = sizes[index];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () => setState(() => selectedSize = size),
                            child: Chip(
                              label: Text(size.toString()),
                              backgroundColor: selectedSize == size
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                else
                  const Text("No sizes available"),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      fixedSize: const Size(350, 50),
                    ),
                    child: const Text(
                      'Add To Cart',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
