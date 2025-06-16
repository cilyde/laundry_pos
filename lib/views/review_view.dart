import 'package:flutter/material.dart';
import 'package:laundry_os/views/home_view.dart';
import 'package:provider/provider.dart';

import '../models/cloth_item.dart';
import '../utils/translation.dart';
import '../view_models/home_view_model.dart';

class ReviewView extends StatefulWidget {
  final String currentLanguage;
  ReviewView({required this.currentLanguage});

  @override
  _ReviewViewState createState() => _ReviewViewState();
}

class _ReviewViewState extends State<ReviewView> {
  final _phoneController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final lang = widget.currentLanguage;
    return Scaffold(
      appBar: AppBar(
        title: Text(translations['review']![lang]!),
        centerTitle: true,
      ),
      // floatingActionButton: ,
      body: isLoading?Center(child: CircularProgressIndicator(),):Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            // Inside ListView children of ReviewView
            ...vm.clothItems.where((i) => i.isSelected).map((item) {
              final key = item.name.toLowerCase();
              return Card(
                margin: EdgeInsets.symmetric(vertical: 6),
                color: Colors.grey[300],
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(item.img, width: 40),
                          SizedBox(width: 10),
                          Text(
                            translations[key]![lang]!,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      Text(translations['quantity']?[lang] ?? 'Quantity',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (item.quantity > 1) item.quantity--;
                              });
                            },
                            icon: Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            item.quantity.toString(),
                            style: TextStyle(fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                item.quantity++;
                              });
                            },
                            icon: Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(translations['select_service']?[lang]??'NULL',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Column(
                        children: ServiceType.values.map((service) {
                          return RadioListTile<ServiceType>(
                            value: service,
                            groupValue: item.selectedService,

                            onChanged: (val) {
                              setState(() {
                                item.selectedService = val;
                              });
                            },
                            title: Text(translations[service.name.toLowerCase()]?[lang] ?? service.name),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
            Divider(),
            ListTile(
              title: Text(translations['total']![lang]!),
              trailing: Text('Dhs ${vm.totalPrice.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: translations['phone']![lang]!,
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text(translations['confirm_print']![lang]!),
              onPressed: () async {
                setState(() {
                  isLoading=true;
                });
                final response = await vm.confirmAndPrintOrder(
                  phoneNumber: _phoneController.text.isNotEmpty
                      ? _phoneController.text
                      : null,
                );

                setState(() {
                  isLoading=false;
                });
                if(response){
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(translations['done']![lang]!)),
                    );
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context) { return HomeView(); }));
                }else{
                  if (context.mounted)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Something went wrong. Please try again.")),
                    );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}