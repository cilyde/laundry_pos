import 'package:flutter/foundation.dart';
import '../models/cloth_item.dart';
import '../services/firebase_service.dart';
import '../services/print_service.dart';


class HomeViewModel extends ChangeNotifier {
  final PrinterService _printer;

  HomeViewModel(this._printer) {
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    final ok = await _printer.initPrinter();
    if (!ok) {
      debugPrint("Printer initialization failed.");
    }
  }

  // Cloth items and selection state
  List<ClothItem> clothItems = [
    ClothItem(name: "Shirt", washPrice: 5.0, ironPrice: 3.0, img:'assets/images/shirt.png', selectedService: ServiceType.wash),
    ClothItem(name: "Pants", washPrice: 6.0, ironPrice: 4.0, img:'assets/images/pants.png', selectedService: ServiceType.wash),
    ClothItem(name: "Gown", washPrice: 7.0, ironPrice: 5.0, img:'assets/images/gown.png', selectedService: ServiceType.wash),
  ];

  void toggleSelection(int index) {
    clothItems[index].isSelected = !clothItems[index].isSelected;
    notifyListeners();
  }

  void setService(int index, ServiceType service) {
    clothItems[index].selectedService = service;
    notifyListeners();
  }

  double get totalPrice => clothItems
      .where((item) => item.isSelected && item.selectedService != null)
      .map((item) => item.totalPrice)
      .fold(0.0, (a, b) => a + b);

  // Future<void> confirmAndPrintOrder() async {
  //   // 1. Save to Firebase
  //   await FirebaseService.saveOrder(clothItems, totalPrice);
  //
  //   // 2. Prepare data for the receipt
  //   final items = clothItems
  //       .where((i) => i.isSelected && i.selectedService != null)
  //       .map((i) => {
  //     'name': i.name,
  //     'service': i.selectedService.toString().split('.').last,
  //     'price': i.totalPrice,
  //   }).toList();
  //
  //   // 3. Print two copies
  //   for (int copy = 0; copy < 2; copy++) {
  //     await _printer.printOrderReceipt(
  //       shopName: 'My Laundry Shop',
  //       items: items,
  //       total: totalPrice,
  //     );
  //     // slight delay between copies (optional)
  //     await Future.delayed(Duration(milliseconds: 500));
  //   }
  // }

  /// Confirms the order: saves to Firebase and prints two copies.
  Future<bool> confirmAndPrintOrder({String? phoneNumber}) async {
    try{
      // 1. Save to Firestore (handles optional phone number)
      await FirebaseService.saveOrder(
        phoneNumber: phoneNumber,
        items: clothItems,
        total: totalPrice,
      );

      // 2. Prepare receipt items
      final receiptItems = clothItems
          .where((item) => item.isSelected && item.selectedService != null)
          .map((item) =>
      {
        'name': item.name,
        'service': item.selectedService
            .toString()
            .split('.')
            .last,
        'price': item.totalPrice,
        'quantity': item.quantity
      })
          .toList();

      // 3. Print two copies
      TODO:
      for (var i = 0; i < 2; i++) {
        // for (var i = 0; i < 1; i++) {
        // await _printer.printOrderReceipt(
        //   shopName: 'Fresh & Clean Laundry',
        //   items: receiptItems,
        //   total: totalPrice,
        //   phoneNumber: phoneNumber
        // );
        await Future.delayed(const Duration(seconds: 3));
      }
      reset();
      return true;
    }
    catch(e){
     return false;
    }
  }

  void reset() {
    for (var item in clothItems) {
      item.isSelected = false;
      item.selectedService = ServiceType.wash;
    }
    notifyListeners();
  }
}
