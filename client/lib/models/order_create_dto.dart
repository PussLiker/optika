import 'order_item_create_dto.dart';

class OrderCreateDto {
  final int userId;
  final List<OrderItemCreateDto> items;
  final double totalPrice;
  final String status;

  OrderCreateDto({
    required this.userId,
    required this.items,
    required this.totalPrice,
    this.status = 'Pending',
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'totalPrice': totalPrice,
    'status': status,
  };
}
