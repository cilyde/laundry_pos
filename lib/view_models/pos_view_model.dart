import 'package:flutter/material.dart';

import '../models/cloth_item.dart';
import '../services/firebase_service.dart';
import '../services/print_service.dart';
import '../utils/translation.dart';

String tr(String key, String lang) => translations[key.toLowerCase()]?[lang] ?? key;

// lib/view_models/pos_view_model.dart

class POSViewModel extends ChangeNotifier {
  final PrinterService _printer;
  bool _isLoading=false;

  bool get isLoading =>_isLoading;

  POSViewModel(this._printer) {
    _initPrinter();
  }

  Future<void> _initPrinter() async {
    final ok = await _printer.initPrinter();
    if (!ok) debugPrint('Printer initialization failed.');
  }

  ServiceType currentService = ServiceType.wash;

  final Map<ServiceType, List<ClothItem>> _selectedItemsByService = {
    ServiceType.wash: [],
    ServiceType.iron: [],
    ServiceType.both: [],
  };

  Map<ServiceType, List<ClothItem>> get allSelectedItemsGrouped => _selectedItemsByService;

  void changeService(ServiceType service) {
    currentService = service;
    notifyListeners();
  }

  void toggleItem(ClothItem item) {
    final items = _selectedItemsByService[currentService]!;
    final index = items.indexWhere((i) => i.name == item.name);
    if (index >= 0) {
      items[index].quantity += 1;
    } else {
      items.add(
        ClothItem(
          name: item.name,
          washPrice: item.washPrice,
          ironPrice: item.ironPrice,
          quantity: 1,
          isSelected: true,
          selectedService: currentService,
          img: item.img,
        ),
      );
    }
    notifyListeners();
  }

  List<ClothItem> get selectedItems => _selectedItemsByService[currentService]!;

  double get totalPrice =>
      _selectedItemsByService.values.expand((list) => list).fold(0.0, (sum, item) => sum + item.totalPrice);

  void updateQuantity(ClothItem item, int newQuantity) {
    final serviceItems = _selectedItemsByService[item.selectedService]!;
    final index = serviceItems.indexWhere(
          (e) => e.name == item.name && e.selectedService == item.selectedService,
    );
    if (index != -1) {
      serviceItems[index].quantity = newQuantity;
      notifyListeners();
    }
  }

  void removeItem(ClothItem item) {
    final items = _selectedItemsByService[item.selectedService]!;
    items.removeWhere((e) => e.name == item.name);
    notifyListeners();
  }

  Future<bool> confirmAndPrintOrder({String? phoneNumber}) async {

    _isLoading=true;
    notifyListeners();
    try {
      final selectedItems = _selectedItemsByService.values.expand((e) => e).toList();
      if(selectedItems.isEmpty){
        return false;
      }
      // Save to Firestore
      final recieptId = await FirebaseService.saveOrder(
        phoneNumber: phoneNumber,
        items: selectedItems,
        total: totalPrice,
      );

      // Prepare receipt items map
      final receiptItems = _selectedItemsByService.values
          .expand((items) => items)
          .map((item) => {
        'name': item.name,
        'service': item.selectedService.toString().split('.').last,
        'price': item.totalPrice,
        'quantity': item.quantity,
      })
          .toList();

      // Print two copies
      for (var i = 0; i < 2; i++) {
        await _printer.printOrderReceipt(
          shopName: 'Fresh & Clean Laundry',
          items: receiptItems,
          total: totalPrice,
          phoneNumber: phoneNumber,
            recieptId:recieptId
        );
        if(i!=1){
          await Future.delayed(const Duration(seconds: 3));
        }
      }

      reset();
      return true;
    } catch (e) {
      debugPrint('Error printing order: $e');
      return false;
    }
    finally
        {
          _isLoading=false;
          notifyListeners();
        }
  }

  void reset() {
    _selectedItemsByService.forEach((_, list) => list.clear());
    currentService = ServiceType.wash;
    notifyListeners();
  }
}
