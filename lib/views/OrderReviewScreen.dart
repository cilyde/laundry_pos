import 'package:flutter/material.dart';
import 'package:laundry_os/views/pos_view.dart';
import 'package:provider/provider.dart';

import '../models/cloth_item.dart';
import '../view_models/pos_view_model.dart';

class OrderReviewScreen extends StatefulWidget {
  OrderReviewScreen({required this.currentLanguage, super.key});

  String currentLanguage;

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {

  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<POSViewModel>();
    final groupedItems = vm.allSelectedItemsGrouped;

    return Scaffold(
      appBar: AppBar(title: Text(tr('Review Order', widget.currentLanguage))),
      body:
          vm.isLoading?Center(child: CircularProgressIndicator(),):
          groupedItems.isEmpty
              ? Center(child: Text(tr('"No items in the order"', widget.currentLanguage)))
              : ListView(
            physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(16),
                children: [
                  ...groupedItems.entries.map((entry) {
                    final service = entry.key;
                    final items = entry.value;
                    final serviceString = _serviceToString(service);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tr(serviceString, widget.currentLanguage), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        if(items.isEmpty)
                          Container(child: Text('No item selected to $serviceString'),),
                        ...items.map(
                          (item) => Card(
                            child: ListTile(
                              leading: Image.asset(item.img, width: 40),
                              title: Text(tr(item.name, widget.currentLanguage)),
                              subtitle: FittedBox(
                                  fit : BoxFit.scaleDown,
                                  alignment : Alignment.centerLeft,
                                  child: Text("${tr('quantity', widget.currentLanguage)}: ${item.quantity}")),
                              dense:true,
                              trailing: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(item.totalPrice.toStringAsFixed(2)),
                                  IconButton(icon: Icon(Icons.edit),
                                      // padding: EdgeInsets.zero,
                                      alignment: Alignment.centerRight,
                                      onPressed: () => _showEditQuantityDialog(context, vm, item)),
                                  IconButton(icon: Icon(Icons.delete),
                                      // padding: EdgeInsets.zero,
                                      alignment: Alignment.centerRight,
                                      onPressed: () => vm.removeItem(item)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    );
                  }),
                  Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      children: [
                        // Phone field takes 2/3 of width
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              labelText: tr('phone', widget.currentLanguage),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  Text(
                    "Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.end,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async{
                      final response = await vm.confirmAndPrintOrder(phoneNumber: _phoneController.text);
                      if(response){
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return POSView(openDialog: true);
                            },
                          ),
                        );
                      }else{
                        showDialog(context: context, builder: (BuildContext context) { return AlertDialog(
                          title: Text("Please select items first"),
                        ); },);
                      }
                      // Proceed to next screen (payment / confirmation)
                    },
                    child: Text("Confirm Order"),
                  ),
                ],
              ),
    );
  }

  String _serviceToString(ServiceType type) {
    switch (type) {
      case ServiceType.wash:
        return "Wash";
      case ServiceType.iron:
        return "Iron";
      case ServiceType.both:
        return "Wash & Iron";
      default:
        return "";
    }
  }

  void _showEditQuantityDialog(BuildContext context, POSViewModel vm, ClothItem item) {
    final controller = TextEditingController(text: item.quantity.toString());
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Edit Quantity"),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(hintText: "Enter new quantity"),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              ElevatedButton(
                onPressed: () {
                  final newQty = int.tryParse(controller.text);
                  if (newQty != null && newQty > 0) {
                    vm.updateQuantity(item, newQty);
                    Navigator.pop(context);
                  }
                },
                child: Text("Update"),
              ),
            ],
          ),
    );
  }
}
