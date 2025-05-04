class CartItem {
  final int productId;
  final String name;
  final String? imageUrl;
  final int quantity;
  final double price;
  final String? brandName;

  CartItem({
    required this.productId,
    required this.name,
    required this.imageUrl,
    required this.quantity,
    required this.price,
    this.brandName
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['productId'],
      name: json['name'],
      imageUrl: json['imageUrl'] ?? '',
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'name': name,
      'imageUrl': imageUrl,
      'quantity': quantity,
      'price': price
    };
  }
}
