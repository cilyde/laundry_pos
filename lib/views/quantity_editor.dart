import 'package:flutter/material.dart';

class QuantityEditor extends StatefulWidget {
  final int initialQuantity;
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
              : null,
        ),
        Text(quantity.toString(), style: TextStyle(fontSize: 18)),
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
