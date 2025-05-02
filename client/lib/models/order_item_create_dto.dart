class OrderItemCreateDto {
  final int productId;
  final int quantity;
  final double price;

  OrderItemCreateDto({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantity': quantity,
    'price': price,
  };
}