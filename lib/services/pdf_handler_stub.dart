import 'package:pawpal/features/admin/admin_bookings_screen.dart';

import 'package:pawpal/features/admin/manage_services_screen.dart';

import 'pdf_handler_base.dart';

class PdfHandlerStub extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    throw UnsupportedError('PDF generation is not supported on this platform.');
  }

  @override
  Future<void> generateAndHandleBookingReport(List<Booking> bookings, Map<String, int> statusCounts, Map<String, double> statusTotals) {
    // TODO: implement generateAndHandleBookingReport
    throw UnimplementedError();
  }

  @override
  Future<void> generateAndHandleServiceReport(List<Service> services) {
    // TODO: implement generateAndHandleServiceReport
    throw UnimplementedError();
  }
}

PdfHandlerBase getPdfHandler() => PdfHandlerStub();
