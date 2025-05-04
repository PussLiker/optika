import 'package:optika/models/product.dart';

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

  CartItem copyWith({
    int? quantity,
  }) {
    return CartItem(
      productId: productId,
      name: name,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
      price: price,
      brandName: brandName,
    );
  }

  factory CartItem.fromProduct(Product product, {int quantity = 1}) {
    return CartItem(
      productId: product.id,
      name: product.name,
      imageUrl: product.imageUrl,
      price: product.price,
      brandName: product.brand?.name,
      quantity: quantity,
    );
  }

  CartItem.fromJson(Map<String, dynamic> json)
      : productId = json['productId'],
        name = json['name'],
        price = json['price'].toDouble(),
        imageUrl = json['imageUrl'],
        brandName = json['brandName'],
        quantity = json['quantity'];

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
