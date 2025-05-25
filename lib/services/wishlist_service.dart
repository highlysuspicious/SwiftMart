// services/wishlist_service.dart
class WishlistManager {
  static final List<Map<String, dynamic>> _wishlistItems = [];

  static List<Map<String, dynamic>> get wishlistItems => _wishlistItems;

  static void addToWishlist(Map<String, dynamic> product) {
    if (!isInWishlist(product)) {
      _wishlistItems.add(product);
    }
  }

  static void removeFromWishlist(Map<String, dynamic> product) {
    _wishlistItems.removeWhere((item) => item['id'] == product['id']);
  }

  static bool isInWishlist(Map<String, dynamic> product) {
    return _wishlistItems.any((item) => item['id'] == product['id']);
  }

  static void clearWishlist() {
    _wishlistItems.clear();
  }
}
