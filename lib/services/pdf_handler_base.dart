// lib/services/pdf_handler_base.dart
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart'; // Import PdfColors for table borders
import 'package:intl/intl.dart'; // Import for DateFormat
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import Service model
import 'package:pawpal/features/admin/admin_bookings_screen.dart'; // Import Booking model

// Abstract interface for PDF handling
abstract class PdfHandlerBase {
  // Abstract method that concrete implementations (mobile/web) will override for bookings
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking);
  
  // Abstract method for service reports
  Future<void> generateAndHandleServiceReport(List<Service> services);

  // NEW Abstract method for booking reports
  Future<void> generateAndHandleBookingReport(List<Booking> bookings, Map<String, int> statusCounts, Map<String, double> statusTotals);


static Future<Uint8List> generatePdfBytes(Map<String, dynamic> booking) async {
  final pdf = pw.Document();

  // Safely extract booking details, **checking both snake_case and camelCase**
  final pet = booking['pet'] as Map<String, dynamic>? ?? {}; // Assuming 'pet' is a map

  final serviceType = (booking['service_type'] as String?) ?? (booking['serviceType'] as String?) ?? 'Unknown Service';
  final status = (booking['status'] as String?) ?? 'N/A';

  final startDateString = (booking['start_date'] as String?) ?? (booking['selectedDate'] as String?);
  final endDateString = (booking['end_date'] as String?) ?? (booking['selectedEndDate'] as String?) ?? startDateString;
  final startTime = (booking['start_time'] as String?) ?? (booking['selectedTime'] as String?) ?? 'N/A';
  final totalPrice = ((booking['total_price'] ?? booking['totalPrice']) as num?)?.toDouble() ?? 0.0;

  final procedures = booking['procedures'] as List<dynamic>? ?? [];
  final instructions =
      (booking['special_instructions'] as String?) ??
      (booking['specialInstructions'] as String?) ??
      'None';

  final String petName = pet['name'] as String? ?? 'N/A';
  final String petType = pet['type'] as String? ?? 'N/A';
  final String petBreed = pet['breed'] as String? ?? 'N/A';

  // Format dates for display
  String formattedReceiptDate = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());

  String formattedStartDate = 'N/A';
  if (startDateString != null) {
    final DateTime? parsedStartDate = DateTime.tryParse(startDateString);
    if (parsedStartDate != null) {
      formattedStartDate = DateFormat('dd MMM yyyy').format(parsedStartDate);
    }
  }

  String formattedEndDate = 'N/A';
  if (endDateString != null) {
    final DateTime? parsedEndDate = DateTime.tryParse(endDateString);
    if (parsedEndDate != null) {
      formattedEndDate = DateFormat('dd MMM yyyy').format(parsedEndDate);
    }
  }

  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(24),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [            pw.Center(child: pw.Text('==============================', style: const pw.TextStyle(fontSize: 14))),
            pw.Center(child: pw.Text('        PAWPAL : GARDENVET', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold))),
            pw.Center(child: pw.Text('          SERVICE RECEIPT', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold))),
            pw.Center(child: pw.Text('==============================', style: const pw.TextStyle(fontSize: 14))),
            pw.SizedBox(height: 10),
            pw.Text('DATE          : $formattedReceiptDate'),
            pw.Text('------------------------------'),
            pw.Text('PET NAME      : $petName'),
            pw.Text('PET TYPE      : $petType'),
            pw.Text('PET BREED     : $petBreed'),
            pw.Text('SERVICE       : $serviceType'),
            pw.Text('STATUS        : $status'),
            pw.Text(
              'SCHEDULE      : $formattedStartDate${formattedEndDate != formattedStartDate ? " - $formattedEndDate" : ""}',
              maxLines: 1,
            ),
            if (startTime != 'N/A')
              pw.Text('TIME          : $startTime'),
            pw.SizedBox(height: 10),
            pw.Text('INSTRUCTIONS:'),
            pw.Text(instructions.isEmpty || instructions == 'None' ? 'None' : instructions),
            pw.SizedBox(height: 10),
            pw.Text('PROCEDURES:'),
            pw.Text('------------------------------'),
            if (procedures.isEmpty)
              pw.Text('   (No specific procedures listed)'),
            ...procedures.map<pw.Widget>((p) {
              final procName = (p is Map ? p['name'] as String? : null) ?? 'N/A';
              final procPrice = (p is Map ? (p['price'] as num?)?.toDouble() : null) ?? 0.0;
              return pw.Row(
                children: [                  pw.Text(' - $procName'),
                  pw.Spacer(),
                  pw.Text('KES ${procPrice.toStringAsFixed(2)}'),
                ],
              );
            }).toList(),
            pw.Spacer(),
            pw.SizedBox(height: 10),
            pw.Text('------------------------------'),
            pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text(
                'TOTAL: KES ${totalPrice.toStringAsFixed(2)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Center(child: pw.Text('==============================')),
            pw.Center(child: pw.Text('   THANK YOU FOR YOUR VISIT')),
            pw.Center(child: pw.Text('    KEEP YOUR PET HEALTHY!')),
            pw.Center(child: pw.Text('==============================')),
          ],
        );
      },
    ),
  );

  return await pdf.save();
}

  // Common PDF generation logic for service reports
  static Future<Uint8List> generateServiceReportPdfBytes(List<Service> services) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              '==============================',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '        PAWPAL : GARDENVET',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '          SERVICE REPORT',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '==============================',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('REPORT DATE: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
          pw.SizedBox(height: 20),
          
          if (services.isEmpty)
            pw.Center(child: pw.Text('No services to display in this report.')),
          
          if (services.isNotEmpty)
            pw.Table.fromTextArray(
              headers: ['Service Name', 'Description', 'Price (KES)', 'Duration (mins)'],
              data: services.map((service) => [
                service.name,
                service.description,
                service.price.toStringAsFixed(2),
                service.durationMinutes.toString(),
              ]).toList(),
              border: pw.TableBorder.all(width: 1.0, color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Name
                1: const pw.FlexColumnWidth(4), // Description
                2: const pw.FlexColumnWidth(1.5), // Price
                3: const pw.FlexColumnWidth(1.5), // Duration
              },
            ),
          
          pw.SizedBox(height: 20),
          pw.Center(child: pw.Text('--- End of Report ---')),
        ],
      ),
    );

    return await pdf.save();
  }

  // NEW: Common PDF generation logic for booking reports
  static Future<Uint8List> generateBookingReportPdfBytes(
      List<Booking> bookings, Map<String, int> statusCounts, Map<String, double> statusTotals) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          pw.Center(
            child: pw.Text(
              '==============================',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '        PAWPAL : GARDENVET',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '          BOOKING REPORT',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Center(
            child: pw.Text(
              '==============================',
              style: const pw.TextStyle(fontSize: 14),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text('REPORT DATE: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
          pw.SizedBox(height: 20),

          pw.Text('Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 10),
          pw.Text('Total Bookings: ${bookings.length}'),
          pw.SizedBox(height: 5),

          pw.Text('Bookings by Status:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          ...statusCounts.entries.map((entry) {
            final statusName = entry.key.replaceAll('_', ' ').replaceFirst(entry.key[0], entry.key[0].toUpperCase());
            final count = entry.value;
            final total = statusTotals[entry.key]?.toStringAsFixed(2) ?? '0.00';
            return pw.Text('  - $statusName: $count (Total: KES $total)');
          }).toList(),
          pw.SizedBox(height: 20),

          if (bookings.isEmpty)
            pw.Center(child: pw.Text('No bookings to display in this report matching filters.')),

          if (bookings.isNotEmpty)
            pw.Table.fromTextArray(
              headers: ['Owner', 'Pet', 'Service', 'Dates', 'Status', 'Total Price (KES)'],
              data: bookings.map((booking) {
                final String formattedStartDate = DateFormat('dd MMM yy').format(booking.startDate);
                final String formattedEndDate = booking.endDate != null
                    ? DateFormat('dd MMM yy').format(booking.endDate!)
                    : formattedStartDate;
                final String dateRange = booking.serviceType == 'Boarding'
                    ? '$formattedStartDate - $formattedEndDate'
                    : formattedStartDate;

                final String displayStatus = booking.status.replaceAll('_', ' ').replaceFirst(booking.status[0], booking.status[0].toUpperCase());

                return [
                  booking.ownerDisplayName ?? 'N/A',
                  booking.petDetails['name'] ?? 'N/A',
                  booking.serviceType,
                  dateRange,
                  displayStatus,
                  booking.totalPrice.toStringAsFixed(2),
                ];
              }).toList(),
              border: pw.TableBorder.all(width: 1.0, color: PdfColors.grey),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Owner
                1: const pw.FlexColumnWidth(1.5), // Pet
                2: const pw.FlexColumnWidth(1.5), // Service
                3: const pw.FlexColumnWidth(2), // Dates
                4: const pw.FlexColumnWidth(1.5), // Status
                5: const pw.FlexColumnWidth(1.5), // Total Price
              },
            ),

          pw.SizedBox(height: 20),
          pw.Center(child: pw.Text('--- End of Report ---')),
        ],
      ),
    );

    return await pdf.save();
  }
}
