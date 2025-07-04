class OrderService {
  // Internal list to store orders
  static final List<Map<String, dynamic>> _orders = [];

  // Getter to access the stored orders
  static List<Map<String, dynamic>> get orders => _orders;

  // Method to add a new order
  static void addOrder({
    required String name,
    required String address,
    required String email,
    required String phone,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required double total,
  }) {
    _orders.add({
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
      'paymentMethod': paymentMethod,
      'items': List.from(items),
      'total': total,
      'date': DateTime.now().toIso8601String(),
    });
  }
}
