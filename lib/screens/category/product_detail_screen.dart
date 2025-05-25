import 'package:flutter/material.dart';
import 'package:fluttercommerce/screens/category/wishlist_screen.dart';
import 'package:fluttercommerce/services/wishlist_service.dart';
import '../../services/cart_service.dart';
import '../homepage/home_screen.dart';
import '../homepage/profile_screen.dart';
import 'cart_screen.dart';


class ProductDetailScreen extends StatelessWidget {
  final dynamic product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product['title'])),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Image.network(product['image'], fit: BoxFit.contain),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(product['description']),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                CartService.addToCart(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart')),
                );
              },
              child: const Text('Add to Cart'),
            ),
          ),Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                WishlistManager.addToWishlist(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to wishlist')),
                );
              },
              child: const Text('Add to wishlist'),
            ),
          ),
        ],
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