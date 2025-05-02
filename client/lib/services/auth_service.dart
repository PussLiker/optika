import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/auth/login_request.dart';
import 'package:optika/models/auth/register_request.dart';
import 'package:optika/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = ApiConfig.baseUrl;


  static Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }
  /// Регистрация нового пользователя
  static Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/api/auth/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': request.name,
        'lastName': request.lastName,
        'email': request.email,
        'password': request.password,
        'role': request.role,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  /// Авторизация пользователя
  static Future<Map<String, dynamic>> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': request.email,
        'password': request.password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка авторизации: ${response.body}');
    }
  }
}
