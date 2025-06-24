import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  late final SupabaseClient _client;
  List<Map<String, dynamic>> _upcomingBookings = [];
  List<Map<String, dynamic>> _pastBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not logged in.';
        if (mounted) context.go('/login'); // Redirect to login if not logged in
        return;
      }

      // Fetch bookings and join with pets table to get pet name/type
      final List<Map<String, dynamic>> data = await _client
          .from('bookings')
          .select('*, pets(name, type)') // Select all booking fields and specific pet fields
          .eq('owner_id', userId)
          .order('start_date', ascending: true); // Order by date for easy separation

      final now = DateTime.now();
      List<Map<String, dynamic>> tempUpcoming = [];
      List<Map<String, dynamic>> tempPast = [];

      for (var booking in data) {
        final startDate = DateTime.parse(booking['start_date']);
        // Consider boarding end date if available, otherwise just start date
        final endDate = booking['end_date'] != null
            ? DateTime.parse(booking['end_date'])
            : startDate;

        if (endDate.isBefore(now)) { // If the booking end date is in the past
          tempPast.add(booking);
        } else {
          tempUpcoming.add(booking);
        }
      }

      if (mounted) {
        setState(() {
          _upcomingBookings = tempUpcoming;
          _pastBookings = tempPast;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bookings: $e';
        });
      }
      print('Error fetching bookings: $e'); // For debugging
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // For Upcoming and Past tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : TabBarView(
                    children: [
                      // Upcoming Bookings Tab
                      _upcomingBookings.isEmpty
                          ? const Center(
                              child: Text('No upcoming bookings yet!'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _upcomingBookings.length,
                              itemBuilder: (context, index) {
                                return BookingCard(booking: _upcomingBookings[index]);
                              },
                            ),
                      // Past Bookings Tab
                      _pastBookings.isEmpty
                          ? const Center(
                              child: Text('No past bookings found.'),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16.0),
                              itemCount: _pastBookings.length,
                              itemBuilder: (context, index) {
                                return BookingCard(booking: _pastBookings[index]);
                              },
                            ),
                    ],
                  ),
      ),
    );
  }
}

// --- Booking Card Widget ---
class BookingCard extends StatelessWidget {
  final Map<String, dynamic> booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final String serviceType = booking['service_type'];
    final DateTime startDate = DateTime.parse(booking['start_date']);
    final DateTime? endDate = booking['end_date'] != null ? DateTime.parse(booking['end_date']) : null;
    final String? startTime = booking['start_time'];
    final String status = booking['status'];
    final String petName = (booking['pets'] as Map<String, dynamic>?)?['name'] ?? 'Unknown Pet';
    final String petType = (booking['pets'] as Map<String, dynamic>?)?['type'] ?? 'Unknown Type';
    final String instructions = booking['special_instructions'] ?? 'None';
    // final double? price = booking['total_price'] as double?; // Uncomment when price is implemented

    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Type and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceType,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, thickness: 1),

            // Pet Info
            _buildInfoRow(context, Icons.pets, 'Pet:', '$petName ($petType)'),

            // Date(s)
            _buildInfoRow(context, Icons.calendar_today, 'Date:', _formatDateRange(startDate, endDate)),

            // Time (if applicable)
            if (startTime != null && startTime.isNotEmpty)
              _buildInfoRow(context, Icons.access_time, 'Time:', _formatTime(startTime, context)),

            // Instructions (if present)
            if (instructions.isNotEmpty && instructions != 'None')
              _buildInfoRow(context, Icons.notes, 'Instructions:', instructions),

            // Price (Uncomment when ready)
            // if (price != null)
            //   _buildInfoRow(context, Icons.attach_money, 'Price:', 'KES ${price.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          SizedBox(
            width: 90, // Adjust width as needed for labels
            child: Text(
              '$label',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateRange(DateTime start, DateTime? end) {
    if (end != null && start.year == end.year && start.month == end.month && start.day == end.day) {
      return DateFormat('MMM d, yyyy').format(start); // Single day
    } else if (end != null) {
      return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    } else {
      return DateFormat('MMM d, yyyy').format(start);
    }
  }

  String _formatTime(String timeString, BuildContext context) {
    try {
      final parts = timeString.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final timeOfDay = TimeOfDay(hour: hour, minute: minute);
      return timeOfDay.format(context);
    } catch (e) {
      return timeString; // Return as is if parsing fails
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}