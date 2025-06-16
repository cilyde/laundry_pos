import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/OrderModel.dart';

class DashboardViewModel extends ChangeNotifier {
  int ordersToday = 0;
  double salesToday = 0.0;
  int ordersThisMonth = 0;
  double salesThisMonth = 0.0;
  int customOrders = 0;
  double customSales = 0.0;

  bool isLoading = false;
  bool hasData = false;
  DashboardPeriod selectedPeriod = DashboardPeriod.today;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // inside DashboardViewModel
  Future<List<OrderModel>> fetchOrdersForCustomer(String customerId) async {
    final snapshot =
        await _firestore.collectionGroup('orders').where('customer_id', isEqualTo: customerId).orderBy('timestamp', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final items =
          (data['items'] as List).map((m) {
            return OrderItem(name: m['name'], service: m['service'], quantity: m['quantity'], price: (m['price'] as num).toDouble());
          }).toList();

      return OrderModel(id: doc.id, timestamp: (data['timestamp'] as Timestamp).toDate(), total: (data['total'] as num).toDouble(), items: items);
    }).toList();
  }

  Future<List<OrderModel>> fetchOrdersForDay(DateTime day) async {
    // Define the start and end of the target day
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));

    // Query all order documents in subcollections named 'orders' within the date range
    final snapshot =
        await _firestore
            .collectionGroup('orders')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
            .where('timestamp', isLessThan: Timestamp.fromDate(end))
            .orderBy('timestamp')
            .get();

    // Map each document to an OrderModel
    return snapshot.docs.map((doc) {
      final data = doc.data();

      // Parse items array
      final itemsData = List<Map<String, dynamic>>.from(data['items'] as List);
      final items =
          itemsData.map((m) {
            return OrderItem(
              name: m['name'] as String,
              service: m['service'] as String,
              quantity: (m['quantity'] as num).toInt(),
              price: (m['price'] as num).toDouble(),
            );
          }).toList();

      return OrderModel(id: doc.id, timestamp: (data['timestamp'] as Timestamp).toDate(), total: (data['total'] as num).toDouble(), items: items);
    }).toList();
  }

  String buildCsv(List<OrderModel> orders) {
    final sb = StringBuffer();
    // Header
    sb.writeln('Order ID,Timestamp,Item,Service,Qty,Price,Line Total');
    for (var o in orders) {
      for (var it in o.items) {
        final lineTotal = it.price * it.quantity;
        sb.writeln(
          [
            o.id,
            // you may need doc.data()['customer_id'] here if not stored on model
            '"${o.timestamp.toIso8601String()}"',
            it.name,
            it.service,
            it.quantity,
            it.price.toStringAsFixed(2),
            lineTotal.toStringAsFixed(2),
          ].join(','),
        );
      }
    }
    return sb.toString();
  }

  Future<void> loadDashboardStats({required DashboardPeriod period, DateTime? targetDate}) async {
    selectedPeriod = period;
    isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    int orders = 0;
    double sales = 0.0;

    try {
      final ordersSnapshot = await _firestore.collectionGroup('orders').get();

      for (final doc in ordersSnapshot.docs) {
        final data = doc.data();

        if (data['timestamp'] == null || data['total'] == null) continue;

        final orderTimestamp = (data['timestamp'] as Timestamp).toDate();
        final orderTotal = (data['total'] as num).toDouble();

        if (period == DashboardPeriod.today && _isSameDay(orderTimestamp, now)) {
          orders++;
          sales += orderTotal;
        } else if (period == DashboardPeriod.month && orderTimestamp.year == now.year && orderTimestamp.month == now.month) {
          orders++;
          sales += orderTotal;
        } else if (period == DashboardPeriod.customDay && targetDate != null && _isSameDay(orderTimestamp, targetDate)) {
          orders++;
          sales += orderTotal;
        } else if (period == DashboardPeriod.customMonth &&
            targetDate != null &&
            orderTimestamp.year == targetDate.year &&
            orderTimestamp.month == targetDate.month) {
          orders++;
          sales += orderTotal;
        }
      }

      // Clear previous values to avoid stale UI
      ordersToday = 0;
      salesToday = 0.0;
      ordersThisMonth = 0;
      salesThisMonth = 0.0;
      customOrders = 0;
      customSales = 0.0;

      // Set only relevant values
      switch (period) {
        case DashboardPeriod.today:
          ordersToday = orders;
          salesToday = sales;
          break;
        case DashboardPeriod.month:
          ordersThisMonth = orders;
          salesThisMonth = sales;
          break;
        case DashboardPeriod.customDay:
        case DashboardPeriod.customMonth:
          customOrders = orders;
          customSales = sales;
          break;
      }
    } catch (e) {
      print("Error fetching dashboard data: $e");
    }
    print('done');
    print(salesToday);
    print(salesThisMonth);
    print(customSales);
    hasData = true;
    isLoading = false;
    notifyListeners();
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

enum DashboardPeriod { today, month, customDay, customMonth }
