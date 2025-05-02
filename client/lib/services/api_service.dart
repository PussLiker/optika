import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:optika/models/brand.dart';
import 'package:optika/models/product.dart';
import 'package:optika/services/api_config.dart';


class ApiService {
  // Метод для получения списка брендов
  Future<List<Brand>> getBrands() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Brand'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((item) => Brand.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load brands');
    }
  }


  // Метод для получения списка товаров с подгрузкой бренда
  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/Product'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      // Загружаем список брендов
      List<Brand> brands = await getBrands();

      return data.map((item) {
        // Преобразуем каждый товар из JSON в объект Product
        Product product = Product.fromJson(item);

        // Находим бренд по ID
        product.brand = brands.firstWhere((brand) => brand.id == product.brandId, orElse: () => Brand(id: 0, name: 'Неизвестный бренд'));

        return product;
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }
}
