// lib/providers/booking_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get allBookings => _allBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Convenience getter for upcoming bookings count
  int get upcomingBookingsCount {
    if (_allBookings.isEmpty) return 0;
    final now = DateTime.now();
    return _allBookings.where((booking) {
      final startDate = DateTime.parse(booking['start_date'] as String);
      final endDate = booking['end_date'] != null
          ? DateTime.parse(booking['end_date'] as String)
          : startDate;
      return !endDate.isBefore(now); // Count if end date is now or in the future
    }).length;
  }

  BookingProvider() {
    fetchBookings(); // Fetch bookings when the provider is created
  }

  Future<void> fetchBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not logged in.';
        _allBookings = []; // Clear bookings if user is not logged in
        return;
      }

      // MODIFIED: Removed 'procedures' from the select statement
      final List<Map<String, dynamic>> data = await _client
          .from('bookings')
          .select('*, pets(name, type)') // Only select existing columns
          .eq('owner_id', userId)
          .order('start_date', ascending: true);
      
      _allBookings = data;
    } catch (e) {
      _errorMessage = 'Failed to load bookings: $e';
      _allBookings = []; // Clear bookings on error
      print('Error fetching bookings in BookingProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }
}
