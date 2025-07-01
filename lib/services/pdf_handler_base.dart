// // lib/services/pdf_handler_base.dart
// import 'dart:typed_data';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:intl/intl.dart'; // Import for DateFormat

// // Abstract interface for PDF handling
// abstract class PdfHandlerBase {
//   // Abstract method that concrete implementations (mobile/web) will override
//   Future<void> generateAndHandleReceipt(Map<String, dynamic> booking);
  
//   // Common PDF generation logic (can be shared across platforms)
//   Future<Uint8List> generatePdfBytes(Map<String, dynamic> booking) async {
//     final pdf = pw.Document();

//     // Safely extract booking details, providing fallbacks
//     final pet = booking['pets'] as Map<String, dynamic>? ?? {}; 
//     final serviceType = booking['service_type'] as String? ?? 'Unknown';
//     final status = booking['status'] as String? ?? 'N/A';
//     final startDateString = booking['start_date'] as String?;
//     final endDateString = booking['end_date'] as String? ?? startDateString;
//     final totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;
//     final procedures = booking['procedures'] as List<dynamic>? ?? []; // Assuming 'procedures' is a List
//     final instructions = booking['special_instructions'] as String? ?? 'None';

//     // Format dates for display
//     String formattedStartDate = 'N/A';
//     if (startDateString != null) {
//       final DateTime? parsedStartDate = DateTime.tryParse(startDateString);
//       if (parsedStartDate != null) {
//         formattedStartDate = DateFormat('dd MMM yyyy').format(parsedStartDate);
//       }
//     }

//     String formattedEndDate = 'N/A';
//     if (endDateString != null) {
//       final DateTime? parsedEndDate = DateTime.tryParse(endDateString);
//       if (parsedEndDate != null) {
//         formattedEndDate = DateFormat('dd MMM yyyy').format(parsedEndDate);
//       }
//     }

//     pdf.addPage(
//   pw.Page(
//     margin: const pw.EdgeInsets.all(24),
//     build: (pw.Context context) {
//       return pw.Column(
//         crossAxisAlignment: pw.CrossAxisAlignment.start,
//         children: [
//           pw.Center(
//             child: pw.Text(
//               '==============================',
//               style: const pw.TextStyle(fontSize: 14),
//             ),
//           ),
//           pw.Center(
//             child: pw.Text(
//               '      PAWPAL : GARDENVET',
//               style: pw.TextStyle(
//                 fontSize: 16,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.Center(
//             child: pw.Text(
//               '         SERVICE RECEIPT',
//               style: pw.TextStyle(
//                 fontSize: 12,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.Center(
//             child: pw.Text(
//               '==============================',
//               style: const pw.TextStyle(fontSize: 14),
//             ),
//           ),
//           pw.SizedBox(height: 10),
//           pw.Text('DATE        : ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}'),
//           pw.Text('------------------------------'),
//           pw.Text('PET NAME    : ${pet['name'] ?? 'N/A'}'),
//           pw.Text('PET TYPE    : ${pet['type'] ?? 'N/A'}'),
//           pw.Text('SERVICE     : $serviceType'),
//           pw.Text('STATUS      : $status'),
//           pw.Text('SCHEDULE    : $formattedStartDate ${formattedEndDate != formattedStartDate ? "- $formattedEndDate" : ""}'),
//           pw.SizedBox(height: 10),
//           pw.Text('INSTRUCTIONS:'),
//           pw.Text(instructions),
//           pw.SizedBox(height: 10),
//           pw.Text('PROCEDURES'),
//           pw.Text('------------------------------'),
//           if (procedures.isEmpty)
//             pw.Text('  (No procedures listed)'),
//           ...procedures.map<pw.Widget>((proc) {
//             final name = proc['name'] ?? 'Procedure';
//             final price = (proc['price'] ?? 0).toStringAsFixed(2);
//             return pw.Text(' - $name ......... KES $price');
//           }).toList(),
//           pw.SizedBox(height: 10),
//           pw.Text('------------------------------'),
//           pw.Align(
//             alignment: pw.Alignment.centerRight,
//             child: pw.Text(
//               'TOTAL: KES ${totalPrice.toStringAsFixed(2)}',
//               style: pw.TextStyle(
//                 fontSize: 14,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Center(child: pw.Text('==============================')),
//           pw.Center(child: pw.Text('  THANK YOU FOR YOUR VISIT')),
//           pw.Center(child: pw.Text('   KEEP YOUR PET HEALTHY!')),
//           pw.Center(child: pw.Text('==============================')),
//         ],
//       );
//     },
//   ),
// );


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
