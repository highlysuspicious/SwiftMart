import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../category/cart_screen.dart';
import '../category/order_history_screen.dart';
import '../category/wishlist_screen.dart';
import '/widgets/product_card.dart';
import '/services/api_service.dart';
import '/screens/category/category_screen.dart';
import 'Contactus.dart';
import 'profile_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _allProducts = [];
  List<dynamic> _filteredProducts = [];
  bool _isLoading = true;
///hi
  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearch);
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Starting to load products...');
      final products = await ApiService.fetchProducts();
      print('Products loaded: ${products.length}');

      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading products: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _allProducts = [];
          _filteredProducts = [];
        });
      }
    }
  }

  void _handleSearch() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredProducts = _allProducts;
      });
    } else {
      final results = _allProducts.where((product) {
        final name = product['title'].toString().toLowerCase();
        final category = product['category'].toString().toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();

      setState(() {
        _filteredProducts = results;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // 🛍️ Logo
                Image.asset(
                  'assets/fluttercommerce.png',
                  height: 40,
                ),
                const SizedBox(width: 12),

                // 📝 App Name or Search Field
                Expanded(
                  child: _isSearching
                      ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: Colors.brown.shade400),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(fontSize: 16),
                  )
                      : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Flutter',
                              style: GoogleFonts.playfairDisplay(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown.shade800,
                              ),
                            ),
                            TextSpan(
                              text: 'commerce',
                              style: GoogleFonts.montserrat(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.brown.shade300,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Shopping Refined',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.brown.shade400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // 🔍 Search Icon
                IconButton(
                  icon: Icon(
                    _isSearching ? Icons.close : Icons.search,
                    color: Colors.brown,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _filteredProducts = _allProducts; // Reset to show all products
                      }
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),

      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Show banner only when not searching
            if (!_isSearching) ...[
              // 🔥 Hero Banner
              CarouselSlider(
                options: CarouselOptions(height: 180, autoPlay: true),
                items: _banners.map((url) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(url, fit: BoxFit.cover, width: double.infinity),
                  );
                }).toList(),
              ).animate().fade(duration: 600.ms).scale(),
              // Category and History buttons
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => CategoryScreen()),
                          );
                        },
                        icon: Icon(Icons.category, size: 18),
                        label: Text('List'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => OrderHistoryScreen()),
                          );
                        },
                        icon: Icon(Icons.history, size: 18),
                        label: Text('Log'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ContactUsScreen()),
                          );
                        },
                        icon: Icon(Icons.support_agent, size: 18),
                        label: Text('Help'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown.shade400,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 14),
                          textStyle: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              ,
              const SizedBox(height: 24),

              // ✨ Section Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'New Arrivals',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
              ),
            ] else ...[
              // Search results header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Search Results (${_filteredProducts.length})',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown.shade700,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // 💎 Product Grid - Now uses filtered products with FutureBuilder fallback
            Expanded(
              child: _allProducts.isNotEmpty
                  ? // Use loaded products for better performance
              _filteredProducts.isEmpty && _isSearching
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.brown.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No products found',
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        color: Colors.brown.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try searching with different keywords',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.brown.shade400,
                      ),
                    ),
                  ],
                ),
              )
                  : GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.65,
                ),
                itemCount: _filteredProducts.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: _filteredProducts[index])
                      .animate()
                      .fade(duration: 300.ms)
                      .scale();
                },
              )
                  : // Fallback to FutureBuilder if products haven't loaded yet
              FutureBuilder<List<dynamic>>(
                future: ApiService.fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading products...'),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.brown.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Failed to load products',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.brown.shade400,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // This will rebuild the FutureBuilder
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: Colors.brown.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products available',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.brown.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Initialize the products list when data arrives
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_allProducts.isEmpty) {
                      setState(() {
                        _allProducts = snapshot.data!;
                        _filteredProducts = snapshot.data!;
                        _isLoading = false;
                      });
                    }
                  });

                  // Display the products
                  final productsToShow = _isSearching ? _filteredProducts : snapshot.data!;

                  if (productsToShow.isEmpty && _isSearching) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.brown.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products found',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try searching with different keywords',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown.shade400,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: productsToShow.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: productsToShow[index])
                          .animate()
                          .fade(duration: 300.ms)
                          .scale();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildFloatingNavbar(),
    );
  }

  final List<String> _banners = [
    'https://images.unsplash.com/photo-1558769132-cb1aea458c5e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=600&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8ZmFzaGlvbnxlbnwwfHwwfHx8MA%3D%3D',
    'https://images.unsplash.com/photo-1506152983158-b4a74a01c721?q=80&w=2073&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://plus.unsplash.com/premium_photo-1683817138481-dcdf64a40859?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
    'https://images.unsplash.com/flagged/photo-1570733117311-d990c3816c47?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
  ];

  Widget _buildFloatingNavbar() {
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
          const Icon(Icons.home, color: Colors.brown),
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
}