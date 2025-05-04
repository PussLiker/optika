import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_services.dart';

class CartProvider with ChangeNotifier {
  Map<int, CartItem> _cartItems = {};

  // Получить все товары в корзине
  Map<int, CartItem> get cartItems => _cartItems;

  // Подсчёт всех товаров
  int get totalItems => _cartItems.length;

  // Общая стоимость корзины
  double get totalPrice {
    double total = 0.0;
    for (var item in _cartItems.values) {
      total += item.price * item.quantity;
    }
    return total;
  }

  // Метод для загрузки корзины с сервера
  Future<void> loadCart(int userId) async {
    try {
      final cartService = CartService();
      final items = await cartService.getCartFromServer();
      _cartItems = {
        for (var item in items) item.productId: item
      }; // Заполняем корзину
      notifyListeners();
    } catch (e) {
      // Обработка ошибок
    }
  }

  // Удалить товар из корзины
  Future<void> removeFromCart(int productId) async {
    try {
      final cartService = CartService();
      await cartService.removeFromCart(productId: productId); // Удаляем товар с сервера
      _cartItems.remove(productId); // Удаляем товар локально
      notifyListeners();
    } catch (e) {
      // Обработка ошибок
    }
  }

  // Очистить корзину
  Future<void> clearCart(int userId) async {
    try {
      final cartService = CartService();
      await cartService.clearCart(); // Очищаем корзину на сервере
      _cartItems.clear(); // Очищаем локальную корзину
      notifyListeners();
    } catch (e) {
      // Обработка ошибок
    }
  }

  // Добавление или увеличение количества товара
  Future<void> addProduct(CartItem item) async {
    try {
      final cartService = CartService();
      await cartService.addToCart(
        productId: item.productId,
        quantity: item.quantity,
      );

      if (_cartItems.containsKey(item.productId)) {
        _cartItems[item.productId]!.quantity += item.quantity;
      } else {
        _cartItems[item.productId] = item;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Ошибка при добавлении в корзину: $e');
    }
  }


  // Обновление количества товара
  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      final cartService = CartService();
      await cartService.updateCartItem(
        productId: productId,
        quantity: quantity,
      );

      if (_cartItems.containsKey(productId)) {
        if (quantity <= 0) {
          await removeFromCart(productId);
        } else {
          _cartItems[productId]!.quantity = quantity;
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Ошибка при обновлении количества: $e');
    }
  }

}
