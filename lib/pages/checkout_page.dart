import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/order_provider.dart';

class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  bool _placing = false;

  Future<void> _placeOrder() async {
    final cart = ref.read(cartProvider);
    final total = cart.fold<double>(0.0, (s, i) => s + i.product.price * i.quantity);

    setState(() => _placing = true);
    final order = await ref.read(orderProvider.notifier).placeOrder(cart, total);
    if (!mounted) return;
    setState(() => _placing = false);

    if (order == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to place order. Please try again.')),
      );
      return;
    }

    // Backend already cleared the DB cart; mirror that locally.
    ref.read(cartProvider.notifier).empty();

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Order Placed!'),
        content: Text('Your order #${order.id.substring(order.id.length - 6).toUpperCase()} has been placed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final total = cart.fold<double>(0.0, (s, i) => s + i.product.price * i.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(item.product.imageUrl),
                      radius: 28,
                    ),
                    title: Text(item.product.title),
                    subtitle: Text('Size: ${item.size}  •  Qty: ${item.quantity}'),
                    trailing: Text(
                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          _CheckoutSummary(total: total, placing: _placing, onPlaceOrder: _placeOrder),
        ],
      ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  final double total;
  final bool placing;
  final VoidCallback onPlaceOrder;

  const _CheckoutSummary({required this.total, required this.placing, required this.onPlaceOrder});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 16)),
              Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: TextStyle(fontSize: 16)),
              Text('Free', style: TextStyle(fontSize: 16, color: Colors.green)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: Theme.of(context).textTheme.titleMedium),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: placing ? null : onPlaceOrder,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: placing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Text('Place Order', style: TextStyle(fontSize: 16, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }
}
