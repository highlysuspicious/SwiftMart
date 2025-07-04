import 'dart:io';
import 'package:fluttercommerce/screens/category/checkout_screen.dart';
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

// Constants for quantity limits
const _minQuantity = 1;

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

  bool _isWishlisted = false;
  bool _isInCart = false;
  int _quantity = 1;
  bool _isAddingToCart = false;
  bool _isOutOfStock = false;
  int _availableStock = 99;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();

    // Initialize product stock
    _availableStock = widget.product['stock'] ?? 99;
    _isOutOfStock = _availableStock <= 0;

    _checkCartStatus();
    _checkWishlistStatus();
  }

  void _checkCartStatus() {
    setState(() {
      final cartItem = CartService.cartItems.firstWhere(
        (item) => item['id'] == widget.product['id'],
        orElse: () => {},
      );

      _isInCart = cartItem.isNotEmpty;

      if (_isInCart) {
        _quantity = cartItem['quantity'] ?? 1;
        // Ensure we don't exceed available stock
        if (_quantity > _availableStock) {
          _quantity = _availableStock;
          // Update cart with corrected quantity
          _updateCartQuantity();
        }
      }
    });
  }

  void _checkWishlistStatus() {
    setState(() {
      _isWishlisted = WishlistManager.wishlistItems.any(
        (item) => item['id'] == widget.product['id'],
      );
    });
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
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _heroAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack),
    );
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

  Future<void> _handleAddToCart() async {
    if (_isOutOfStock) return;

    HapticFeedback.heavyImpact();

    setState(() => _isAddingToCart = true);

    try {
      if (!_isInCart) {
        // Add new item to cart
        final productWithQuantity = Map<String, dynamic>.from(widget.product);
        productWithQuantity['quantity'] = _quantity;

        await CartService.addToCart(productWithQuantity);

        setState(() {
          _isInCart = true;
          _quantity = _quantity.clamp(_minQuantity, _availableStock);
        });

        _quantityController.forward();
        _showCustomSnackbar(
          'Added to cart! Adjust quantity below.',
          icon: Icons.shopping_cart_checkout,
        );
      } else {
        // Remove from cart
        await CartService.removeFromCart(widget.product);

        setState(() {
          _isInCart = false;
          _quantity = 1; // Reset quantity when removed
        });

        _quantityController.reverse();
        _showCustomSnackbar(
          'Removed from cart',
          icon: Icons.remove_shopping_cart,
        );
      }
    } catch (e) {
      _showCustomSnackbar('Failed to update cart', icon: Icons.error_outline);
    } finally {
      setState(() => _isAddingToCart = false);
    }
  }

  void _navigateToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CheckoutScreen(
              products: CartService.cartItems,
              totalAmount:
                  double.parse(widget.product['price']?.toString() ?? '0') *
                  _quantity,
            ),
      ),
    );
  }

  void _updateCartQuantity() {
    final updatedProduct = Map<String, dynamic>.from(widget.product);
    updatedProduct['quantity'] = _quantity;
    CartService.updateCartItem(updatedProduct);
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
        slivers: [_buildHeroImage(), _buildProductDetails()],
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
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
            color: Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
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
                final response = await http.get(
                  Uri.parse(widget.product['image']),
                );
                if (response.statusCode == 200) {
                  final bytes = response.bodyBytes;

                  final tempDir = await getTemporaryDirectory();
                  final file =
                      await File(
                        '${tempDir.path}/${widget.product['title']}.jpg',
                      ).create();
                  await file.writeAsBytes(bytes);

                  await Share.shareXFiles(
                    [XFile(file.path)],
                    text:
                        'Check out ${widget.product['title']} for ${widget.product['price']}!',
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
                margin: const EdgeInsets.only(
                  top: 100,
                  left: 20,
                  right: 20,
                  bottom: 20,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
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
            _buildProductDescription(),
            const SizedBox(height: 32),
            _buildActionButtons(),
            const SizedBox(height: 120),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B4513).withValues(alpha: 0.1),
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
                      color:
                          index < 4
                              ? const Color(0xFFDAA520)
                              : const Color(0xFFE5E5E5),
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    '4.8 (124 reviews)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
        child: Column(
          children: [
            Row(
              children: [
                // Wishlist Button
                _buildWishlistButton(),
                const SizedBox(width: 16),
                // Main Add to Cart/Buy Now section
                Expanded(
                  child: Column(
                    children: [
                      // Add to Cart/In Cart button
                      _buildCartActionButton(),
                      const SizedBox(height: 12),
                      // Buy Now button
                      _buildBuyNowButton(),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWishlistButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        color:
            _isWishlisted ? const Color(0xFF8B4513) : const Color(0xFFF0EDE8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            HapticFeedback.mediumImpact();
            setState(() {
              _isWishlisted = !_isWishlisted;
            });
            if (_isWishlisted) {
              WishlistManager.addToWishlist(widget.product);
              _showCustomSnackbar('Added to wishlist');
            } else {
              WishlistManager.removeFromWishlist(widget.product);
              _showCustomSnackbar('Removed from wishlist');
            }
          },
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Icon(
                _isWishlisted ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(_isWishlisted),
                color: _isWishlisted ? Colors.white : const Color(0xFF8B4513),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartActionButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      decoration: BoxDecoration(
        gradient:
            _isOutOfStock
                ? LinearGradient(colors: [Colors.grey, Colors.grey[700]!])
                : _isInCart
                ? LinearGradient(
                  colors: [const Color(0xFF228B22), const Color(0xFF32CD32)],
                )
                : LinearGradient(
                  colors: [const Color(0xFF8B4513), const Color(0xFFA0522D)],
                ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_isOutOfStock ? Colors.grey : const Color(0xFF8B4513))
                .withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              _isOutOfStock
                  ? null
                  : _isInCart
                  ? _handleAddToCart // Remove from cart if already in cart
                  : _showAddToCartModal, // Show modal if not in cart
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedOpacity(
                  opacity: _isAddingToCart ? 0 : 1,
                  duration: const Duration(milliseconds: 200),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isOutOfStock
                            ? Icons.block
                            : _isInCart
                            ? Icons.check_circle
                            : Icons.shopping_cart,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isOutOfStock
                            ? 'Out of Stock'
                            : _isInCart
                            ? 'Added to Cart'
                            : 'Add to Cart',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isAddingToCart)
                  const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: Material(
        color: _isOutOfStock ? Colors.grey : const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap:
              _isOutOfStock
                  ? null
                  : () {
                    HapticFeedback.heavyImpact();
                    _showBuyNowModal();
                  },
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_isOutOfStock
                                ? Colors.grey
                                : const Color(0xFF4CAF50))
                            .withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _isOutOfStock ? 'Unavailable' : 'Buy Now',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isAddingToCart)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: const Center(
                      child: SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomSnackbar(
    String message, {
    IconData icon = Icons.check_circle,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF8B4513),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        elevation: 6,
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
            Colors.white.withValues(alpha: 0.95),
            const Color(0xFFF7F5F3).withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF8B4513).withValues(alpha: 0.1),
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
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const HomeScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
                  return FadeTransition(opacity: animation, child: child);
                },
              ),
            );
          }),
          _buildNavItem(Icons.favorite_border, 'Wishlist', () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const WishlistScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const CartScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
                pageBuilder:
                    (context, animation, secondaryAnimation) =>
                        const ProfileScreen(),
                transitionsBuilder: (
                  context,
                  animation,
                  secondaryAnimation,
                  child,
                ) {
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
            Icon(icon, color: const Color(0xFF8B4513), size: 24),
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

  void _showBuyNowModal() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product title and price
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(double.parse(widget.product['price']?.toString() ?? '0') * _quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity selector
                  Text(
                    'Quantity',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Decrease button
                        _QuantityButton(
                          icon: Icons.remove,
                          isEnabled: _quantity > _minQuantity,
                          onPressed: () {
                            setModalState(() {
                              _quantity = (_quantity - 1).clamp(
                                _minQuantity,
                                _availableStock,
                              );
                            });
                          },
                        ),

                        // Quantity display
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Increase button
                        _QuantityButton(
                          icon: Icons.add,
                          isEnabled: _quantity < _availableStock,
                          onPressed: () {
                            setModalState(() {
                              _quantity = (_quantity + 1).clamp(
                                _minQuantity,
                                _availableStock,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buy now button only
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Close the modal
                        await _handleAddToCart();
                        if (_isInCart) {
                          _navigateToCheckout();
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.payment, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Buy Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddToCartModal() {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product title and price
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.product['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${(double.parse(widget.product['price']?.toString() ?? '0') * _quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF8B4513),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Quantity selector
                  Text(
                    'Quantity',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F5F3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        // Decrease button
                        _QuantityButton(
                          icon: Icons.remove,
                          isEnabled: _quantity > _minQuantity,
                          onPressed: () {
                            setModalState(() {
                              _quantity = (_quantity - 1).clamp(
                                _minQuantity,
                                _availableStock,
                              );
                            });
                          },
                        ),

                        // Quantity display
                        Expanded(
                          child: Center(
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Increase button
                        _QuantityButton(
                          icon: Icons.add,
                          isEnabled: _quantity < _availableStock,
                          onPressed: () {
                            setModalState(() {
                              _quantity = (_quantity + 1).clamp(
                                _minQuantity,
                                _availableStock,
                              );
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Add to cart button only
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B4513),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        Navigator.pop(context); // Close the modal
                        await _handleAddToCart();
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Add to Cart',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _QuantityButton({
    required this.icon,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isEnabled
                    ? const Color(0xFF8B4513).withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border:
                isEnabled
                    ? Border.all(
                      color: const Color(0xFF8B4513).withValues(alpha: 0.2),
                      width: 1,
                    )
                    : null,
          ),
          child: Center(
            child: Icon(
              icon,
              color:
                  isEnabled
                      ? const Color(0xFF8B4513)
                      : Colors.grey.withValues(alpha: 0.5),
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}
