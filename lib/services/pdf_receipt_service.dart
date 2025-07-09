// import 'dart:io' show Platform;

// import 'pdf_handler_base.dart';
// import 'pdf_handler_mobile.dart';
// // import 'pdf_handler_web.dart';

// /// Factory to select the correct handler depending on platform
// PdfHandlerBase getPdfHandler() {
//   // if (Platform.isAndroid || Platform.isIOS) {
//     return PdfHandlerMobile();
//   // } else {
//   //   return PdfHandlerWeb();
//   // }
// }

// /// Exposed function for your app to call to generate receipt
// Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//   final handler = getPdfHandler();
//   await handler.generateAndHandleReceipt(booking);
// }




// lib/services/pdf_receipt_service.dart (This is the file you import in other parts of your app)

// Import the base class definition
import 'pdf_handler_base.dart'; 

// Conditional import:
// These imports provide the *definitions* of PdfHandlerMobile and PdfHandlerWeb.
// The actual instantiation will happen via the _createPdfHandler function below.
import 'package:pawpal/services/pdf_handler_mobile.dart';
import 'package:pawpal/services/pdf_handler_web.dart';


// This is the single, platform-agnostic instance that other parts of your app will use.
// It will be initialized with either PdfHandlerMobile or PdfHandlerWeb at compile time.
final PdfHandlerBase pdfReceiptHandler = _createPdfHandler();

// Helper function to create the correct handler instance based on the platform
// This uses the compile-time constant 'dart.library.html' to pick the right implementation.
PdfHandlerBase _createPdfHandler() {
  // const bool.fromEnvironment("dart.library.html") is a compile-time constant
  // that is true when compiling for web, false otherwise.
  if (const bool.fromEnvironment("dart.library.html")) {
    return PdfHandlerWeb(); // Instantiate the web-specific handler
  } else {
    return PdfHandlerMobile(); // Instantiate the mobile/desktop handler
  }
}

// You can also provide a convenience function to directly call the handler's method
Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) {
  return pdfReceiptHandler.generateAndHandleReceipt(booking);
}
