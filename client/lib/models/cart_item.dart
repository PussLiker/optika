class CartItem {
  final int id;
  final int productId;
  final String name;
  final String imageUrl;
  final int quantity;
  final double price;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
