// TODO Implement this library.// lib/providers/admin_stats_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ignore: unnecessary_import
import 'package:postgrest/postgrest.dart'; // Required for CountOption

class AdminStatsProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  int _totalUsers = 0;
  int _totalPets = 0;
  int _totalBookings = 0;
  double _totalRevenue = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters for the stats
  int get totalUsers => _totalUsers;
  int get totalPets => _totalPets;
  int get totalBookings => _totalBookings;
  double get totalRevenue => _totalRevenue;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor to fetch stats immediately when initialized
  AdminStatsProvider() {
    fetchAdminStats();
  }

  Future<void> fetchAdminStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      // Fetch Total Users
      final PostgrestResponse userCountResponse = await _client
          .from('profiles')
          .select('id')
          .count(CountOption.exact);
      _totalUsers = userCountResponse.count;

      // Fetch Total Pets
      final PostgrestResponse petCountResponse = await _client
          .from('pets')
          .select('id')
          .count(CountOption.exact);
      _totalPets = petCountResponse.count;

      // Fetch Total Bookings and Total Revenue
      final List<Map<String, dynamic>> bookingsData = await _client
          .from('bookings')
          .select('total_price');

      _totalBookings = bookingsData.length;
      _totalRevenue = bookingsData.fold(0.0, (sum, booking) {
        return sum + ((booking['total_price'] as num?)?.toDouble() ?? 0.0);
      });

    } on PostgrestException catch (e) {
      _errorMessage = 'Error fetching admin stats: ${e.message}';
      debugPrint('Supabase Error fetching admin stats: ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('Unexpected Error fetching admin stats: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }
}
