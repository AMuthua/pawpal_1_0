import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:pawpal/providers/admin_stats_provider.dart'; // Import AdminStatsProvider
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import Service model for _fetchAvailableServices
import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service; // Import the aliased PDF service

// Define a simple Booking model for cleaner data handling
class Booking {
  final String id;
  final String ownerId;
  final String petId;
  final String serviceType;
  final DateTime startDate;
  final DateTime? endDate;
  final String? startTime;
  final String specialInstructions;
  final double totalPrice;
  String status; // Status can be changed by admin
  final Map<String, dynamic> petDetails; // Nested pet details
  final List<dynamic> procedures;
  String? ownerDisplayName; // Changed from ownerUsername to ownerDisplayName

  Booking({
    required this.id,
    required this.ownerId,
    required this.petId,
    required this.serviceType,
    required this.startDate,
    this.endDate,
    this.startTime,
    required this.specialInstructions,
    required this.totalPrice,
    required this.status,
    required this.petDetails,
    required this.procedures,
    this.ownerDisplayName, // Initialize ownerDisplayName
  });

  // Factory constructor for creating a Booking from a Supabase row (Map)
  factory Booking.fromMap(Map<String, dynamic> data) {
    // Safely extract nested 'pets' and 'profiles' data
    final Map<String, dynamic>? petData = data['pets'] as Map<String, dynamic>?;
    final Map<String, dynamic>? profileData = data['profiles'] as Map<String, dynamic>?;

    return Booking(
      id: data['id'] as String,
      ownerId: data['owner_id'] as String,
      petId: data['pet_id'] as String, 
      serviceType: data['service_type'] as String,
      startDate: DateTime.parse(data['start_date'] as String),
      endDate: data['end_date'] != null ? DateTime.parse(data['end_date'] as String) : null,
      startTime: data['start_time'] as String?,
      specialInstructions: data['special_instructions'] as String? ?? 'None',
      totalPrice: (data['total_price'] as num).toDouble(),
      status: data['status'] as String,
      petDetails: petData ?? {}, // Use extracted petData
      procedures: data['procedures'] as List<dynamic>? ?? [],
      // Directly assign ownerDisplayName from joined profile data
      ownerDisplayName: profileData?['display_name'] as String?, 
    );
  }

  // Method to convert a Booking to a Map for Supabase update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'pet_id': petId,
      'service_type': serviceType,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'start_time': startTime,
      'special_instructions': specialInstructions,
      'total_price': totalPrice,
      'status': status,
      'procedures': procedures,
    };
  }
}

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Booking> _allBookings = []; // Changed to List<Booking>
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
  static const List<String> _bookingStatuses = [
    'pending',
    'paid',
    'rejected',
    'completed',
    'cancelled',
    'pending_payment'
  ];

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
      final List<Map<String, dynamic>> data =
          await supabase.from('services').select('*').order('name', ascending: true);
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
      var query = supabase
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
        query = query.ilike('pets.name', '%${_filterPetNameController.text.trim()}%');
      }
      if (_filterOwnerNameController.text.isNotEmpty) {
        query = query.ilike('profiles.display_name', '%${_filterOwnerNameController.text.trim()}%');
      }

      final List<Map<String, dynamic>> data = await query
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _allBookings = data.map((json) => Booking.fromMap(json)).toList(); // Map to Booking objects
        });
      }
    } on PostgrestException catch (e) {
      _errorMessage = 'Error fetching bookings: ${e.message}';
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
      await supabase.from('bookings').update({'status': newStatus}).eq('id', bookingId);
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
            content: const Text('Are you sure you want to delete this booking? This action cannot be undone.'),
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
      await supabase.from('bookings').delete().eq('id', bookingId);
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
                              child: Text(status.replaceAll('_', ' ').replaceFirst(status[0], status[0].toUpperCase())),
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

  // NEW: Method to export current filtered bookings list to PDF
  void _exportBookingsToPdf() async {
    if (_allBookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No bookings to export!')),
      );
      return;
    }

    // Calculate summary statistics for the report
    final Map<String, int> statusCounts = {};
    final Map<String, double> statusTotals = {};

    for (var booking in _allBookings) {
      final normalizedStatus = booking.status.toLowerCase().replaceAll(' ', '_');
      statusCounts[normalizedStatus] = (statusCounts[normalizedStatus] ?? 0) + 1;
      statusTotals[normalizedStatus] = (statusTotals[normalizedStatus] ?? 0.0) + booking.totalPrice;
    }

    try {
      await pdf_service.generateAndHandleBookingReport(_allBookings, statusCounts, statusTotals);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking report generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate booking report: $e')),
        );
      }
      debugPrint('Error generating booking report: $e');
    }
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
            icon: const Icon(Icons.picture_as_pdf), // PDF icon
            onPressed: _exportBookingsToPdf,
            tooltip: 'Export to PDF',
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
                        // FIX: Normalize the status string from the database
                        final String status = booking.status.toLowerCase().replaceAll(' ', '_');

                        final String startDate = DateFormat('MMM d,yyyy').format(booking.startDate);
                        final String endDate = booking.endDate != null
                            ? DateFormat('MMM d,yyyy').format(booking.endDate!)
                            : startDate;

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
                                      '${booking.serviceType} for ${booking.petDetails['name'] ?? 'N/A'}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: _getStatusColor(status),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        status.toUpperCase().replaceAll('_', ' '), // Display in readable format
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 20, thickness: 1),
                                _buildInfoRow(context, Icons.person, 'Owner:', booking.ownerDisplayName ?? 'N/A'),
                                _buildInfoRow(context, Icons.calendar_today, 'Dates:', '$startDate - $endDate'),
                                _buildInfoRow(context, Icons.attach_money, 'Total:', 'KES ${booking.totalPrice.toStringAsFixed(2)}'),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    DropdownButton<String>(
                                      value: status, // Use the normalized status here
                                      items: _bookingStatuses.map((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value.replaceAll('_', ' ').replaceFirst(value[0], value[0].toUpperCase())),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          _updateBookingStatus(booking.id, newValue);
                                        }
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                      onPressed: () => _deleteBooking(booking.id),
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
        return Colors.lightBlue;
      case 'paid':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      case 'cancelled':
        return Colors.grey;
      case 'unpaid':
        return Colors.purple;
      case 'pending_payment':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
