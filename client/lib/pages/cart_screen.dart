import 'package:flutter/material.dart';
import 'package:optika/services/api_config.dart';
import '../models/product.dart';
import 'package:optika/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  final Function onClearCart;

  const CartScreen({super.key, required this.onClearCart});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Корзина', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),),
        backgroundColor: Color(0xFF045300),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _showClearCartConfirmation(context, cartProvider);  // Подтверждение очистки

            },
          ),
        ],
      ),
      body: cartProvider.items.isEmpty
          ? Center(child: Text('Ваша корзина пуста'))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cartProvider.items.length,
              itemBuilder: (context, index) {
                final product = cartProvider.items.values.toList()[index];
                return _buildCartItem(product, cartProvider);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Общая стоимость:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${cartProvider.totalPrice.toStringAsFixed(2)} руб',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 12, 16, 16),
            child: ElevatedButton(
              onPressed: () {
                // Логика оформления заказа
              },
              child: Text('Оформить заказ'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 32),  // Увеличение горизонтального отступа
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildCartItem(Product product, CartProvider cartProvider) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      height: 160, // Чтобы помещалось 3–5 карточек
      child: Row(
        children: [
          // Левый столбец: изображение
          Container(
            width: 150,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: product.imageUrl != null
                  ? DecorationImage(
                image: NetworkImage('${ApiConfig.baseUrl}${product.imageUrl}'),
                fit: BoxFit.cover,
              )
                  : null,
            ),
            child: product.imageUrl == null
                ? Icon(Icons.image_not_supported, size: 40)
                : null,
          ),

          SizedBox(width: 12),

          // Правый столбец: текст и кнопки
          Expanded(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Верх: текстовая информация
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand?.name ?? '',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      product.name,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${product.price.toStringAsFixed(2)} руб',
                      style: TextStyle(fontSize: 15),
                    ),
                  ]
                ),

                // Низ: кнопки
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Количество
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if (product.quantity > 1) {
                              product.quantity--;
                              cartProvider.notifyListeners();
                            } else {
                              cartProvider.removeFromCart(product.id);
                            }
                          },
                        ),
                        Text('${product.quantity}', style: TextStyle(fontSize: 16)),
                        IconButton(
                          icon: Icon(Icons.add),
                          iconSize: 20,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            product.quantity++;
                            cartProvider.notifyListeners();
                          },
                        ),
                      ],
                    ),

                    // Удалить
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => cartProvider.removeFromCart(product.id),
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



  void _showClearCartConfirmation(BuildContext context, CartProvider cartProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Подтвердите очистку корзины'),
          content: Text('Вы уверены, что хотите очистить корзину?'),
          actionsPadding: EdgeInsets.only(right: 14, bottom: 12),
          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Отмена'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.pop(context);
              },
              child: Text('Очистить'),
            ),

          ],
        );
      },
    );
  }

}
