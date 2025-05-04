import 'package:flutter/material.dart';
import 'package:optika/models/cart_item.dart';
import 'package:optika/models/product.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/cart_services.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};
  final CartService _cartService = CartService();

  Map<int, CartItem> get items => Map.unmodifiable(_items);

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  Future<void> _syncWithServer() async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not authenticated');

      final serverItems = await _cartService.getCartFromServer(userId);
      _items.clear();
      for (var item in serverItems) {
        _items[item.productId] = item;
      }
      notifyListeners();
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }

  Future<int?> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userId');
  }

  Future<void> loadCart() async {
    await _syncWithServer();
  }

  Future<void> addProduct(Product product) async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not authenticated');

      // 1. Добавляем на сервер
      await _cartService.addToCart(
          userId: userId,
          productId: product.id,
          quantity: 1
      );

      // 2. Обновляем локальное состояние
      if (_items.containsKey(product.id)) {
        _items.update(
            product.id,
                (item) => item.copyWith(quantity: item.quantity + 1)
        );
      } else {
        _items[product.id] = CartItem.fromProduct(product);
      }

      notifyListeners();
    } catch (e) {
      print('Add to cart error: $e');
      rethrow;
    }
  }

  Future<void> updateQuantity(int productId, int newQuantity) async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not authenticated');

      if (newQuantity <= 0) {
        await removeFromCart(productId);
        return;
      }

      // 1. Обновляем на сервере
      await _cartService.updateCartItem(
          userId: userId,
          productId: productId,
          quantity: newQuantity
      );

      // 2. Локальное обновление
      if (_items.containsKey(productId)) {
        _items.update(
            productId,
                (item) => item.copyWith(quantity: newQuantity)
        );
        notifyListeners();
      }
    } catch (e) {
      print('Update quantity error: $e');
      rethrow;
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not authenticated');

      // 1. Удаляем с сервера
      await _cartService.removeFromCart(
          userId: userId,
          productId: productId
      );

      // 2. Локальное удаление
      _items.remove(productId);
      notifyListeners();
    } catch (e) {
      print('Remove from cart error: $e');
      rethrow;
    }
  }

  Future<void> clearCart() async {
    try {
      final userId = await _getUserId();
      if (userId == null) throw Exception('User not authenticated');

      await _cartService.clearCart(userId);
      _items.clear();
      notifyListeners();
    } catch (e) {
      print('Clear cart error: $e');
      rethrow;
    }
  }
}