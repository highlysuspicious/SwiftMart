/// Updated ProductDetailScreen with center-aligned product display, rating info, size selector, and quantity control

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercommerce/screens/category/wishlist_screen.dart';
import 'package:fluttercommerce/services/wishlist_service.dart';
import '../../services/cart_service.dart';
import '../homepage/home_screen.dart';
import '../homepage/profile_screen.dart';
import 'cart_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import '/widgets/product_card.dart';

class ProductDetailScreen extends StatefulWidget {
  final dynamic product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  String selectedSize = 'M';
  final List<String> sizes = ['S', 'M', 'L', 'XL'];

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _heroController;
  late AnimationController _quantityController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _heroAnimation;
  late Animation<double> _quantityAnimation;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _slideController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeController = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _scaleController = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _heroController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _quantityController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut));
    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack));
    _quantityAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _quantityController, curve: Curves.elasticOut));
  }

  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _heroController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _fadeController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _slideController.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _heroController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Widget _buildSizeSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Size',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1810),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: sizes.map((size) {
              final isSelected = size == selectedSize;
              return ChoiceChip(
                label: Text(
                  size,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) {
                  HapticFeedback.selectionClick();
                  setState(() {
                    selectedSize = size;
                  });
                },
                selectedColor: const Color(0xFF8B4513),
                backgroundColor: const Color(0xFFF0EDE8),
                labelPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _quantity > 1
              ? () => setState(() => _quantity--)
              : null,
        ),
        Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () => setState(() => _quantity++),
        ),
      ],
    );
  }

  void _showCustomSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF8B4513),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product['title'] ?? 'Product'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.network(widget.product['image'], height: 300, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(widget.product['title'],
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    if (widget.product['rating'] != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text('${widget.product['rating']} star',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    const SizedBox(height: 8),
                    Text(widget.product['description'] ?? '',
                        style: const TextStyle(fontSize: 16), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    _buildSizeSelector(),
                    const SizedBox(height: 16),
                    _buildQuantitySelector(),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        final productWithQuantity = Map<String, dynamic>.from(widget.product);
                        productWithQuantity['quantity'] = _quantity;
                        productWithQuantity['size'] = selectedSize;
                        CartService.addToCart(productWithQuantity);
                        _showCustomSnackbar('Added to cart');
                      },
                      child: const Text('Add to Cart'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
