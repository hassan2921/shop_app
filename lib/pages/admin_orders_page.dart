import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/pages/order_detail_page.dart';
import 'package:shop_app/services/api_service.dart';

final _adminOrdersProvider = FutureProvider<List<Order>>((ref) async {
  return ApiService.instance.getAdminOrders();
});

class AdminOrdersPage extends ConsumerWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(_adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_adminOrdersProvider),
          ),
        ],
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (orders) => orders.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No orders yet', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _AdminOrderCard(
                  order: orders[i],
                  onStatusChanged: (newStatus) async {
                    try {
                      await ApiService.instance.updateOrderStatus(orders[i].id, newStatus);
                      ref.invalidate(_adminOrdersProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update: $e')),
                        );
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _AdminOrderCard extends StatelessWidget {
  final Order order;
  final ValueChanged<String> onStatusChanged;

  const _AdminOrderCard({required this.order, required this.onStatusChanged});

  static const _statuses = ['pending', 'processing', 'shipped', 'delivered'];
  static const _statusColors = {
    'pending': Color(0xFFFFA726),
    'processing': Color(0xFF42A5F5),
    'shipped': Color(0xFFAB47BC),
    'delivered': Color(0xFF66BB6A),
  };

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColors[order.status] ?? Colors.grey;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(order.id.length - 6).toUpperCase()}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      if (order.userName != null)
                        Text(
                          '${order.userName}  •  ${order.userEmail ?? ''}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
                Text(
                  '\$${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: order.status,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      isDense: true,
                    ),
                    items: _statuses.map((s) {
                      final c = _statusColors[s] ?? Colors.grey;
                      return DropdownMenuItem(
                        value: s,
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(color: c, fontWeight: FontWeight.w600),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null && v != order.status) onStatusChanged(v);
                    },
                    selectedItemBuilder: (_) => _statuses.map((s) {
                      final c = _statusColors[s] ?? Colors.grey;
                      return Text(
                        s[0].toUpperCase() + s.substring(1),
                        style: TextStyle(color: c, fontWeight: FontWeight.w600),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => OrderDetailPage(order: order)),
                  ),
                  child: Text('View', style: TextStyle(color: statusColor)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
