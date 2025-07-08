

// lib/services/pdf_handler_mobile.dart
import 'dart:typed_data';
import 'dart:io' as io;

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'pdf_handler_base.dart';

class PdfHandlerMobile extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);
    final filename = 'pawpal_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/$filename';
    final file = io.File(filePath);
    await file.writeAsBytes(pdfBytes);

    await Share.shareXFiles([XFile(file.path)], text: 'Here is your PawPal receipt 🧾');
  }
}
// No createPdfHandler() needed here anymore, as it's directly instantiated in pdf_receipt_service.dart