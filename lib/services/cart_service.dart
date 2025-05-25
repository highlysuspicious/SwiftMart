class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];

  static List<Map<String, dynamic>> get cartItems => _cartItems;

  /// Add a product to the cart
  static void addToCart(Map<String, dynamic> product) {
    _cartItems.add(Map<String, dynamic>.from(product));
  }

  /// Removes one instance of the product (by ID match)
  static void removeOneFromCart(String productId) {
    final index = _cartItems.indexWhere((item) => item['id'].toString() == productId);
    if (index != -1) {
      _cartItems.removeAt(index);
    }
  }

  /// Removes all instances of the product (optional utility)
  static void removeAllOfProduct(String productId) {
    _cartItems.removeWhere((item) => item['id'].toString() == productId);
  }

  static void clearCart() {
    _cartItems.clear();
  }
}
