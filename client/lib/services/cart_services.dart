import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/services/api_config.dart';
import '../models/cart_item.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class CartService {
  final String baseUrl = ApiConfig.baseUrl;
  final String _cartEndpoint = 'api/cart';
  final _storage = FlutterSecureStorage();

  Future<String> _getUserToken() async {
    return await _storage.read(key: 'auth_token') ?? '';
  }
  Future<List<CartItem>> getCartFromServer(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$_cartEndpoint'),
      headers: _buildHeaders(userId),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart. Status: ${response.statusCode}');
    }
  }

  Future<void> addToCart({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/$_cartEndpoint/add'),
      headers: _buildHeaders(userId),
      body: json.encode({
        'ProductId': productId,
        'Quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add to cart. Status: ${response.statusCode}');
    }
  }

  Future<void> updateCartItem({
    required int userId,
    required int productId,
    required int quantity,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$_cartEndpoint/update'),
      headers: _buildHeaders(userId),
      body: json.encode({
        'ProductId': productId,
        'Quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item. Status: ${response.statusCode}');
    }
  }

  Future<void> removeFromCart({
    required int userId,
    required int productId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$_cartEndpoint/$productId'),
      headers: _buildHeaders(userId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart. Status: ${response.statusCode}');
    }
  }

  Future<void> clearCart(int userId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$_cartEndpoint/clear'),
      headers: _buildHeaders(userId),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart. Status: ${response.statusCode}');
    }
  }

  Map<String, String> _buildHeaders(int userId) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${_getUserToken()}', //  JWT
    };
  }
}