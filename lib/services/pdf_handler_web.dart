
// lib/services/pdf_handler_web.dart
import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'pdf_handler_base.dart';

class PdfHandlerWeb extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);
    final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
// No createPdfHandler() needed here anymore, as it's directly instantiated in pdf_receipt_service.dart










// // // Try and comment it to see
// // //  whether it will compile without this. for mobile app. 
// // IT HAS!!!!
// // SO TO MAKE MOBILE i NEED TO COMMENT THIS PAGE OUT AND PDF RECEIPT SERVICE. 
// // The Good thing is that, It has no problem to compile the app as well for web usage. 
//         // Too early to say?