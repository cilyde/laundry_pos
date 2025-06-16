import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laundry_os/views/quantity_editor.dart';
import 'package:provider/provider.dart';

import '../models/cloth_item.dart';
import '../utils/service_converter.dart';
import '../view_models/pos_view_model.dart';
import 'order_review_screen.dart';

/// POSView shows the main point-of-sale interface where
/// users select laundry services and items, edit quantities,
/// and proceed to order review.
///
/// Supports multi-language selection with a dialog.
///
class POSView extends StatefulWidget {
  POSView({this.openDialog = false, super.key});

  final bool openDialog; // If true, open language selection dialog on load

  @override
  State<POSView> createState() => _POSViewState();
}

class _POSViewState extends State<POSView> {
  String currentLanguage = 'en'; // Current selected UI language
  bool _isLoading = false; // Loading indicator flag

  // Hardcoded list of available clothing items with prices and images
  final List<ClothItem> availableItems = [
    // ClothItem(name, washPrice, ironPrice, image)
    ClothItem(name: 'Shirt', washPrice: 1, ironPrice: 1.5, img: 'assets/images/shirt.png'),
    ClothItem(name: 'Pants', washPrice: 1, ironPrice: 1.5, img: 'assets/images/pants.png'),
    ClothItem(name: 'Uniform', washPrice: 2.5, ironPrice: 3, img: 'assets/images/uniform.png'),
    ClothItem(name: 'Kanthoora', washPrice: 3, ironPrice: 3, img: 'assets/images/kandhoora.png'),
    ClothItem(name: 'Salwar', washPrice: 3, ironPrice: 3, img: 'assets/images/salwar.png'),
    ClothItem(name: 'Bedsheet', washPrice: 1, ironPrice: 2, img: 'assets/images/bedsheet.png'),
    ClothItem(name: 'Inner Garment', washPrice: 1, ironPrice: null, img: 'assets/images/innergarments.png'),
    ClothItem(name: 'Single Blanket', washPrice: 10, ironPrice: null, img: 'assets/images/blanket_single.png'),
    ClothItem(name: 'Double Blanket', washPrice: 15, ironPrice: null, img: 'assets/images/blanket_double.png'),
    ClothItem(name: 'Pillow Covers', washPrice: 1, ironPrice: null, img: 'assets/images/pillow_covers.png'),
    ClothItem(name: 'Suit', washPrice: 7.5, ironPrice: 7.5, img: 'assets/images/suitandpants.png'),
  ];

  // Icons corresponding to the service types
  final serviceIcons = [
    Icon(Icons.local_laundry_service, size: 50), // Wash
    Icon(Icons.iron, size: 50),                   // Iron
    Row(children: [Icon(Icons.local_laundry_service_outlined, size: 30), Icon(Icons.iron_outlined, size: 30)]), // Both
  ];

  // Opens the dialog to select UI language
  void openLanguageDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text("Select Language"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _languageButton('English', 'en'),
              _languageButton('हिन्दी', 'hi'),
              _languageButton('عربي', 'ar'),
              _languageButton('اردو', 'ur'),
            ],
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Open language dialog if requested on widget creation
    if (widget.openDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openLanguageDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<POSViewModel>(); // Provider ViewModel for state

    // Filter items based on selected service and availability of iron price
    final filteredItems = availableItems.where((item) {
      if ((vm.currentService == ServiceType.iron || vm.currentService == ServiceType.both) && item.ironPrice == null) {
        return false; // Exclude items with no iron price when iron is selected
      }
      return true;
    }).toList();

    // Debug prints, might want to remove in production
    if (kDebugMode) {
      print(vm.currentService.name);
      print('No items selected to ${vm.currentService.name}');
      print('${tr('No items selected to ${vm.currentService.name}', currentLanguage)}');
    }

    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Service type toggle buttons (Wash, Iron, Both)
          Padding(
            padding: const EdgeInsets.only(top: 40.0),
            child: ToggleButtons(
              selectedBorderColor: Colors.deepPurple,
              selectedColor: Colors.blue,
              borderColor: Colors.black54,
              isSelected: ServiceType.values.map((s) => vm.currentService == s).toList(),
              onPressed: (index) {
                vm.changeService(ServiceType.values[index]);
              },
              children: ServiceType.values
                  .map((s) => Padding(padding: const EdgeInsets.all(16), child: _serviceColumn(context, s)))
                  .toList(),
            ),
          ),

          // Grid of filtered available items to select
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return GestureDetector(
                  onTap: () => vm.toggleItem(item), // Add or remove from selection
                  child: Card(
                    elevation: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('${item.img}', height: 60),
                        SizedBox(height: 8),
                        Text(tr(item.name, currentLanguage), style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(getPriceLabel(item, vm.currentService)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Divider(),

          // Selected items section with quantity edit and remove options
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Text(
                  "${tr('selected items', currentLanguage)} (${serviceLabel(vm.currentService, currentLanguage)})",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // If no items selected, show message
                vm.selectedItems.isEmpty
                    ? Text('${tr('No items selected to ${vm.currentService.name}', currentLanguage)}')
                    : Container(
                  constraints: BoxConstraints(
                    maxHeight: 200, // Limit height for scroll
                  ),
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: vm.selectedItems.length,
                    shrinkWrap: true,
                    reverse: true,
                    itemBuilder: (context, index) {
                      final item = vm.selectedItems[index];
                      return ListTile(
                        title: Row(
                          children: [
                            Text("${tr(item.name, currentLanguage)} x${item.quantity}"),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Open quantity editor dialog
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Edit Quantity"),
                                    content: QuantityEditor(
                                      initialQuantity: item.quantity,
                                      onQuantityChanged: (newQty) {
                                        vm.updateQuantity(item, newQty);
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                                icon: Icon(Icons.delete, color: Colors.orange),
                                onPressed: () => vm.removeItem(item)),
                          ],
                        ),
                        subtitle: Text("${tr('Service', currentLanguage)}: ${serviceLabel(item.selectedService!, currentLanguage)}"),
                        trailing: Text("Dhs ${item.totalPrice.toStringAsFixed(2)}"),
                      );
                    },
                  ),
                ),

                Divider(),
                SizedBox(height: 16),

                // Bottom row: Language button, total price, and Next button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        openLanguageDialog();
                      },
                      child: Icon(Icons.language),
                    ),

                    Text("Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                    ElevatedButton.icon(
                      icon: Icon(Icons.arrow_forward),
                      label: Text(tr("Next", currentLanguage)),
                      style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        await Future.delayed(Duration(milliseconds: 300)); // For animation effect
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => OrderReviewScreen(currentLanguage: currentLanguage)),
                        ).whenComplete(() {
                          setState(() {
                            _isLoading = false;
                          });
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a column widget showing icon and label for each service type
  Column _serviceColumn(BuildContext context, ServiceType type) {
    switch (type) {
      case ServiceType.wash:
        return Column(
          children: [
            Icon(Icons.local_laundry_service, size: 50),
            Text(tr('wash', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold))
          ],
        );
      case ServiceType.iron:
        return Column(
          children: [
            Icon(Icons.iron, size: 50),
            Text(tr('iron', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold))
          ],
        );
      case ServiceType.both:
        return Column(
          children: [
            Row(
              children: [
                Icon(Icons.local_laundry_service_outlined, size: 50),
                Icon(Icons.iron_outlined, size: 50)
              ],
            ),
            Text(tr('both', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        );
    }
  }

  /// Helper widget to create a language selection button for the dialog
  Widget _languageButton(String label, String code) {
    return ElevatedButton(
      onPressed: () {
        setState(() => currentLanguage = code);
        Navigator.pop(context);
      },
      child: Text(label),
    );
  }

  /// Returns price label string for the given item and service type
  String getPriceLabel(ClothItem item, ServiceType service) {
    switch (service) {
      case ServiceType.wash:
        return 'Dhs ${item.washPrice.toStringAsFixed(2)}';
      case ServiceType.iron:
        if (item.ironPrice != null) {
          return 'Dhs ${item.ironPrice!.toStringAsFixed(2)}';
        } else {
          return 'Iron not available'; // Indicates no iron service for this item
        }
      case ServiceType.both:
        if (item.ironPrice != null) {
          final total = item.washPrice + item.ironPrice!;
          return 'Dhs ${total.toStringAsFixed(2)}';
        } else {
          return 'Dhs ${item.washPrice.toStringAsFixed(2)}';
        }
    }
  }
}