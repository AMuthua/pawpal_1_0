







// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:pawpal/services/mpesa_service.dart';
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

//   bool _isProcessingMpesa = false;

//   // Directly use pet details from bookingDetails, no need to fetch again
//   late final Map<String, dynamic> _petDetails;
//   late final String _petName;
//   late final String _petType;
//   late final String _petBreed;

//   @override
//   void initState() {
//     super.initState();
//     _client = Supabase.instance.client;

//     debugPrint('BookingConfirmationScreen received bookingDetails: ${widget.bookingDetails}');

//     _petDetails = widget.bookingDetails['pet'] as Map<String, dynamic>? ?? {};
//     _petName = _petDetails['name'] as String? ?? 'Unnamed Pet';
//     _petType = _petDetails['type'] as String? ?? 'Unknown Type';
//     _petBreed = _petDetails['breed'] as String? ?? 'N/A'; // Ensures 'N/A' if breed is not provided

//     // FIX: Defer SnackBar calls until after the first frame is rendered
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!widget.bookingDetails.containsKey('selectedDate') || widget.bookingDetails['selectedDate'] == null) {
//         _showSnackBar('Error: Booking start date is missing from previous screen.', isError: true);
//         // Future.microtask(() => context.pop()); // Uncomment to pop back if critical data is missing
//       }
//       if (!widget.bookingDetails.containsKey('serviceType') || widget.bookingDetails['serviceType'] == null) {
//         _showSnackBar('Error: Service type is missing from previous screen.', isError: true);
//         // Future.microtask(() => context.pop());
//       }
//       if (!widget.bookingDetails.containsKey('selectedPetId') || widget.bookingDetails['selectedPetId'] == null) {
//         _showSnackBar('Error: Pet ID is missing from previous screen.', isError: true);
//         // Future.microtask(() => context.pop());
//       }
//     });
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     // Ensure context is still valid before showing SnackBar
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   Future<bool> _checkForConflict() async {
//     final String? serviceType = widget.bookingDetails['serviceType'] as String?;
//     final String? selectedDateString = widget.bookingDetails['selectedDate'] as String?;
//     final String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?;
    
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
        
//         if (existingStartDate == null) continue;

//         // Overlap check.
//         if (
//           startDate.isBefore(existingEndDate.add(const Duration(days: 1))) &&
//           bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)
//         ) {
//           _showSnackBar('Conflict detected: This service is already booked for the selected dates.', isError: true);
//           return true; // Conflict found
//         }
//       }
//       return false; // No conflict
//     } catch (e) {
//       _showSnackBar('Error checking for conflicts: $e', isError: true);
//       debugPrint('Error checking for conflicts: $e');
//       return true; // Assume conflict on error to prevent double booking
//     }
//   }

//   Future<void> _initiateMpesaPayment() async {
//     if (_isProcessingPayment || _isProcessingMpesa) return;

//     setState(() {
//       _isProcessingMpesa = true;
//     });

//     try {
//       final user = _client.auth.currentUser;
//       if (user == null) throw Exception('User not logged in');
      
//       // Get user's phone number from profile
//       final profile = await _client
//           .from('profiles')
//           .select('phone_number')
//           .eq('id', user.id)
//           .single();
      
//       final String userPhone = profile['phone_number'] ?? '';
//       if (userPhone.isEmpty) throw Exception('Phone number not found in profile');

//       // Get booking amount
//       final double amount = (widget.bookingDetails['totalPrice'] as num?)?.toDouble() ?? 0.0;

//       // Initiate M-Pesa payment
//       final result = await MpesaService.initiateStkPush(
//         phoneNumber: userPhone,
//         amount: amount,
//         bookingId: 'TEST_${DateTime.now().millisecondsSinceEpoch}', // Use a test ID
//       );

//       if (result == "success") {
//         _showSnackBar('M-Pesa payment initiated! Check your phone', isError: false);
        
//         // For school demo: Simulate payment completion after some time
//         await Future.delayed(const Duration(seconds: 3));
//         setState(() {
//           _isPaymentCompleted = true;
//           _isProcessingMpesa = false;
//         });
//       } else {
//         _showSnackBar('M-Pesa payment failed', isError: true);
//         setState(() => _isProcessingMpesa = false);
//       }
//     } catch (e) {
//       _showSnackBar('MPesa error: ${e.toString()}', isError: true);
//       setState(() => _isProcessingMpesa = false);
//     }
//   }



//   Future<void> _confirmBooking() async {
//   if (_isProcessingPayment) return;

//   setState(() {
//     _isProcessingPayment = true;
//     _isBooking = true;
//   });

//   try {
//     final user = _client.auth.currentUser;
//     if (user == null) {
//       _showSnackBar('User not logged in.', isError: true);
//       if (mounted) context.go('/login');
//       return;
//     }

//     // Check for conflict before booking
//     if (await _checkForConflict()) {
//       setState(() {
//         _isProcessingPayment = false;
//         _isBooking = false;
//       });
//       return;
//     }

//     // final String userPhone = user.phone ?? ''; // Optional: fetch from profile table
//     // if (userPhone.isEmpty) {
//     //   _showSnackBar('Missing phone number. Please get your profile updated with a phone number.', isError: true);
//     //   return;
//     // }
//     final profile = await _client
//       .from('profiles')
//       .select('phone_number')
//       .eq('id', user.id)
//       .single();

//     final String userPhone = profile['phone_number'] ?? '';

//     // Booking data to insert
//     final Map<String, dynamic> bookingData = {
//       'owner_id': user.id,
//       'pet_id': widget.bookingDetails['selectedPetId'],
//       'service_type': widget.bookingDetails['serviceType'],
//       'start_date': widget.bookingDetails['selectedDate'],
//       'end_date': widget.bookingDetails['selectedEndDate'],
//       'start_time': widget.bookingDetails['selectedTime'],
//       'special_instructions': widget.bookingDetails['specialInstructions'],
//       'total_price': widget.bookingDetails['totalPrice'],
//       'status': 'pending', // Default status for new bookings
//       'procedures': widget.bookingDetails['procedures'] ?? [],
//     };

//     // Insert booking and get the ID
//     final inserted = await _client
//         .from('bookings')
//         .insert(bookingData)
//         .select('id')
//         .single();

//     final bookingId = inserted['id'];

//     // Call M-Pesa STK push
//     final result = await MpesaService.initiateStkPush(
//       phoneNumber: userPhone,
//       amount: bookingData['total_price'].toDouble(),
//       bookingId: bookingId,
//     );

//     if (result == "success") {
//       // Update status to paid
//       await _client.from('bookings').update({'status': 'paid'}).eq('id', bookingId);
//       _showSnackBar('Booking successful and payment received!');

//       setState(() {
//         _isPaymentCompleted = true;
//       });

//       // Optional: refresh state if needed
//       Provider.of<BookingProvider>(context, listen: false).fetchBookings();
//     } else {
//       _showSnackBar('Payment failed or cancelled.', isError: true);
//     }
//   } catch (e) {
//     _showSnackBar('Booking error: $e', isError: true);
//     debugPrint('Booking error: $e');
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isBooking = false;
//         _isProcessingPayment = false;
//       });
//     }
//   }
// }



//   // Receipt generation (now uses the platform-agnostic service)
//   void _generateReceipt() async {
//     try {
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
//       debugPrint('Error generating/handling receipt: $e');
//     }
//   }

//   // Helper to calculate boarding days for display
//   int _calculateBoardingDays() {
//     final String? startStr = widget.bookingDetails['selectedDate'] as String?;
//     final String? endStr = widget.bookingDetails['selectedEndDate'] as String?;
//     if (startStr == null) return 0;

//     final DateTime? start = DateTime.tryParse(startStr);
//     if (start == null) return 0;

//     final DateTime? end = endStr != null ? DateTime.tryParse(endStr) : null;

//     if (end == null || end.isBefore(start)) {
//       return 1;
//     }
//     return end.difference(start).inDays + 1;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Extract details for display, using the corrected keys
//     final String serviceType = widget.bookingDetails['serviceType'] as String? ?? 'N/A';
//     final String? startDateString = widget.bookingDetails['selectedDate'] as String?;
//     final String? endDateString = widget.bookingDetails['selectedEndDate'] as String?;
//     final String? startTime = widget.bookingDetails['selectedTime'] as String?;
//     // FIX: Ensure special instructions default to 'None' for consistency with BookServiceScreen
//     final String specialInstructions = widget.bookingDetails['specialInstructions'] as String? ?? 'None'; 
//     final double totalPrice = (widget.bookingDetails['totalPrice'] as num?)?.toDouble() ?? 0.0;

//     // Format dates for display
//     String formattedStartDate = startDateString != null
//         ? DateFormat('MMM d,yyyy').format(DateTime.parse(startDateString))
//         : 'N/A';
//     String formattedEndDate = endDateString != null
//         ? DateFormat('MMM d,yyyy').format(DateTime.parse(endDateString))
//         : formattedStartDate;

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
//                   // ... (existing booking details card remains the same)

//                   const SizedBox(height: 24),

//                   // M-PESA PAYMENT BUTTON - NEW SECTION
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _isProcessingMpesa || _isPaymentCompleted 
//                           ? null 
//                           : _initiateMpesaPayment,
//                       icon: _isProcessingMpesa
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : const Icon(Icons.phone_android),
//                       label: Text(
//                         _isProcessingMpesa 
//                             ? 'Processing M-Pesa...'
//                             : 'Pay with M-Pesa',
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: Colors.green[700],
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
                  
//                   // EXISTING BOOKING CONFIRMATION BUTTON
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _isBooking || _isPaymentCompleted ? null : _confirmBooking,
//                       icon: _isBooking
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : _isPaymentCompleted
//                               ? const Icon(Icons.check_circle_outline)
//                               : const Icon(Icons.payment),
//                       label: Text(
//                         _isBooking
//                             ? 'Processing...'
//                             : _isPaymentCompleted
//                                 ? 'Booking Confirmed!'
//                                 : 'Confirm Booking',
//                       ),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(vertical: 16),
//                         backgroundColor: _isPaymentCompleted
//                             ? Colors.green[700]
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
                  
//                   // ... (existing receipt and home buttons remain the same)
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
import 'package:pawpal/services/mpesa_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/booking_provider.dart';
import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service;

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingDetails;

  const BookingConfirmationScreen({super.key, required this.bookingDetails});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  late final SupabaseClient _client;
  bool _isProcessing = false;
  bool _isPaymentCompleted = false;
  String _paymentStatus = '';
  String _bookingStatus = 'Pending';

  // Pet details
  late final Map<String, dynamic> _petDetails;
  late final String _petName;
  late final String _petType;
  late final String _petBreed;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _initializePetDetails();
  }

  void _initializePetDetails() {
    _petDetails = widget.bookingDetails['pet'] as Map<String, dynamic>? ?? {};
    _petName = _petDetails['name'] as String? ?? 'Unnamed Pet';
    _petType = _petDetails['type'] as String? ?? 'Unknown Type';
    _petBreed = _petDetails['breed'] as String? ?? 'N/A';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<bool> _checkForConflict() async {
  final String? serviceType = widget.bookingDetails['serviceType'] as String?;
  final String? selectedDateString = widget.bookingDetails['selectedDate'] as String?;
  final String? selectedEndDateString = widget.bookingDetails['selectedEndDate'] as String?;
  
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
        .inFilter('status', ['pending', 'approved', 'paid']);

    for (final booking in conflicts) {
      final existingStartDateStr = booking['start_date'] as String?;
      final existingEndDateStr = booking['end_date'] as String?;
      if (existingStartDateStr == null) continue;
      
      final DateTime? existingStartDate = DateTime.tryParse(existingStartDateStr);
      final DateTime? existingEndDate = existingEndDateStr != null
          ? DateTime.tryParse(existingEndDateStr)
          : existingStartDate;
      
      if (existingStartDate == null) continue;

      // Fixed overlap check with proper null handling
      if (existingEndDate != null) {
        // Check if the new booking overlaps with existing booking
        if (startDate.isBefore(existingEndDate) &&
            bookingEndDate.isAfter(existingStartDate)) {
          _showSnackBar('Conflict detected: This service is already booked for the selected dates.', isError: true);
          return true;
        }
      } else {
        // Handle single-day bookings
        if (startDate.isAtSameMomentAs(existingStartDate) ||
            (startDate.isBefore(existingStartDate) && bookingEndDate.isAfter(existingStartDate))) {
          _showSnackBar('Conflict detected: This service is already booked for the selected date.', isError: true);
          return true;
        }
      }
    }
    return false;
  } catch (e) {
    _showSnackBar('Error checking for conflicts: $e', isError: true);
    return true;
  }
}


  Future<String> _createBookingRecord(String status) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final bookingData = {
      'owner_id': user.id,
      'pet_id': widget.bookingDetails['selectedPetId'],
      'service_type': widget.bookingDetails['serviceType'],
      'start_date': widget.bookingDetails['selectedDate'],
      'end_date': widget.bookingDetails['selectedEndDate'] ?? widget.bookingDetails['selectedDate'],
      'start_time': widget.bookingDetails['selectedTime'],
      'special_instructions': widget.bookingDetails['specialInstructions'] ?? 'None',
      'total_price': widget.bookingDetails['totalPrice'],
      'status': status,
      'procedures': widget.bookingDetails['procedures'] ?? [],
    };

    final inserted = await _client
        .from('bookings')
        .insert(bookingData)
        .select('id')
        .single();

    return inserted['id'] as String;
  }

  Future<void> _confirmBookingWithoutPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _paymentStatus = 'Confirming booking...';
    });

    try {
      if (await _checkForConflict()) return;

      final bookingId = await _createBookingRecord('Booked (Unpaid)');
      _bookingStatus = 'Booked (Unpaid)';
      
      setState(() {
        _isPaymentCompleted = true;
        _isProcessing = false;
      });
      
      _showSnackBar('Booking confirmed!');
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    } catch (e) {
      _showSnackBar('Booking failed: $e', isError: true);
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _handleMpesaPayment() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
      _paymentStatus = 'Initiating M-Pesa...';
    });

    try {
      if (await _checkForConflict()) return;
      
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not logged in');
      
      final profile = await _client
          .from('profiles')
          .select('phone_number')
          .eq('id', user.id)
          .single();
      
      final String userPhone = profile['phone_number'] ?? '';
      if (userPhone.isEmpty) throw Exception('Phone number not found');
      
      final double amount = widget.bookingDetails['totalPrice'] as double;
      final bookingId = await _createBookingRecord('Pending Payment');

      setState(() => _paymentStatus = 'Sending payment request...');
      final result = await MpesaService.initiateStkPush(
        phoneNumber: userPhone,
        amount: amount,
        bookingId: bookingId,
      );

      if (result.contains("success")) {
        await _client.from('bookings').update({
          'status': 'Paid',
          'payment_time': DateTime.now().toIso8601String(),
        }).eq('id', bookingId);
        
        _bookingStatus = 'Paid';
        
        setState(() {
          _isPaymentCompleted = true;
          _isProcessing = false;
        });
        
        _showSnackBar('Payment successful! Booking confirmed.');
        Provider.of<BookingProvider>(context, listen: false).fetchBookings();
      } else {
        throw Exception('Payment failed: $result');
      }
    } catch (e) {
      _showSnackBar('Payment failed: $e', isError: true);
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _generateReceipt() async {
    try {
      final receiptData = {
        ...widget.bookingDetails,
        'status': _bookingStatus,
        'payment_time': DateTime.now().toIso8601String(),
      };
      
      await pdf_service.generateAndHandleReceipt(receiptData);
      _showSnackBar('Receipt downloaded successfully!');
    } catch (e) {
      _showSnackBar('Failed to generate receipt: $e', isError: true);
    }
  }

  int _calculateBoardingDays() {
    final String? startStr = widget.bookingDetails['selectedDate'] as String?;
    final String? endStr = widget.bookingDetails['selectedEndDate'] as String?;
    if (startStr == null) return 0;

    final DateTime? start = DateTime.tryParse(startStr);
    if (start == null) return 0;

    final DateTime? end = endStr != null ? DateTime.tryParse(endStr) : start;

    return end!.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final serviceType = widget.bookingDetails['serviceType'] as String? ?? 'N/A';
    final startDateString = widget.bookingDetails['selectedDate'] as String?;
    final endDateString = widget.bookingDetails['selectedEndDate'] as String?;
    final startTime = widget.bookingDetails['selectedTime'] as String?;
    final specialInstructions = widget.bookingDetails['specialInstructions'] as String? ?? 'None'; 
    final totalPrice = (widget.bookingDetails['totalPrice'] as num?)?.toDouble() ?? 0.0;

    final formattedStartDate = startDateString != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(startDateString))
        : 'N/A';
    final formattedEndDate = endDateString != null
        ? DateFormat('MMM d, yyyy').format(DateTime.parse(endDateString))
        : formattedStartDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _paymentStatus,
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
                    'Review Your Booking',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Booking Details Card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow(Icons.pets, 'Pet Name:', _petName),
                          _buildDetailRow(Icons.category, 'Pet Type:', _petType),
                          _buildDetailRow(Icons.pets_sharp, 'Breed:', _petBreed),
                          const SizedBox(height: 12),
                          
                          _buildDetailRow(Icons.medical_services, 'Service:', serviceType),
                          _buildDetailRow(Icons.calendar_today, 'Date:', formattedStartDate),
                          
                          if (serviceType == 'Boarding')
                            _buildDetailRow(Icons.calendar_today, 'End Date:', formattedEndDate),
                          
                          if (startTime != null)
                            _buildDetailRow(Icons.access_time, 'Time:', startTime),
                          
                          _buildDetailRow(Icons.notes, 'Instructions:', specialInstructions),
                          
                          const Divider(height: 24),
                          
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Price:',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
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
                          ),
                          
                          if (serviceType == 'Boarding')
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                '(${_calculateBoardingDays()} ${_calculateBoardingDays() > 1 ? 'days' : 'day'} boarding)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Payment Buttons
                  if (!_isPaymentCompleted) ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _handleMpesaPayment,
                        icon: const Icon(Icons.phone_android),
                        label: const Text('Pay with M-Pesa'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _confirmBookingWithoutPayment,
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Confirm Without Payment'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(color: Theme.of(context).colorScheme.primary),
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          textStyle: const TextStyle(fontSize: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  // Success State
                  if (_isPaymentCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Booking Confirmed!',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text('Status: $_bookingStatus'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _generateReceipt,
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Download Receipt'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/home'),
                      child: Text(
                        'Back to Home',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
