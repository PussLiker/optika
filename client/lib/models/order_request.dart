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

  OrderItemDto({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
  };
}
