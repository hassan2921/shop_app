import 'package:flutter/material.dart';
import 'package:shop_app/models/order.dart';
import 'package:shop_app/services/api_service.dart';
import 'package:shop_app/utils/product_image.dart';

class OrderDetailPage extends StatefulWidget {
  final Order order;
  const OrderDetailPage({super.key, required this.order});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  late Order _order;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final fresh = await ApiService.instance.getOrder(_order.id);
      if (mounted) setState(() => _order = fresh);
    } catch (_) {}
    if (mounted) setState(() => _refreshing = false);
  }

  static const _steps = ['pending', 'processing', 'shipped', 'delivered'];
  static const _stepLabels = ['Pending', 'Processing', 'Shipped', 'Delivered'];
  static const _stepIcons = [
    Icons.receipt_long,
    Icons.inventory_2,
    Icons.local_shipping,
    Icons.check_circle,
  ];
  static const _stepColors = {
    'pending': Color(0xFFFFA726),
    'processing': Color(0xFF42A5F5),
    'shipped': Color(0xFFAB47BC),
    'delivered': Color(0xFF66BB6A),
  };

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps.indexOf(_order.status);
    final theme = Theme.of(context);
    final statusColor = _stepColors[_order.status] ?? Colors.grey;

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${_order.id.substring(_order.id.length - 6).toUpperCase()}'),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refresh,
              tooltip: 'Refresh status',
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status stepper
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F7F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: List.generate(_steps.length * 2 - 1, (i) {
                    if (i.isOdd) {
                      final stepIndex = i ~/ 2;
                      final active = stepIndex < currentStep;
                      return Expanded(
                        child: Container(
                          height: 3,
                          color: active ? theme.colorScheme.primary : Colors.grey.shade300,
                        ),
                      );
                    }
                    final stepIndex = i ~/ 2;
                    final done = stepIndex < currentStep;
                    final current = stepIndex == currentStep;
                    return Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: done || current
                                  ? theme.colorScheme.primary
                                  : Colors.grey.shade200,
                            ),
                            child: Icon(
                              _stepIcons[stepIndex],
                              size: 20,
                              color: done || current ? Colors.black : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _stepLabels[stepIndex],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: current ? FontWeight.bold : FontWeight.normal,
                              color: done || current ? Colors.black87 : Colors.grey,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 16),

              // Current status pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    _order.status[0].toUpperCase() + _order.status.substring(1),
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order meta
              Text('Order Details', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                'Placed on ${_formatDate(_order.createdAt)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Items list
              ..._order.items.map((item) => _OrderItemTile(item: item)),

              const Divider(height: 32),

              // Totals
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shipping', style: TextStyle(fontSize: 15)),
                  Text('Free', style: TextStyle(color: Colors.green[700], fontSize: 15)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total', style: theme.textTheme.titleMedium),
                  Text(
                    '\$${_order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: productImage(item.imageUrl, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Size: ${item.size}  •  Qty: ${item.quantity}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          Text(
            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
