import 'package:flutter/material.dart';
import 'package:optika/models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<int, Product> _items = {};

  Map<int, Product> get items => _items;

  // Метод для добавления товара в корзину
  void addToCart(Product product) {
    if (_items.containsKey(product.id)) {
      // Если товар уже есть в корзине, увеличиваем его количество
      _items[product.id]!.quantity++;
    } else {
      // Если товар в корзине нет, добавляем его с количеством 1
      _items[product.id] = product..quantity = 1;
    }
    notifyListeners();
  }


  // Метод для удаления товара из корзины
  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Метод для очистки корзины
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  // Метод для получения общей стоимости
  double get totalPrice => _items.values.fold(0, (sum, item) => sum + item.price * item.quantity);

  // Метод для получения общего количества товаров в корзине
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);
}
