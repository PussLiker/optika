import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/brand.dart';
import 'package:optika/models/product.dart';

class ApiService {
  final String baseUrl = 'http://192.168.0.14:5197/api';

  // Метод для получения списка брендов
  Future<List<Brand>> getBrands() async {
    final response = await http.get(Uri.parse('$baseUrl/Brand'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Brand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }

  // Метод для получения списка товаров с подгрузкой бренда
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/Product'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Получаем список брендов (для связывания с товарами)
      List<Brand> brands = await getBrands();

      return data.map((item) {
        // Находим бренд по ID
        Brand? brand = brands.firstWhere((b) => b.id == item['brandId']);

        // Создаем объект Product с брендом
        return Product.fromJson(item, brand: brand);
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
