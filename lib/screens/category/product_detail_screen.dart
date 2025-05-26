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

  bool _isWishlisted = false;
  bool _isInCart = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }


  void _initializeAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _heroController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _quantityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _heroAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _heroController,
      curve: Curves.easeOutBack,
    ));

    _quantityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _quantityController,
      curve: Curves.elasticOut,
    ));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F3),
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildHeroImage(),
          _buildProductDetails(),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavbar(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B4513)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF8B4513)),
            onPressed: () async {
              HapticFeedback.lightImpact();

              try {
                final response = await http.get(Uri.parse(widget.product['image']));
                if (response.statusCode == 200) {
                  final bytes = response.bodyBytes;

                  final tempDir = await getTemporaryDirectory();
                  final file = await File('${tempDir.path}/${widget.product['title']}.jpg').create();
                  await file.writeAsBytes(bytes);

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text: 'Check out ${widget.product['title']} for ${widget.product['price']}!',
                  );
                } else {
                  await Share.share(
                    'Check out this amazing product: ${widget.product['title']}\n${widget.product['price']}\n\nGet it now!',
                    subject: widget.product['title'],
                  );
                }
              } catch (e) {
                await Share.share(
                  'Check out this amazing product: ${widget.product['title']}\n${widget.product['price']}\n\nGet it now!',
                  subject: widget.product['title'],
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeroImage() {
    return SliverAppBar(
      expandedHeight: 400,
      pinned: false,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: AnimatedBuilder(
          animation: _heroAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * _heroAnimation.value),
              child: Container(
                margin: const EdgeInsets.only(top: 100, left: 20, right: 20, bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    widget.product['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: const Color(0xFFF0EDE8),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              const Color(0xFF8B4513),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProductDetails() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(32),
            topRight: Radius.circular(32),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildProductHeader(),
            const SizedBox(height: 24),
            // Only show quantity selector if item is in cart
            if (_isInCart) ...[
              _buildQuantitySelector(),
              const SizedBox(height: 24),
            ],
            _buildProductDescription(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 120), // Space for bottom navigation
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.product['title'],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${widget.product['price']?.toString() ?? 'N/A'}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      Icons.star,
                      size: 20,
                      color: index < 4
                          ? const Color(0xFFDAA520)
                          : const Color(0xFFE5E5E5),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '4.8 (124 reviews)',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return AnimatedSize(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.5),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: _quantityController,
          curve: Curves.easeOutBack,
        )),
        child: FadeTransition(
          opacity: _quantityController,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF8B4513).withOpacity(0.05),
                  const Color(0xFFA0522D).withOpacity(0.03),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF8B4513).withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B4513).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Color(0xFF8B4513),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'In Cart - Adjust Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C1810),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // DECREASE BUTTON
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _quantity > 1 ? () {
                                    HapticFeedback.lightImpact();
                                    print('DEBUG: Decrease pressed, current quantity: $_quantity');
                                    setState(() {
                                      _quantity--;
                                    });
                                    print('DEBUG: New quantity: $_quantity');
                                    _updateCartQuantity();
                                    _triggerQuantityAnimation();
                                  } : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _quantity > 1
                                          ? const Color(0xFF8B4513).withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: _quantity > 1
                                          ? const Color(0xFF8B4513)
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // QUANTITY DISPLAY
                            Expanded(
                              child: AnimatedBuilder(
                                animation: _quantityAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: 1.0 + (0.1 * _quantityAnimation.value),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                        _quantity.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF8B4513),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            // INCREASE BUTTON
                            Container(
                              margin: const EdgeInsets.all(8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: _quantity < 99 ? () {
                                    HapticFeedback.lightImpact();
                                    setState(() {
                                      _quantity++;
                                    });
                                    _updateCartQuantity();
                                    _triggerQuantityAnimation();
                                  } : null,
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: _quantity < 99
                                          ? const Color(0xFF8B4513).withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: _quantity < 99
                                          ? const Color(0xFF8B4513)
                                          : Colors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quantity: $_quantity ${_quantity == 1 ? 'item' : 'items'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_quantity),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Total: \$${(double.parse(widget.product['price']?.toString() ?? '0') * _quantity).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateCartQuantity() {
    print('DEBUG: _updateCartQuantity called, quantity: $_quantity, isInCart: $_isInCart');

    final productWithQuantity = Map<String, dynamic>.from(widget.product);
    productWithQuantity['quantity'] = _quantity;

    // Simply update the cart without changing visibility
    CartService.addToCart(productWithQuantity);

    // Don't change _isInCart or animation state here - quantity selector should stay visible
    print('DEBUG: Cart updated, quantity selector should remain visible');
  }


  Widget _buildProductDescription() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C1810),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.product['description'] ?? 'No description available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 56,
              width: 56,
              decoration: BoxDecoration(
                color: _isWishlisted
                    ? const Color(0xFF8B4513)
                    : const Color(0xFFF0EDE8),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isWishlisted = !_isWishlisted;
                  });
                  WishlistManager.addToWishlist(widget.product);
                  _showCustomSnackbar('Added to wishlist');
                },
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    _isWishlisted ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(_isWishlisted),
                    color: _isWishlisted ? Colors.white : const Color(0xFF8B4513),
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isInCart
                        ? [const Color(0xFF228B22), const Color(0xFF32CD32)]
                        : [const Color(0xFF8B4513), const Color(0xFFA0522D)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B4513).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child:ElevatedButton(
    onPressed: () {
    HapticFeedback.heavyImpact();
    print('DEBUG: Add to cart pressed, current _isInCart: $_isInCart');

    if (!_isInCart) {
    // Adding to cart
    setState(() {
    _isInCart = true;
    _quantity = 1; // Reset quantity to 1 when first adding
    });

    final productWithQuantity = Map<String, dynamic>.from(widget.product);
    productWithQuantity['quantity'] = _quantity;
    CartService.addToCart(productWithQuantity);

    print('DEBUG: Added to cart, starting quantity animation');
    _quantityController.forward(); // Show quantity selector
    _showCustomSnackbar('Added to cart! Adjust quantity below.');

    } else {
    // Removing from cart completely
    setState(() {
    _isInCart = false;
    _quantity = 1; // Reset quantity
    });

    CartService.removeOneFromCart(widget.product);
    print('DEBUG: Removed from cart, hiding quantity selector');
    _quantityController.reverse(); // Hide quantity selector
    _showCustomSnackbar('Removed from cart');
    }
    },

                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Row(
                      key: ValueKey(_isInCart),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isInCart ? Icons.check_circle : Icons.shopping_cart,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isInCart ? 'Added to Cart' : 'Add to Cart',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildFloatingNavbar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.95),
            const Color(0xFFF7F5F3).withOpacity(0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF8B4513).withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }),
          _buildNavItem(Icons.favorite_border, 'Wishlist', () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const WishlistScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          }),
          _buildNavItem(Icons.shopping_bag_outlined, 'Cart', () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const CartScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          }),
          _buildNavItem(Icons.person_outline, 'Profile', () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
  void _triggerQuantityAnimation() {
    print('DEBUG: Triggering quantity animation');
    _quantityController.forward().then((_) {
      _quantityController.reset();
    });
  }


  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: const Color(0xFF8B4513),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF8B4513),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}