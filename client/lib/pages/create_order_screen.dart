import 'package:flutter/material.dart';

class CreateOrderScreen extends StatefulWidget {
  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _userId;
  String _status = 'Pending';
  List<OrderItemForm> _items = [OrderItemForm()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Создать заказ')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // User ID
              TextFormField(
                decoration: const InputDecoration(labelText: 'ID пользователя'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Введите ID';
                  if (int.tryParse(value) == null) return 'Только цифры';
                  return null;
                },
                onSaved: (value) => _userId = int.parse(value!),
              ),

              const SizedBox(height: 20),
              const Text('Товары', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

              ..._items.map((item) => item),

              TextButton.icon(
                onPressed: () {
                  setState(() => _items.add(OrderItemForm()));
                },
                icon: const Icon(Icons.add),
                label: const Text('Добавить товар'),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Оформить заказ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();

      final order = {
        'userId': _userId,
        'totalPrice': _items.fold(0.0, (sum, item) => sum + item.price * item.quantity),
        'status': _status,
        'items': _items.map((i) => i.toJson()).toList(),
      };

      // Здесь отправка на сервер через http или Dio
      print('Заказ сформирован: $order');
    }
  }
}

class OrderItemForm extends StatefulWidget {
  int productId = 0;
  int quantity = 1;
  double price = 0.01;

  @override
  State<OrderItemForm> createState() => _OrderItemFormState();

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'price': price,
  };
}

class _OrderItemFormState extends State<OrderItemForm> {
  final _productIdController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _priceController = TextEditingController(text: '0.01');

  @override
  void dispose() {
    _productIdController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'ID товара'),
              keyboardType: TextInputType.number,
              controller: _productIdController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Обязательное поле';
                if (int.tryParse(value) == null) return 'Введите число';
                return null;
              },
              onSaved: (value) => widget.productId = int.parse(value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Количество'),
              keyboardType: TextInputType.number,
              controller: _quantityController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Обязательное поле';
                final val = int.tryParse(value);
                if (val == null || val <= 0) return 'Должно быть больше 0';
                return null;
              },
              onSaved: (value) => widget.quantity = int.parse(value!),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Цена'),
              keyboardType: TextInputType.number,
              controller: _priceController,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Обязательное поле';
                final val = double.tryParse(value);
                if (val == null || val <= 0) return 'Цена должна быть > 0';
                return null;
              },
              onSaved: (value) => widget.price = double.parse(value!),
            ),
          ],
        ),
      ),
    );
  }
}
