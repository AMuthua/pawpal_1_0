// // lib/services/pdf_handler_mobile.dart
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:path_provider/path_provider.dart'; // For getting local directories
// import 'package:open_file_plus/open_file_plus.dart'; // For opening files on mobile
// import 'package:pawpal/services/pdf_handler_base.dart'; // Import the base class

// class PdfHandlerMobile extends PdfHandlerBase {
//   @override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
//     // Generate the PDF bytes using the common logic from the base class
//     // FIX: Call the static method on the base class directly
//     final pdfBytes = await PdfHandlerBase.generatePdfBytes(booking);

//     try {
//       // Get the application's temporary directory
//       final output = await getTemporaryDirectory();
//       final filePath = '${output.path}/receipt_${DateTime.now().millisecondsSinceEpoch}.pdf';
//       final file = File(filePath);

//       // Write the PDF bytes to the file
//       await file.writeAsBytes(pdfBytes);

//       // Open the PDF file using open_file_plus
//       // FIX: Ensure OpenFilePlus and ResultType are correctly referenced
//       final result = await OpenFilePlus.open(filePath);

//       // You can add more robust error handling or user feedback here
//       if (result.type != ResultType.done) {
//         print('Failed to open PDF: ${result.message}');
//         // In a real app, you might show a SnackBar or AlertDialog to the user
//       } else {
//         print('PDF saved and opened successfully at: $filePath');
//       }
//     } catch (e) {
//       print('Error generating or opening PDF on mobile: $e');
//       // In a real app, you might show a SnackBar or AlertDialog to the user
//     }
//   }
// }

// class OpenFilePlus {
//   static open(String filePath) {}
// }

// // Factory function for mobile
// PdfHandlerBase createPdfHandler() => PdfHandlerMobile();






// lib/services/pdf_handler_web.dart
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html; // For web-specific functionality
import 'package:pawpal/services/pdf_handler_base.dart'; // Import the base class
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import Service model
import 'package:pawpal/features/admin/admin_bookings_screen.dart'; // Import Booking model

class PdfHandlerWeb extends PdfHandlerBase {
  PdfHandlerWeb();

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

  @override
  Future<void> generateAndHandleServiceReport(List<Service> services) async {
    final pdfBytes = await PdfHandlerBase.generateServiceReportPdfBytes(services);

    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'service_report_${DateTime.now().millisecondsSinceEpoch}.pdf')
      ..click();

    html.Url.revokeObjectUrl(url);
  }

  @override
  Future<void> generateAndHandleBookingReport(List<Booking> bookings, Map<String, int> statusCounts, Map<String, double> statusTotals) async {
    // Call the static method from PdfHandlerBase to generate the PDF bytes
    final pdfBytes = await PdfHandlerBase.generateBookingReportPdfBytes(bookings, statusCounts, statusTotals);

    // Create a Blob from the PDF bytes
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a temporary anchor element and click it to trigger download
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'booking_report_${DateTime.now().millisecondsSinceEpoch}.pdf')
      ..click();

    // Revoke the URL to free up memory
    html.Url.revokeObjectUrl(url);
  }
}

// Factory function for web
PdfHandlerBase createPdfHandler() => PdfHandlerWeb();
