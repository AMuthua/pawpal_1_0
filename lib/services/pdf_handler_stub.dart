import 'pdf_handler_base.dart';

class PdfHandlerStub extends PdfHandlerBase {
  @override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking) async {
    throw UnsupportedError('PDF generation is not supported on this platform.');
  }
}

PdfHandlerBase getPdfHandler() => PdfHandlerStub();
