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

  // Получить корзину пользователя с сервера
  Future<List<CartItem>> getCartFromServer() async {
    final response = await http.get(
      Uri.parse('$baseUrl/$_cartEndpoint'),
      headers: await _buildHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load cart. Status: ${response.statusCode}');
    }
  }
  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cart/add'),
      headers: await _buildHeaders(),
      body: jsonEncode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    print('Ответ от сервера: ${response.statusCode}');
    print('Тело ответа: ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Не удалось добавить товар в корзину');
    }
  }




  Future<void> updateCartItem({
    required int productId,
    required int quantity,
  }) async {
    final headers = await _buildHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/cart/update'),
      headers: headers,
      body: json.encode({
        'productId': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item. Status: ${response.statusCode}');
    }
  }


  Future<void> removeFromCart({

    required int productId,
  }) async {
    final headers = await _buildHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$_cartEndpoint/$productId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to remove from cart. Status: ${response.statusCode}');
    }
  }

  Future<void> clearCart() async {
    final headers = await _buildHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/$_cartEndpoint'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart. Status: ${response.statusCode}');
    }
  }

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _storage.read(key: 'auth_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

}