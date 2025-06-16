// lib/web/views/daily_transactions_view.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DailyTransactionsView extends StatelessWidget {
  final DateTime selectedDate;

  const DailyTransactionsView({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    final targetDateStart = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final targetDateEnd = targetDateStart.add(Duration(days: 1));

    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions on ${selectedDate.toLocal().toString().split(' ')[0]}"),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collectionGroup('orders')
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(targetDateStart))
            .where('timestamp', isLessThan: Timestamp.fromDate(targetDateEnd))
            .orderBy('timestamp')
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No transactions found."));
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final customerId = data['customer_id'] ?? 'Unknown';
              final items = List<Map<String, dynamic>>.from(data['items'] ?? []);
              final total = data['total'] ?? 0;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text("Customer: $customerId | Total: Dhs $total"),
                  subtitle: Text("Time: ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}"),
                  children: items.map((item) {
                    return ListTile(
                      title: Text("${item['name']} (${item['service']})"),
                      trailing: Text("Qty: ${item['quantity']} x Dhs ${item['price']}", style: TextStyle(fontWeight: FontWeight.bold),),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
