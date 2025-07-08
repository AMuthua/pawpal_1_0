// // import 'package:flutter/material.dart';
// // import 'package:go_router/go_router.dart';
// // import 'package:intl/intl.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:provider/provider.dart'; // Import provider
// // import 'package:pawpal/providers/booking_provider.dart'; // Import BookingProvider

// // // Import the platform-agnostic PDF service
// // import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service;

// // class BookingConfirmationScreen extends StatefulWidget {
// //   final Map<String, dynamic> bookingDetails;

// //   const BookingConfirmationScreen({super.key, required this.bookingDetails});

// //   @override
// //   State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
// // }

// // class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
// //   late final SupabaseClient _client;
// //   bool _isBooking = false;
// //   bool _isProcessingPayment = false;
// //   bool _isPaymentCompleted = false;

// //   // Directly use pet details from bookingDetails, no need to fetch again
// //   late final Map<String, dynamic> _petDetails;
// //   late final String _petName;
// //   late final String _petType;
// //   late final String _petBreed; // NEW: Added pet breed

// //   @override
// //   void initState() {
// //     super.initState();
// //     _client = Supabase.instance.client;

// //     // --- NEW: Debugging and Initial Data Validation ---
// //     debugPrint('BookingConfirmationScreen received bookingDetails: ${widget.bookingDetails}');

// //     // Safely access 'pet' map and its 'name'/'type'/'breed'
// //     _petDetails = widget.bookingDetails['pet'] as Map<String, dynamic>? ?? {};
// //     _petName = _petDetails['name'] as String? ?? 'Unnamed Pet';
// //     _petType = _petDetails['type'] as String? ?? 'Unknown Type';
// //     _petBreed = _petDetails['breed'] as String? ?? 'Unknown Breed'; // NEW: Get pet breed

// //     // Perform initial checks for critical data
// //     if (!widget.bookingDetails.containsKey('start_date') || widget.bookingDetails['start_date'] == null) {
// //       _showSnackBar('Error: Booking start date is missing from previous screen.', isError: true);
// //       // Future.microtask(() => context.pop()); // Uncomment to pop back if critical data is missing
// //     }
// //     if (!widget.bookingDetails.containsKey('service_type') || widget.bookingDetails['service_type'] == null) {
// //       _showSnackBar('Error: Service type is missing from previous screen.', isError: true);
// //       // Future.microtask(() => context.pop());
// //     }
// //     if (!widget.bookingDetails.containsKey('pet_id') || widget.bookingDetails['pet_id'] == null) {
// //       _showSnackBar('Error: Pet ID is missing from previous screen.', isError: true);
// //       // Future.microtask(() => context.pop());
// //     }
// //     // --- END NEW: Debugging and Initial Data Validation ---
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message),
// //         backgroundColor: isError ? Colors.red : Colors.green,
// //       ),
// //     );
// //   }

// //   Future<bool> _checkForConflict() async {
// //     // Use the correct keys from bookingDetails
// //     final String? serviceType = widget.bookingDetails['service_type'] as String?;
// //     final String? selectedDateString = widget.bookingDetails['start_date'] as String?;
// //     final String? selectedEndDateString = widget.bookingDetails['end_date'] as String?;
    
// //     if (serviceType == null || selectedDateString == null) {
// //       _showSnackBar('Missing essential booking details for conflict check.', isError: true);
// //       return true;
// //     }

// //     final DateTime? startDate = DateTime.tryParse(selectedDateString);
// //     final DateTime? endDate = selectedEndDateString != null
// //         ? DateTime.tryParse(selectedEndDateString)
// //         : null;

// //     if (startDate == null) {
// //       _showSnackBar('Invalid start date format.', isError: true);
// //       return true;
// //     }
// //     final DateTime bookingEndDate = endDate ?? startDate;

// //     try {
// //       final conflicts = await _client
// //           .from('bookings')
// //           .select('id, start_date, end_date')
// //           .eq('service_type', serviceType)
// //           .inFilter('status', ['pending', 'approved']);

// //       for (final booking in conflicts) {
// //         final existingStartDateStr = booking['start_date'] as String?;
// //         final existingEndDateStr = booking['end_date'] as String?;
// //         if (existingStartDateStr == null) continue;
// //         final DateTime? existingStartDate = DateTime.tryParse(existingStartDateStr);
// //         final DateTime existingEndDate = existingEndDateStr != null
// //             ? (DateTime.tryParse(existingEndDateStr) ?? existingStartDate!)
// //             : existingStartDate!;
        
// //         // Ensure existingStartDate is not null before comparison
// //         if (existingStartDate == null) continue;

// //         // Overlap check.
// //         // We add 1 day to the end date to make the range inclusive for the last day.
// //         // This ensures that a booking ending on day X conflicts with a booking starting on day X.
// //         if (
// //           startDate.isBefore(existingEndDate.add(const Duration(days: 1))) &&
// //           bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)
// //         ) {
// //           return true; // Conflict found
// //         }
// //       }
// //       return false; // No conflict
// //     } catch (e) {
// //       _showSnackBar('Error checking for conflicts: $e', isError: true);
// //       print('Error checking for conflicts: $e'); // For debugging
// //       return true; // Assume conflict on error to prevent double booking
// //     }
// //   }

// //   Future<void> _confirmBooking() async {
// //     if (_isProcessingPayment) return; // Prevent multiple taps

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

// //       // Check for conflicts before proceeding
// //       if (await _checkForConflict()) {
// //         if (mounted) {
// //           setState(() {
// //             _isProcessingPayment = false;
// //             _isBooking = false;
// //           });
// //         }
// //         return; // Stop booking process
// //       }

// //       // Prepare data for Supabase insertion using the correct keys
// //       final Map<String, dynamic> bookingDataToSave = {
// //         'owner_id': userId,
// //         'pet_id': widget.bookingDetails['pet_id'], // Use the pet_id passed
// //         'service_type': widget.bookingDetails['service_type'],
// //         'start_date': widget.bookingDetails['start_date'],
// //         'end_date': widget.bookingDetails['end_date'],
// //         'start_time': widget.bookingDetails['start_time'],
// //         'special_instructions': widget.bookingDetails['special_instructions'],
// //         'total_price': widget.bookingDetails['total_price'],
// //         'status': 'pending', // Default status for new bookings
// //         'procedures': widget.bookingDetails['procedures'] ?? [], // Ensure procedures are passed, even if empty
// //       };

// //       await _client.from('bookings').insert(bookingDataToSave);

// //       // Simulate payment processing (replace with actual payment gateway)
// //       await Future.delayed(const Duration(seconds: 2));

// //       if (mounted) {
// //         setState(() {
// //           _isPaymentCompleted = true;
// //         });
// //         _showSnackBar('Booking confirmed and payment successful!');
        
// //         // Notify BookingProvider to refresh data on Home Screen and My Bookings
// //         Provider.of<BookingProvider>(context, listen: false).fetchBookings();
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar('Booking failed: $e', isError: true);
// //         print('Booking failed: $e'); // For debugging
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() {
// //           _isProcessingPayment = false;
// //           _isBooking = false;
// //         });
// //       }
// //     }
// //   }

// //   // Receipt generation (now uses the platform-agnostic service)
// //   void _generateReceipt() async {
// //     try {
// //       // Pass the complete booking details for receipt generation.
// //       // This map should already contain 'pet' and 'procedures' from BookServiceScreen.
// //       await pdf_service.generateAndHandleReceipt(widget.bookingDetails);

// //       if (mounted) {
// //         showDialog(
// //           context: context,
// //           builder: (context) => AlertDialog(
// //             title: const Text('Receipt Generated'),
// //             content: const Text('Your receipt has been generated successfully.'),
// //             actions: [
// //               TextButton(
// //                 onPressed: () => Navigator.pop(context),
// //                 child: const Text('OK'),
// //               ),
// //             ],
// //           ),
// //         );
// //       }
// //     } catch (e) {
// //       if (mounted) {
// //         _showSnackBar('Failed to generate or handle receipt: $e', isError: true);
// //       }
// //       print('Error generating/handling receipt: $e');
// //     }
// //   }

// //   // Helper to calculate boarding days for display
// //   int _calculateBoardingDays() {
// //     final String? startStr = widget.bookingDetails['start_date'] as String?;
// //     final String? endStr = widget.bookingDetails['end_date'] as String?;
// //     if (startStr == null) return 0; // Start date is mandatory

// //     final DateTime? start = DateTime.tryParse(startStr);
// //     if (start == null) return 0;

// //     final DateTime? end = endStr != null ? DateTime.tryParse(endStr) : null;

// //     if (end == null || end.isBefore(start)) {
// //       return 1; // For single-day services or invalid end date, count as 1 day
// //     }
// //     return end.difference(start).inDays + 1;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     // Extract details for display, using the corrected keys
// //     final String serviceType = widget.bookingDetails['service_type'] as String? ?? 'N/A';
// //     final String? startDateString = widget.bookingDetails['start_date'] as String?;
// //     final String? endDateString = widget.bookingDetails['end_date'] as String?;
// //     final String? startTime = widget.bookingDetails['start_time'] as String?;
// //     final String specialInstructions = widget.bookingDetails['special_instructions'] as String? ?? 'None';
// //     final double totalPrice = (widget.bookingDetails['total_price'] as num?)?.toDouble() ?? 0.0;

// //     // Format dates for display
// //     String formattedStartDate = startDateString != null
// //         ? DateFormat('MMM d,yyyy').format(DateTime.parse(startDateString))
// //         : 'N/A';
// //     String formattedEndDate = endDateString != null
// //         ? DateFormat('MMM d,yyyy').format(DateTime.parse(endDateString))
// //         : formattedStartDate; // If no end date, it's a single-day service

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Confirm Booking'),
// //         backgroundColor: Theme.of(context).colorScheme.primary,
// //         foregroundColor: Theme.of(context).colorScheme.onPrimary,
// //       ),
// //       body: _isBooking || _isProcessingPayment
// //           ? Center(
// //               child: Column(
// //                 mainAxisAlignment: MainAxisAlignment.center,
// //                 children: [
// //                   const CircularProgressIndicator(),
// //                   const SizedBox(height: 16),
// //                   Text(_isBooking ? 'Confirming Booking...' : 'Processing Payment...',
// //                     style: Theme.of(context).textTheme.titleMedium,
// //                   ),
// //                 ],
// //               ),
// //             )
// //           : SingleChildScrollView(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     'Review Your Booking Details',
// //                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
// //                           fontWeight: FontWeight.bold,
// //                           color: Theme.of(context).colorScheme.onBackground,
// //                         ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   Card(
// //                     elevation: 4,
// //                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     child: Padding(
// //                       padding: const EdgeInsets.all(16.0),
// //                       child: Column(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           _buildDetailRow(context, Icons.pets, 'Pet Name:', _petName),
// //                           _buildDetailRow(context, Icons.category, 'Pet Type:', _petType),
// //                           _buildDetailRow(context, Icons.pets_sharp, 'Pet Breed:', _petBreed), // NEW: Display pet breed
// //                           _buildDetailRow(context, Icons.medical_services, 'Service Type:', serviceType),
// //                           _buildDetailRow(context, Icons.calendar_today, 'Start Date:', formattedStartDate),
// //                           if (serviceType == 'Boarding') // Only show end date for boarding
// //                             _buildDetailRow(context, Icons.calendar_today, 'End Date:', formattedEndDate),
// //                           if (startTime != null && startTime.isNotEmpty)
// //                             _buildDetailRow(context, Icons.access_time, 'Preferred Time:', startTime),
// //                           _buildDetailRow(context, Icons.notes, 'Instructions:', specialInstructions),
// //                           const Divider(height: 24),
// //                           Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text(
// //                                 'Total Price:',
// //                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Theme.of(context).colorScheme.onBackground,
// //                                     ),
// //                               ),
// //                               Text(
// //                                 'KES ${totalPrice.toStringAsFixed(2)}',
// //                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
// //                                       fontWeight: FontWeight.bold,
// //                                       color: Theme.of(context).colorScheme.primary,
// //                                     ),
// //                               ),
// //                             ],
// //                           ),
// //                           if (serviceType == 'Boarding')
// //                             Padding(
// //                               padding: const EdgeInsets.only(top: 8.0),
// //                               child: Text(
// //                                 '(${_calculateBoardingDays()} days boarding)',
// //                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
// //                                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
// //                                     ),
// //                               ),
// //                             ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 24),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: ElevatedButton.icon(
// //                       onPressed: _isBooking || _isProcessingPayment ? null : _confirmBooking,
// //                       icon: _isBooking
// //                           ? const CircularProgressIndicator(color: Colors.white)
// //                           : _isPaymentCompleted
// //                               ? const Icon(Icons.check_circle_outline)
// //                               : const Icon(Icons.payment),
// //                       label: Text(
// //                         _isBooking
// //                             ? 'Processing...'
// //                             : _isPaymentCompleted
// //                                 ? 'Booking Confirmed!'
// //                                 : 'Confirm Booking & Pay',
// //                       ),
// //                       style: ElevatedButton.styleFrom(
// //                         padding: const EdgeInsets.symmetric(vertical: 16),
// //                         backgroundColor: _isPaymentCompleted
// //                             ? Colors.green[700] // Green when confirmed
// //                             : Theme.of(context).colorScheme.primary,
// //                         foregroundColor: Colors.white,
// //                         textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(12),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 16),
// //                   if (_isPaymentCompleted)
// //                     SizedBox(
// //                       width: double.infinity,
// //                       child: OutlinedButton.icon(
// //                         onPressed: _generateReceipt,
// //                         icon: const Icon(Icons.receipt_long),
// //                         label: const Text('Get Receipt'),
// //                         style: OutlinedButton.styleFrom(
// //                           padding: const EdgeInsets.symmetric(vertical: 16),
// //                           side: BorderSide(color: Theme.of(context).colorScheme.primary),
// //                           foregroundColor: Theme.of(context).colorScheme.primary,
// //                           textStyle: Theme.of(context).textTheme.titleMedium,
// //                           shape: RoundedRectangleBorder(
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   const SizedBox(height: 16),
// //                   SizedBox(
// //                     width: double.infinity,
// //                     child: TextButton(
// //                       onPressed: () => context.pop(), // Go back to the booking form
// //                       child: Text(
// //                         'Go Back to Edit',
// //                         style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7)),
// //                       ),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //     );
// //   }

// //   Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 8.0),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
// //           const SizedBox(width: 12),
// //           Text(
// //             label,
// //             style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
// //           ),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: Theme.of(context).textTheme.bodyLarge,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart'; // Import provider
// import 'package:pawpal/providers/booking_provider.dart'; // Import BookingProvider

// // Import the platform-agnostic PDF service
// import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service;

// class BookingConfirmationScreen extends StatefulWidget {
//   final Map<String, dynamic> bookingDetails;

//   const BookingConfirmationScreen({super.key, required this.bookingDetails});

//   @override
//   State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
// }

// class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
//   late final SupabaseClient _client;
//   bool _isBooking = false;
//   bool _isProcessingPayment = false;
//   bool _isPaymentCompleted = false;

//   // Directly use pet details from bookingDetails, no need to fetch again
//   late final Map<String, dynamic> _petDetails;
//   late final String _petName;
//   late final String _petType;
//   late final String _petBreed; // NEW: Added pet breed

//   @override
//   void initState() {
//     super.initState();
//     _client = Supabase.instance.client;

//     // --- NEW: Debugging and Initial Data Validation ---
//     debugPrint('BookingConfirmationScreen received bookingDetails: ${widget.bookingDetails}');

//     // Safely access 'pet' map and its 'name'/'type'/'breed'
//     _petDetails = widget.bookingDetails['pet'] as Map<String, dynamic>? ?? {};
//     _petName = _petDetails['name'] as String? ?? 'Unnamed Pet';
//     _petType = _petDetails['type'] as String? ?? 'Unknown Type';
//     _petBreed = _petDetails['breed'] as String? ?? 'N/A'; // NEW: Get pet breed, default to N/A

//     // Perform initial checks for critical data
//     if (!widget.bookingDetails.containsKey('start_date') || widget.bookingDetails['start_date'] == null) {
//       _showSnackBar('Error: Booking start date is missing from previous screen.', isError: true);
//       // Future.microtask(() => context.pop()); // Uncomment to pop back if critical data is missing
//     }
//     if (!widget.bookingDetails.containsKey('service_type') || widget.bookingDetails['service_type'] == null) {
//       _showSnackBar('Error: Service type is missing from previous screen.', isError: true);
//       // Future.microtask(() => context.pop());
//     }
//     if (!widget.bookingDetails.containsKey('pet_id') || widget.bookingDetails['pet_id'] == null) {
//       _showSnackBar('Error: Pet ID is missing from previous screen.', isError: true);
//       // Future.microtask(() => context.pop());
//     }
//     // --- END NEW: Debugging and Initial Data Validation ---
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   Future<bool> _checkForConflict() async {
//     // Use the correct keys from bookingDetails
//     final String? serviceType = widget.bookingDetails['service_type'] as String?;
//     final String? selectedDateString = widget.bookingDetails['start_date'] as String?;
//     final String? selectedEndDateString = widget.bookingDetails['end_date'] as String?;
    
//     if (serviceType == null || selectedDateString == null) {
//       _showSnackBar('Missing essential booking details for conflict check.', isError: true);
//       return true;
//     }

//     final DateTime? startDate = DateTime.tryParse(selectedDateString);
//     final DateTime? endDate = selectedEndDateString != null
//         ? DateTime.tryParse(selectedEndDateString)
//         : null;

//     if (startDate == null) {
//       _showSnackBar('Invalid start date format.', isError: true);
//       return true;
//     }
//     final DateTime bookingEndDate = endDate ?? startDate;

//     try {
//       final conflicts = await _client
//           .from('bookings')
//           .select('id, start_date, end_date')
//           .eq('service_type', serviceType)
//           .inFilter('status', ['pending', 'approved']);

//       for (final booking in conflicts) {
//         final existingStartDateStr = booking['start_date'] as String?;
//         final existingEndDateStr = booking['end_date'] as String?;
//         if (existingStartDateStr == null) continue;
//         final DateTime? existingStartDate = DateTime.tryParse(existingStartDateStr);
//         final DateTime existingEndDate = existingEndDateStr != null
//             ? (DateTime.tryParse(existingEndDateStr) ?? existingStartDate!)
//             : existingStartDate!;
        
//         // Ensure existingStartDate is not null before comparison
//         if (existingStartDate == null) continue;

//         // Overlap check.
//         // We add 1 day to the end date to make the range inclusive for the last day.
//         // This ensures that a booking ending on day X conflicts with a booking starting on day X.
//         if (
//           startDate.isBefore(existingEndDate.add(const Duration(days: 1))) &&
//           bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)
//         ) {
//           return true; // Conflict found
//         }
//       }
//       return false; // No conflict
//     } catch (e) {
//       _showSnackBar('Error checking for conflicts: $e', isError: true);
//       print('Error checking for conflicts: $e'); // For debugging
//       return true; // Assume conflict on error to prevent double booking
//     }
//   }

//   Future<void> _confirmBooking() async {
//     if (_isProcessingPayment) return; // Prevent multiple taps

//     setState(() {
//       _isProcessingPayment = true;
//       _isBooking = true;
//     });

//     try {
//       final userId = _client.auth.currentUser?.id;
//       if (userId == null) {
//         _showSnackBar('User not logged in.', isError: true);
//         if (mounted) context.go('/login');
//         return;
//       }

//       // Check for conflicts before proceeding
//       if (await _checkForConflict()) {
//         if (mounted) {
//           setState(() {
//             _isProcessingPayment = false;
//             _isBooking = false;
//           });
//         }
//         return; // Stop booking process
//       }

//       // Prepare data for Supabase insertion using the correct keys
//       final Map<String, dynamic> bookingDataToSave = {
//         'owner_id': userId,
//         'pet_id': widget.bookingDetails['pet_id'], // Use the pet_id passed
//         'service_type': widget.bookingDetails['service_type'],
//         'start_date': widget.bookingDetails['start_date'],
//         'end_date': widget.bookingDetails['end_date'],
//         'start_time': widget.bookingDetails['start_time'],
//         'special_instructions': widget.bookingDetails['special_instructions'],
//         'total_price': widget.bookingDetails['total_price'],
//         'status': 'pending', // Default status for new bookings
//         'procedures': widget.bookingDetails['procedures'] ?? [], // Ensure procedures are passed, even if empty
//       };

//       await _client.from('bookings').insert(bookingDataToSave);

//       // Simulate payment processing (replace with actual payment gateway)
//       await Future.delayed(const Duration(seconds: 2));

//       if (mounted) {
//         setState(() {
//           _isPaymentCompleted = true;
//         });
//         _showSnackBar('Booking confirmed and payment successful!');
        
//         // Notify BookingProvider to refresh data on Home Screen and My Bookings
//         Provider.of<BookingProvider>(context, listen: false).fetchBookings();
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Booking failed: $e', isError: true);
//         print('Booking failed: $e'); // For debugging
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isProcessingPayment = false;
//           _isBooking = false;
//         });
//       }
//     }
//   }

//   // Receipt generation (now uses the platform-agnostic service)
//   void _generateReceipt() async {
//     try {
//       // Pass the complete booking details for receipt generation.
//       // This map should already contain 'pet' and 'procedures' from BookServiceScreen.
//       await pdf_service.generateAndHandleReceipt(widget.bookingDetails);

//       if (mounted) {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Receipt Generated'),
//             content: const Text('Your receipt has been generated successfully.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('Failed to generate or handle receipt: $e', isError: true);
//       }
//       print('Error generating/handling receipt: $e');
//     }
//   }

//   // Helper to calculate boarding days for display
//   int _calculateBoardingDays() {
//     final String? startStr = widget.bookingDetails['start_date'] as String?;
//     final String? endStr = widget.bookingDetails['end_date'] as String?;
//     if (startStr == null) return 0; // Start date is mandatory

//     final DateTime? start = DateTime.tryParse(startStr);
//     if (start == null) return 0;

//     final DateTime? end = endStr != null ? DateTime.tryParse(endStr) : null;

//     if (end == null || end.isBefore(start)) {
//       return 1; // For single-day services or invalid end date, count as 1 day
//     }
//     return end.difference(start).inDays + 1;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Extract details for display, using the corrected keys
//     final String serviceType = widget.bookingDetails['service_type'] as String? ?? 'N/A';
//     final String? startDateString = widget.bookingDetails['start_date'] as String?;
//     final String? endDateString = widget.bookingDetails['end_date'] as String?;
//     final String? startTime = widget.bookingDetails['start_time'] as String?;
//     final String specialInstructions = widget.bookingDetails['special_instructions'] as String? ?? 'TBC Upon Recieval of the Pet';
//     final double totalPrice = (widget.bookingDetails['total_price'] as num?)?.toDouble() ?? 0.0;

//     // Format dates for display
//     String formattedStartDate = startDateString != null
//         ? DateFormat('MMM d,yyyy').format(DateTime.parse(startDateString))
//         : 'N/A';
//     String formattedEndDate = endDateString != null
//         ? DateFormat('MMM d,yyyy').format(DateTime.parse(endDateString))
//         : formattedStartDate; // If no end date, it's a single-day service

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Confirm Booking'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: _isBooking || _isProcessingPayment
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const CircularProgressIndicator(),
//                   const SizedBox(height: 16),
//                   Text(_isBooking ? 'Confirming Booking...' : 'Processing Payment...',
//                     style: Theme.of(context).textTheme.titleMedium,
//                   ),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Review Your Booking Details',
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).colorScheme.onSurface,
//                         ),
//                   ),
//                   const SizedBox(height: 16),
//                   Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _buildDetailRow(context, Icons.pets, 'Pet Name:', _petName),
//                           _buildDetailRow(context, Icons.category, 'Pet Type:', _petType),
//                           _buildDetailRow(context, Icons.pets_sharp, 'Pet Breed:', _petBreed), // NEW: Display pet breed
//                           _buildDetailRow(context, Icons.medical_services, 'Service Type:', serviceType),
//                           _buildDetailRow(context, Icons.calendar_today, 'Start Date:', formattedStartDate),
//                           if (serviceType == 'Boarding') // Only show end date for boarding
//                             _buildDetailRow(context, Icons.calendar_today, 'End Date:', formattedEndDate),
//                           if (startTime != null && startTime.isNotEmpty)
//                             _buildDetailRow(context, Icons.access_time, 'Preferred Time:', startTime),
//                           _buildDetailRow(context, Icons.notes, 'Instructions:', specialInstructions),
//                           const Divider(height: 24),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Total Price:',
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: Theme.of(context).colorScheme.onSurface,
//                                     ),
//                               ),
//                               Text(
//                                 'KES ${totalPrice.toStringAsFixed(2)}',
//                                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                       fontWeight: FontWeight.bold,
//                                       color: Theme.of(context).colorScheme.primary,
//                                     ),
//                               ),
//                             ],
//                           ),
//                           if (serviceType == 'Boarding')
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8.0),
//                               child: Text(
//                                 '(${_calculateBoardingDays()} days boarding)',
//                                 style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                                       color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                                     ),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _isBooking || _isProcessingPayment
//                           ? null
//                           : (_isPaymentCompleted ? () => context.go('/home') : _confirmBooking), // Modified onPressed
//                       icon: _isBooking
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : _isPaymentCompleted
//                               ? const Icon(Icons.check_circle_outline)
//                               : const Icon(Icons.payment),
//                       label: Text(
//                         _isBooking
//                             ? 'Processing...'
//                             : _isPaymentCompleted
//                                 ? 'Return Home' // Modified label
//                                 : 'Confirm Booking & Pay',
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: _isPaymentCompleted
//                             ? Colors.green[700] // Green when confirmed
//                             : Theme.of(context).colorScheme.primary,
//                         foregroundColor: Colors.white,
//                         textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   if (_isPaymentCompleted)
//                     SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton.icon(
//                         onPressed: _generateReceipt,
//                         icon: const Icon(Icons.receipt_long),
//                         label: const Text('Get Receipt'),
//                         style: OutlinedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           side: BorderSide(color: Theme.of(context).colorScheme.primary),
//                           foregroundColor: Theme.of(context).colorScheme.primary,
//                           textStyle: Theme.of(context).textTheme.titleMedium,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                       ),
//                     ),
//                   // Removed the "Go Back to Edit" TextButton as it's now redundant
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
//           const SizedBox(width: 12),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 8),
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









import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:pawpal/providers/booking_provider.dart'; // Import BookingProvider

// Import the platform-agnostic PDF service
import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service;

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationScreen({super.key, required this.bookingDetails});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late final SupabaseClient _client;
  bool _isBooking = false;
  bool _isProcessingPayment = false;
  bool _isPaymentCompleted = false;

  // Directly use pet details from bookingDetails, no need to fetch again
  late final Map<String, dynamic> _petDetails;
  late final String _petName;
  late final String _petType;
  late final String _petBreed;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;

    debugPrint('BookingConfirmationScreen received bookingDetails: ${widget.bookingDetails}');

    _petDetails = widget.bookingDetails['pet'] as Map<String, dynamic>? ?? {};
    _petName = _petDetails['name'] as String? ?? 'Unnamed Pet';
    _petType = _petDetails['type'] as String? ?? 'Unknown Type';
    _petBreed = _petDetails['breed'] as String? ?? 'N/A';

    // FIX: Defer SnackBar calls until after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.bookingDetails.containsKey('selectedDate') || widget.bookingDetails['selectedDate'] == null) {
        _showSnackBar('Error: Booking start date is missing from previous screen.', isError: true);
        // Future.microtask(() => context.pop()); // Uncomment to pop back if critical data is missing
      }
      if (!widget.bookingDetails.containsKey('serviceType') || widget.bookingDetails['serviceType'] == null) {
        _showSnackBar('Error: Service type is missing from previous screen.', isError: true);
        // Future.microtask(() => context.pop());
      }
      if (!widget.bookingDetails.containsKey('selectedPetId') || widget.bookingDetails['selectedPetId'] == null) {
        _showSnackBar('Error: Pet ID is missing from previous screen.', isError: true);
        // Future.microtask(() => context.pop());
      }
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    // Ensure context is still valid before showing SnackBar
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _checkForConflict() async {
    final String? serviceType = widget.bookingDetails['serviceType'] as String?; // Use serviceType
    final String? selectedDateString = widget.bookingDetails['selectedDate'] as String?; // Use selectedDate
    final String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?; // Use selectedEndDate
    
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
        
        if (existingStartDate == null) continue;

        // Overlap check.
        if (
          startDate.isBefore(existingEndDate.add(const Duration(days: 1))) &&
          bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)
        ) {
          _showSnackBar('Conflict detected: This service is already booked for the selected dates.', isError: true);
          return true; // Conflict found
        }
      }
      return false; // No conflict
    } catch (e) {
      _showSnackBar('Error checking for conflicts: $e', isError: true);
      debugPrint('Error checking for conflicts: $e'); // For debugging
      return true; // Assume conflict on error to prevent double booking
    }
  }

  Future<void> _confirmBooking() async {
    if (_isProcessingPayment) return; // Prevent multiple taps

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

      // Check for conflicts before proceeding
      if (await _checkForConflict()) {
        if (mounted) {
          setState(() {
            _isProcessingPayment = false;
            _isBooking = false;
          });
        }
        return; // Stop booking process
      }

      // Prepare data for Supabase insertion using the correct keys
      final Map<String, dynamic> bookingDataToSave = {
        'owner_id': userId,
        'pet_id': widget.bookingDetails['selectedPetId'], // Use the pet_id passed from BookServiceScreen
        'service_type': widget.bookingDetails['serviceType'], // Use serviceType from BookServiceScreen
        'start_date': widget.bookingDetails['selectedDate'], // Use selectedDate from BookServiceScreen
        'end_date': widget.bookingDetails['selectedEndDate'], // Use selectedEndDate from BookServiceScreen
        'start_time': widget.bookingDetails['selectedTime'], // Use selectedTime from BookServiceScreen
        'special_instructions': widget.bookingDetails['specialInstructions'], // Use specialInstructions
        'total_price': widget.bookingDetails['totalPrice'], // Use totalPrice
        'status': 'pending', // Default status for new bookings
        'procedures': widget.bookingDetails['procedures'] ?? [], // Ensure procedures are passed, even if empty
      };

      await _client.from('bookings').insert(bookingDataToSave);

      // Simulate payment processing (replace with actual payment gateway)
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isPaymentCompleted = true;
        });
        _showSnackBar('Booking confirmed and payment successful!');
        
        // Notify BookingProvider to refresh data on Home Screen and My Bookings
        Provider.of<BookingProvider>(context, listen: false).fetchBookings();
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Booking failed: $e', isError: true);
        debugPrint('Booking failed: $e'); // For debugging
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
          _isBooking = false;
        });
      }
    }
  }

  // Receipt generation (now uses the platform-agnostic service)
  void _generateReceipt() async {
    try {
      // Pass the complete booking details for receipt generation.
      // This map should already contain 'pet' and 'procedures' from BookServiceScreen.
      await pdf_service.generateAndHandleReceipt(widget.bookingDetails);

      if (mounted) {
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
    } catch (e) {
      if (mounted) {
        _showSnackBar('Failed to generate or handle receipt: $e', isError: true);
      }
      debugPrint('Error generating/handling receipt: $e');
    }
  }

  // Helper to calculate boarding days for display
  int _calculateBoardingDays() {
    final String? startStr = widget.bookingDetails['selectedDate'] as String?; // Use selectedDate
    final String? endStr = widget.bookingDetails['selectedEndDate'] as String?; // Use selectedEndDate
    if (startStr == null) return 0; // Start date is mandatory

    final DateTime? start = DateTime.tryParse(startStr);
    if (start == null) return 0;

    final DateTime? end = endStr != null ? DateTime.tryParse(endStr) : null;

    if (end == null || end.isBefore(start)) {
      return 1; // For single-day services or invalid end date, count as 1 day
    }
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    // Extract details for display, using the corrected keys
    final String serviceType = widget.bookingDetails['serviceType'] as String? ?? 'N/A';
    final String? startDateString = widget.bookingDetails['selectedDate'] as String?;
    final String? endDateString = widget.bookingDetails['selectedEndDate'] as String?;
    final String? startTime = widget.bookingDetails['selectedTime'] as String?;
    final String specialInstructions = widget.bookingDetails['specialInstructions'] as String? ?? 'TBC Upon Recieval of the Pet';
    final double totalPrice = (widget.bookingDetails['totalPrice'] as num?)?.toDouble() ?? 0.0;

    // Format dates for display
    String formattedStartDate = startDateString != null
        ? DateFormat('MMM d,yyyy').format(DateTime.parse(startDateString))
        : 'N/A';
    String formattedEndDate = endDateString != null
        ? DateFormat('MMM d,yyyy').format(DateTime.parse(endDateString))
        : formattedStartDate; // If no end date, it's a single-day service

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isBooking || _isProcessingPayment
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(_isBooking ? 'Confirming Booking...' : 'Processing Payment...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Review Your Booking Details',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(context, Icons.pets, 'Pet Name:', _petName),
                          _buildDetailRow(context, Icons.category, 'Pet Type:', _petType),
                          _buildDetailRow(context, Icons.pets_sharp, 'Pet Breed:', _petBreed),
                          _buildDetailRow(context, Icons.medical_services, 'Service Type:', serviceType),
                          _buildDetailRow(context, Icons.calendar_today, 'Start Date:', formattedStartDate),
                          if (serviceType == 'Boarding')
                            _buildDetailRow(context, Icons.calendar_today, 'End Date:', formattedEndDate),
                          if (startTime != null && startTime.isNotEmpty)
                            _buildDetailRow(context, Icons.access_time, 'Preferred Time:', startTime),
                          _buildDetailRow(context, Icons.notes, 'Instructions:', specialInstructions),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Price:',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              ),
                              Text(
                                'KES ${totalPrice.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ],
                          ),
                          if (serviceType == 'Boarding')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '(${_calculateBoardingDays()} days boarding)',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round()),
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isBooking || _isProcessingPayment ? null : _confirmBooking,
                      icon: _isBooking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : _isPaymentCompleted
                              ? const Icon(Icons.check_circle_outline)
                              : const Icon(Icons.payment),
                      label: Text(
                        _isBooking
                            ? 'Processing...'
                            : _isPaymentCompleted
                                ? 'Booking Confirmed!'
                                : 'Confirm Booking & Pay',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _isPaymentCompleted
                            ? Colors.green[700]
                            : Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isPaymentCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _generateReceipt,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Get Receipt'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: Theme.of(context).textTheme.titleMedium,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => context.pop(), // Go back to the booking form
                      child: Text(
                        'Go Back to Edit',
                        style: TextStyle(color: Theme.of(context).colorScheme.onBackground.withAlpha((255 * 0.7).round())),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
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
}
