
import 'package:flutter/material.dart';
import 'package:laundry_os/views/review_view.dart';
import 'package:provider/provider.dart';
import '../utils/translation.dart';
import '../view_models/home_view_model.dart';
import '../models/cloth_item.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translations['title']![currentLanguage]!),
        centerTitle: true,
        actions: [

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _languageButton('English', 'en'),
                _languageButton('हिन्दी','hi'),
                _languageButton('عربي','ar'),
              ],
            ),
            Expanded(child: _buildGrid(context)),
            ElevatedButton.icon(
              icon: Icon(Icons.arrow_forward),
              label: Text(translations['next']![currentLanguage]!),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReviewView(currentLanguage: currentLanguage),
                ),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      children: vm.clothItems.map((item) {
        final key = item.name.toLowerCase();
        return GestureDetector(
          onTap: () => vm.toggleSelection(vm.clothItems.indexOf(item)),
          child: Card(
            color: item.isSelected ? Colors.teal.shade100 : null,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(item.img, width: 60),
                  SizedBox(height: 8),
                  Text(
                    translations[key]![currentLanguage]!,
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _languageButton(String label,String code) {
    return TextButton(
      onPressed: () => setState(() => currentLanguage = code),
      child: Text(label),
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../view_models/home_view_model.dart';
// import '../models/cloth_item.dart';
//
// class HomeView extends StatefulWidget {
//   @override
//   _HomeViewState createState() => _HomeViewState();
// }
//
// class _HomeViewState extends State<HomeView> {
//   final _phoneController = TextEditingController();
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final vm = Provider.of<HomeViewModel>(context);
//
//     return Scaffold(
//       appBar: AppBar(title: Text('Cloth Service')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             // Cloth selection list
//             Expanded(
//               child: ListView.builder(
//                 itemCount: vm.clothItems.length,
//                 itemBuilder: (context, index) {
//                   final item = vm.clothItems[index];
//                   return ListTile(
//                     title: Text(item.name),
//                     subtitle: item.isSelected && item.selectedService != null
//                         ? Text(
//                         'Service: ${item.selectedService!.name.toUpperCase()} - Dhs ${item.totalPrice.toStringAsFixed(2)}')
//                         : null,
//                     trailing: Checkbox(
//                       value: item.isSelected,
//                       onChanged: (_) => vm.toggleSelection(index),
//                     ),
//                     onTap: () => vm.toggleSelection(index),
//                   );
//                 },
//               ),
//             ),
//
//             // Service picker button
//             ElevatedButton(
//               onPressed: () => _showServicePicker(context, vm),
//               child: Text("Select Services"),
//             ),
//
//             // Total price display
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12.0),
//               child: Text(
//                 'Total: Dhs ${vm.totalPrice.toStringAsFixed(2)}',
//                 style: Theme.of(context).textTheme.titleLarge,
//               ),
//             ),
//
//             // Optional phone number input
//             TextField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: 'Phone Number (optional)',
//                 border: OutlineInputBorder(),
//                 prefixIcon: Icon(Icons.phone),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             SizedBox(height: 16),
//
//             // Confirm & print button
//             ElevatedButton(
//               onPressed: () async {
//                 await vm.confirmAndPrintOrder(
//                   phoneNumber: _phoneController.text.isNotEmpty
//                       ? _phoneController.text
//                       : null,
//                 );
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text("Order saved and printed!")),
//                 );
//               },
//               child: Text("Confirm & Print"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _showServicePicker(BuildContext context, HomeViewModel vm) {
//     showModalBottomSheet(
//       context: context,
//       builder: (ctx) {
//         return ListView.builder(
//           itemCount: vm.clothItems.length,
//           itemBuilder: (context, index) {
//             final item = vm.clothItems[index];
//             if (!item.isSelected) return SizedBox.shrink();
//             return ListTile(
//               title: Text(item.name),
//               subtitle: Column(
//                 children: ServiceType.values.map((service) {
//                   return RadioListTile<ServiceType>(
//                     title: Text(service.name.toUpperCase()),
//                     value: service,
//                     groupValue: item.selectedService,
//                     onChanged: (val) {
//                       vm.setService(index, val!);
//                       Navigator.pop(context);
//                     },
//                   );
//                 }).toList(),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../utils/translation.dart';
// import '../view_models/home_view_model.dart';
// import '../models/cloth_item.dart';
//
//
// class HomeView extends StatefulWidget {
//   @override
//   _HomeViewState createState() => _HomeViewState();
// }
//
// class _HomeViewState extends State<HomeView> {
//   final _phoneController = TextEditingController();
//
//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }
//   var currentLanguage = 'en'; // change to 'hi' or 'ar' for Hindi or Arabic
//
//   @override
//   Widget build(BuildContext context) {
//
//     final vm = context.watch<HomeViewModel>();
//     final hasSelection = vm.clothItems.any((item) => item.isSelected);
//     final allServicesSet = vm.clothItems
//         .where((item) => item.isSelected)
//         .every((item) => item.selectedService != null);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Laundry Service'),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: ListView(
//           children: [
//
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//             ElevatedButton(onPressed: (){
//               setState(() {
//                 currentLanguage='en';
//               });
//             },
//                 child: Text('English')),
//               ElevatedButton(onPressed: (){
//                 setState(() {
//                   currentLanguage='hi';
//                 });
//               },
//                   child: Text('हिन्दी')),
//               ElevatedButton(onPressed: (){
//                 setState(() {
//                   currentLanguage='ar';
//                 });
//               },
//                   child: Text('عربي')),
//             ],),
//
//             // Cloth grid
//             GridView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 crossAxisSpacing: 8,
//                 mainAxisSpacing: 8,
//                 childAspectRatio: 0.8,
//               ),
//               itemCount: vm.clothItems.length,
//               itemBuilder: (context, index) {
//                 final item = vm.clothItems[index];
//                 return GestureDetector(
//                   onTap: () => vm.toggleSelection(index),
//                   child: Card(
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       side: BorderSide(
//                         color: item.isSelected ? Colors.teal : Colors.grey,
//                         width: 2,
//                       ),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Icon(
//                           //   Icons.local_laundry_service,
//                           //   size: 40,
//                           //   color: item.isSelected ? Colors.teal : Colors.grey,
//                           // ),
//                           Image.asset(item.img, scale: 10,),
//                           const SizedBox(height: 8),
//                           Text(
//                             translations['shirt']![currentLanguage]!,
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               color: item.isSelected ? Colors.teal : Colors.black,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//
//             // Instruction
//             if (!hasSelection)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 16.0),
//                 child: Text(
//                   'Select items above to choose services',
//                   textAlign: TextAlign.center,
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//               ),
//
//             // Service options for selected items
//             if (hasSelection)
//               ...vm.clothItems
//                   .asMap()
//                   .entries
//                   .where((e) => e.value.isSelected)
//                   .map(
//                     (entry) => ExpansionTile(
//                   title: Text(entry.value.name),
//                   subtitle: Text(
//                     entry.value.selectedService != null
//                         ? entry.value.selectedService!.name.toUpperCase()
//                         : 'Choose service',
//                   ),
//                   children: ServiceType.values.map((service) {
//                     return RadioListTile<ServiceType>(
//                       title: Text(service.name.toUpperCase()),
//                       value: service,
//                       groupValue: entry.value.selectedService,
//                       onChanged: (val) {
//                         vm.setService(entry.key, val!);
//                       },
//                     );
//                   }).toList(),
//                 ),
//               ),
//
//             const SizedBox(height: 12),
//             // Summary row
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total:',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 Text(
//                   'Dhs ${vm.totalPrice.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             // Phone input
//             TextField(
//               controller: _phoneController,
//               decoration: InputDecoration(
//                 labelText: 'Phone (optional)',
//                 prefixIcon: const Icon(Icons.phone),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               keyboardType: TextInputType.phone,
//             ),
//             const SizedBox(height: 12),
//             // Confirm & Print
//             ElevatedButton(
//               onPressed: hasSelection && allServicesSet
//                   ? () async {
//                 await vm.confirmAndPrintOrder(
//                   phoneNumber: _phoneController.text.isNotEmpty
//                       ? _phoneController.text
//                       : null,
//                 );
//                 if (context.mounted) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Order saved & printed!'),
//                     ),
//                   );
//                 }
//               }
//                   : null,
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//               ),
//               child: const Text('Confirm & Print'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
