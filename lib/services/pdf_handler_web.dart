// import 'dart:html' as html;
// import 'dart:typed_data';
// import 'package:pawpal/services/pdf_handler_base.dart';

// class PdfHandlerWeb extends PdfHandlerBase {
//   @override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//     final bytes = await generatePdfBytes(booking);
//     final blob = html.Blob([bytes]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute('download', 'receipt.pdf')
//       ..click();
//     html.Url.revokeObjectUrl(url);
//   }
// }



// lib/services/pdf_handler_web.dart
import 'dart:typed_data';
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // Required for setUrlStrategy
import 'package:pdf/pdf.dart';
import 'package:universal_html/html.dart' as html; // For web-specific functionality
import 'package:pawpal/services/pdf_handler_base.dart'; // Import the base class

class PdfHandlerWeb extends PdfHandlerBase {
  // PdfHandlerWeb() {
  //   // Ensure URL strategy is set for web if needed (often done in main.dart)
  //   // setUrlStrategy(PathUrlStrategy());
  // }

  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    // Call the static method on the base class directly
    final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);

    // Create a Blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a temporary anchor element and click it to trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'receipt_${DateTime.now().millisecondsSinceEpoch}.pdf')
      ..click();

    // Revoke the URL to free up memory
    html.Url.revokeObjectUrl(url);
  }
}

// Factory function for web
PdfHandlerBase createPdfHandler() => PdfHandlerWeb();
