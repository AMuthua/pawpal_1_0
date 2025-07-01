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
