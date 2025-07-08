

// // // lib/services/pdf_handler_mobile.dart
// // import 'dart:typed_data';
// // import 'dart:io' as io;

// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';

// // import 'pdf_handler_base.dart';

// // class PdfHandlerMobile extends PdfHandlerBase {
// //   @override
// //   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
// //     final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);
// //     final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

// //     final dir = await getTemporaryDirectory();
// //     final filePath = '${dir.path}/$filename';
// //     final file = io.File(filePath);
// //     await file.writeAsBytes(pdfBytes);

// //     await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');
// //   }
// // }
// // // No createPdfHandler() needed here anymore, as it's directly instantiated in pdf_receipt_service.dart




// // lib/services/pdf_handler_mobile.dart
// import 'dart:typed_data';
// import 'dart:io' as io;

// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';

// import 'pdf_handler_base.dart';

// class PdfHandlerMobile extends PdfHandlerBase {
//   @override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//     final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking); // Corrected call
//     final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

//     final dir = await getTemporaryDirectory();
//     final filePath = '${dir.path}/$filename';
//     final file = io.File(filePath);
//     await file.writeAsBytes(pdfBytes);

//     await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');
//   }
// }




// // lib/services/pdf_handler_mobile.dart
// import 'dart:typed_data';
// import 'dart:io' as io; // Use alias to avoid conflict with 'File' from XFile

// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw; // Ensure pdf widgets are imported for common logic
// // import 'package:printing/printing.dart'; // Only needed if you want a system print dialog

// import 'pdf_handler_base.dart'; // Import the base interface

// class PdfHandlerMobile extends PdfHandlerBase {
//   @override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//     final pdfBytes = await generatePdfBytes(booking); // Use common generation logic from base
//     final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

//     // Save PDF to a temporary directory for sharing
//     final dir = await getTemporaryDirectory();
//     final filePath = '${dir.path}/$filename';
//     final file = io.File(filePath);
//     await file.writeAsBytes(pdfBytes);

//     // Open system share sheet (email, WhatsApp, PDF viewers, etc.)
//     await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');

//     // Optionally, if you want a direct print dialog (requires 'printing' package):
//     // await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
//   }
// }

// // FIX: Add a top-level factory function for conditional import
// PdfHandlerBase createPdfHandler() => PdfHandlerMobile();






// lib/services/pdf_handler_mobile.dart
import 'dart:typed_data';
import 'dart:io' as io; // Use alias to avoid conflict with 'File' from XFile

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw; // Ensure pdf widgets are imported for common logic
// import 'package:printing/printing.dart'; // Only needed if you want a system print dialog

import 'pdf_handler_base.dart'; // Import the base interface

class PdfHandlerMobile extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    // FIX: Call super.generatePdfBytes to use the common logic from the base class
    final pdfBytes = await super.generatePdfBytes(booking); 
    final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

    // Save PDF to a temporary directory for sharing
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$filename';
    final file = io.File(filePath);
    await file.writeAsBytes(pdfBytes);

    // Open system share sheet (email, WhatsApp, PDF viewers, etc.)
    await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');

    // Optionally, if you want a direct print dialog (requires 'printing' package):
    // await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
  }
}

// FIX: Add a top-level factory function for conditional import
PdfHandlerBase createPdfHandler() => PdfHandlerMobile();
