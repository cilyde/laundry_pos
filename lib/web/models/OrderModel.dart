// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class OrderItem {
//   final String name;
//   final String service;
//   final int quantity;
//   final double price;
//
//   OrderItem({
//     required this.name,
//     required this.service,
//     required this.quantity,
//     required this.price,
//   });
//
//   factory OrderItem.fromMap(Map<String, dynamic> map) {
//     return OrderItem(
//       name: map['name'],
//       service: map['service'],
//       quantity: map['quantity'],
//       price: (map['price'] as num).toDouble(),
//     );
//   }
// }
//
// class OrderModel {
//   final String customerId;
//   final DateTime timestamp;
//   final double total;
//   final List<OrderItem> items;
//
//   OrderModel({
//     required this.customerId,
//     required this.timestamp,
//     required this.total,
//     required this.items,
//   });
//
//   factory OrderModel.fromMap(Map<String, dynamic> map) {
//     // Safely get items as a list
//     final itemsRaw = map['items'] as List<dynamic>? ?? [];
//
//     return OrderModel(
//       customerId: map['customer_id'] as String,
//       timestamp: (map['timestamp'] as Timestamp).toDate(),
//       total: (map['total'] as num).toDouble(),
//       items: itemsRaw
//           .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
//           .toList(),
//     );
//   }
//
// }


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
