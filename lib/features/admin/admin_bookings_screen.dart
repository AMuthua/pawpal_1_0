// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart'; // Import provider
// import 'package:pawpal/providers/admin_stats_provider.dart'; // Import AdminStatsProvider

// // Define a simple Booking model for cleaner data handling
// class Booking {
//   final String id;
//   final String ownerId;
//   final String petId;
//   final String serviceType;
//   final DateTime startDate;
//   final DateTime? endDate;
//   final String? startTime;
//   final String specialInstructions;
//   final double totalPrice;
//   String status; // Status can be changed by admin
//   final Map<String, dynamic> petDetails; // Nested pet details
//   final List<dynamic> procedures;
//   String? ownerDisplayName; // Changed from ownerUsername to ownerDisplayName

//   Booking({
//     required this.id,
//     required this.ownerId,
//     required this.petId,
//     required this.serviceType,
//     required this.startDate,
//     this.endDate,
//     this.startTime,
//     required this.specialInstructions,
//     required this.totalPrice,
//     required this.status,
//     required this.petDetails,
//     required this.procedures,
//     this.ownerDisplayName, // Initialize ownerDisplayName
//   });

//   // Factory constructor for creating a Booking from a Supabase row (Map)
//   factory Booking.fromMap(Map<String, dynamic> data) {
//     // Safely extract nested 'pets' and 'profiles' data
//     final Map<String, dynamic>? petData = data['pets'] as Map<String, dynamic>?;
//     final Map<String, dynamic>? profileData = data['profiles'] as Map<String, dynamic>?;

//     return Booking(
//       id: data['id'] as String,
//       ownerId: data['owner_id'] as String,
//       petId: data['pet_id'] as String, 
//       serviceType: data['service_type'] as String,
//       startDate: DateTime.parse(data['start_date'] as String),
//       endDate: data['end_date'] != null ? DateTime.parse(data['end_date'] as String) : null,
//       startTime: data['start_time'] as String?,
//       specialInstructions: data['special_instructions'] as String? ?? 'None',
//       totalPrice: (data['total_price'] as num).toDouble(),
//       status: data['status'] as String,
//       petDetails: petData ?? {}, // Use extracted petData
//       procedures: data['procedures'] as List<dynamic>? ?? [],
//       // Directly assign ownerDisplayName from joined profile data
//       ownerDisplayName: profileData?['display_name'] as String?, 
//     );
//   }

//   // Method to convert a Booking to a Map for Supabase update
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'owner_id': ownerId,
//       'pet_id': petId,
//       'service_type': serviceType,
//       'start_date': startDate.toIso8601String(),
//       'end_date': endDate?.toIso8601String(),
//       'start_time': startTime,
//       'special_instructions': specialInstructions,
//       'total_price': totalPrice,
//       'status': status,
//       'procedures': procedures,
//     };
//   }
// }

// class AdminBookingsScreen extends StatefulWidget {
//   const AdminBookingsScreen({super.key});

//   @override
//   State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
// }

// class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Booking> _bookings = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAllBookings();
//   }

//   Future<void> _fetchAllBookings() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       // FIX: Fetch bookings, including pet details AND owner display_name in one query
//       final List<Map<String, dynamic>> data = await supabase
//           .from('bookings')
//           .select('*, pets(name, type, breed), profiles(display_name)') // JOIN with profiles table for display_name
//           .order('start_date', ascending: false); // Order by most recent bookings first

//       List<Booking> fetchedBookings = data.map((json) => Booking.fromMap(json)).toList();

//       // DEBUG PRINT: Log the raw data fetched to inspect 'profiles' field
//       debugPrint('Raw data fetched for Admin Bookings: $data');

//       // The separate loop to fetch owner display names is no longer needed
//       // as it's now part of the initial select statement.
//       // The Booking.fromMap factory is updated to directly use this joined data.

//       _bookings = fetchedBookings;
//     } on PostgrestException catch (e) {
//       _errorMessage = 'Error fetching bookings: ${e.message}';
//       debugPrint(_errorMessage);
//     } catch (e) {
//       _errorMessage = 'An unexpected error occurred: $e';
//       debugPrint(_errorMessage);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
//     try {
//       await supabase
//           .from('bookings')
//           .update({'status': newStatus})
//           .eq('id', bookingId);
      
//       if (mounted) {
//         _showSnackBar('Booking status updated to $newStatus!');
//         // Trigger refresh of admin stats after status update
//         Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
//       }
//       _fetchAllBookings(); // Refresh the list
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         _showSnackBar('Error updating status: ${e.message}', isError: true);
//       }
//       debugPrint('Error updating booking status: ${e.message}');
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('An unexpected error occurred: $e', isError: true);
//       }
//       debugPrint('Unexpected error updating booking status: $e');
//     }
//   }

//   Future<void> _deleteBooking(String bookingId) async {
//     final bool confirmDelete = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Confirm Deletion'),
//             content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(false),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(true),
//                 child: const Text('Delete'),
//               ),
//             ],
//           ),
//         ) ??
//         false;

//     if (!confirmDelete) return;

//     try {
//       await supabase.from('bookings').delete().eq('id', bookingId);
//       if (mounted) {
//         _showSnackBar('Booking deleted successfully!');
//         // Trigger refresh of admin stats after deletion
//         Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
//       }
//       _fetchAllBookings(); // Refresh the list
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         _showSnackBar('Error deleting booking: ${e.message}', isError: true);
//       }
//       debugPrint('Error deleting booking: ${e.message}');
//     } catch (e) {
//       if (mounted) {
//         _showSnackBar('An unexpected error occurred: $e', isError: true);
//       }
//       debugPrint('Unexpected error deleting booking: $e');
//     }
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Bookings'),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             context.go('/admin_dashboard'); // Navigate back to the admin dashboard
//           },
//         ),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _errorMessage != null
//               ? Center(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 50),
//                         const SizedBox(height: 16),
//                         Text(
//                           _errorMessage!,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(color: Theme.of(context).colorScheme.error),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton.icon(
//                           onPressed: _fetchAllBookings,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : _bookings.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.calendar_month, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
//                           const SizedBox(height: 20),
//                           Text(
//                             'No bookings found yet.',
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
//                                 ),
//                           ),
//                           const SizedBox(height: 20),
//                           // Optionally add a button to create a booking if that's an admin function
//                         ],
//                       ),
//                     )
//                   : RefreshIndicator( // NEW: Added RefreshIndicator
//                       onRefresh: _fetchAllBookings, // Call fetchAllBookings on pull-to-refresh
//                       child: Padding(
//                         padding: EdgeInsets.all(isDesktop ? 20 : 16),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'All Bookings',
//                               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                     color: Theme.of(context).colorScheme.onSurface,
//                                   ),
//                             ),
//                             const SizedBox(height: 16),
//                             Expanded(
//                               child: ListView.builder(
//                                 itemCount: _bookings.length,
//                                 itemBuilder: (context, index) {
//                                   final booking = _bookings[index];
//                                   final petName = booking.petDetails['name'] as String? ?? 'N/A';
//                                   final petType = booking.petDetails['type'] as String? ?? 'N/A';
//                                   final petBreed = booking.petDetails['breed'] as String? ?? 'N/A';
//                                   final ownerDisplayName = booking.ownerDisplayName ?? 'N/A'; // Use the fetched display name

//                                   return Card(
//                                     margin: const EdgeInsets.symmetric(vertical: 8),
//                                     elevation: 4,
//                                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(16.0),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Service: ${booking.serviceType}',
//                                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: Theme.of(context).colorScheme.primary,
//                                                 ),
//                                           ),
//                                           const SizedBox(height: 8),
//                                           _buildDetailRow(context, Icons.person, 'Owner:', ownerDisplayName), // Display owner display name
//                                           _buildDetailRow(context, Icons.pets, 'Pet:', '$petName ($petType, $petBreed)'),
//                                           _buildDetailRow(context, Icons.calendar_today, 'Date:', 
//                                             '${DateFormat('MMM d,yyyy').format(booking.startDate)} '
//                                             '${booking.endDate != null && booking.endDate != booking.startDate ? '- ${DateFormat('MMM d,yyyy').format(booking.endDate!)}' : ''}'
//                                           ),
//                                           if (booking.startTime != null && booking.startTime!.isNotEmpty)
//                                             _buildDetailRow(context, Icons.access_time, 'Time:', booking.startTime!),
//                                           _buildDetailRow(context, Icons.attach_money, 'Price:', 'KES ${booking.totalPrice.toStringAsFixed(2)}'),
//                                           _buildDetailRow(context, Icons.info_outline, 'Instructions:', booking.specialInstructions.isEmpty ? 'None' : booking.specialInstructions),
                                          
//                                           const SizedBox(height: 12),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                             children: [
//                                               Expanded(
//                                                 child: _buildStatusChip(context, booking.status),
//                                               ),
//                                               PopupMenuButton<String>(
//                                                 onSelected: (String newValue) {
//                                                   if (newValue == 'delete') {
//                                                     _deleteBooking(booking.id);
//                                                   } else {
//                                                     _updateBookingStatus(booking.id, newValue);
//                                                   }
//                                                 },
//                                                 itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
//                                                   const PopupMenuItem<String>(
//                                                     value: 'pending',
//                                                     child: Text('Set to Pending'),
//                                                   ),
//                                                   const PopupMenuItem<String>(
//                                                     value: 'approved',
//                                                     child: Text('Set to Approved'),
//                                                   ),
//                                                   const PopupMenuItem<String>(
//                                                     value: 'completed',
//                                                     child: Text('Set to Completed'),
//                                                   ),
//                                                   const PopupMenuItem<String>(
//                                                     value: 'cancelled',
//                                                     child: Text('Set to Cancelled'),
//                                                   ),
//                                                   const PopupMenuDivider(),
//                                                   const PopupMenuItem<String>(
//                                                     value: 'delete',
//                                                     child: Text('Delete Booking', style: TextStyle(color: Colors.red)),
//                                                   ),
//                                                 ],
//                                                 icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurfaceVariant),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//     );
//   }

//   // Helper for detail rows
//   Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(width: 6),
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

//   // Helper for status chip
//   Widget _buildStatusChip(BuildContext context, String status) {
//     Color chipColor;
//     Color textColor;
//     switch (status.toLowerCase()) {
//       case 'pending':
//         chipColor = Colors.orange.shade100;
//         textColor = Colors.orange.shade800;
//         break;
//       case 'approved':
//         chipColor = Colors.green.shade100;
//         textColor = Colors.green.shade800;
//         break;
//       case 'completed':
//         chipColor = Colors.blue.shade100;
//         textColor = Colors.blue.shade800;
//         break;
//       case 'cancelled':
//         chipColor = Colors.red.shade100;
//         textColor = Colors.red.shade800;
//         break;
//       default:
//         chipColor = Colors.grey.shade200;
//         textColor = Colors.grey.shade800;
//     }
//     return Chip(
//       label: Text(
//         status.toUpperCase(),
//         style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
//       ),
//       backgroundColor: chipColor,
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import Service model

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  List<Map<String, dynamic>> _allBookings = [];
  bool _isLoading = true;
  String? _errorMessage;

  // --- Filter State Variables ---
  String? _filterServiceType;
  String? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;
  final TextEditingController _filterPetNameController = TextEditingController();
  final TextEditingController _filterOwnerNameController = TextEditingController();

  // Data for filter dropdowns
  List<Service> _availableServices = [];
  List<String> _bookingStatuses = ['pending', 'approved', 'rejected', 'completed', 'cancelled', 'pending_payment'];

  @override
  void initState() {
    super.initState();
    _fetchAvailableServices(); // Fetch services for filter dropdown
    _fetchBookings(); // Initial fetch of all bookings
  }

  @override
  void dispose() {
    _filterPetNameController.dispose();
    _filterOwnerNameController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableServices() async {
    try {
      // Select all fields (*) instead of just 'name'
      // This ensures Service.fromMap has all required data, preventing 'null is not a subtype of String'
      final List<Map<String, dynamic>> data =
          await _client.from('services').select('*').order('name', ascending: true);
      if (mounted) {
        setState(() {
          _availableServices = data.map((json) => Service.fromMap(json)).toList();
        });
      }
    } on PostgrestException catch (e) {
      debugPrint('Error fetching services for filter: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected error fetching services for filter: $e');
    }
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // FIX: Initialize with .from().select() to get a PostgrestFilterBuilder
      // All subsequent filter methods are chained to this 'query' variable.
      var query = _client
          .from('bookings')
          .select('*, pets(name, type, breed), profiles(display_name)');

      // Apply filters
      if (_filterServiceType != null && _filterServiceType!.isNotEmpty) {
        query = query.eq('service_type', _filterServiceType!);
      }
      if (_filterStatus != null && _filterStatus!.isNotEmpty) {
        query = query.eq('status', _filterStatus!);
      }
      if (_filterStartDate != null) {
        query = query.gte('start_date', _filterStartDate!.toIso8601String().split('T')[0]);
      }
      if (_filterEndDate != null) {
        query = query.lte('end_date', _filterEndDate!.toIso8601String().split('T')[0]);
      }
      if (_filterPetNameController.text.isNotEmpty) {
        // Filter by pet name using the nested 'pets' relation with ilike
        query = query.ilike('pets.name', '%${_filterPetNameController.text.trim()}%');
      }
      if (_filterOwnerNameController.text.isNotEmpty) {
        // Filter by owner display name using the nested 'profiles' relation with ilike
        query = query.ilike('profiles.display_name', '%${_filterOwnerNameController.text.trim()}%');
      }

      // Finally, apply the order and await the data
      final List<Map<String, dynamic>> data = await query
          .order('created_at', ascending: false); // Order by most recent bookings

      if (mounted) {
        setState(() {
          _allBookings = data;
        });
      }
    } on PostgrestException catch (e) {
      _errorMessage = 'Error fetching bookings: ${e.message}';
      debugPrint('Raw data fetched for Admin Bookings: $_allBookings'); // Debug print
      debugPrint('Supabase Error fetching admin bookings: ${e.message}');
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint('Unexpected error fetching admin bookings: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _client.from('bookings').update({'status': newStatus}).eq('id', bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking $bookingId status updated to $newStatus')),
        );
      }
      _fetchBookings(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update status: $e')),
        );
      }
      debugPrint('Error updating booking status: $e');
    }
  }

  Future<void> _deleteBooking(String bookingId) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this booking?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmDelete) return;

    try {
      await _client.from('bookings').delete().eq('id', bookingId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking deleted successfully!')),
        );
      }
      _fetchBookings(); // Refresh the list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete booking: $e')),
        );
      }
      debugPrint('Error deleting booking: $e');
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempServiceType = _filterServiceType;
        String? tempStatus = _filterStatus;
        DateTime? tempStartDate = _filterStartDate;
        DateTime? tempEndDate = _filterEndDate;
        TextEditingController tempPetNameController = TextEditingController(text: _filterPetNameController.text);
        TextEditingController tempOwnerNameController = TextEditingController(text: _filterOwnerNameController.text);

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Filter Bookings'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Service Type'),
                      value: tempServiceType,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Services')),
                        ..._availableServices.map((service) => DropdownMenuItem(
                          value: service.name,
                          child: Text(service.name),
                        )).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempServiceType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Status'),
                      value: tempStatus,
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Statuses')),
                        ..._bookingStatuses.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.replaceFirst(status[0], status[0].toUpperCase())),
                        )).toList(),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          tempStatus = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: tempStartDate == null ? '' : DateFormat('MMM d,yyyy').format(tempStartDate!),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Start Date (min)',
                        suffixIcon: tempStartDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setDialogState(() => tempStartDate = null)) : null,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempStartDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tempStartDate = picked;
                            if (tempEndDate != null && tempStartDate!.isAfter(tempEndDate!)) {
                              tempEndDate = null; // Reset end date if it's before new start date
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: tempEndDate == null ? '' : DateFormat('MMM d,yyyy').format(tempEndDate!),
                      ),
                      decoration: InputDecoration(
                        labelText: 'End Date (max)',
                        suffixIcon: tempEndDate != null ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setDialogState(() => tempEndDate = null)) : null,
                      ),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: tempEndDate ?? tempStartDate ?? DateTime.now(),
                          firstDate: tempStartDate ?? DateTime(2020),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            tempEndDate = picked;
                            if (tempStartDate != null && tempEndDate!.isBefore(tempStartDate!)) {
                              tempStartDate = null; // Reset start date if it's after new end date
                            }
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tempPetNameController,
                      decoration: const InputDecoration(labelText: 'Pet Name'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: tempOwnerNameController,
                      decoration: const InputDecoration(labelText: 'Owner Name'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    setDialogState(() {
                      tempServiceType = null;
                      tempStatus = null;
                      tempStartDate = null;
                      tempEndDate = null;
                      tempPetNameController.clear();
                      tempOwnerNameController.clear();
                    });
                    _filterServiceType = null;
                    _filterStatus = null;
                    _filterStartDate = null;
                    _filterEndDate = null;
                    _filterPetNameController.clear();
                    _filterOwnerNameController.clear();
                    _fetchBookings(); // Re-fetch without filters
                    Navigator.of(context).pop();
                  },
                  child: const Text('Clear Filters'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _filterServiceType = tempServiceType;
                      _filterStatus = tempStatus;
                      _filterStartDate = tempStartDate;
                      _filterEndDate = tempEndDate;
                      _filterPetNameController.text = tempPetNameController.text;
                      _filterOwnerNameController.text = tempOwnerNameController.text;
                    });
                    _fetchBookings(); // Apply filters
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Bookings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin_dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'Filter Bookings',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchBookings,
            tooltip: 'Refresh Bookings',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 50),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchBookings,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _allBookings.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
                          const SizedBox(height: 20),
                          Text(
                            'No bookings found matching filters.',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
                                ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _allBookings.length,
                      itemBuilder: (context, index) {
                        final booking = _allBookings[index];
                        // Access nested data safely
                        final petData = booking['pets'] as Map<String, dynamic>?;
                        final profileData = booking['profiles'] as Map<String, dynamic>?;

                        final String petName = petData?['name'] ?? 'N/A';
                        final String ownerName = profileData?['display_name'] ?? 'N/A'; // Use display_name
                        final String serviceType = booking['service_type'] ?? 'N/A';
                        final String status = booking['status'] ?? 'N/A';
                        final String startDate = DateFormat('MMM d,yyyy').format(DateTime.parse(booking['start_date']));
                        final String endDate = booking['end_date'] != null
                            ? DateFormat('MMM d,yyyy').format(DateTime.parse(booking['end_date']))
                            : startDate;
                        final double totalPrice = (booking['total_price'] as num?)?.toDouble() ?? 0.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$serviceType for $petName',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                                _buildInfoRow(context, Icons.person, 'Owner:', ownerName),
                                _buildInfoRow(context, Icons.calendar_today, 'Dates:', '$startDate - $endDate'),
                                _buildInfoRow(context, Icons.attach_money, 'Total:', 'KES ${totalPrice.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    DropdownButton<String>(
                                      value: status,
                                      items: _bookingStatuses.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value.replaceFirst(value[0], value[0].toUpperCase())),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          _updateBookingStatus(booking['id'], newValue);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                      onPressed: () => _deleteBooking(booking['id']),
                                      tooltip: 'Delete Booking',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
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
      case 'pending_payment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
