// // // lib/services/pdf_handler_mobile.dart
// // import 'dart:typed_data';
// // import 'dart:io' as io; // Use alias to avoid conflict with 'File' from XFile

// // import 'package:path_provider/path_provider.dart';
// // import 'package:share_plus/share_plus.dart';
// // // import 'package:printing/printing.dart'; // Only needed if you want a system print dialog

// // import 'pdf_handler_base.dart'; // Import the base interface

// // class PdfHandlerMobile extends PdfHandlerBase {
// //   @override
// //   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
// //     final pdfBytes = await _generatePdfBytes(booking); // Use common generation logic
// //     final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

// //     // Save PDF to a temporary directory for sharing
// //     final dir = await getTemporaryDirectory();
// //     final filePath = '${dir.path}/$filename';
// //     final file = io.File(filePath);
// //     await file.writeAsBytes(pdfBytes);

// //     // Open system share sheet (email, WhatsApp, PDF viewers, etc.)
// //     await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');

// //     // Optionally, if you want a direct print dialog (requires 'printing' package):
// //     // await Printing.layoutPdf(onLayout: (format) async => pdfBytes);
// //   }
// // }

// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';

// class PdfHandlerMobile {
//   Future<void> generateAndSharePdf(Map<String, dynamic> booking) async {
//     final pdfBytes = await _generatePdfBytes(booking);
//     final directory = await getTemporaryDirectory();
//     final path = '${directory.path}/receipt.pdf';
//     final file = File(path);
//     await file.writeAsBytes(pdfBytes);

//     await Share.shareXFiles([XFile(path)], text: 'Here is your receipt 🧾');
//   }

//   Future<Uint8List> _generatePdfBytes(Map<String, dynamic> booking) async {
//     final pdf = pw.Document();
//     pdf.addPage(pw.Page(
//       build: (context) => pw.Text('PDF for: ${booking['service_type']}'),
//     ));
//     return pdf.save();
//   }
// }


// lib/services/pdf_handler_mobile.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_handler_base.dart';

class PdfHandlerMobile extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    final Uint8List pdfBytes = await generatePdfBytes(booking);

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/pawpal_receipt.pdf';

    final file = File(filePath);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: '🧾 Here is your receipt!');
  }
}
