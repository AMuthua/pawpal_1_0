// // lib/services/pdf_handler_web.dart
// import 'dart:typed_data';
// // ignore: avoid_web_libraries_in_flutter
// import 'dart:html' as html;

// import 'pdf_handler_base.dart';

// class PdfHandlerWeb extends PdfHandlerBase {
//   @override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//     final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking); // Corrected call
//     final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

//     final blob = html.Blob([pdfBytes], 'application/pdf');
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute('download', filename)
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   }
// }



// lib/services/pdf_handler_web.dart
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html; // Only imported when building for web

import 'package:pdf/widgets.dart' as pw; // Ensure pdf widgets are imported for common logic
import 'pdf_handler_base.dart'; // Import the base interface

class PdfHandlerWeb extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    // FIX: Call super.generatePdfBytes to use the common logic from the base class
    final pdfBytes = await super.generatePdfBytes(booking); 
    final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // WEB: trigger download using dart:html
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click(); // Simulate a click to trigger download
    html.Url.revokeObjectUrl(url); // Clean up the object URL
  }
}

// FIX: Add a top-level factory function for conditional import
PdfHandlerBase createPdfHandler() => PdfHandlerWeb();



// // // // Try and comment it to see
// // // //  whether it will compile without this. for mobile app. 
// // // IT HAS!!!!
// // // SO TO MAKE MOBILE i NEED TO COMMENT THIS PAGE OUT AND PDF RECEIPT SERVICE. 
// // // The Good thing is that, It has no problem to compile the app as well for web usage. 
// //         // Too early to say?