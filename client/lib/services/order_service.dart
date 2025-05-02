import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/order_create_dto.dart';

class OrderService {
  final String baseUrl;
  final String authToken;

  OrderService({required this.baseUrl, required this.authToken});

  Future<bool> createOrder(OrderCreateDto order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode(order.toJson()),
    );

    return response.statusCode == 201;
  }
}
