import 'package:flutter/material.dart';
import '../../services/wishlist_service.dart';
import '../homepage/home_screen.dart';
import '../homepage/profile_screen.dart';
import 'cart_screen.dart';


class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartItems = WishlistManager.wishlistItems;
    return Scaffold(
      appBar: AppBar(title: const Text('Your Wishlist')),
      body: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) {
          final item = cartItems[index];
          return ListTile(
            leading: Image.network(item['image'], width: 50),
            title: Text(item['title']),
            subtitle: Text('\$${item['price']}'),
          );
        },
      ),
      bottomNavigationBar: _buildFloatingNavbar(context),
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