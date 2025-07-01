// /*
//   This is the Bookings page where all bookings are done and dusted.
// */ 


// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:intl/intl.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:pawpal/services/pdf_receipt_service.dart';



// class MyBookingsScreen extends StatefulWidget {
//   const MyBookingsScreen({super.key});

//   @override
//   State<MyBookingsScreen> createState() => _MyBookingsScreenState();
// }

// class _MyBookingsScreenState extends State<MyBookingsScreen> {
//   late final SupabaseClient _client;
//   List<Map<String, dynamic>> _upcomingBookings = [];
//   List<Map<String, dynamic>> _pastBookings = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _client = Supabase.instance.client;
//     _fetchBookings();
//   }

//   Future<void> _fetchBookings() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final userId = _client.auth.currentUser?.id;
//       if (userId == null) {
//         _errorMessage = 'User not logged in.';
//         if (mounted) context.go('/login'); // Redirect to login if not logged in
//         return;
//       }

//       // Fetch bookings and join with pets table to get pet name/type
//       final List<Map<String, dynamic>> data = await _client
//           .from('bookings')
//           .select('*, pets(name, type)') // Select all booking fields and specific pet fields
//           .eq('owner_id', userId)
//           .order('start_date', ascending: true); // Order by date for easy separation

//       final now = DateTime.now();
//       List<Map<String, dynamic>> tempUpcoming = [];
//       List<Map<String, dynamic>> tempPast = [];

//       for (var booking in data) {
//         final startDate = DateTime.parse(booking['start_date']);
//         // Consider boarding end date if available, otherwise just start date
//         final endDate = booking['end_date'] != null
//             ? DateTime.parse(booking['end_date'])
//             : startDate;

//         if (endDate.isBefore(now)) { // If the booking end date is in the past
//           tempPast.add(booking);
//         } else {
//           tempUpcoming.add(booking);
//         }

//         // if (endDate.isBefore(now)) {
//         //   if (booking['status'] == 'approved') {
//         //     await _client
//         //       .from('bookings')
//         //       .update({'status': 'completed'})
//         //       .eq('id', booking['id']);
//         //     booking['status'] = 'completed'; // Update local object too
//         //   }
//         //   tempPast.add(booking);
//         // } else {
//         //   tempUpcoming.add(booking);
//         // }
//       }

//       if (mounted) {
//         setState(() {
//           _upcomingBookings = tempUpcoming;
//           _pastBookings = tempPast;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _errorMessage = 'Failed to load bookings: $e';
//         });
//       }
//       print('Error fetching bookings: $e'); // For debugging
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 2, // For Upcoming and Past tabs
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('My Bookings'),
//           bottom: const TabBar(
//             tabs: [
//               Tab(text: 'Upcoming'),
//               Tab(text: 'Past'),
//             ],
//           ),
//         ),
//         body: _isLoading
//             ? const Center(child: CircularProgressIndicator())
//             : _errorMessage != null
//                 ? Center(child: Text(_errorMessage!))
//                 : TabBarView(
//                     children: [
//                       // Upcoming Bookings Tab
//                       _upcomingBookings.isEmpty
//                           ? const Center(
//                               child: Text('No upcoming bookings yet!'),
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.all(16.0),
//                               itemCount: _upcomingBookings.length,
//                               itemBuilder: (context, index) {
//                                 return BookingCard(booking: _upcomingBookings[index]);
//                               },
//                             ),
//                       // Past Bookings Tab
//                       _pastBookings.isEmpty
//                           ? const Center(
//                               child: Text('No past bookings found.'),
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.all(16.0),
//                               itemCount: _pastBookings.length,
//                               itemBuilder: (context, index) {
//                                 return BookingCard(booking: _pastBookings[index]);
//                               },
//                             ),
//                     ],
//                   ),
//       ),
//     );
//   }
// }

// // --- Booking Card Widget ---
// class BookingCard extends StatelessWidget {
//   final Map<String, dynamic> booking;

//   const BookingCard({super.key, required this.booking});

//   @override
//   Widget build(BuildContext context) {
//     final String serviceType = booking['service_type'];
//     final DateTime startDate = DateTime.parse(booking['start_date']);
//     final DateTime? endDate = booking['end_date'] != null ? DateTime.parse(booking['end_date']) : null;
//     final String? startTime = booking['start_time'];
//     final String status = booking['status'];
//     final String petName = (booking['pets'] as Map<String, dynamic>?)?['name'] ?? 'Unknown Pet';
//     final String petType = (booking['pets'] as Map<String, dynamic>?)?['type'] ?? 'Unknown Type';
//     final String instructions = booking['special_instructions'] ?? 'None';
//     final double? price = booking['total_price'] as double?; // Uncomment when price is implemented

//     return Card(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Service Type and Status
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   serviceType,
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: _getStatusColor(status),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Text(
//                     status.toUpperCase(),
//                     style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//             const Divider(height: 20, thickness: 1),

//             // Pet Info
//             _buildInfoRow(context, Icons.pets, 'Pet:', '$petName ($petType)'),

//             // Date(s)
//             _buildInfoRow(context, Icons.calendar_today, 'Date:', _formatDateRange(startDate, endDate)),

//             // Time (if applicable)
//             if (startTime != null && startTime.isNotEmpty)
//               _buildInfoRow(context, Icons.access_time, 'Time:', _formatTime(startTime, context)),

//             // Instructions (if present)
//             if (instructions.isNotEmpty && instructions != 'None')
//               _buildInfoRow(context, Icons.notes, 'Instructions:', instructions),

//             // Price (Uncomment when ready)
//             if (price != null)
//               _buildInfoRow(context, Icons.attach_money, 'Price:', 'KES ${price.toStringAsFixed(2)}'),
//             const SizedBox(height: 8),
//             // --- VIEW DETAILS BUTTON ---
//             Align(
//               alignment: Alignment.centerRight,
//               child: TextButton.icon(
//                 icon: const Icon(Icons.receipt_long_outlined),
//                 label: const Text('View Details'),
//                 onPressed: () {
//                   Navigator.of(context).push(
//                     MaterialPageRoute(
//                       builder: (_) => BookingDetailsScreen(booking: booking),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
//           const SizedBox(width: 8),
//           SizedBox(
//             width: 90, // Adjust width as needed for labels
//             child: Text(
//               '$label',
//               style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           ),
//         ],
//       ),
      
//     );
//   }
  

//   String _formatDateRange(DateTime start, DateTime? end) {
//     if (end != null && start.year == end.year && start.month == end.month && start.day == end.day) {
//       return DateFormat('MMM d, yyyy').format(start); // Single day
//     } else if (end != null) {
//       return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
//     } else {
//       return DateFormat('MMM d, yyyy').format(start);
//     }
//   }

//   String _formatTime(String timeString, BuildContext context) {
//     try {
//       final parts = timeString.split(':');
//       final hour = int.parse(parts[0]);
//       final minute = int.parse(parts[1]);
//       final timeOfDay = TimeOfDay(hour: hour, minute: minute);
//       return timeOfDay.format(context);
//     } catch (e) {
//       return timeString; // Return as is if parsing fails
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'pending':
//         return Colors.orange;
//       case 'approved':
//         return Colors.green;
//       case 'rejected':
//         return Colors.red;
//       case 'completed':
//         return Colors.blueGrey;
//       case 'cancelled':
//         return Colors.grey;
//       default:
//         return Colors.grey;
//     }
//   }
// }


// class BookingDetailsScreen extends StatelessWidget {
//   final Map<String, dynamic> booking;
//   const BookingDetailsScreen({super.key, required this.booking});

//   @override
//   Widget build(BuildContext context) {
//     final pet = booking['pets'] ?? {};
//     final petName = pet['name'] ?? 'Unknown';
//     final petType = pet['type'] ?? 'Unknown';
//     final serviceType = booking['service_type'] ?? '';
//     final status = booking['status'] ?? '';
//     final startDate = DateTime.parse(booking['start_date']);
//     final endDate = booking['end_date'] != null ? DateTime.parse(booking['end_date']) : startDate;
//     final dayCount = (endDate.difference(startDate).inDays + 1);
//     final pricePerDay = booking['price_per_day'] as double? ?? 0.0;
//     final totalPrice = booking['total_price'] as double? ?? 0.0;
//     final procedures = booking['procedures'] as List<dynamic>? ?? [];
//     final specialInstructions = booking['special_instructions'] ?? 'None';

//     return Scaffold(
//             appBar: AppBar(
//         title: const Text('Booking Details'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ListView(
//           children: [
//             Text(
//               '$petName (${petType})',
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             Text('Service Type: $serviceType', style: Theme.of(context).textTheme.bodyLarge),
//             Text('Status: $status', style: Theme.of(context).textTheme.bodyLarge),
//             const Divider(height: 32),

//             // Date and Days
//             Row(
//               children: [
//                 const Icon(Icons.calendar_today, size: 18),
//                 const SizedBox(width: 8),
//                 Text(
//                   'From: ${DateFormat('MMM d, yyyy').format(startDate)}  To: ${DateFormat('MMM d, yyyy').format(endDate)}',
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 const Icon(Icons.today, size: 18),
//                 const SizedBox(width: 8),
//                 Text('Number of Days: $dayCount'),
//               ],
//             ),
//             const SizedBox(height: 8),
//             // Price per Day
//             Row(
//               children: [
//                 const Icon(Icons.attach_money, size: 18),
//                 const SizedBox(width: 8),
//                 Text('Price per Day: KES ${pricePerDay.toStringAsFixed(2)}'),
//               ],
//             ),
//             const Divider(height: 32),

//             // Procedures Section
//             if (procedures.isNotEmpty) ...[
//               Text('Procedures:', style: Theme.of(context).textTheme.titleMedium),
//               ...procedures.map<Widget>((proc) {
//                 final procName = proc['name'] ?? 'Procedure';
//                 final procPrice = proc['price'] ?? 0;
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(procName, style: Theme.of(context).textTheme.bodyMedium),
//                       Text('KES ${procPrice.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
//                     ],
//                   ),
//                 );
//               }),
//               const Divider(height: 32),
//             ],

//             // Special Instructions
//             if (specialInstructions.isNotEmpty && specialInstructions != 'None') ...[
//               const Text('Special Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
//               Padding(
//                 padding: const EdgeInsets.only(top: 4, bottom: 16),
//                 child: Text(specialInstructions),
//               ),
//             ],

//             // Total Price
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Total Price:', style: Theme.of(context).textTheme.titleMedium),
//                 Text(
//                   'KES ${totalPrice.toStringAsFixed(2)}',
//                   style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//                       const SizedBox(height: 24),
//             Row(
//                   mainAxisSize: MainAxisSize.min, // Prevents row from expanding
//                   children: [
//                     // Your existing button
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         generateAndHandleReceipt(booking);
//                       },
//                       icon: const Icon(Icons.picture_as_pdf, size: 20),
//                       label: const Text('Download Receipt'),
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                         backgroundColor: Theme.of(context).colorScheme.primary,
//                         foregroundColor: Colors.white,
//                         elevation: 2,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         textStyle: Theme.of(context).textTheme.labelLarge,
//                       ),
//                     ),
                    
//                     SizedBox(width: 10), // Space between buttons
                    
//                     // Additional buttons (example)
//                     // ElevatedButton.icon(
//                     //   onPressed: () {},
//                     //   icon: Icon(Icons.share),
//                     //   label: Text('Share'),
//                     //   style: ElevatedButton.styleFrom(
//                     //     // Your custom style
//                     //   ),
//                     // ),
//                   ],
//                 )

//           ],
//         ),
//       ),
//     );
//   }
// }







