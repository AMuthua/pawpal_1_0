// lib/services/pdf_handler_base.dart
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Import for DateFormat

// Abstract interface for PDF handling
abstract class PdfHandlerBase {
  // Abstract method that concrete implementations (mobile/web) will override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking);
  
  // Common PDF generation logic (now static)
  static Future<Uint8List> generatePdfBytes(Map<String, dynamic> booking) async { // Made static
    final pdf = pw.Document();

    // Safely extract booking details, checking for both snake_case (from DB) and camelCase (from UI)
    // Prioritize snake_case as it comes directly from the database for MyBookingsScreen
    final pet = booking['pet'] as Map<String, dynamic>? ?? {}; // Assuming 'pet' key holds a map

    final serviceType = (booking['service_type'] as String?) ?? (booking['serviceType'] as String?) ?? 'Unknown Service';
    final status = (booking['status'] as String?) ?? 'N/A'; // Get actual status from booking
    
    final startDateString = (booking['start_date'] as String?) ?? (booking['selectedDate'] as String?);
    final endDateString = (booking['end_date'] as String?) ?? (booking['selectedEndDate'] as String?) ?? startDateString;
    final startTime = (booking['start_time'] as String?) ?? (booking['selectedTime'] as String?) ?? 'N/A';
    final totalPrice = ((booking['total_price'] ?? booking['totalPrice']) as num?)?.toDouble() ?? 0.0;
    
    final procedures = booking['procedures'] as List<dynamic>? ?? [];
    final instructions = (booking['special_instructions'] as String?) ?? (booking['specialInstructions'] as String?) ?? 'None';

    // Format dates for display
    String formattedReceiptDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

    String formattedStartDate = 'N/A';
    if (startDateString != null) {
      final DateTime? parsedStartDate = DateTime.tryParse(startDateString);
      if (parsedStartDate != null) {
        formattedStartDate = DateFormat('MMM d,yyyy').format(parsedStartDate);
      }
    }

    String formattedEndDate = 'N/A';
    if (endDateString != null) {
      final DateTime? parsedEndDate = DateTime.tryParse(endDateString);
      if (parsedEndDate != null) {
        formattedEndDate = DateFormat('MMM d,yyyy').format(parsedEndDate);
      }
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  '==============================',
                  style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'PAWPAL:GARDENVET',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'SERVICE RECEIPT',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '==============================',
                  style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Text('DATE: $formattedReceiptDate', style: pw.TextStyle(fontSize: 12)),
              pw.Text('-----------------------------', style: pw.TextStyle(fontSize: 12, font: pw.Font.courier())),
              pw.SizedBox(height: 5),

              pw.Text('PET NAME : ${pet['name'] as String? ?? 'N/A'}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('PET TYPE : ${pet['type'] as String? ?? 'N/A'}', style: pw.TextStyle(fontSize: 12)),
              pw.Text('PET BREED : ${pet['breed'] as String? ?? 'N/A'}', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 5),

              pw.Text('SERVICE : $serviceType', style: pw.TextStyle(fontSize: 12)),
              pw.Text('STATUS : ${status.toUpperCase()}', style: pw.TextStyle(fontSize: 12)),
              pw.Text(
                'SCHEDULE : ${formattedStartDate} ${formattedStartDate != formattedEndDate ? '- $formattedEndDate' : ''}',
                style: pw.TextStyle(fontSize: 12),
              ),
              if (startTime != 'N/A')
                pw.Text('TIME : $startTime', style: pw.TextStyle(fontSize: 12)),
              pw.Text('INSTRUCTIONS: ${instructions.isEmpty || instructions == 'None' ? 'None' : instructions}', style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 5),

              pw.Text('PROCEDURES:-----------------------------', style: pw.TextStyle(fontSize: 12, font: pw.Font.courier())),
              if (procedures.isEmpty)
                pw.Text('(No specific procedures listed)', style: pw.TextStyle(fontSize: 12)),
              ...procedures.map<pw.Widget>((p) {
                final procName = p['name'] as String? ?? 'N/A';
                final procPrice = (p['price'] as num?)?.toDouble() ?? 0.0;
                return pw.Text("$procName: KES ${procPrice.toStringAsFixed(2)}", style: pw.TextStyle(fontSize: 12));
              }).toList(),
              pw.Text('-----------------------------', style: pw.TextStyle(fontSize: 12, font: pw.Font.courier())),
              pw.SizedBox(height: 10),

              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: KES ${totalPrice.toStringAsFixed(2)}', 
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)
                ),
              ),
              pw.SizedBox(height: 20),

              pw.Center(
                child: pw.Text(
                  '==============================',
                  style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'THANK YOU FOR YOUR VISIT',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'KEEP YOUR PET HEALTHY!',
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '==============================',
                  style: pw.TextStyle(fontSize: 10, font: pw.Font.courier()),
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }
}
