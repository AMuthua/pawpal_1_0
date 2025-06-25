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

