import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '/widgets/product_card.dart';
import '/services/api_service.dart';
import '/screens/category/category_screen.dart';
import 'package:google_fonts/google_fonts.dart';

bool _isSearching = false;
TextEditingController _searchController = TextEditingController();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

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
                      hintText: 'Search...',
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
                      if (!_isSearching) _searchController.clear();
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
            Padding(
              padding: const EdgeInsets.only(right: 16, top: 12),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryScreen()),
                    );
                  },
                  icon: const Icon(Icons.grid_view, size: 20),
                  label: const Text('Categories'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown.shade100,
                    foregroundColor: Colors.brown.shade800,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    textStyle: GoogleFonts.montserrat(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ),


            // 🔥 Hero Banner
            CarouselSlider(
              options: CarouselOptions(height: 180, autoPlay: true),
              items: _banners.map((url) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(url, fit: BoxFit.cover, width: double
                      .infinity),
                );
              }).toList(),
            ).animate().fade(duration: 600.ms).scale(),

            const SizedBox(height: 24),

            // ✨ Section Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('New Arrivals',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade700,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 💎 Product Grid
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                future: ApiService.fetchProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      return ProductCard(product: snapshot.data![index])
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
        children: const [
          Icon(Icons.home, color: Colors.brown),
          Icon(Icons.favorite_border, color: Colors.brown),
          Icon(Icons.shopping_cart_outlined, color: Colors.brown),
          Icon(Icons.person_outline, color: Colors.brown),
        ],
      ),
    );
  }
}