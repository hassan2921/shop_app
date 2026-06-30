import 'package:flutter/material.dart';
import 'package:shop_app/pages/admin_orders_page.dart';
import 'package:shop_app/pages/admin_products_page.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _AdminCard(
            icon: Icons.shopping_bag_outlined,
            title: 'Manage Orders',
            subtitle: 'View all orders and update their status',
            color: const Color(0xFF42A5F5),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminOrdersPage()),
            ),
          ),
          const SizedBox(height: 16),
          _AdminCard(
            icon: Icons.inventory_2_outlined,
            title: 'Manage Products',
            subtitle: 'Add, edit, or delete products',
            color: const Color(0xFF66BB6A),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminProductsPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
