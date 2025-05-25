import 'package:flutter/material.dart';
import '/services/wishlist_service.dart';
import '../screens/category/product_detail_screen.dart';
import '/services/cart_service.dart';

class ProductCard extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCard({required this.product, super.key});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  late bool isFavorited;

  @override
  void initState() {
    super.initState();
    isFavorited = WishlistManager.isInWishlist(widget.product);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: widget.product),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(widget.product['image'], fit: BoxFit.cover, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product['title'], maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text("\$${widget.product['price']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add_shopping_cart),
                        onPressed: () {
                          CartService.addToCart(widget.product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Added to cart')),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorited ? Icons.favorite : Icons.favorite_border,
                          color: isFavorited ? Colors.red : null,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFavorited) {
                              WishlistManager.removeFromWishlist(widget.product);
                              isFavorited = false;
                            } else {
                              WishlistManager.addToWishlist(widget.product);
                              isFavorited = true;
                            }
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isFavorited ? 'Added to wishlist' : 'Removed from wishlist')),
                          );
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
