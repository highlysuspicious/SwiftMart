class OrderService {
  static final List<Map<String, dynamic>> _orders = [];

  static List<Map<String, dynamic>> get orders => _orders;

  static void addOrder({
    required String name,
    required String address,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    required double total,
  }) {
    _orders.add({
      'name': name,
      'address': address,
      'paymentMethod': paymentMethod,
      'items': List.from(items),
      'total': total,
      'date': DateTime.now().toString(),
    });
  }
}
