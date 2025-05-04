import 'package:flutter/material.dart';
import 'package:optika/providers/cart_provider.dart';
import 'package:optika/models/cart_item.dart';
import 'package:optika/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../services/order_service.dart';
import '../models/order_request.dart';
import '../services/api_config.dart';

class CartScreen extends StatefulWidget {
  final int userId;

  const CartScreen({super.key, required this.userId});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      await Provider.of<CartProvider>(context, listen: false).loadCart(widget.userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить корзину с сервера')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Корзина',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        ),
        backgroundColor: const Color(0xFF045300),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () => _showClearCartConfirmation(context, cartProvider),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.cartItems.isEmpty
          ? const Center(child: Text('Ваша корзина пуста'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.cartItems.length,
              itemBuilder: (context, index) {
                final item = cartProvider.cartItems.values.elementAt(index);
                return _buildCartItem(item, cartProvider);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Общая стоимость:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(2)} руб',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12, 16, 16),
            child: ElevatedButton(
              onPressed: () async {
                if (cartProvider.cartItems.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Корзина пуста')),
                  );
                  return;
                }

                final orderRequest = OrderRequest(
                  items: cartProvider.cartItems.values.map((item) {
                    return OrderItemDto(
                      productId: item.productId,
                      quantity: item.quantity,
                      price: item.price, // фиксированная цена товара!
                    );
                  }).toList(),
                );

                final success = await OrderService.placeOrder(orderRequest);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Заказ успешно оформлен!'
                          : 'Ошибка при оформлении заказа',
                    ),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );

                if (success) cartProvider.clearCart(widget.userId);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                textStyle: const TextStyle(fontSize: 16),
              ),
              child: const Text('Оформить заказ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      height: 160,
      child: Row(
        children: [
          Container(
            width: 150,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                  ? DecorationImage(
                image: NetworkImage('${ApiConfig.baseUrl}${item.imageUrl}'),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: (item.imageUrl == null || item.imageUrl!.isEmpty)
                ? const Icon(Icons.image_not_supported, size: 40)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brandName ?? 'Неизвестно',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.price.toStringAsFixed(2)} руб',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (item.quantity > 1) {
                              provider.updateQuantity(item.productId, item.quantity - 1);
                            } else {
                              provider.removeFromCart(item.productId);
                            }
                          },
                        ),
                        Text('${item.quantity}', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            provider.updateQuantity(item.productId, item.quantity + 1);
                          },
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => provider.removeFromCart(item.productId),
                      iconSize: 24,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartConfirmation(BuildContext context, CartProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Подтвердите очистку корзины'),
        content: const Text('Вы уверены, что хотите очистить корзину?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              provider.clearCart(widget.userId);
              Navigator.pop(ctx);
            },
            child: const Text('Очистить'),
          ),
        ],
      ),
    );
  }
}
