import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/services/api_config.dart';
import '../models/cart_item.dart';

class CartService {
  final String baseUrl = ApiConfig.baseUrl; // замени на IP телефона/эмулятора

  Future<List<CartItem>> getCart() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Не удалось загрузить корзину');
    }
  }

  Future<void> addToCart(int productId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'productId': productId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось добавить в корзину');
    }
  }

  Future<void> removeFromCart(int productId) async {
    final response = await http.delete(Uri.parse('$baseUrl/$productId'));

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить из корзины');
    }
  }
}
