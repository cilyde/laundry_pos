import 'package:flutter/material.dart';

/// QuantityEditor is a reusable widget for editing integer quantities.
///
/// It shows plus and minus buttons to increment or decrement the quantity,
/// displays the current value, and provides an 'Update' button
/// that triggers a callback with the updated quantity.
class QuantityEditor extends StatefulWidget {
  /// The initial quantity to display.
  final int initialQuantity;

  /// Callback to be called when the quantity is updated.
  final ValueChanged<int> onQuantityChanged;

  const QuantityEditor({
    Key? key,
    required this.initialQuantity,
    required this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<QuantityEditor> createState() => _QuantityEditorState();
}

class _QuantityEditorState extends State<QuantityEditor> {
  late int quantity;

  @override
  void initState() {
    super.initState();
    quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: quantity > 1
              ? () => setState(() => quantity--)
              : null, // Disable button when quantity is 1
        ),
        Text(
          quantity.toString(),
          style: TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => setState(() => quantity++),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          child: Text("Update"),
          onPressed: () {
            widget.onQuantityChanged(quantity);
          },
        ),
      ],
    );
  }
}
