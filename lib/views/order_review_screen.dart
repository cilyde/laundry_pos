import 'package:flutter/material.dart';
import 'package:laundry_os/views/pos_view.dart';
import 'package:provider/provider.dart';

import '../models/cloth_item.dart';
import '../utils/service_converter.dart';
import '../view_models/pos_view_model.dart';

/// OrderReviewScreen displays a detailed review of all selected laundry items grouped by service type.
/// It allows editing item quantities, removing items, entering a phone number, and confirming the order.
/// On confirmation, it triggers order printing and returns to the main POS screen.
///
/// It supports multi-language display via `currentLanguage` passed in constructor.
class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({required this.currentLanguage, super.key});

  // The current language code for translations (e.g., 'en', 'ar', 'hi')
  final String currentLanguage;

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  // Controller for the phone number text field
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose controller to free resources when widget is removed
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access the POSViewModel from Provider to get order data and logic
    final vm = context.watch<POSViewModel>();

    // Group selected items by service type (wash, iron, both)
    final groupedItems = vm.allSelectedItemsGrouped;

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('Review Order', widget.currentLanguage)), // Translated title
      ),
      body: vm.isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading spinner during processing
          : groupedItems.isEmpty
          ? Center(
        child: Text(tr('"No items in the order"', widget.currentLanguage)),
      ) // Message if no items are selected
          : ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16),
        children: [
          // Iterate over each service group (wash/iron/both)
          ...groupedItems.entries.map((entry) {
            final service = entry.key;
            final items = entry.value;
            final serviceString = serviceLabel(service, widget.currentLanguage);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service header with translated name (e.g., "Wash")
                Text(
                  tr(serviceString, widget.currentLanguage),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                // Show message if no items under this service
                if (items.isEmpty)
                  Container(
                    child: Text('No item selected to $serviceString'),
                  ),

                // List all items for this service
                ...items.map(
                      (item) => Card(
                    child: ListTile(
                      leading: Image.asset(item.img, width: 40), // Item image
                      title: Text(tr(item.name, widget.currentLanguage)), // Translated name
                      subtitle: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text("${tr('quantity', widget.currentLanguage)}: ${item.quantity}"), // Quantity
                      ),
                      dense: true,
                      trailing: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(item.totalPrice.toStringAsFixed(2)), // Price display

                          // Edit quantity button opens dialog
                          IconButton(
                            icon: Icon(Icons.edit),
                            alignment: Alignment.centerRight,
                            onPressed: () => _showEditQuantityDialog(context, vm, item),
                          ),

                          // Delete button removes item from selection
                          IconButton(
                            icon: Icon(Icons.delete),
                            alignment: Alignment.centerRight,
                            onPressed: () => vm.removeItem(item),
                          ),
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

          // Phone number input field
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2, // Takes 2/3 of available width
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: tr('phone', widget.currentLanguage), // Translated label
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Total price summary
          Text(
            "Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.end,
          ),

          SizedBox(height: 20),

          // Confirm Order button triggers order submission and printing
          ElevatedButton(
            onPressed: () async {
              // Call ViewModel method with phone number
              final response = await vm.confirmAndPrintOrder(phoneNumber: _phoneController.text);

              if (response) {
                // On success, navigate back to POS screen and open language dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return POSView(openDialog: true);
                    },
                  ),
                );
              } else {
                // Show alert if no items selected or order failed
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Please select items first"),
                    );
                  },
                );
              }
            },
            child: Text("Confirm Order"),
          ),
        ],
      ),
    );
  }

  /// Shows a dialog to edit the quantity of a selected cloth item.
  /// Updates the quantity in the ViewModel if valid input is entered.
  void _showEditQuantityDialog(BuildContext context, POSViewModel vm, ClothItem item) {
    final controller = TextEditingController(text: item.quantity.toString());

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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
                vm.updateQuantity(item, newQty); // Update quantity in VM
                Navigator.pop(context); // Close dialog
              }
            },
            child: Text("Update"),
          ),
        ],
      ),
    );
  }
}
