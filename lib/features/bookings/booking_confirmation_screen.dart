import 'package:flutter/material.dart';

import 'dart:async'; // For Timer
import 'package:http/http.dart' as http; // For direct HTTP if not using Supabase client for Edge Function


import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/booking_provider.dart';
import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service;

import 'dart:convert'; // Essential for jsonDecode


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


  String? _checkoutRequestId; // <-- Will be set from STK response
  String? _bookingId;         // <-- Set when you create the booking
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  final int _maxPollingAttempts = 12;

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
      
      // Create booking with "Pending Payment" status
      final bookingId = await _createBookingRecord('Pending Payment');
      _bookingStatus = 'Pending Payment';
      
      setState(() => _paymentStatus = 'Sending payment request...');
      
      // Call the Supabase Edge Function for M-Pesa
      final response = await _client.functions.invoke(
        'mpesa-handler',
        body: {
          'phone': userPhone.toString(),
          'amount': amount.toDouble(),
          'bookingId': bookingId.toString(),
        },
      );

      final responseData = response.data;
          final data = responseData is Map<String, dynamic>
        ? responseData
        : jsonDecode(responseData as String) as Map<String, dynamic>;

          if (data['ResponseCode'] == '0') {
            setState(() {
              _isProcessing = false;
              _isPaymentCompleted = true;
              _paymentStatus = 'Payment initiated! Waiting for confirmation...';
              _checkoutRequestId = data['CheckoutRequestID'];
              _bookingId = bookingId;
              
              
               // ← Save for polling!
            });
              _showSnackBar('Check your phone and complete the M-Pesa prompt');

            // Start polling for status
              _pollMpesaPaymentStatus();
            } else {
              final errorMsg = data['errorMessage'] ?? 'Unknown payment error';
              throw Exception('M-Pesa failed: $errorMsg');
            }
          } catch (e) {
            _showSnackBar('Payment failed: $e', isError: true);
            setState(() => _isProcessing = false);
          }
        }
  
    Future<void> _pollMpesaPaymentStatus() async {
      _pollingAttempts = 0;
      _pollingTimer?.cancel();

      if (_checkoutRequestId == null || _bookingId == null) {
        _showSnackBar('No payment reference available to query status.', isError: true);
        return;
      }

      setState(() => _paymentStatus = 'Checking payment status...');

      final session = Supabase.instance.client.auth.currentSession;
      final accessToken = session?.accessToken;

      _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
        _pollingAttempts++;
        try {
          final url = Uri.parse('https://zoyuahsnhrhxuukjveck.supabase.co/functions/v1/mpesa-query-status');
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode({
              'checkoutRequestId': _checkoutRequestId,
              'bookingId': _bookingId,
            }),
          );
          if (response.statusCode == 200) {
            final result = jsonDecode(response.body);
            if (result['ResultCode'] == '0' && result['paymentUpdated'] == true) {
              timer.cancel();
              setState(() {
                _bookingStatus = 'Paid';
                _paymentStatus = 'Payment successful! Booking confirmed.';
                _isPaymentCompleted = true;
              });
              _showSnackBar('Payment successful! Booking confirmed.');
              Provider.of<BookingProvider>(context, listen: false).fetchBookings();
            } else {
              setState(() => _paymentStatus = result['ResultDesc'] ?? 'Waiting for payment...');
            }
          } else if (response.statusCode == 401) {
            timer.cancel();
            setState(() => _paymentStatus = 'You are not authenticated. Please log in again.');
            _showSnackBar('Session expired, you need to re-login.', isError: true);
          } else {
            setState(() => _paymentStatus = 'Network error while checking payment.');
          }
        } catch (e) {
          setState(() => _paymentStatus = 'Error while checking payment status.');
        }

        if (_pollingAttempts >= _maxPollingAttempts) {
          timer.cancel();
          setState(() => _paymentStatus = 'Timeout. Could not confirm payment in time.');
          _showSnackBar('Payment confirmation timed out. You can try again from your bookings page.', isError: true);
        }
      });
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
void dispose() {
  _pollingTimer?.cancel();
  super.dispose();
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
                  // In build() method:
                  if (_isPaymentCompleted) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: _bookingStatus == 'Paid' 
                            ? Colors.green[50] 
                            : Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _bookingStatus == 'Paid' 
                              ? Colors.green 
                              : Colors.orange,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _bookingStatus == 'Paid' 
                                ? Icons.check_circle 
                                : Icons.access_time,
                            color: _bookingStatus == 'Paid' 
                                ? Colors.green 
                                : Colors.orange,
                            size: 40,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _bookingStatus == 'Paid' 
                                      ? 'Booking Confirmed!' 
                                      : 'Payment Pending',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: _bookingStatus == 'Paid' 
                                            ? Colors.green[800] 
                                            : Colors.orange[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text('Status: $_bookingStatus'),
                                if (_bookingStatus == 'Pending Payment')
                                  const Text('Complete payment on your phone'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Only show receipt button for paid bookings
                    if (_bookingStatus == 'Paid')
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
