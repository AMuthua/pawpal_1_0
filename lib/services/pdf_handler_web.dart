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
