class CartService {
  static final List<Map<String, dynamic>> _cartItems = [];

  static List<Map<String, dynamic>> get cartItems =>
      List.unmodifiable(_cartItems);

  /// Add a product to the cart or increment quantity if already exists
  static Future<void> addToCart(Map<String, dynamic> product) async {
    final existingIndex = _cartItems.indexWhere(
      (item) => item['id'] == product['id'],
    );

    if (existingIndex != -1) {
      // Product already in cart - increment quantity
      final currentQuantity = _cartItems[existingIndex]['quantity'] ?? 1;
      _cartItems[existingIndex]['quantity'] =
          currentQuantity + (product['quantity'] ?? 1);
    } else {
      // Add new product to cart
      _cartItems.add({
        ...product,
        'quantity': product['quantity'] ?? 1, // Ensure quantity exists
      });
    }
  }

  /// Removes one instance of the product (by ID match)
  static Future<void> removeOneFromCart(String productId) async {
    final index = _cartItems.indexWhere(
      (item) => item['id'].toString() == productId,
    );

    if (index != -1) {
      if (_cartItems[index]['quantity'] > 1) {
        // Decrement quantity if more than 1
        _cartItems[index]['quantity'] -= 1;
      } else {
        // Remove completely if quantity is 1
        _cartItems.removeAt(index);
      }
    }
  }

  /// Removes all instances of the product
  static Future<void> removeAllOfProduct(String productId) async {
    _cartItems.removeWhere((item) => item['id'].toString() == productId);
  }

  /// Clear the entire cart
  static Future<void> clearCart() async {
    _cartItems.clear();
  }

  /// Update the product in the cart with new data
  static Future<void> updateCartItem(
    Map<String, dynamic> updatedProduct,
  ) async {
    final index = _cartItems.indexWhere(
      (item) => item['id'] == updatedProduct['id'],
    );

    if (index != -1) {
      _cartItems[index] = {
        ..._cartItems[index], // Keep existing properties
        ...updatedProduct, // Apply updates
      };
    }
  }

  /// Remove a product entirely from the cart
  static Future<void> removeFromCart(Map<String, dynamic> product) async {
    _cartItems.removeWhere((item) => item['id'] == product['id']);
  }

  /// Get total number of items in cart (summing quantities)
  static int get itemCount {
    return _cartItems.fold<int>(
      0,
      (sum, item) => sum + (item['quantity'] ?? 1) as int,
    );
  }

  /// Get total cart value
  static double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) {
      final price = double.tryParse(item['price']?.toString() ?? '0') ?? 0;
      final quantity = item['quantity'] ?? 1;
      return sum + (price * quantity);
    });
  }

  /// Check if product exists in cart
  static bool containsProduct(String productId) {
    return _cartItems.any((item) => item['id'].toString() == productId);
  }
}
