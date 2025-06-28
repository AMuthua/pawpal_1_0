

// lib/services/pdf_handler_web.dart
import 'dart:typed_data';
import 'dart:html' as html; // Allowed ONLY in web

import 'pdf_handler_base.dart';

class PdfHandlerWeb extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    final Uint8List pdfBytes = await generatePdfBytes(booking);
    
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = 'pawpal_receipt.pdf'
      ..click();

    html.Url.revokeObjectUrl(url);
  }
}


// // Try and comment it to see
// //  whether it will compile without this. for mobile app. 
// IT HAS!!!!
// SO TO MAKE MOBILE i NEED TO COMMENT THIS PAGE OUT AND PDF RECEIPT SERVICE. 
// The Good thing is that, It has no problem to compile the app as well for web usage. 
        // Too early to say?