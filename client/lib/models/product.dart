import 'package:optika/models/brand.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final double price;
  final String? imageUrl;
  final int brandId; // ID бренда
  final Brand? brand; // Объект бренда
  final int categoryId;
  final bool isActive;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.imageUrl,
    required this.brandId,
    this.brand, // Добавляем объект бренда
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
  });

  // Фабричный метод для создания Product из JSON
  factory Product.fromJson(Map<String, dynamic> json, {Brand? brand}) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      imageUrl: json['imageUrl'],
      brandId: json['brandId'],
      brand: brand, // Передаем объект бренда
      categoryId: json['categoryId'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Метод для преобразования Product в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'brandId': brandId,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
