import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shop_app/pages/cart_page.dart';
import 'package:shop_app/pages/profile_page.dart';
import 'package:shop_app/pages/wishlist_page.dart';
import 'package:shop_app/providers/cart_provider.dart';
import 'package:shop_app/widgets/product_list.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentPage = 0;

  static const _pages = <Widget>[
    ProductList(),
    CartPage(),
    WishlistPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final totalQty = cart.fold<int>(0, (sum, i) => sum + i.quantity);

    return Scaffold(
      body: IndexedStack(index: _currentPage, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 30,
        selectedFontSize: 0,
        unselectedFontSize: 0,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPage,
        onTap: (i) => setState(() => _currentPage = i),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: totalQty > 0,
              label: Text('$totalQty'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: totalQty > 0,
              label: Text('$totalQty'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: '',
          ),
        ],
      ),
    );
  }
}
