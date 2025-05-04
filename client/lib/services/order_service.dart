import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/order_request.dart';
import 'api_config.dart';

class OrderService {
  static Future<bool> placeOrder(OrderRequest order) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/Order');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(order.toJson()),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }
}
