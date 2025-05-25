import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  /// Fetch all products from the API
  static Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch products by category
  static Future<List<dynamic>> fetchByCategory(String category) async {
    try {
      final encodedCategory = Uri.encodeComponent(category.toLowerCase());
      final response = await http.get(
        Uri.parse('$baseUrl/products/category/$encodedCategory'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products for $category: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Search products by query (searches title and category)
  static Future<List<dynamic>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        List<dynamic> products = jsonDecode(response.body);

        if (query.trim().isEmpty) {
          return products;
        }

        final searchQuery = query.toLowerCase().trim();
        return products.where((product) {
          final title = product['title']?.toString().toLowerCase() ?? '';
          final category = product['category']?.toString().toLowerCase() ?? '';
          final description = product['description']?.toString().toLowerCase() ?? '';

          return title.contains(searchQuery) ||
              category.contains(searchQuery) ||
              description.contains(searchQuery);
        }).toList();
      } else {
        throw Exception('Failed to search products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch all available categories
  static Future<List<String>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/categories'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> categories = jsonDecode(response.body);
        return categories.map((category) => category.toString()).toList();
      } else {
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch a single product by ID
  static Future<Map<String, dynamic>> fetchProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load product: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Fetch limited number of products (useful for pagination)
  static Future<List<dynamic>> fetchLimitedProducts(int limit) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  /// Sort products by various criteria
  static Future<List<dynamic>> fetchSortedProducts({
    String sortBy = 'asc', // 'asc' or 'desc'
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products?sort=$sortBy'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load sorted products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Deprecated: Use ApiService.fetchByCategory instead
@Deprecated('Use ApiService.fetchByCategory instead')
class CategoryService {
  static const baseUrl = 'https://fakestoreapi.com';

  static Future<List<dynamic>> fetchByCategory(String category) async {
    return ApiService.fetchByCategory(category);
  }
}

// Deprecated: Use ApiService.searchProducts instead
@Deprecated('Use ApiService.searchProducts instead')
Future<List<dynamic>> searchProducts(String query) async {
  return ApiService.searchProducts(query);
}