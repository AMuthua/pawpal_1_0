// lib/services/pdf_receipt_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

import 'pdf_handler_mobile.dart';
import 'pdf_handler_web.dart';

Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
  if (kIsWeb) {
    await PdfHandlerWeb().generateAndHandleReceipt(booking);
  } else {
    await PdfHandlerMobile().generateAndHandleReceipt(booking);
  }
}



