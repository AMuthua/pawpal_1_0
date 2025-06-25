// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// // ignore: unused_import
// import 'package:uuid/uuid.dart'; // For generating UUID for booking ID, if not relying solely on DB default

// class BookingConfirmationScreen extends StatefulWidget {
//   final Map<String, dynamic> bookingDetails;

//   const BookingConfirmationScreen({super.key, required this.bookingDetails});

//   @override
//   State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
// }

// class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {

//   late final SupabaseClient _client;
//   bool _isBooking = false;
//   String _petName = 'Loading...';
//   String _petType = 'Loading...';

//   // Add payment state variables
//   bool _isProcessingPayment = false;
//   bool _isPaymentCompleted = false;

//   @override
//   void initState() {
//     super.initState();
//     _client = Supabase.instance.client;
//     _fetchPetDetails();
//   }

//   // Fetch pet's name based on ID for display
//   Future<void> _fetchPetDetails() async {
//     try {
//       final petId = widget.bookingDetails['selectedPetId'] as String;
//       final response = await _client.from('pets').select('name, type').eq('id', petId).single();
//       if (mounted) {
//         setState(() {
//           _petName = response['name'] as String? ?? 'Unnamed Pet';
//           _petType = response['type'] as String? ?? 'Unknown Type';
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _petName = 'Error';
//           _petType = 'Error';
//         });
//       }
//       _showSnackBar('Failed to load pet details: $e', isError: true);
//     }
//   }

//   // Helper to show SnackBar messages
//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   // --- Time Slot Conflict Check ---
//   // --- Time Slot Conflict Check ---
// Future<bool> _checkForConflict() async {
//   // SAFELY retrieve and cast values
//   final String? serviceType = widget.bookingDetails['serviceType'] as String?;
//   final String? selectedDateString = widget.bookingDetails['selectedDate'] as String?;
//   final String? selectedTime = widget.bookingDetails['selectedTime'] as String?;
//   final String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?;

//   // Crucial: Handle cases where essential booking details are missing or invalid
//   if (serviceType == null || selectedDateString == null) {
//     _showSnackBar('Missing essential booking details for conflict check.', isError: true);
//     return true; // Assume conflict or error to prevent invalid booking
//   }

//   DateTime? startDateTime = DateTime.tryParse(selectedDateString);
//   if (startDateTime == null) {
//     _showSnackBar('Invalid service date format for conflict check.', isError: true);
//     return true; // Assume conflict
//   }

//   DateTime? fullStartTime;
//   if (selectedTime != null && selectedTime.isNotEmpty) {
//     try {
//       final parts = selectedTime.split(':');
//       fullStartTime = DateTime(
//         startDateTime.year,
//         startDateTime.month,
//         startDateTime.day,
//         int.parse(parts[0]),
//         int.parse(parts[1]),
//       );
//     } catch (e) {
//       print('Error parsing selectedTime in _checkForConflict: "$selectedTime" -> $e');
//       _showSnackBar('Invalid service time format for conflict check.', isError: true);
//       return true; // Assume conflict
//     }
//   }

//   DateTime? endDateTime;
//   if (selectedEndDateString != null) {
//     endDateTime = DateTime.tryParse(selectedEndDateString);
//     if (endDateTime == null) {
//       _showSnackBar('Invalid end date format for conflict check.', isError: true);
//       return true; // Assume conflict
//     }
//   }

//   // Adjust end date for single-day boarding to be the same as start date
//   DateTime bookingEndDate = endDateTime ?? startDateTime;

//   try {
//     final conflicts = await _client
//         .from('bookings')
//         .select('id, start_date, end_date, start_time')
//         .eq('service_type', serviceType) // Use the safely retrieved serviceType
//         .inFilter('status', ['pending', 'approved']); // Only active/pending bookings

//     for (final booking in conflicts) {
//       // Safely parse existing booking dates
//       final existingStartDateString = booking['start_date'] as String?;
//       final existingEndDateString = booking['end_date'] as String?;
//       final existingStartTimeString = booking['start_time'] as String?;

//       if (existingStartDateString == null) {
//         // Skip malformed existing bookings or handle as an error
//         print('Warning: Existing booking with null start_date found. Skipping conflict check for this booking.');
//         continue;
//       }

//       final existingStartDate = DateTime.tryParse(existingStartDateString);
//       if (existingStartDate == null) {
//         print('Warning: Existing booking with invalid start_date format. Skipping conflict check for this booking.');
//         continue;
//       }

//       final existingEndDate = existingEndDateString != null
//           ? DateTime.tryParse(existingEndDateString) ?? existingStartDate
//           : existingStartDate;

//       // Parse existing start time (if available)
//       DateTime? existingFullStartTime;
//       if (existingStartTimeString != null && existingStartTimeString.isNotEmpty) {
//         try {
//           final parts = existingStartTimeString.split(':');
//           existingFullStartTime = DateTime(
//             existingStartDate.year,
//             existingStartDate.month,
//             existingStartDate.day,
//             int.parse(parts[0]),
//             int.parse(parts[1]),
//           );
//         } catch (e) {
//           print('Error parsing existing start_time "$existingStartTimeString": $e');
//           // Continue or handle as needed, maybe skip this booking for conflict check
//         }
//       }

//       // --- Conflict Logic ---
//       // For Boarding (date-based conflict)
//       if (serviceType == 'Boarding') {
//         // Check for date overlaps
//         if (
//             (startDateTime.isBefore(existingEndDate.add(const Duration(days: 1))) &&
//                 bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)) ||
//             (existingStartDate.isBefore(bookingEndDate.add(const Duration(days: 1))) &&
//                 existingEndDate.add(const Duration(days: 1)).isAfter(startDateTime))
//         ) {
//           return true; // Conflict found
//         }
//       }
//       // For other services (specific time slot conflict)
//       else {
//         if (fullStartTime != null && existingFullStartTime != null) {
//           // This is a simplified check: assumes services take 1 hour
//           // You might need to adjust duration based on service type.
//           final proposedEnd = fullStartTime.add(const Duration(hours: 1)); // Assuming 1 hour service
//           final existingProposedEnd = existingFullStartTime.add(const Duration(hours: 1)); // Assuming 1 hour service

//           if (startDateTime.isAtSameMomentAs(existingStartDate) && // Same Day
//               fullStartTime.isBefore(existingProposedEnd) &&
//               proposedEnd.isAfter(existingFullStartTime)) {
//             return true; // Conflict found
//           }
//         }
//       }
//     }
//     return false; // No conflict found
//   } catch (e) {
//     _showSnackBar('Error checking for conflicts: $e', isError: true);
//     print('Detailed error during conflict check: $e');
//     return true; // Assume conflict or error to prevent double booking
//   }
// }

// // Future<void> _confirmBooking() async {
// //     if (_isProcessingPayment) return;
    
// //     setState(() {
// //       _isProcessingPayment = true;
// //       _isBooking = true;
// //     });

// //     try {
// //       final userId = _client.auth.currentUser?.id;
// //       if (userId == null) {
// //         _showSnackBar('User not logged in.', isError: true);
// //         if (mounted) context.go('/login');
// //         return;
// //       }

// //       // Perform conflict check
// //       final hasConflict = await _checkForConflict();
// //       if (hasConflict) {
// //         _showSnackBar('Selected time slot is already booked. Please choose another.', isError: true);
// //         return;
// //       }

// //       // Parse dates and time
// //       final selectedDate = DateTime.parse(widget.bookingDetails['selectedDate'] as String);
// //       final selectedTime = widget.bookingDetails['selectedTime'] as String?;
// //       final selectedEndDate = widget.bookingDetails['selectedEndDate'] != null
// //           ? DateTime.parse(widget.bookingDetails['selectedEndDate'] as String)
// //           : null;

// //       // NEW: Get price from booking details
// //       final double totalPrice = widget.bookingDetails['totalPrice'] as double? ?? 0.0;

// //       // Prepare data with price and payment status
// //       final newBooking = {
// //         'owner_id': userId,
// //         'pet_id': widget.bookingDetails['selectedPetId'],
// //         'service_type': widget.bookingDetails['serviceType'],
// //         'start_date': DateFormat('yyyy-MM-dd').format(selectedDate),
// //         'end_date': selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate) : null,
// //         'start_time': selectedTime,
// //         'special_instructions': widget.bookingDetails['specialInstructions'],
// //         'status': 'pending_payment', // Payment pending status
// //         'total_price': totalPrice, // NEW: Include price
// //       };

// //       await _client.from('bookings').insert(newBooking);

// //       // NEW: Simulate payment processing
// //       await _processMpesaPayment();

// //       if (mounted) context.go('/home');
// //     } catch (e) {
// //       _showSnackBar('Failed to create booking: $e', isError: true);
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isProcessingPayment = false;
// //           _isBooking = false;
// //         });
// //       }
// //     }
// //   }


// Future<void> _confirmBooking() async {
//   if (_isProcessingPayment) return;

//   setState(() {
//     _isProcessingPayment = true;
//     _isBooking = true;
//   });
// // This is debugging, to check what data is being fed into the Booking process
//   print('Booking Details received in _confirmBooking: ${widget.bookingDetails}');

//   try {
//     final userId = _client.auth.currentUser?.id;
//     if (userId == null) {
//       _showSnackBar('User not logged in.', isError: true);
//       if (mounted) context.go('/login');
//       return;
//     }

//     // Perform conflict check
//     final hasConflict = await _checkForConflict();
//     if (hasConflict) {
//       _showSnackBar('Selected time slot is already booked. Please choose another.', isError: true);
//       return;
//     }

//     // Parse dates and time safely
//     final String? selectedDateString = widget.bookingDetails['startDate'] as String?;
//     if (startDateString == null) {
//       _showSnackBar('Service date is missing.', isError: true);
//       return;
//     }
//     final DateTime? startDate = DateTime.tryParse(selectedDateString);
//     if (selectedDate == null) {
//       _showSnackBar('Service date format is invalid.', isError: true);
//       return;
//     }

//     final String? selectedTime = widget.bookingDetails['selectedTime'] as String?; // Can be null, handled below

//     final String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?;
//     DateTime? selectedEndDate;
//     if (selectedEndDateString != null) {
//       selectedEndDate = DateTime.tryParse(selectedEndDateString);
//       if (selectedEndDate == null) {
//         _showSnackBar('End date format is invalid.', isError: true);
//         return;
//       }
//     }

//     // Ensure other critical booking details are present and of the correct type
//     final String? selectedPetId = widget.bookingDetails['selectedPetId'] as String?;
//     if (selectedPetId == null) {
//       _showSnackBar('Pet ID is missing for booking.', isError: true);
//       return;
//     }

//     final String? serviceType = widget.bookingDetails['serviceType'] as String?;
//     if (serviceType == null) {
//       _showSnackBar('Service type is missing for booking.', isError: true);
//       return;
//     }

//     final String specialInstructions = widget.bookingDetails['specialInstructions'] as String? ?? ''; // Default to empty string

//     final double totalPrice = widget.bookingDetails['totalPrice'] as double? ?? 0.0;

//     // Prepare data with price and payment status
//     final newBooking = {
//       'owner_id': userId,
//       'pet_id': selectedPetId,
//       'service_type': serviceType,
//       'start_date': DateFormat('yyyy-MM-dd').format(selectedDate),
//       'end_date': selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate) : null,
//       'start_time': selectedTime, // This can be null if not provided, matching your DB schema (TIME WITHOUT TIME ZONE)
//       'special_instructions': specialInstructions,
//       'status': 'pending_payment',
//       'total_price': totalPrice,
//     };

//     await _client.from('bookings').insert(newBooking);

//     await _processMpesaPayment();

//     if (mounted) context.go('/home');
//   } catch (e) {
//     _showSnackBar('Failed to create booking: $e', isError: true);
//     // Print the full error for detailed debugging in console
//     print('Error during booking confirmation: $e');
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isProcessingPayment = false;
//         _isBooking = false;
//       });
//     }
//   }
// }
//   // NEW: M-Pesa payment simulation
//   Future<void> _processMpesaPayment() async {
//     // Simulate payment processing delay
//     await Future.delayed(const Duration(seconds: 2));
    
//     // In a real app, this would:
//     // 1. Initiate M-Pesa STK push
//     // 2. Wait for payment confirmation
//     // 3. Update booking status to 'completed'
    
//     setState(() => _isPaymentCompleted = true);
//     _showSnackBar('Payment successful!', isError: false);
//   }

//   // NEW: Calculate boarding days for display
//   // int _calculateBoardingDays() {
//   //   if (widget.bookingDetails['selectedDate'] == null || 
//   //       widget.bookingDetails['selectedEndDate'] == null) {
//   //     return 0;
//   //   }
    
//   //   final start = DateTime.parse(widget.bookingDetails['selectedDate']);
//   //   final end = DateTime.parse(widget.bookingDetails['selectedEndDate']);
//   //   return end.difference(start).inDays + 1;
//   // }

//   int _calculateBoardingDays() {
//   String? selectedDateString = widget.bookingDetails['selectedDate'] as String?;
//   String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?;

//   if (selectedDateString == null || selectedEndDateString == null) {
//     return 0; // Cannot calculate if dates are missing
//   }

//   final DateTime? start = DateTime.tryParse(selectedDateString);
//   final DateTime? end = DateTime.tryParse(selectedEndDateString);

//   if (start == null || end == null) {
//     // Dates were present but not validly formatted
//     print('Warning: Invalid date format for boarding days calculation. Start: $selectedDateString, End: $selectedEndDateString');
//     return 0;
//   }

//   // Ensure end date is not before start date for valid calculation
//   if (end.isBefore(start)) {
//     return 0;
//   }

//   return end.difference(start).inDays + 1;
// }

//   // @override
//   // Widget build(BuildContext context) {
//   // final booking = widget.bookingDetails;
//   // final serviceType = booking['serviceType'];
  
//   // // SAFE DATE HANDLING
//   // DateTime? startDate;
//   // String? selectedDate = booking['selectedDate'] as String?;
//   // if (selectedDate != null) {
//   //   startDate = DateTime.tryParse(selectedDate);
//   // }
  
//   // DateTime? endDate;
//   // String? selectedEndDate = booking['selectedEndDate'] as String?;
//   // if (selectedEndDate != null) {
//   //   endDate = DateTime.tryParse(selectedEndDate);
//   // }
  
//   // final String? selectedTime = booking['selectedTime'] as String?;
//   // final String specialInstructions = booking['specialInstructions'] ?? 'None';
//   // final double totalPrice = booking['totalPrice'] as double? ?? 0.0;

//   // // FORMATTED DATE STRINGS
//   // String formattedDate = startDate != null 
//   //     ? DateFormat('EEEE, MMM d, yyyy').format(startDate)
//   //     : 'Not selected';

//   // String formattedEndDate = endDate != null 
//   //     ? DateFormat('EEEE, MMM d, yyyy').format(endDate)
//   //     : 'N/A';

//   // String formattedTime = selectedTime != null 
//   //     ? TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(selectedTime)).format(context)
//   //     : 'N/A';
// @override
// Widget build(BuildContext context) {
//   final booking = widget.bookingDetails;
//   final String? serviceType = booking['serviceType'] as String?; // Make nullable

//   // SAFE DATE HANDLING
//   DateTime? startDate;
//   String? selectedDateString = booking['selectedDate'] as String?;
//   if (selectedDateString != null) {
//     startDate = DateTime.tryParse(selectedDateString);
//   }

//   DateTime? endDate;
//   String? selectedEndDateString = booking['selectedEndDate'] as String?;
//   if (selectedEndDateString != null) {
//     endDate = DateTime.tryParse(selectedEndDateString);
//   }

//   final String? selectedTime = booking['selectedTime'] as String?;
//   final String specialInstructions = booking['specialInstructions'] as String? ?? 'None';
//   final double totalPrice = booking['totalPrice'] as double? ?? 0.0;

//   // FORMATTED DATE STRINGS
//   String formattedDate = startDate != null
//       ? DateFormat('EEEE, MMM d, yyyy').format(startDate) // Ensure 'yyyy' is there
//       : 'Not selected';

//   String formattedEndDate = endDate != null
//       ? DateFormat('EEEE, MMM d, yyyy').format(endDate) // Ensure 'yyyy' is there
//       : 'N/A';

//   String formattedTime = 'N/A'; // Default value
//   if (selectedTime != null && selectedTime.isNotEmpty) {
//     try {
//       final parsedTime = DateFormat('HH:mm').parse(selectedTime);
//       formattedTime = TimeOfDay.fromDateTime(parsedTime).format(context);
//     } catch (e) {
//       print('Error parsing selectedTime in build method: "$selectedTime" -> $e');
//       formattedTime = 'Invalid Time'; // Indicate that the format was bad
//     }
//   }

//   return Scaffold(
//     appBar: AppBar(title: const Text('Confirm Booking')),
//     body: _isBooking || _isProcessingPayment
//         ? const Center(child: CircularProgressIndicator())
//         : SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Booking Summary',
//                   style: Theme.of(context).textTheme.headlineSmall,
//                 ),
//                 const SizedBox(height: 24),
                
//                 // Price display card
//                 Card(
//                   elevation: 4,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             const Text('Total Amount:', style: TextStyle(fontSize: 18)),
//                             Text(
//                               'KES ${totalPrice.toStringAsFixed(2)}',
//                               style: const TextStyle(
//                                 fontSize: 24,
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.green,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         if (serviceType == 'Boarding')
//                           Text(
//                             '(${_calculateBoardingDays()} days boarding)',
//                             style: const TextStyle(color: Colors.grey),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 Text(
//                   'Booking Details',
//                   style: Theme.of(context).textTheme.titleLarge,
//                 ),
//                 const SizedBox(height: 16),
                
//                 _buildDetailRow(context, 'Service Type', serviceType ?? 'Unknown'),
//                 _buildDetailRow(context, 'Pet Name', _petName),
//                 _buildDetailRow(context, 'Pet Type', _petType),
//                 _buildDetailRow(context, 'Service Date', formattedDate),
//                 if (serviceType == 'Boarding')
//                   _buildDetailRow(context, 'End Date', formattedEndDate),
//                 _buildDetailRow(context, 'Service Time', formattedTime),
//                 _buildDetailRow(context, 'Instructions', specialInstructions),
                
//                 const SizedBox(height: 32),
                
//                 // Payment button
//                 if (!_isPaymentCompleted)
//                   ElevatedButton(
//                     onPressed: _confirmBooking,
//                     style: ElevatedButton.styleFrom(
//                       minimumSize: const Size.fromHeight(50),
//                       backgroundColor: Colors.green,
//                     ),
//                     child: const Text(
//                       'PAY WITH M-PESA',
//                       style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                     ),
//                   ),
                
//                 // Payment success UI
//                 if (_isPaymentCompleted)
//                   Column(
//                     children: [
//                       const Icon(Icons.check_circle, size: 60, color: Colors.green),
//                       const SizedBox(height: 16),
//                       const Text(
//                         'Payment Successful!',
//                         style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                       ),
//                       const SizedBox(height: 16),
//                       OutlinedButton(
//                         onPressed: () => _generateReceipt(context),
//                         child: const Text('VIEW RECEIPT'),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//   );
// }

//   // NEW: Receipt generation (simulated)
//   void _generateReceipt(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Receipt Generated'),
//         content: const Text('Your receipt has been generated successfully.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   // ... keep existing _buildDetailRow and other methods ...

//     Widget _buildDetailRow(BuildContext context, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120, // Fixed width for labels
//             child: Text(
//               '$label:',
//               style: Theme.of(context).textTheme.titleMedium,
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Theme.of(context).textTheme.bodyLarge,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






// Testing Refactored code. 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationScreen({super.key, required this.bookingDetails});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late final SupabaseClient _client;
  bool _isBooking = false;
  String _petName = 'Loading...';
  String _petType = 'Loading...';
  bool _isProcessingPayment = false;
  bool _isPaymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _fetchPetDetails();
  }

  Future<void> _fetchPetDetails() async {
    try {
      final String? petId = widget.bookingDetails['selectedPetId'] as String?;
      if (petId == null) throw Exception('No pet selected.');
      final response = await _client
          .from('pets')
          .select('name, type')
          .eq('id', petId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          _petName = response?['name'] as String? ?? 'Unnamed Pet';
          _petType = response?['type'] as String? ?? 'Unknown Type';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _petName = 'Error';
          _petType = 'Error';
        });
      }
      _showSnackBar('Failed to load pet details: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _checkForConflict() async {
    final String? serviceType = widget.bookingDetails['serviceType'] as String?;
    final String? selectedDateString = widget.bookingDetails['startDate'] as String?;
    final String? selectedEndDateString = widget.bookingDetails['endDate'] as String?;
    if (serviceType == null || selectedDateString == null) {
      _showSnackBar('Missing essential booking details for conflict check.', isError: true);
      return true;
    }

    final DateTime? startDate = DateTime.tryParse(selectedDateString);
    final DateTime? endDate = selectedEndDateString != null
        ? DateTime.tryParse(selectedEndDateString)
        : null;

    if (startDate == null) {
      _showSnackBar('Invalid start date format.', isError: true);
      return true;
    }
    final DateTime bookingEndDate = endDate ?? startDate;
    try {
      final conflicts = await _client
          .from('bookings')
          .select('id, start_date, end_date')
          .eq('service_type', serviceType)
          .inFilter('status', ['pending', 'approved']);

      for (final booking in conflicts) {
        final existingStartDateStr = booking['start_date'] as String?;
        final existingEndDateStr = booking['end_date'] as String?;
        if (existingStartDateStr == null) continue;
        final DateTime? existingStartDate = DateTime.tryParse(existingStartDateStr);
        final DateTime existingEndDate = existingEndDateStr != null
            ? (DateTime.tryParse(existingEndDateStr) ?? existingStartDate!)
            : existingStartDate!;
        // Overlap check.
        if (
          startDate.isBefore(existingEndDate.add(const Duration(days: 1))) &&
          bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate!)
        ) {
          return true;
        }
      }
      return false;
    } catch (e) {
      _showSnackBar('Error checking for conflicts: $e', isError: true);
      return true;
    }
  }

  Future<void> _confirmBooking() async {
    if (_isProcessingPayment) return;
    setState(() {
      _isProcessingPayment = true;
      _isBooking = true;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _showSnackBar('User not logged in.', isError: true);
        if (mounted) context.go('/login');
        return;
      }

      // if (await _checkForConflict()) {
      //   _showSnackBar('Selected dates are already booked. Please choose others.', isError: true);
      //   return;
      // }

      final String? selectedDateString = widget.bookingDetails['startDate'] as String?;
      final String? selectedEndDateString = widget.bookingDetails['endDate'] as String?;
      if (selectedDateString == null) {
        _showSnackBar('Service start date is required.', isError: true);
        return;
      }
      final DateTime? selectedDate = DateTime.tryParse(selectedDateString);
      DateTime? selectedEndDate = selectedEndDateString != null ? DateTime.tryParse(selectedEndDateString) : null;
      if (selectedDate == null) {
        _showSnackBar('Invalid start date.', isError: true);
        return;
      }
      if (selectedEndDateString != null && selectedEndDate == null) {
        _showSnackBar('Invalid end date.', isError: true);
        return;
      }

      final String? selectedPetId = widget.bookingDetails['selectedPetId'] as String?;
      final String? serviceType = widget.bookingDetails['serviceType'] as String?;
      final String specialInstructions = widget.bookingDetails['specialInstructions'] as String? ?? '';
      final double totalPrice = widget.bookingDetails['totalPrice'] as double? ?? 0.0;

      final Map<String, dynamic> newBooking = {
        'owner_id': userId,
        'pet_id': selectedPetId,
        'service_type': serviceType,
        'start_date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'end_date': selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate) : null,
                'special_instructions': specialInstructions,
        'status': 'pending_payment',
        'total_price': totalPrice,
      };

      await _client.from('bookings').insert(newBooking);

      // Simulate payment processing
      await _processMpesaPayment();

      if (mounted) context.go('/home');
    } catch (e) {
      _showSnackBar('Failed to create booking: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isBooking = false;
        });
      }
    }
  }

  Future<void> _processMpesaPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isPaymentCompleted = true);
    _showSnackBar('Payment successful!', isError: false);
  }

  int _calculateBoardingDays() {
    final String? startStr = widget.bookingDetails['startDate'] as String?;
    final String? endStr = widget.bookingDetails['endDate'] as String?;
    if (startStr == null || endStr == null) return 0;
    final DateTime? start = DateTime.tryParse(startStr);
    final DateTime? end = DateTime.tryParse(endStr);
    if (start == null || end == null || end.isBefore(start)) return 0;
    return end.difference(start).inDays + 1;
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receipt Generated'),
        content: const Text('Your receipt has been generated successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
  final booking = widget.bookingDetails;
  final String? serviceType = booking['serviceType'] as String?;
  DateTime? startDate = booking['startDate'] != null
      ? DateTime.tryParse(booking['startDate'] as String)
      : null;
  DateTime? endDate = booking['endDate'] != null
      ? DateTime.tryParse(booking['endDate'] as String)
      : null;
  final String specialInstructions = booking['specialInstructions'] as String? ?? 'None';
  final double totalPrice = booking['totalPrice'] as double? ?? 0.0;

  String formattedStartDate = startDate != null
      ? DateFormat('EEEE, MMM d, yyyy').format(startDate)
      : 'Not selected';
  String formattedEndDate = endDate != null
      ? DateFormat('EEEE, MMM d, yyyy').format(endDate)
      : 'N/A';

  return Scaffold(
    appBar: AppBar(title: const Text('Confirm Booking')),
    body: _isBooking || _isProcessingPayment
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount:', style: TextStyle(fontSize: 18)),
                            Text(
                              'KES ${totalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                        // RE-ADDED: Number of days under price for boarding
                        if (serviceType == 'Boarding')
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '(${_calculateBoardingDays()} days boarding)',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Booking Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(context, 'Service Type', serviceType ?? 'Unknown'),
                _buildDetailRow(context, 'Pet Name', _petName),
                _buildDetailRow(context, 'Pet Type', _petType),
                _buildDetailRow(context, 'Start Date', formattedStartDate),
                if (serviceType == 'Boarding')
                  _buildDetailRow(context, 'End Date', formattedEndDate),
                _buildDetailRow(context, 'Instructions', specialInstructions),
                const SizedBox(height: 32),
                if (!_isPaymentCompleted)
                  ElevatedButton(
                    onPressed: _confirmBooking, // (see updated confirmBooking below)
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'PAY WITH M-PESA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (_isPaymentCompleted)
                  Column(
                    children: [
                      const Icon(Icons.check_circle, size: 60, color: Colors.green),
                      const SizedBox(height: 16),
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _generateReceipt(context),
                        child: const Text('VIEW RECEIPT'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
  );
}
}

