
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:universal_html/html.dart' as html;
import '../view_models/dashboard_view_model.dart';
import 'daily_transactions_view.dart';

class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final theme = Theme.of(context);
print('rebuilt');
print(vm.hasData);
    return Scaffold(
      appBar: AppBar(
        title: Text("Fresh & Clean Laundry Dashboard", style:  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Analytics Overview", style: theme.textTheme.titleLarge),
            SizedBox(height: 24),

            // Toggle Buttons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _FilterButton(
                      label: "Today's Stats",
                      icon: Icons.today,
                      isSelected: vm.selectedPeriod == DashboardPeriod.today,
                      onTap: () => vm.loadDashboardStats(period: DashboardPeriod.today),
                    ),
                    SizedBox(width: 16),
                    _FilterButton(
                      label: "This Month",
                      icon: Icons.calendar_month,
                      isSelected: vm.selectedPeriod == DashboardPeriod.month,
                      onTap: () => vm.loadDashboardStats(period: DashboardPeriod.month),
                    ),
                    SizedBox(width: 16),

                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.calendar_today),
                          label: Text("Choose Day"),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2024),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              final normalized = DateTime(picked.year, picked.month, picked.day);
                              await vm.loadDashboardStats(period: DashboardPeriod.customDay, targetDate: normalized);
                              // vm.loadDashboardStats(period: DashboardPeriod.customDay, customDate: picked);
                            }
                          },
                        ),
                        SizedBox(width: 16),
                        ElevatedButton.icon(
                          icon: Icon(Icons.date_range),
                          label: Text("Choose Month"),
                          onPressed: () async {
                            final selectedMonth = await showDialog<DateTime>(
                              context: context,
                              builder: (context) => MonthPickerDialog(),
                            );

                            if (selectedMonth != null) {
                              final monthDate = DateTime(selectedMonth.year, selectedMonth.month);
                              vm.loadDashboardStats(period: DashboardPeriod.customMonth, targetDate: monthDate);
                            }
                          },
                        ),

                      ],
                    ),
                    SizedBox(width: 16),

                    ElevatedButton.icon(
                      icon: Icon(Icons.search),
                      label: Text("View a Day’s Transactions"),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DailyTransactionsView(selectedDate: picked),
                            ),
                          );
                        }
                      },
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      child: Text("Download CSV"),
                      onPressed: () async {
                        // Let the user pick the date if you want:
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2024),
                          lastDate: DateTime.now(),
                        );
                        if (picked == null) return;

                        // Fetch & build CSV
                        final orders = await vm.fetchOrdersForDay(picked);
                        final csv = vm.buildCsv(orders);

                        // Create a blob from the CSV string
                        final blob = html.Blob([csv], 'text/csv');

                        // Generate a download URL and trigger the download
                        final url = html.Url.createObjectUrlFromBlob(blob);
                        final anchor = html.document
                            .createElement('a') as html.AnchorElement
                          ..href = url
                          ..style.display = 'none'
                          ..download = 'transactions_${picked.toIso8601String().split("T").first}.csv';
                        html.document.body!.append(anchor);
                        anchor.click();
                        html.document.body!.children.remove(anchor);
                        html.Url.revokeObjectUrl(url);
                      },


                    ),

                  ],
                ),
              ),
            ),
            SizedBox(height: 32),
              if (vm.isLoading)
                Center(child: CircularProgressIndicator())
              else if (vm.hasData)
                Wrap(
                  spacing: 24,
                  runSpacing: 24,
                  children: [
                    if (vm.selectedPeriod == DashboardPeriod.today) ...[
                      _StatCard(
                        title: "Orders Today",
                        value: "${vm.ordersToday}",
                        icon: Icons.shopping_bag,
                        color: Colors.deepPurple,
                      ),
                      _StatCard(
                        title: "Sales Today",
                        value: "Dhs ${vm.salesToday.toStringAsFixed(2)}",
                        icon: Icons.attach_money,
                        color: Colors.green,
                      ),
                    ] else if (vm.selectedPeriod == DashboardPeriod.month) ...[
                      _StatCard(
                        title: "Monthly Orders",
                        value: "${vm.ordersThisMonth}",
                        icon: Icons.insert_chart,
                        color: Colors.orange,
                      ),
                      _StatCard(
                        title: "Monthly Sales",
                        value: "Dhs ${vm.salesThisMonth.toStringAsFixed(2)}",
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                    ]
                    else if (vm.selectedPeriod == DashboardPeriod.customDay ||
                          vm.selectedPeriod == DashboardPeriod.customMonth) ...[
                        _StatCard(
                          title: "Orders in selected period",
                          value: "${vm.customOrders}",
                          icon: Icons.insert_chart,
                          color: Colors.orange,
                        ),
                        _StatCard(
                          title: "Sales in selected period",
                          value: "Dhs ${vm.customSales.toStringAsFixed(2)}",
                          icon: Icons.trending_up,
                          color: Colors.blue,
                        ),
                      ]
                  ],
                )
              else
                Center(child: Text("Select a period to view stats")),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(icon, size: 20),
      label: Text(label),
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.deepPurple : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, color: color)),
          SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// class DashboardView extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     final vm = context.watch<DashboardViewModel>();
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Supervisor Dashboard"),
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Dashboard Overview", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//
//             // Period Buttons
//             Wrap(
//               spacing: 10,
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.today),
//                   label: const Text("Today"),
//                   onPressed: () => vm.loadDashboardStats(period: DashboardPeriod.today),
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.calendar_month),
//                   label: const Text("This Month"),
//                   onPressed: () => vm.loadDashboardStats(period: DashboardPeriod.month),
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.date_range),
//                   label: const Text("Choose Day"),
//                   onPressed: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2024),
//                       lastDate: DateTime.now(),
//                     );
//                     if (picked != null) {
//                       vm.loadDashboardStats(period: DashboardPeriod.customDay, targetDate: picked);
//                     }
//                   },
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.calendar_view_month),
//                   label: const Text("Choose Month"),
//                   onPressed: () async {
//                     final picked = await showDatePicker(
//                       context: context,
//                       initialDate: DateTime.now(),
//                       firstDate: DateTime(2024),
//                       lastDate: DateTime.now(),
//                       helpText: 'Pick any date from desired month',
//                     );
//                     if (picked != null) {
//                       final monthDate = DateTime(picked.year, picked.month);
//                       vm.loadDashboardStats(period: DashboardPeriod.customMonth, targetDate: monthDate);
//                     }
//                   },
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 16),
//
//             // Filter by Customer
//             TextField(
//               decoration: const InputDecoration(labelText: 'Filter by customer name'),
//               onChanged: vm.filterTransactionsByCustomer,
//             ),
//
//             const SizedBox(height: 20),
//
//             // Dashboard Stats
//             if (vm.hasData) ...[
//               Text("Orders: ${vm.filteredOrders.length}"),
//               Text("Sales: Dhs ${vm.filteredSales.toStringAsFixed(2)}"),
//               const SizedBox(height: 20),
//             ],
//
//             // Export Buttons
//             Row(
//               children: [
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.picture_as_pdf),
//                   label: const Text("Export PDF"),
//                   onPressed: vm.exportAsPdf,
//                 ),
//                 const SizedBox(width: 16),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.table_view),
//                   label: const Text("Export CSV"),
//                   onPressed: vm.exportAsCsv,
//                 ),
//               ],
//             ),
//
//             const SizedBox(height: 20),
//
//             // Grouped Orders
//             Expanded(
//               child: vm.groupedOrders.isEmpty
//                   ? const Center(child: Text("No orders to display."))
//                   : ListView(
//                 children: vm.groupedOrders.entries.map((entry) {
//                   return ExpansionTile(
//                     title: Text("Customer: ${entry.key}"),
//                     children: entry.value.map((order) => ListTile(
//                       title: Text("Total: Dhs ${order.total}"),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Time: ${order.timestamp}"),
//                           Text("Items: ${order.items.map((i) => i.name).join(', ')}"),
//                         ],
//                       ),
//                     )).toList(),
//                   );
//                 }).toList(),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class MonthPickerDialog extends StatefulWidget {
  @override
  _MonthPickerDialogState createState() => _MonthPickerDialogState();
}

class _MonthPickerDialogState extends State<MonthPickerDialog> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;

  final List<int> years = List.generate(10, (index) => 2024 + index); // From 2024 to 2033
  final List<String> months = const [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select Month'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          DropdownButton<int>(
            value: selectedYear,
            onChanged: (val) => setState(() => selectedYear = val!),
            items: years.map((year) {
              return DropdownMenuItem<int>(
                value: year,
                child: Text(year.toString()),
              );
            }).toList(),
          ),
          DropdownButton<int>(
            value: selectedMonth,
            onChanged: (val) => setState(() => selectedMonth = val!),
            items: List.generate(12, (index) {
              return DropdownMenuItem<int>(
                value: index + 1,
                child: Text(months[index]),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
        ElevatedButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.pop(context, DateTime(selectedYear, selectedMonth));
          },
        ),
      ],
    );
  }
}
