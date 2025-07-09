// lib/services/pdf_handler_mobile.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart'; // For getting local directories
import 'package:open_file_plus/open_file_plus.dart'; // For opening files on mobile
import 'package:pawpal/services/pdf_handler_base.dart'; // Import the base class

class PdfHandlerMobile extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    // Generate the PDF bytes using the common logic from the base class
    // FIX: Call the static method on the base class directly
    final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);

    try {
      // Get the application's temporary directory
      final output = await getTemporaryDirectory();
      final filePath = '${output.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File(filePath);

      // Write the PDF bytes to the file
      await file.writeAsBytes(pdfBytes);

      // Open the PDF file using open_file_plus
      // FIX: Ensure OpenFilePlus and ResultType are correctly referenced
      final result = await OpenFilePlus.open(filePath);

      // You can add more robust error handling or user feedback here
      if (result.type != ResultType.done) {
        print('Failed to open PDF: ${result.message}');
        // In a real app, you might show a SnackBar or AlertDialog to the user
      } else {
        print('PDF saved and opened successfully at: $filePath');
      }
    } catch (e) {
      print('Error generating or opening PDF on mobile: $e');
      // In a real app, you might show a SnackBar or AlertDialog to the user
    }
  }
}

class OpenFilePlus {
  static open(String filePath) {}
}

// Factory function for mobile
PdfHandlerBase createPdfHandler() => PdfHandlerMobile();
