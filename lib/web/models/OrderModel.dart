
// lib/web/models/order_model.dart
class OrderModel {
  final String id;
  final DateTime timestamp;
  final double total;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.timestamp,
    required this.total,
    required this.items,
  });
}

class OrderItem {
  final String name;
  final String service;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.service,
    required this.quantity,
    required this.price,
  });
}
