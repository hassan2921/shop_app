import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/services/api_service.dart';
import 'package:shop_app/utils/product_image.dart';

final _adminProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ApiService.instance.getAdminProducts();
});

class AdminProductsPage extends ConsumerWidget {
  const AdminProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(_adminProductsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(_adminProductsProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const _ProductFormPage()),
          );
          if (added == true) {
            ref.invalidate(_adminProductsProvider);
            ref.invalidate(productListProvider);
          }
        },
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (products) => products.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    Text('No products', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                  ],
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _ProductTile(
                  product: products[i],
                  onEdit: () async {
                    final edited = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => _ProductFormPage(product: products[i]),
                      ),
                    );
                    if (edited == true) {
                      ref.invalidate(_adminProductsProvider);
                      ref.invalidate(productListProvider);
                    }
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: Text('Delete "${products[i].title}"?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      try {
                        await ApiService.instance.deleteProduct(products[i].id);
                        ref.invalidate(_adminProductsProvider);
                        ref.invalidate(productListProvider);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete failed: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              ),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductTile({required this.product, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 56,
            height: 56,
            child: productImage(product.imageUrl, fit: BoxFit.contain),
          ),
        ),
        title: Text(product.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${product.company}  •  \$${product.price.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product form (add / edit) ─────────────────────────────────────────────

class _ProductFormPage extends StatefulWidget {
  final Product? product;
  const _ProductFormPage({this.product});

  @override
  State<_ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<_ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _id;
  late final TextEditingController _title;
  late final TextEditingController _price;
  late final TextEditingController _imageUrl;
  late final TextEditingController _company;
  late final TextEditingController _sizes;
  late final TextEditingController _description;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _id = TextEditingController(text: p?.id ?? '');
    _title = TextEditingController(text: p?.title ?? '');
    _price = TextEditingController(text: p != null ? p.price.toString() : '');
    _imageUrl = TextEditingController(text: p?.imageUrl ?? '');
    _company = TextEditingController(text: p?.company ?? '');
    _sizes = TextEditingController(text: p != null ? p.sizes.join(', ') : '');
    _description = TextEditingController(text: p?.description ?? '');
  }

  @override
  void dispose() {
    for (final c in [_id, _title, _price, _imageUrl, _company, _sizes, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final sizes = _sizes.text
        .split(',')
        .map((s) => int.tryParse(s.trim()))
        .whereType<int>()
        .toList();

    final data = {
      'id': _id.text.trim(),
      'title': _title.text.trim(),
      'price': double.parse(_price.text.trim()),
      'imageUrl': _imageUrl.text.trim(),
      'company': _company.text.trim(),
      'sizes': sizes,
      'colors': [],
      'description': _description.text.trim(),
    };

    try {
      if (_isEdit) {
        await ApiService.instance.updateProduct(widget.product!.id, data);
      } else {
        await ApiService.instance.createProduct(data);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Product' : 'Add Product')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (!_isEdit)
              _field(_id, 'Product ID', 'e.g. shoe_5', required: true),
            _field(_title, 'Title', 'e.g. Nike Air Max', required: true),
            _field(_price, 'Price', 'e.g. 99.99',
                required: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                extraValidator: (v) => double.tryParse(v ?? '') == null ? 'Enter a valid number' : null),
            _field(_imageUrl, 'Image URL or asset path', 'e.g. assets/images/shoes_1.png or https://...', required: true),
            _field(_company, 'Company / Brand', 'e.g. Nike', required: true),
            _field(_sizes, 'Sizes (comma-separated)', 'e.g. 38, 39, 40, 41'),
            _field(_description, 'Description', 'Optional', maxLines: 3),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                    : Text(_isEdit ? 'Save Changes' : 'Add Product',
                        style: const TextStyle(fontSize: 16, color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool required = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? extraValidator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) {
          if (required && (v == null || v.trim().isEmpty)) return '$label is required';
          return extraValidator?.call(v);
        },
      ),
    );
  }
}
