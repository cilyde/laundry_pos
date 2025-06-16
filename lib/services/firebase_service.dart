// import 'package:cloud_firestore/cloud_firestore.dart';
// import '../models/cloth_item.dart';
//
// class FirebaseService {
//   static Future<void> saveOrder(List<ClothItem> items, double total) async {
//     final selectedItems = items
//         .where((item) => item.isSelected && item.selectedService != null)
//         .map((item) => {
//       'name': item.name,
//       'service': item.selectedService.toString().split('.').last,
//       'price': item.totalPrice,
//     })
//         .toList();
//
//     await FirebaseFirestore.instance.collection('orders').add({
//       'items': selectedItems,
//       'total': total,
//       'timestamp': FieldValue.serverTimestamp(),
//     });
//   }
// }
// lib/services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cloth_item.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  /// Creates or updates a customer document.
  /// Returns the customerId used (either the phone number or an auto-ID).
  static Future<String> _ensureCustomer({
    String? phoneNumber,
    String? address,
  }) async {
    final customers = FirebaseFirestore.instance.collection('customers');
    DocumentReference<Map<String, dynamic>> docRef;

    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      // Use phone number as the document ID
      docRef = customers.doc(phoneNumber);
      await docRef.set({
        'phone_number': phoneNumber,
        if (address != null) 'address': address,
        // If new, set creation timestamp; if existing, leave unchanged
        'account_creation': FieldValue.serverTimestamp(),
        'last_purchase_date': FieldValue.serverTimestamp(),
        'loyalty_points': FieldValue.increment(0),
      }, SetOptions(merge: true));
    } else {
      // No phone number: create a new doc with auto-ID
      docRef = customers.doc();
      await docRef.set({
        if (address != null) 'address': address,
        'account_creation': FieldValue.serverTimestamp(),
        'last_purchase_date': FieldValue.serverTimestamp(),
        'loyalty_points': 0,
      });
    }

    return docRef.id;
  }

  /// Saves an order under 'orders' collection, grouped by date,
  /// and links it to a customer (by phoneNumber or auto-ID).
  static Future<String> saveOrder({
    String? phoneNumber,
    String? address,
    required List<ClothItem> items,
    required double total,
  }) async {
    // 1. Ensure we have a customer document, get its ID
    final customerId = await _ensureCustomer(
      phoneNumber: phoneNumber,
      address: address,
    );

    // 2. Prepare date key (e.g. "2025-05-28")
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // 3. Map selected items, default quantity = 1
    final selectedItems = items
        .where((i) => i.isSelected && i.selectedService != null)
        .map((i) => {
      'name': i.name,
      'service': i.selectedService.toString().split('.').last,
      'price': i.totalPrice,
      'quantity': i.quantity,
    })
        .toList();


    // 4. Reference the date‐specific subcollection
    final ordersRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(dateKey)
        .collection('orders');

    // 5. Add the order document
    final docRef = await ordersRef.add({
      'customer_id': customerId,
      'timestamp': FieldValue.serverTimestamp(),
      'total': total,
      'items': selectedItems,
    });

    // 6. Update the customer's last purchase date
    // await FirebaseFirestore.instance
    //     .collection('customers')
    //     .doc(customerId)
    //     .update({
    //   'last_purchase_date': FieldValue.serverTimestamp(),

    // 5. Update customer's last_purchase_date and increment loyalty_points
    final customerRef =
    FirebaseFirestore.instance.collection('customers').doc(customerId);

    await customerRef.update({
      'last_purchase_date': FieldValue.serverTimestamp(),
      'total_spent': FieldValue.increment(total),
    });
    return docRef.id;
  }
}
