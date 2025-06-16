import 'package:flutter/material.dart';
import 'package:laundry_os/views/quantity_editor.dart';
import 'package:provider/provider.dart';

import '../models/cloth_item.dart';
import '../view_models/pos_view_model.dart';
import 'OrderReviewScreen.dart';

class POSView extends StatefulWidget {
  POSView({this.openDialog = false, super.key});

  bool openDialog;

  @override
  State<POSView> createState() => _POSViewState();
}

class _POSViewState extends State<POSView> {
  String currentLanguage = 'en';
  bool _isLoading = false;

  final List<ClothItem> availableItems = [
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

  final serviceIcons = [
    Icon(Icons.local_laundry_service, size: 50), // Wash
    Icon(Icons.iron, size: 50), // Iron
    Row(children: [Icon(Icons.local_laundry_service_outlined, size: 30), Icon(Icons.iron_outlined, size: 30)]), // Both
  ];

  void openLanguageDialog() {
    if (mounted) {
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: Text("Select Language"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [_languageButton('English', 'en'), _languageButton('हिन्दी', 'hi'), _languageButton('عربي', 'ar'),_languageButton('اردو', 'ur'),],
              ),
            ),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.openDialog) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        openLanguageDialog();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<POSViewModel>();

    final filteredItems =
        availableItems.where((item) {
          if ((vm.currentService == ServiceType.iron || vm.currentService == ServiceType.both) && item.ironPrice == null) {
            return false;
          }
          return true;
        }).toList();
    print(vm.currentService.name);
    print('No items selected to ${vm.currentService.name}');
    print('${tr('No items selected to ${vm.currentService.name}', currentLanguage)}');
    return Scaffold(
      // appBar: AppBar(title: Text('POS')),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Tab bar
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
                      children: ServiceType.values.map((s) => Padding(padding: const EdgeInsets.all(16), child: serviceColumn(context, s))).toList(),
                    ),
                  ),

                  // Available items list
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 0.75),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return GestureDetector(
                          onTap: () => vm.toggleItem(item),
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

                  // Selected items display
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          "${tr('selected items', currentLanguage)} (${serviceLabel(context, vm.currentService)})",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),

                        vm.selectedItems.isEmpty
                            ? Text('${tr('No items selected to ${vm.currentService.name}', currentLanguage)}')
                            : Container(
                              constraints: BoxConstraints(
                                maxHeight: 200, // about 2 rows tall
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
                                            showDialog(
                                              context: context,
                                              builder:
                                                  (context) => AlertDialog(
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
                                        IconButton(icon: Icon(Icons.delete, color: Colors.orange), onPressed: () => vm.removeItem(item)),
                                      ],
                                    ),
                                    subtitle: Text("${tr('Service', currentLanguage)}: ${serviceLabel(context, item.selectedService!)}"),
                                    trailing: Text("Dhs ${item.totalPrice.toStringAsFixed(2)}"),
                                  );
                                },
                              ),
                            ),

                        Divider(),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                openLanguageDialog();
                              },
                              child: Icon(Icons.language),
                            ),

                            Text("Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                            // Next button
                            ElevatedButton.icon(
                              icon: Icon(Icons.arrow_forward),
                              label: Text(tr("Next", currentLanguage)),
                              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                              onPressed: () async {
                                setState(() {
                                  _isLoading = true;
                                });
                                await Future.delayed(Duration(milliseconds: 300));
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => OrderReviewScreen(currentLanguage: currentLanguage)),
                                ).whenComplete(() async {
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

  // String serviceLabel(ServiceType type) {
  String serviceLabel(BuildContext context, ServiceType type) {
    switch (type) {
      case ServiceType.wash:
        return tr('wash', currentLanguage);
      case ServiceType.iron:
        return tr('iron', currentLanguage);
      case ServiceType.both:
        return tr('both', currentLanguage);
    }
  }

  Column serviceColumn(BuildContext context, ServiceType type) {
    switch (type) {
      case ServiceType.wash:
        return Column(
          children: [Icon(Icons.local_laundry_service, size: 50), Text(tr('wash', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold))],
        );
      case ServiceType.iron:
        return Column(children: [Icon(Icons.iron, size: 50), Text(tr('iron', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold))]);
      case ServiceType.both:
        return Column(
          children: [
            Row(children: [Icon(Icons.local_laundry_service_outlined, size: 50), Icon(Icons.iron_outlined, size: 50)]),
            Text(tr('both', currentLanguage), style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        );
        ;
    }
  }

  Widget _languageButton(String label, String code) {
    return ElevatedButton(
      onPressed: () {
        setState(() => currentLanguage = code);
        Navigator.pop(context);
      },
      child: Text(label),
    );
  }

  String getPriceLabel(ClothItem item, ServiceType service) {
    switch (service) {
      case ServiceType.wash:
        return 'Dhs ${item.washPrice.toStringAsFixed(2)}';
      case ServiceType.iron:
        if (item.ironPrice != null) {
          return 'Dhs ${item.ironPrice!.toStringAsFixed(2)}';
        } else {
          return 'Iron not available';
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
