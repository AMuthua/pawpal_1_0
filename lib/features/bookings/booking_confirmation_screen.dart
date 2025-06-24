import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unused_import
import 'package:uuid/uuid.dart'; // For generating UUID for booking ID, if not relying solely on DB default

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

  // Add payment state variables
  bool _isProcessingPayment = false;
  bool _isPaymentCompleted = false;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _fetchPetDetails();
  }

  // Fetch pet's name based on ID for display
  Future<void> _fetchPetDetails() async {
    try {
      final petId = widget.bookingDetails['selectedPetId'] as String;
      final response = await _client.from('pets').select('name, type').eq('id', petId).single();
      if (mounted) {
        setState(() {
          _petName = response['name'] as String? ?? 'Unnamed Pet';
          _petType = response['type'] as String? ?? 'Unknown Type';
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

  // Helper to show SnackBar messages
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  // --- Time Slot Conflict Check ---
  Future<bool> _checkForConflict() async {
    final serviceType = widget.bookingDetails['serviceType'] as String;
    final startDateTime = DateTime.parse(widget.bookingDetails['selectedDate'] as String);
    final selectedTime = widget.bookingDetails['selectedTime'] as String?;
    final endDateTime = widget.bookingDetails['selectedEndDate'] != null
        ? DateTime.parse(widget.bookingDetails['selectedEndDate'] as String)
        : null;

    // Convert TimeOfDay string to a full DateTime for comparison
    DateTime? fullStartTime;
    if (selectedTime != null) {
      final parts = selectedTime.split(':');
      fullStartTime = DateTime(
        startDateTime.year,
        startDateTime.month,
        startDateTime.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
    }

    // Adjust end date for single-day boarding to be the same as start date
    DateTime bookingEndDate = endDateTime ?? startDateTime;
    // For single-day services, the end time might be derived from duration or considered just the start_time
    // For now, let's assume specific appointment services are point-in-time or very short duration around start_time

    try {
      final conflicts = await _client
          .from('bookings')
          .select('id, start_date, end_date, start_time')
          .eq('service_type', serviceType) // Check for conflicts for the same service type
          .inFilter('status', ['pending', 'approved']); // Only active/pending bookings

      for (final booking in conflicts) {
        final existingStartDate = DateTime.parse(booking['start_date']);
        final existingEndDate = booking['end_date'] != null
            ? DateTime.parse(booking['end_date'])
            : existingStartDate; // For single-day services

        // Parse existing start time (if available)
        DateTime? existingFullStartTime;
        if (booking['start_time'] != null) {
          final parts = (booking['start_time'] as String).split(':');
          existingFullStartTime = DateTime(
            existingStartDate.year,
            existingStartDate.month,
            existingStartDate.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }

        // --- Conflict Logic ---
        // For Boarding (date-based conflict)
        if (serviceType == 'Boarding') {
          // Check for date overlaps
          if (
              (startDateTime.isBefore(existingEndDate.add(const Duration(days: 1))) &&
               bookingEndDate.add(const Duration(days: 1)).isAfter(existingStartDate)) ||
              (existingStartDate.isBefore(bookingEndDate.add(const Duration(days: 1))) &&
               existingEndDate.add(const Duration(days: 1)).isAfter(startDateTime))
          ) {
            return true; // Conflict found
          }
        }
        // For other services (specific time slot conflict)
        else {
          if (fullStartTime != null && existingFullStartTime != null) {
            // This is a simplified check: assumes services take 1 hour
            // You might need to adjust duration based on service type.
            final proposedEnd = fullStartTime.add(const Duration(hours: 1)); // Assuming 1 hour service
            final existingProposedEnd = existingFullStartTime.add(const Duration(hours: 1)); // Assuming 1 hour service

            if (startDateTime.isAtSameMomentAs(existingStartDate) && // Same Day
                fullStartTime.isBefore(existingProposedEnd) &&
                proposedEnd.isAfter(existingFullStartTime)) {
              return true; // Conflict found
            }
          }
        }
      }
      return false; // No conflict found
    } catch (e) {
      _showSnackBar('Error checking for conflicts: $e', isError: true);
      return true; // Assume conflict or error to prevent double booking
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

      // Perform conflict check
      final hasConflict = await _checkForConflict();
      if (hasConflict) {
        _showSnackBar('Selected time slot is already booked. Please choose another.', isError: true);
        return;
      }

      // Parse dates and time
      final selectedDate = DateTime.parse(widget.bookingDetails['selectedDate'] as String);
      final selectedTime = widget.bookingDetails['selectedTime'] as String?;
      final selectedEndDate = widget.bookingDetails['selectedEndDate'] != null
          ? DateTime.parse(widget.bookingDetails['selectedEndDate'] as String)
          : null;

      // NEW: Get price from booking details
      final double totalPrice = widget.bookingDetails['totalPrice'] as double? ?? 0.0;

      // Prepare data with price and payment status
      final newBooking = {
        'owner_id': userId,
        'pet_id': widget.bookingDetails['selectedPetId'],
        'service_type': widget.bookingDetails['serviceType'],
        'start_date': DateFormat('yyyy-MM-dd').format(selectedDate),
        'end_date': selectedEndDate != null ? DateFormat('yyyy-MM-dd').format(selectedEndDate) : null,
        'start_time': selectedTime,
        'special_instructions': widget.bookingDetails['specialInstructions'],
        'status': 'pending_payment', // Payment pending status
        'total_price': totalPrice, // NEW: Include price
      };

      await _client.from('bookings').insert(newBooking);

      // NEW: Simulate payment processing
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

  // NEW: M-Pesa payment simulation
  Future<void> _processMpesaPayment() async {
    // Simulate payment processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, this would:
    // 1. Initiate M-Pesa STK push
    // 2. Wait for payment confirmation
    // 3. Update booking status to 'completed'
    
    setState(() => _isPaymentCompleted = true);
    _showSnackBar('Payment successful!', isError: false);
  }

  // NEW: Calculate boarding days for display
  int _calculateBoardingDays() {
    if (widget.bookingDetails['selectedDate'] == null || 
        widget.bookingDetails['selectedEndDate'] == null) {
      return 0;
    }
    
    final start = DateTime.parse(widget.bookingDetails['selectedDate']);
    final end = DateTime.parse(widget.bookingDetails['selectedEndDate']);
    return end.difference(start).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
  final booking = widget.bookingDetails;
  final serviceType = booking['serviceType'];
  
  // SAFE DATE HANDLING
  DateTime? startDate;
  String? selectedDate = booking['selectedDate'] as String?;
  if (selectedDate != null) {
    startDate = DateTime.tryParse(selectedDate);
  }
  
  DateTime? endDate;
  String? selectedEndDate = booking['selectedEndDate'] as String?;
  if (selectedEndDate != null) {
    endDate = DateTime.tryParse(selectedEndDate);
  }
  
  final String? selectedTime = booking['selectedTime'] as String?;
  final String specialInstructions = booking['specialInstructions'] ?? 'None';
  final double totalPrice = booking['totalPrice'] as double? ?? 0.0;

  // FORMATTED DATE STRINGS
  String formattedDate = startDate != null 
      ? DateFormat('EEEE, MMM d, yyyy').format(startDate)
      : 'Not selected';

  String formattedEndDate = endDate != null 
      ? DateFormat('EEEE, MMM d, yyyy').format(endDate)
      : 'N/A';

  String formattedTime = selectedTime != null 
      ? TimeOfDay.fromDateTime(DateFormat('HH:mm').parse(selectedTime)).format(context)
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
                
                // Price display card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                        const SizedBox(height: 8),
                        if (serviceType == 'Boarding')
                          Text(
                            '(${_calculateBoardingDays()} days boarding)',
                            style: const TextStyle(color: Colors.grey),
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
                
                _buildDetailRow(context, 'Service Type', serviceType),
                _buildDetailRow(context, 'Pet Name', _petName),
                _buildDetailRow(context, 'Pet Type', _petType),
                _buildDetailRow(context, 'Service Date', formattedDate),
                if (serviceType == 'Boarding')
                  _buildDetailRow(context, 'End Date', formattedEndDate),
                _buildDetailRow(context, 'Service Time', formattedTime),
                _buildDetailRow(context, 'Instructions', specialInstructions),
                
                const SizedBox(height: 32),
                
                // Payment button
                if (!_isPaymentCompleted)
                  ElevatedButton(
                    onPressed: _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      'PAY WITH M-PESA',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                
                // Payment success UI
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

  // NEW: Receipt generation (simulated)
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

  // ... keep existing _buildDetailRow and other methods ...

    Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120, // Fixed width for labels
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
}

