// // lib/services/pdf_handler_base.dart
// import 'dart:typed_data';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart'; // Import for DateFormat

// // Abstract interface for PDF handling
// abstract class PdfHandlerBase {
//   // Abstract method that concrete implementations (mobile/web) will override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking);
  
//   // Common PDF generation logic (now static and public)
//   static Future<Uint8List> generatePdfBytes(Map<String, dynamic> booking) async { // Made static and public
//     final pdf = pw.Document();

//     // Safely extract booking details, providing fallbacks
//     final pet = booking['pet'] as Map<String, dynamic>? ?? {}; // Assuming 'pet' key holds a map
//     // FIX: Use correct keys from bookingDetails map passed from BookingConfirmationScreen
//     final serviceType = booking['serviceType'] as String? ?? 'Unknown Service';
//     // For receipt, we can assume 'Confirmed' as it's generated after successful booking
//     final status = 'Confirmed'; 
//     final startDateString = booking['selectedDate'] as String?; // FIX: Use 'selectedDate'
//     final endDateString = booking['selectedEndDate'] as String? ?? startDateString; // FIX: Use 'selectedEndDate'
//     final totalPrice = (booking['totalPrice'] as num?)?.toDouble() ?? 0.0; // FIX: Use 'totalPrice'
//     final procedures = booking['procedures'] as List<dynamic>? ?? []; // This key was already correct
//     final instructions = booking['specialInstructions'] as String? ?? 'None'; // FIX: Use 'specialInstructions'

//     // Format dates for display
//     String formattedStartDate = 'N/A';
//     if (startDateString != null) {
//       final DateTime? parsedStartDate = DateTime.tryParse(startDateString);
//       if (parsedStartDate != null) {
//         formattedStartDate = DateFormat('dd MMM yyyy').format(parsedStartDate); // Changed format for clarity
//       }
//     }

//     String formattedEndDate = 'N/A';
//     if (endDateString != null) {
//       final DateTime? parsedEndDate = DateTime.tryParse(endDateString);
//       if (parsedEndDate != null) {
//         formattedEndDate = DateFormat('dd MMM yyyy').format(parsedEndDate); // Changed format for clarity
//       }
//     }

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('PawPal : GardenVet Receipt', style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 16),
//               pw.Text('Receipt Date: ${DateFormat('dd MMM yyyy HH:mm').format(DateTime.now())}'),
//               pw.SizedBox(height: 12),
//               pw.Text('--- Booking Details ---', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 8),
//               pw.Text('Pet Name: ${pet['name'] as String? ?? 'N/A'}'),
//               pw.Text('Pet Type: ${pet['type'] as String? ?? 'N/A'}'),
//               pw.Text('Pet Breed: ${pet['breed'] as String? ?? 'N/A'}'), // Added pet breed
//               pw.Text('Service Type: $serviceType'),
//               pw.Text('Booking Status: $status'),
//               pw.Text('Service Dates: $formattedStartDate ${formattedStartDate != formattedEndDate ? 'to $formattedEndDate' : ''}'),
//               pw.SizedBox(height: 12),
//               pw.Text('Special Instructions: $instructions'),
//               pw.SizedBox(height: 12),
//               pw.Text('--- Procedures/Items ---', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 8),
//               if (procedures.isEmpty) pw.Text('No specific procedures listed.'),
//               ...procedures.map<pw.Widget>((p) {
//                 final procName = p['name'] as String? ?? 'N/A';
//                 final procPrice = (p['price'] as num?)?.toDouble() ?? 0.0;
//                 return pw.Bullet(text: "$procName: KES ${procPrice.toStringAsFixed(2)}");
//               }).toList(), // Convert to list
//               pw.SizedBox(height: 12),
//               pw.Divider(),
//               pw.SizedBox(height: 12),
//               pw.Align(
//                 alignment: pw.Alignment.centerRight,
//                 child: pw.Text(
//                   'Total Amount Paid: KES ${totalPrice.toStringAsFixed(2)}', 
//                   style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)
//                 ),
//               ),
//               pw.SizedBox(height: 20),
//               pw.Text('Thank you for choosing PawPal!', style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
//             ],
//           );
//         },
//       ),
//     );

//     return await pdf.save();
//   }
// }








// lib/services/pdf_handler_base.dart
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart'; // Import for DateFormat

// Abstract interface for PDF handling
abstract class PdfHandlerBase {
  // Abstract method that concrete implementations (mobile/web) will override
  Future<void> generateAndHandleReceipt(Map<String, dynamic> booking);
  
  // Common PDF generation logic (can be shared across platforms)
  Future<Uint8List> generatePdfBytes(Map<String, dynamic> booking) async {
    final pdf = pw.Document();

    // Safely extract booking details, providing fallbacks
    // FIXED: Changed 'pets' to 'pet' to match the key passed from BookServiceScreen
    final Map<String, dynamic> pet = booking['pet'] as Map<String, dynamic>? ?? {}; 
    final String serviceType = booking['service_type'] as String? ?? 'Unknown Service';
    final String status = booking['status'] as String? ?? 'N/A';
    final String? startDateString = booking['start_date'] as String?;
    final String? endDateString = booking['end_date'] as String?; // Keep nullable for logic
    final double totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
    // Ensure procedures is a List<Map<String, dynamic>>
    final List<Map<String, dynamic>> procedures = (booking['procedures'] as List<dynamic>?)
        ?.map((e) => e as Map<String, dynamic>)
        .toList() ?? [];
    final String instructions = booking['special_instructions'] as String? ?? 'None';

    // Extract pet details from the 'pet' map
    final String petName = pet['name'] as String? ?? 'N/A';
    final String petType = pet['type'] as String? ?? 'N/A';
    final String petBreed = pet['breed'] as String? ?? 'N/A'; // NEW: Get pet breed

    // Format dates for display
    String formattedStartDate = 'N/A';
    if (startDateString != null) {
      final DateTime? parsedStartDate = DateTime.tryParse(startDateString);
      if (parsedStartDate != null) {
        formattedStartDate = DateFormat('dd MMM yyyy').format(parsedStartDate);
      }
    }

    String formattedEndDate = formattedStartDate; // Default to start date if no end date
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
            children: [
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
                  '          SERVICE RECEIPT',
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
              pw.Text('DATE          : ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
              pw.Text('------------------------------'),
              pw.Text('PET NAME      : $petName'),
              pw.Text('PET TYPE      : $petType'),
              pw.Text('PET BREED     : $petBreed'), // NEW: Display pet breed
              pw.Text('SERVICE       : $serviceType'),
              pw.Text('STATUS        : $status'),
              pw.Text('SCHEDULE      : $formattedStartDate ${serviceType == 'Boarding' ? "- $formattedEndDate" : ""}'),
              pw.SizedBox(height: 10),
              pw.Text('INSTRUCTIONS:'),
              pw.Text(instructions),
              pw.SizedBox(height: 10),
              pw.Text('PROCEDURES:'), // Added colon for consistency
              pw.Text('------------------------------'),
              if (procedures.isEmpty)
                pw.Text('   (No specific procedures listed)'),
              ...procedures.map<pw.Widget>((proc) {
                final name = proc['name'] as String? ?? 'Procedure';
                final price = (proc['price'] as num?)?.toDouble() ?? 0.0;
                return pw.Row(
                  children: [
                    pw.Text(' - $name'),
                    pw.Spacer(), // Pushes price to the right
                    pw.Text('KES ${price.toStringAsFixed(2)}'),
                  ],
                );
              }).toList(),
              pw.SizedBox(height: 10),
              pw.Text('------------------------------'),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                  'TOTAL: KES ${totalPrice.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
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
}
