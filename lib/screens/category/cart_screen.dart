import 'package:flutter/material.dart';
import 'package:fluttercommerce/screens/category/wishlist_screen.dart';
import '../../services/cart_service.dart';
import '../homepage/profile_screen.dart';
import '../homepage/home_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, Map<String, dynamic>> groupedItems = {};

  @override
  void initState() {
    super.initState();
    groupCartItems();
  }

  void groupCartItems() {
    groupedItems.clear();
    for (var item in CartService.cartItems) {
      final id = item['id'].toString();
      if (groupedItems.containsKey(id)) {
        groupedItems[id]!['quantity'] += 1;
      } else {
        groupedItems[id] = {
          'product': item,
          'quantity': 1,
        };
      }
    }
  }

  void updateQuantity(String id, int delta) {
    final items = CartService.cartItems;
    final product = groupedItems[id]!['product'];

    if (delta > 0) {
      CartService.addToCart(product);
    } else {
      // Remove one instance of the product
      final index = items.indexWhere((item) => item['id'].toString() == id);
      if (index != -1) {
        items.removeAt(index);
      }
    }

    setState(() {
      groupCartItems();
    });
  }

  double getTotalPrice() {
    double total = 0.0;
    for (var entry in groupedItems.entries) {
      final product = entry.value['product'];
      final quantity = entry.value['quantity'];
      total += (product['price'] as num).toDouble() * quantity;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: groupedItems.isEmpty
          ? const Center(child: Text("Your cart is empty"))
          : Column(
        children: [
          Expanded(
            child: ListView(
              children: groupedItems.entries.map((entry) {
                final id = entry.key;
                final product = entry.value['product'];
                final quantity = entry.value['quantity'];

                return ListTile(
                  leading: Image.network(product['image'], width: 50),
                  title: Text(product['title']),
                  subtitle: Text('\$${product['price']} × $quantity'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () => updateQuantity(id, -1),
                      ),
                      Text(quantity.toString()),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () => updateQuantity(id, 1),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  "Total: \$${getTotalPrice().toStringAsFixed(2)}",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(
                          total: getTotalPrice(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade200,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 24),
                  ),
                  child: const Text("Proceed to Checkout"),
                ),
              ],
            ),
          )
        ],
      ),
        bottomNavigationBar: _buildFloatingNavbar(context), // <-- pass context

    );
  }
}
Widget _buildFloatingNavbar(BuildContext context) {
  return Container(
    margin: const EdgeInsets.all(16),
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.85),
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.brown.withOpacity(0.2),
          blurRadius: 10,
        )
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
          child: const Icon(Icons.home, color: Colors.brown),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistScreen()),
            );
          },
          child: const Icon(Icons.favorite_border, color: Colors.brown),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
          child: const Icon(Icons.shopping_cart_outlined, color: Colors.brown),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: const Icon(Icons.person_outline, color: Colors.brown),
        ),
      ],
    ),
  );
}