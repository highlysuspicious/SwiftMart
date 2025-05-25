import 'package:flutter/material.dart';
import 'package:fluttercommerce/screens/category/wishlist_screen.dart';
import '../../services/cart_service.dart';
import '../../services/order_service.dart';
import '../homepage/home_screen.dart';
import '../homepage/profile_screen.dart';
import 'cart_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final double total;

  const CheckoutScreen({super.key, required this.total});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String paymentMethod = 'Cash on Delivery';

  void _placeOrder() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save order
      OrderService.addOrder(
        name: name,
        address: address,
        paymentMethod: paymentMethod,
        items: List.from(CartService.cartItems),
        total: widget.total,
      );

      // Clear cart
      CartService.clearCart();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Order Confirmed!"),
          content: Text("Thank you $name!\nYour order has been placed."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Checkout"), backgroundColor: Colors.brown),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Shipping Details", style: TextStyle(fontSize: 18)),
              const SizedBox(height: 10),
              TextFormField(
                decoration: const InputDecoration(labelText: "Full Name"),
                validator: (value) =>
                value!.isEmpty ? "Please enter your name" : null,
                onSaved: (val) => name = val ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: "Address"),
                validator: (value) =>
                value!.isEmpty ? "Please enter your address" : null,
                onSaved: (val) => address = val ?? '',
              ),
              DropdownButtonFormField<String>(
                decoration:
                const InputDecoration(labelText: "Payment Method"),
                value: paymentMethod,
                items: const [
                  DropdownMenuItem(
                      value: 'Cash on Delivery',
                      child: Text("Cash on Delivery")),
                  DropdownMenuItem(value: 'Credit Card', child: Text("Credit Card")),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      paymentMethod = val;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              Text("Total: \$${widget.total.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  padding:
                  const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                child: const Text("Place Order"),
              )
            ],
          ),
        ),
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