// // lib/services/printer_service.dart
//
//
// import 'package:sunmi_printer_plus/core/enums/enums.dart';
// import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
// import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
//
// class PrinterService {
//   /// Binds to the Sunmi print service and begins a buffered transaction.
//   Future<void> _beginPrintTransaction() async {
//     await SunmiPrinter.bindingPrinter();                // bind to printer :contentReference[oaicite:0]{index=0}
//     await SunmiPrinter.startTransactionPrint(true);     // start buffered printing :contentReference[oaicite:1]{index=1}
//   }
//
//   /// Ends the buffered transaction and cuts the paper.
//   Future<void> _endPrintTransaction() async {
//     await SunmiPrinter.exitTransactionPrint(true);      // commit print buffer :contentReference[oaicite:2]{index=2}
//     await SunmiPrinter.cut();                           // cut the paper :contentReference[oaicite:3]{index=3}
//   }
//
//   /// Prints a single receipt.
//   Future<void> printReceipt({
//     required String shopName,
//     required List<Map<String, dynamic>> items, // each: {'name','service','price'}
//     required double total,
//   }) async {
//     await _beginPrintTransaction();
//
//     // 1) Header
//     await SunmiPrinter.printText(
//       shopName,
//       style: SunmiTextStyle(
//         align: SunmiPrintAlign.CENTER,
//         //TODO: fontSize: SunmiFontSize.XL.index * 16, // XL enum → 5†SM†MD… maps to fontSize in px :contentReference[oaicite:4]{index=4}
//       ),
//     );
//     await SunmiPrinter.lineWrap(1);
//
//     // 2) Items
//     for (var item in items) {
//       final line =
//           '${item['name']} (${item['service']}): \$${(item['price'] as double).toStringAsFixed(2)}';
//       await SunmiPrinter.printText(line);
//     }
//     await SunmiPrinter.lineWrap(1);
//
//     // 3) Total
//     await SunmiPrinter.printText(
//       'TOTAL: \$${total.toStringAsFixed(2)}',
//       style: SunmiTextStyle(
//         align: SunmiPrintAlign.RIGHT,
//         //TODO: fontSize: SunmiFontSize.LG.index * 16,
//         bold: true,
//       ),
//     );
//     await SunmiPrinter.lineWrap(2);
//
//     await _endPrintTransaction();
//   }
// }
// lib/services/printer_service.dart
import 'package:sunmi_printer_plus/core/enums/enums.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_barcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_qrcode_style.dart';
import 'package:sunmi_printer_plus/core/styles/sunmi_text_style.dart';
import 'package:sunmi_printer_plus/core/sunmi/sunmi_printer.dart';
import 'package:sunmi_printer_plus/core/types/sunmi_column.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import 'dart:typed_data';
import 'package:intl/intl.dart';  // for date formattin

class PrinterService {
  /// Initializes the printer. Returns true if successful.
  Future<bool> initPrinter() async {
    try {
      // bind to the native Sunmi printer service
      await SunmiPrinter.bindingPrinter();
      // then initialize it
      await SunmiPrinter.initPrinter();
      return true;
    } catch (e) {
      // log or handle error
      return false;
    }
  }

  /// Prints plain text with optional style.
  Future<void> printText(
      String text, {
        bool bold = false,
        int fontSize = 24,
        SunmiPrintAlign align = SunmiPrintAlign.LEFT,
      }) async {
    await SunmiPrinter.printText(
      text,
      style: SunmiTextStyle(
        bold: bold,
        fontSize: fontSize,
        align: align,
      ),
    );
  }

  /// Prints a QR code.
  Future<void> printQRCode(
      String data, {
        int qrcodeSize = 3,
        SunmiQrcodeLevel errorLevel = SunmiQrcodeLevel.LEVEL_M,
      }) async {
    await SunmiPrinter.printQRCode(
      data,
      style: SunmiQrcodeStyle(
        qrcodeSize: qrcodeSize,
        errorLevel: errorLevel,
      ),
    );
  }

  /// Prints a barcode.
  Future<void> printBarCode(
      String data, {
        SunmiBarcodeType type = SunmiBarcodeType.CODE128,
        int height = 50,
        int width = 2,
        SunmiBarcodeTextPos textPosition = SunmiBarcodeTextPos.TEXT_UNDER,
        SunmiPrintAlign align = SunmiPrintAlign.CENTER,
      }) async {
    await SunmiPrinter.printBarCode(
      data,
      style: SunmiBarcodeStyle(
        type: type,
        height: height,
        size: width,
        // textPosition: textPosition,
        align: align,
      ),
    );
  }

  /// Prints an image from bytes (Uint8List).
  Future<void> printImage(Uint8List imageBytes, {SunmiPrintAlign align = SunmiPrintAlign.CENTER}) async {
    await SunmiPrinter.printImage(
      imageBytes,
      align: align,
    );
  }

  /// Prints a divider line.
  Future<void> printDivider() async {
    await SunmiPrinter.printText('------------------------------');
  }

  /// Jumps n lines.
  Future<void> lineWrap(int lines) async {
    await SunmiPrinter.lineWrap(lines);
  }

  /// Cuts the paper.
  Future<void> cutPaper() async {
    await SunmiPrinter.cutPaper();
  }

  /// Gets the printer serial number.
  // Future<String?> getSerialNumber() async {
  //   return await SunmiPrinter.getPrinterSerialNo();
  // }

  /// Gets the printer version.
  // Future<String?> getPrinterVersion() async {
  //   return await SunmiPrinter.getPrinterVersion();
  // }

  /// Gets the printer paper size (0: 80mm, 1: 58mm).
  // Future<int?> getPaperSize() async {
  //   return await SunmiPrinter.getPrinterPaperSize();
  // }

}



extension ReceiptPrinting on PrinterService {
  Future<void> printOrderReceipt({
    required String shopName,
    required List<Map<String, dynamic>> items,  // name, service, price
    required double total,
    String? phoneNumber, required String recieptId
  }) async {
    // await SunmiPrinter.line();
    // await SunmiPrinter.addText(text: "THis is addText");
    // await SunmiPrinter.printRow(cols: [SunmiColumn(text: 'col text', width: 10),SunmiColumn(text: '2col2text', width: 10)]);
    // await SunmiPrinter.cutPaper();
    final now = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    // 1. Header
    await printText(shopName, bold: true, fontSize: 28, align: SunmiPrintAlign.CENTER);
    await printText('Receipt No:$recieptId}', bold: true, align: SunmiPrintAlign.CENTER);
    await printDivider();

    // if(phoneNumber!=null){
    //   if(phoneNumber.isNotEmpty){
    //     await printText('Customer Number : $phoneNumber', bold: true, align: SunmiPrintAlign.CENTER);
    //   }
    // }

    // 2. Items
    for (var item in items) {
      final line = '${item['name']} (${item['service']}) x ${item['quantity']}';
      await printText(line, bold: false, fontSize: 24);
      await printText('Dhs ${item['price'].toStringAsFixed(2)}', align: SunmiPrintAlign.RIGHT);
    }
    await printDivider();
    print(total);
    // 3. Total
    // await printText('TOTAL:', bold: true, fontSize: 26);
    await printText('TOTAL: Dhs ${total.toStringAsFixed(2)}', bold: true, fontSize: 26, align: SunmiPrintAlign.RIGHT);

    // 4. Footer
    await printDivider();
    await printText('Date: $now', fontSize: 20);
    await printText('Thank you for your business!', align: SunmiPrintAlign.CENTER);
    await printDivider();
    // await lineWrap(4);
    await cutPaper();
  }
}