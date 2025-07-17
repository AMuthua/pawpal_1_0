// lib/services/pdf_receipt_service.dart (This is the file you import in other parts of your app)

// Import the base class definition
import 'pdf_handler_base.dart'; 
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import Service model
import 'package:pawpal/features/admin/admin_bookings_screen.dart'; // Import Booking model

// Conditional import:
// Use 'as platform_handler' to alias the imported library,
// which will then expose the createPdfHandler function.
import 'pdf_handler_mobile.dart' // Default for non-web
    if (dart.library.html) 'pdf_handler_web.dart' as platform_handler;

// This is the single, platform-agnostic instance that other parts of your app will use.
// It will be initialized with either PdfHandlerMobile or PdfHandlerWeb at compile time.
final PdfHandlerBase pdfReceiptHandler = platform_handler.createPdfHandler();

// You can also provide a convenience function to directly call the handler's method
Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) {
  return pdfReceiptHandler.generateAndHandleReceipt(booking);
}

// Convenience function to directly call the handler's method for service reports
Future<void> generateAndHandleServiceReport(List<Service> services) {
  return pdfReceiptHandler.generateAndHandleServiceReport(services);
}

// NEW: Convenience function to directly call the handler's method for booking reports
Future<void> generateAndHandleBookingReport(List<Booking> bookings, Map<String, int> statusCounts, Map<String, double> statusTotals) {
  return pdfReceiptHandler.generateAndHandleBookingReport(bookings, statusCounts, statusTotals);
}
