import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/models/product.dart';
import 'package:shop_app/pages/product_details_page.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/providers/category_provider.dart';
import 'package:shop_app/providers/product_provider.dart';
import 'package:shop_app/providers/wishlist_provider.dart';
import 'package:shop_app/widgets/product_card.dart';

enum _SortOption { none, priceAsc, priceDesc, nameAZ }

class ProductList extends ConsumerStatefulWidget {
  const ProductList({super.key});

  @override
  ConsumerState<ProductList> createState() => _ProductListState();
}

class _ProductListState extends ConsumerState<ProductList> {
  String _selectedFilter = 'All';
  _SortOption _sort = _SortOption.none;
  RangeValues? _priceRange;

  List<Product> _applyFilters(List<Product> all, String query) {
    final range = _priceRange;
    var list = all.where((p) {
      final matchesSearch = p.title.toLowerCase().contains(query) ||
          p.company.toLowerCase().contains(query);
      final matchesFilter = _selectedFilter == 'All' || p.category == _selectedFilter;
      final matchesPrice = range == null ||
          (p.price >= range.start && p.price <= range.end);
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
    final productsAsync = ref.watch(productListProvider);
    final query = ref.watch(searchProvider).toLowerCase();
    final wishlistIds =
        ref.watch(wishlistProvider).map((p) => p.id).toSet();

    const border = OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromRGBO(225, 225, 225, 1)),
      borderRadius: BorderRadius.horizontal(left: Radius.circular(50)),
    );

    return SafeArea(
      child: Column(
        children: [
          // Title + search + sort
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text('Shop\nCollection',
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
          // Category filter chips (dynamic from API)
          ref.watch(categoryProvider).when(
            loading: () => const SizedBox(height: 60, child: Center(child: LinearProgressIndicator())),
            error: (_, __) => const SizedBox(height: 60),
            data: (categories) {
              final filters = ['All', ...categories];
              return SizedBox(
                height: 60,
                child: ListView.builder(
                  itemCount: filters.length,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemBuilder: (context, index) {
                    final filter = filters[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedFilter = filter),
                        child: Chip(
                          backgroundColor: _selectedFilter == filter
                              ? Theme.of(context).colorScheme.primary
                              : const Color.fromRGBO(245, 247, 249, 1),
                          side: const BorderSide(color: Color.fromRGBO(245, 247, 249, 1)),
                          label: Text(filter),
                          labelStyle: const TextStyle(fontSize: 16),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          // Product area
          Expanded(
            child: productsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Could not load products',
                        style: TextStyle(
                            color: Colors.grey[600], fontSize: 16)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(productListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (productList) {
                // Initialise price range once after first load.
                if (_priceRange == null && productList.isNotEmpty) {
                  final prices = productList.map((p) => p.price).toList();
                  final mn =
                      prices.reduce((a, b) => a < b ? a : b);
                  final mx =
                      prices.reduce((a, b) => a > b ? a : b);
                  _priceRange = RangeValues(mn, mx);
                }

                final minP = _priceRange?.start ?? 0;
                final maxP = _priceRange?.end ?? 1000;
                final filtered = _applyFilters(productList, query);

                return Column(
                  children: [
                    // Price range slider
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text('\$${minP.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12)),
                          Expanded(
                            child: RangeSlider(
                              min: productList.isEmpty
                                  ? 0
                                  : productList
                                      .map((p) => p.price)
                                      .reduce((a, b) => a < b ? a : b),
                              max: productList.isEmpty
                                  ? 1000
                                  : productList
                                      .map((p) => p.price)
                                      .reduce((a, b) => a > b ? a : b),
                              values: _priceRange ??
                                  RangeValues(minP, maxP),
                              onChanged: (v) =>
                                  setState(() => _priceRange = v),
                            ),
                          ),
                          Text('\$${maxP.toStringAsFixed(0)}',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off,
                                      size: 64,
                                      color: Colors.grey[400]),
                                  const SizedBox(height: 12),
                                  Text('No products found',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16)),
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
                                    itemBuilder: (context, index) =>
                                        _buildCard(
                                            context,
                                            filtered[index],
                                            index,
                                            wishlistIds),
                                  );
                                }
                                return ListView.builder(
                                  itemCount: filtered.length,
                                  itemBuilder: (context, index) =>
                                      _buildCard(
                                          context,
                                          filtered[index],
                                          index,
                                          wishlistIds),
                                );
                              },
                            ),
                    ),
                  ],
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
        category: product.category,
        isWishlisted: wishlistIds.contains(product.id),
        onWishlistTap: () =>
            ref.read(wishlistProvider.notifier).toggle(product),
      ),
    );
  }
}
