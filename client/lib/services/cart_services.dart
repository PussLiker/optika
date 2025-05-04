import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/services/api_config.dart';
import '../models/cart_item.dart';

class CartService {
  final String baseUrl = ApiConfig.baseUrl;

  Future<List<CartItem>> getCartFromServer(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/cart/$userId'));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart from server');
    }
  }

  Future<void> saveCartToServer(List<CartItem> cartItems, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cart/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'items': cartItems.map((e) => e.toJson()).toList()}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save cart to server');
    }
  }
}
