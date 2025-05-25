import 'package:flutter/material.dart';
import 'package:fluttercommerce/screens/category/wishlist_screen.dart';
import '../../services/order_service.dart';
import '../homepage/home_screen.dart';
import '../homepage/profile_screen.dart';
import 'cart_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = OrderService.orders;

    return Scaffold(
      appBar: AppBar(title: const Text("Order History"), backgroundColor: Colors.brown),
      body: orders.isEmpty
          ? const Center(child: Text("No orders yet."))
          : ListView.builder(
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return Card(
            margin: const EdgeInsets.all(12),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${order['name']}"),
                  Text("Address: ${order['address']}"),
                  Text("Payment: ${order['paymentMethod']}"),
                  Text("Total: \$${order['total'].toStringAsFixed(2)}"),
                  Text("Date: ${order['date']}"),
                  const SizedBox(height: 8),
                  const Text("Items:"),
                  ...order['items'].map<Widget>((item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item['title']),
                    subtitle: Text("\$${item['price']}"),
                    leading: Image.network(item['image'], width: 40),
                  )),
                ],
              ),
            ),
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