class OrderRequest {
  final List<OrderItemDto> items;

  OrderRequest({required this.items});

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
  };
}

class OrderItemDto {
  final int productId;
  final int quantity;
  final double price;

  OrderItemDto({required this.productId, required this.quantity, required this.price});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'price': price
  };
}
