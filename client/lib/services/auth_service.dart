import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/auth/login_request.dart';
import 'package:optika/models/auth/register_request.dart';
import 'package:optika/services/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = ApiConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  /// Проверка аутентификации
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// Получение роли пользователя
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  /// Регистрация нового пользователя
  static Future<Map<String, dynamic>> register(RegisterRequest request) async {
    final url = Uri.parse('$baseUrl/api/Auth/register');

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
      final responseData = jsonDecode(response.body);

      // Автоматическая авторизация после регистрации
      if (responseData['token'] != null) {
        await _saveAuthData(
          responseData['token'],
          responseData['userId'],
          responseData['role'],
        );
      }

      return responseData;
    } else {
      throw Exception('Ошибка регистрации: ${response.body}');
    }
  }

  /// Авторизация пользователя
  static Future<Map<String, dynamic>> login(LoginRequest request) async {
    final url = Uri.parse('$baseUrl/api/Auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': request.email,
        'password': request.password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      await _saveAuthData(
        responseData['token'],
        responseData['userId'],
        responseData['role'],
      );
      return responseData;
    } else {
      throw Exception('Ошибка авторизации: ${response.body}');
    }
  }

  /// Выход из системы
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
  }

  /// Получение токена
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Получение ID пользователя
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString(_userIdKey);
    return userId != null ? int.tryParse(userId) : null;
  }

  /// Сохранение данных аутентификации
  static Future<void> _saveAuthData(String token, dynamic userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userIdKey, userId.toString());
    await prefs.setString(_userRoleKey, role);
  }

  /// Получение заголовков с токеном
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) throw Exception('User not authenticated');

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}