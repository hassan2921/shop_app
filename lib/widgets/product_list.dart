import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/global_variables.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/pages/product_details_page.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/wishlist_provider.dart';
import 'package:shop_app/widgets/product_card.dart';

enum _SortOption { none, priceAsc, priceDesc, nameAZ }

class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  static const _filters = ['All', 'Adidas', 'Nike', 'Bata'];
  String _selectedFilter = 'All';
  _SortOption _sort = _SortOption.none;

  static final double _minPrice =
      products.map((p) => p.price).reduce((a, b) => a < b ? a : b);
  static final double _maxPrice =
      products.map((p) => p.price).reduce((a, b) => a > b ? a : b);
  late RangeValues _priceRange;

  @override
  void initState() {
    super.initState();
    _priceRange = RangeValues(_minPrice, _maxPrice);
  }

  List<Product> _applyFilters(String query) {
    var list = products.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(query) ||
          p.company.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' ||
          p.company.toLowerCase() == _selectedFilter.toLowerCase();
      final matchesPrice =
          p.price >= _priceRange.start && p.price <= _priceRange.end;
      return matchesSearch && matchesFilter && matchesPrice;
    }).toList();

    switch (_sort) {
      case _SortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case _SortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
      case _SortOption.nameAZ:
        list.sort((a, b) => a.title.compareTo(b.title));
      case _SortOption.none:
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(225, 225, 225, 1)),
      borderRadius: BorderRadius.horizontal(left: Radius.circular(50)),
    );

    final query = ref.watch(searchProvider).toLowerCase();
    final wishlistIds =
        ref.watch(wishlistProvider).map((p) => p.id).toSet();
    final filtered = _applyFilters(query);

    return SafeArea(
      child: Column(
        children: [
          // Title + search + sort
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Shoes\nCollection',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border,
                  ),
                  onChanged: (v) =>
                      ref.read(searchProvider.notifier).state = v,
                ),
              ),
              PopupMenuButton<_SortOption>(
                icon: const Icon(Icons.sort),
                onSelected: (v) => setState(() => _sort = v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: _SortOption.none, child: Text('Default')),
                  PopupMenuItem(
                      value: _SortOption.priceAsc,
                      child: Text('Price: Low → High')),
                  PopupMenuItem(
                      value: _SortOption.priceDesc,
                      child: Text('Price: High → Low')),
                  PopupMenuItem(
                      value: _SortOption.nameAZ,
                      child: Text('Name: A → Z')),
                ],
              ),
            ],
          ),
          // Price range slider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('\$${_priceRange.start.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12)),
                Expanded(
                  child: RangeSlider(
                    min: _minPrice,
                    max: _maxPrice,
                    values: _priceRange,
                    onChanged: (v) => setState(() => _priceRange = v),
                  ),
                ),
                Text('\$${_priceRange.end.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          // Brand filter chips
          SizedBox(
            height: 60,
            child: ListView.builder(
              itemCount: _filters.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFilter = filter),
                    child: Chip(
                      backgroundColor: _selectedFilter == filter
                          ? Theme.of(context).colorScheme.primary
                          : const Color.fromRGBO(245, 247, 249, 1),
                      side: const BorderSide(
                          color: Color.fromRGBO(245, 247, 249, 1)),
                      label: Text(filter),
                      labelStyle: const TextStyle(fontSize: 16),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                );
              },
            ),
          ),
          // Product list or empty state
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text('No products found',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16)),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth > 1080) {
                        return GridView.builder(
                          itemCount: filtered.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.75,
                          ),
                          itemBuilder: (context, index) => _buildCard(
                              context, filtered[index], index, wishlistIds),
                        );
                      }
                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, index) => _buildCard(
                            context, filtered[index], index, wishlistIds),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, Product product, int index,
      Set<String> wishlistIds) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
            builder: (_) => ProductDetailsPage(product: product)),
      ),
      child: ProductCard(
        title: product.title,
        price: product.price,
        image: product.imageUrl,
        backgroundColor: index.isEven
            ? const Color.fromRGBO(216, 240, 253, 1)
            : const Color.fromRGBO(245, 247, 249, 1),
        heroTag: 'product-${product.id}',
        isWishlisted: wishlistIds.contains(product.id),
        onWishlistTap: () =>
            ref.read(wishlistProvider.notifier).toggle(product),
      ),
    );
  }
}
