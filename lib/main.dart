import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laundry_os/services/print_service.dart';
import 'package:laundry_os/view_models/pos_view_model.dart';
import 'package:laundry_os/views/pos_view.dart';
import 'package:laundry_os/web/view_models/dashboard_view_model.dart';
import 'package:laundry_os/web/views/dashboard_view.dart';
import 'package:provider/provider.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Only initialize Sunmi printer if app is NOT running on web platform
  if (!kIsWeb) {
    await SunmiPrinter.initPrinter();
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<PrinterService>(
          create: (_) => PrinterService(),
        ),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
        ChangeNotifierProvider<POSViewModel>(
          create: (ctx) => POSViewModel(ctx.read<PrinterService>()),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      title: 'Fresh & Clean Laundry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: kIsWeb ? DashboardView() : POSView(),
    );
  }
}
