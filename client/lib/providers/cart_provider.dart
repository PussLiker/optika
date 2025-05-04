import 'package:flutter/material.dart';
import 'package:optika/models/cart_item.dart';
import 'package:optika/models/product.dart';

class CartProvider with ChangeNotifier {
  final Map<int, CartItem> _items = {};

  Map<int, CartItem> get items => _items;

  double get totalPrice =>
      _items.values.fold(0.0, (sum, item) => sum + item.price * item.quantity);

  void addToCart(CartItem item) {
    if (_items.containsKey(item.productId)) {
      _items.update(
        item.productId,
            (existing) => CartItem(
          productId: existing.productId,
          name: existing.name,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + item.quantity,
          price: existing.price,
        ),
      );
    } else {
      _items[item.productId] = item;
    }
    notifyListeners();
  }

  void addProduct(Product product) {
    addToCart(CartItem(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      quantity: 1,
      price: product.price,
      brandName: product.brand!.name,
    ));
  }


  void updateQuantity(int productId, int quantity) {
    if (_items.containsKey(productId)) {
      final item = _items[productId]!;
      _items[productId] = CartItem(
        productId: item.productId,
        name: item.name,
        imageUrl: item.imageUrl,
        quantity: quantity,
        price: item.price,
      );
      notifyListeners();
    }
  }

  void removeFromCart(int productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
