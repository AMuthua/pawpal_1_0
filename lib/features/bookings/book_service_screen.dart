// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:pawpal/features/admin/manage_services_screen.dart'; // NEW: Import the Service model

// class BookServiceScreen extends StatefulWidget {
//   const BookServiceScreen({super.key});

//   @override
//   State<BookServiceScreen> createState() => _BookServiceScreenState();
// }

// class _BookServiceScreenState extends State<BookServiceScreen> {
//   final SupabaseClient _client = Supabase.instance.client;
//   final _formKey = GlobalKey<FormState>();

//   // Form fields
//   String? _selectedServiceTypeId; // Changed to store service ID
//   String? _selectedPetId;
//   DateTime? _startDate;
//   DateTime? _endDate; // Used for boarding
//   TimeOfDay? _startTime; // Used for services with specific times
//   final TextEditingController _instructionsController = TextEditingController();

//   // Data for dropdowns
//   List<Map<String, dynamic>> _pets = [];
//   bool _isLoadingPets = true;
//   String? _petFetchError;

//   // NEW: State for available services
//   List<Service> _availableServices = [];
//   bool _isLoadingServices = true;
//   String? _serviceFetchError;

//   // Price Calculation State
//   double _totalPrice = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPets();
//     _fetchAvailableServices(); // NEW: Fetch services on init
//   }

//   @override
//   void dispose() {
//     _instructionsController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchPets() async {
//     setState(() {
//       _isLoadingPets = true;
//       _petFetchError = null;
//     });
//     try {
//       final userId = _client.auth.currentUser?.id;
//       if (userId == null) {
//         _petFetchError = 'User not logged in.';
//         if (mounted) context.go('/login');
//         return;
//       }
//       final List<Map<String, dynamic>> data =
//           await _client.from('pets').select('id, name, type').eq('owner_id', userId);
//       if (mounted) {
//         setState(() {
//           _pets = data;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _petFetchError = 'Failed to load pets: $e';
//         });
//       }
//       debugPrint('Error fetching pets: $e'); // Use debugPrint
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingPets = false;
//         });
//       }
//     }
//   }

//   // NEW: Method to fetch services from Supabase
//   Future<void> _fetchAvailableServices() async {
//     setState(() {
//       _isLoadingServices = true;
//       _serviceFetchError = null;
//     });
//     try {
//       final List<Map<String, dynamic>> data =
//           await _client.from('services').select().order('name', ascending: true);
//       if (mounted) {
//         setState(() {
//           _availableServices = data.map((json) => Service.fromMap(json)).toList();
//         });
//       }
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         setState(() {
//           _serviceFetchError = 'Failed to load services: ${e.message}';
//         });
//       }
//       debugPrint('Error fetching services: ${e.message}');
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _serviceFetchError = 'An unexpected error occurred while fetching services: $e';
//         });
//       }
//       debugPrint('Unexpected error fetching services: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingServices = false;
//         });
//       }
//     }
//   }

//   void _calculatePrice() {
//     double calculatedPrice = 0.0;
//     if (_selectedServiceTypeId == null) {
//       _totalPrice = 0.0;
//       return;
//     }

//     // Find the selected service from the fetched list
//     final selectedService = _availableServices.firstWhere(
//       (service) => service.id == _selectedServiceTypeId,
//       orElse: () => Service(id: '', name: '', description: '', price: 0.0, durationMinutes: 0), // Fallback
//     );

//     if (selectedService.name == 'Boarding') { // Use service name for logic
//       if (_startDate != null && _endDate != null) {
//         final difference = _endDate!.difference(_startDate!).inDays;
//         calculatedPrice = (difference + 1) * selectedService.price; // Use dynamic price
//       }
//     } else {
//       calculatedPrice = selectedService.price; // Use dynamic price for other services
//     }

//     if (mounted) {
//       setState(() {
//         _totalPrice = calculatedPrice;
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context, bool isStartDate) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2101),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: Theme.of(context).colorScheme.primary, // AppBar color
//               onPrimary: Theme.of(context).colorScheme.onPrimary, // Text/icon color on AppBar
//               surface: Theme.of(context).colorScheme.surface, // Background of the picker itself
//               onSurface: Theme.of(context).colorScheme.onSurface, // Text/icon color on picker background
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).colorScheme.primary, // OK/Cancel button color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStartDate) {
//           _startDate = picked;
//           // If start date is set after end date, reset end date
//           if (_endDate != null && _startDate!.isAfter(_endDate!)) {
//             _endDate = null;
//           }
//         } else {
//           _endDate = picked;
//           // Ensure end date is not before start date
//           if (_startDate != null && _endDate!.isBefore(_startDate!)) {
//             _endDate = _startDate; // Set end date to start date if invalid
//           } else {
//             _startDate ??= picked; // If start date is null, set it to picked end date
//           }
//         }
//         _calculatePrice(); // Recalculate price on date change
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: Theme.of(context).colorScheme.copyWith(
//               primary: Theme.of(context).colorScheme.primary, // Header color
//               onPrimary: Theme.of(context).colorScheme.onPrimary, // Text/icon color on header
//               surface: Theme.of(context).colorScheme.surface, // Background of the picker itself
//               onSurface: Theme.of(context).colorScheme.onSurface, // Text/icon color on picker background
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: Theme.of(context).colorScheme.primary, // OK/Cancel button color
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && mounted) {
//       setState(() {
//         _startTime = picked;
//       });
//     }
//   }

//   void _navigateToConfirmation() {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     // Add null checks for dates
//     if (_startDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a start date')),
//       );
//       return;
//     }

//     final selectedService = _availableServices.firstWhere(
//       (service) => service.id == _selectedServiceTypeId,
//       orElse: () => Service(id: '', name: '', description: '', price: 0.0, durationMinutes: 0), // Fallback
//     );

//     if (selectedService.name == 'Boarding' && _endDate == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select an end date for boarding')),
//       );
//       return;
//     }

//     if (_totalPrice <= 0) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please select a service and dates to calculate price.')),
//       );
//       return;
//     }

//     // Prepare booking details
//     final Map<String, dynamic> bookingDetails = {
//       'selectedPetId': _selectedPetId,
//       'serviceType': selectedService.name, // Use service name from fetched data
//       'selectedDate': _startDate?.toIso8601String(),
//       'selectedEndDate': _endDate?.toIso8601String(),
//       'selectedTime': _startTime?.format(context),
//       'specialInstructions': _instructionsController.text.trim(),
//       'totalPrice': _totalPrice,
//       'pet': _pets.firstWhere(
//         (pet) => pet['id'] == _selectedPetId,
//         orElse: () => {'name': 'Unknown', 'type': 'Unknown'},
//       ),
//       'procedures': [],
//     };

//     context.push('/book/select-pet/${selectedService.name}/schedule/confirm', extra: bookingDetails); // Updated path
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show loading indicators if either pets or services are loading
//     if (_isLoadingPets || _isLoadingServices) {
//       return Scaffold(
//         appBar: AppBar(title: Text('Book a Service')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     // Show error if pet or service fetching failed
//     if (_petFetchError != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Book a Service')),
//         body: Center(child: Text('Error loading pets: $_petFetchError')),
//       );
//     }
//     if (_serviceFetchError != null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Book a Service')),
//         body: Center(child: Text('Error loading services: $_serviceFetchError')),
//       );
//     }

//     // If no pets are added
//     if (_pets.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Book a Service')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'You need to add a pet first!',
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => context.push('/pets/add'),
//                 child: const Text('Add a Pet'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     // If no services are added by admin
//     if (_availableServices.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Book a Service')),
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'No services available for booking yet. Please check back later!',
//                 textAlign: TextAlign.center,
//                 style: Theme.of(context).textTheme.titleMedium,
//               ),
//               const SizedBox(height: 16),
//               // Optionally provide a way for admin to add services, or just inform user
//             ],
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book a Service'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Schedule a Service for Your Pet',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 'Choose your pet, the service you need, and preferred dates/times.',
//                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.onBackground.withAlpha((255 * 0.7).round()), // Use withAlpha
//                     ),
//               ),
//               const SizedBox(height: 24),

//               // Pet Selection
//               Text(
//                 '1. Select Your Pet',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               DropdownButtonFormField<String>(
//                 decoration: InputDecoration(
//                   labelText: 'Choose Pet',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//                 value: _selectedPetId,
//                 items: _pets
//                     .map((pet) => DropdownMenuItem(
//                           value: pet['id'] as String,
//                           child: Text(
//                             '${pet['name']} (${pet['type']})',
//                             style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
//                           ),
//                         ))
//                     .toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedPetId = value;
//                   });
//                 },
//                 validator: (value) =>
//                     value == null ? 'Please select a pet' : null,
//               ),
//               const SizedBox(height: 32),

//               // Service Type Selection with Explanations (Dynamically generated)
//               Text(
//                 '2. Choose a Service Type',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               // NEW: Dynamically build service cards
//               ..._availableServices.map((service) {
//                 IconData serviceIcon;
//                 // Assign icons based on service name (you can expand this logic)
//                 switch (service.name) {
//                   case 'Boarding':
//                     serviceIcon = Icons.home;
//                     break;
//                   case 'Grooming':
//                     serviceIcon = Icons.cut;
//                     break;
//                   case 'Vet Visit':
//                     serviceIcon = Icons.local_hospital;
//                     break;
//                   default:
//                     serviceIcon = Icons.miscellaneous_services; // Default icon
//                 }

//                 return _buildServiceTypeCard(
//                   context,
//                   service.name,
//                   serviceIcon,
//                   service.description,
//                   service.id, // Pass service ID
//                 );
//               }).toList(),
//               const SizedBox(height: 32),

//               // Date & Time Selection
//               Text(
//                 '3. Select Date & Time',
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onBackground,
//                     ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 readOnly: true,
//                 controller: TextEditingController(
//                   text: _startDate == null
//                       ? ''
//                       : DateFormat('MMM d,yyyy').format(_startDate!),
//                 ),
//                 decoration: InputDecoration(
//                   labelText: 'Start Date',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
//                   suffixIcon: _startDate != null
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             setState(() {
//                               _startDate = null;
//                               _calculatePrice();
//                             });
//                           },
//                         )
//                       : null,
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//                 onTap: () => _selectDate(context, true),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Please select a start date' : null,
//               ),
//               const SizedBox(height: 16),

//               // End Date (only for Boarding)
//               // NEW: Check selected service name for boarding logic
//               if (_availableServices.any((s) => s.id == _selectedServiceTypeId && s.name == 'Boarding'))
//                 Column(
//                   children: [
//                     TextFormField(
//                       readOnly: true,
//                       controller: TextEditingController(
//                         text: _endDate == null
//                             ? ''
//                             : DateFormat('MMM d,yyyy').format(_endDate!),
//                       ),
//                       decoration: InputDecoration(
//                         labelText: 'End Date (for Boarding)',
//                         border: const OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
//                         suffixIcon: _endDate != null
//                             ? IconButton(
//                                 icon: const Icon(Icons.clear),
//                                 onPressed: () {
//                                   setState(() {
//                                     _endDate = null;
//                                     _calculatePrice();
//                                   });
//                                 },
//                               )
//                             : null,
//                         floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                         ),
//                       ),
//                       onTap: () => _selectDate(context, false),
//                       validator: (value) {
//                         final selectedService = _availableServices.firstWhere((s) => s.id == _selectedServiceTypeId);
//                         if (selectedService.name == 'Boarding' && (value == null || value.isEmpty)) {
//                           return 'Please select an end date for boarding';
//                         }
//                         return null;
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                   ],
//                 ),

//               // Start Time
//               TextFormField(
//                 readOnly: true,
//                 controller: TextEditingController(
//                   text: _startTime == null ? '' : _startTime!.format(context),
//                 ),
//                 decoration: InputDecoration(
//                   labelText: 'Preferred Time (Optional)',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
//                   suffixIcon: _startTime != null
//                       ? IconButton(
//                           icon: const Icon(Icons.clear),
//                           onPressed: () {
//                             setState(() {
//                               _startTime = null;
//                             });
//                           },
//                         )
//                       : null,
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//                 onTap: () => _selectTime(context),
//               ),
//               const SizedBox(height: 16),

//               // Special Instructions
//               TextFormField(
//                 controller: _instructionsController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Special Instructions (e.g., allergies, preferences)',
//                   border: const OutlineInputBorder(),
//                   alignLabelWithHint: true,
//                   prefixIcon: Icon(Icons.notes, color: Theme.of(context).colorScheme.primary),
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Display Total Price
//               Align(
//                 alignment: Alignment.center,
//                 child: Column(
//                   children: [
//                     Text(
//                       'Estimated Total Price:',
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             color: Theme.of(context).colorScheme.onBackground,
//                           ),
//                     ),
//                     Text(
//                       'KES ${_totalPrice.toStringAsFixed(2)}',
//                       style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).colorScheme.primary,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Review and Pay Button
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton.icon(
//                   onPressed: _navigateToConfirmation,
//                   icon: const Icon(Icons.arrow_forward),
//                   label: const Text('Review and Pay'),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     backgroundColor: Theme.of(context).colorScheme.primary,
//                     foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                     textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper Widget for Service Type Cards
//   Widget _buildServiceTypeCard(
//       BuildContext context, String title, IconData icon, String description, String serviceId) {
//     final bool isSelected = _selectedServiceTypeId == serviceId;
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 8.0),
//       elevation: isSelected ? 8 : 2,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(15),
//         side: isSelected
//             ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
//             : BorderSide.none,
//       ),
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             _selectedServiceTypeId = serviceId;
//             _calculatePrice();
//             // Reset end date if service type changes from Boarding
//             final selectedService = _availableServices.firstWhere((s) => s.id == serviceId);
//             if (selectedService.name != 'Boarding') {
//               _endDate = null;
//             }
//           });
//         },
//         borderRadius: BorderRadius.circular(15),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Icon(icon, size: 40, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
//                           ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       description,
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.8).round()),
//                           ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       'Price: KES ${_availableServices.firstWhere((s) => s.id == serviceId).price.toStringAsFixed(2)}',
//                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                             color: Theme.of(context).colorScheme.secondary,
//                           ),
//                     ),
//                   ],
//                 ),
//               ),
//               if (isSelected)
//                 Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 28),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pawpal/features/admin/manage_services_screen.dart'; // Import the Service model

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedServiceTypeId; // Changed to store service ID
  String? _selectedPetId;
  DateTime? _startDate;
  DateTime? _endDate; // Used for boarding
  TimeOfDay? _startTime; // Used for services with specific times
  final TextEditingController _instructionsController = TextEditingController();

  // Data for dropdowns
  List<Map<String, dynamic>> _pets = [];
  bool _isLoadingPets = true;
  String? _petFetchError;

  // State for available services
  List<Service> _availableServices = [];
  bool _isLoadingServices = true;
  String? _serviceFetchError;

  // Price Calculation State
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchPets();
    _fetchAvailableServices(); // Fetch services on init
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _fetchPets() async {
    setState(() {
      _isLoadingPets = true;
      _petFetchError = null;
    });
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _petFetchError = 'User not logged in.';
        if (mounted) context.go('/login');
        return;
      }
      // FIX: Select 'breed' column as well
      final List<Map<String, dynamic>> data =
          await _client.from('pets').select('id, name, type, breed').eq('owner_id', userId);
      if (mounted) {
        setState(() {
          _pets = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _petFetchError = 'Failed to load pets: $e';
        });
      }
      debugPrint('Error fetching pets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
      }
    }
  }

  // Method to fetch services from Supabase
  Future<void> _fetchAvailableServices() async {
    setState(() {
      _isLoadingServices = true;
      _serviceFetchError = null;
    });
    try {
      final List<Map<String, dynamic>> data =
          await _client.from('services').select().order('name', ascending: true);
      if (mounted) {
        setState(() {
          _availableServices = data.map((json) => Service.fromMap(json)).toList();
        });
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _serviceFetchError = 'Failed to load services: ${e.message}';
        });
      }
      debugPrint('Error fetching services: ${e.message}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _serviceFetchError = 'An unexpected error occurred while fetching services: $e';
        });
      }
      debugPrint('Unexpected error fetching services: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingServices = false;
        });
      }
    }
  }

  void _calculatePrice() {
    double calculatedPrice = 0.0;
    if (_selectedServiceTypeId == null) {
      _totalPrice = 0.0;
      return;
    }

    // Find the selected service from the fetched list
    final selectedService = _availableServices.firstWhere(
      (service) => service.id == _selectedServiceTypeId,
      orElse: () => Service(id: '', name: '', description: '', price: 0.0, durationMinutes: 0), // Fallback
    );

    if (selectedService.name == 'Boarding') { // Use service name for logic
      if (_startDate != null && _endDate != null) {
        final difference = _endDate!.difference(_startDate!).inDays;
        calculatedPrice = (difference + 1) * selectedService.price; // Use dynamic price
      }
    } else {
      calculatedPrice = selectedService.price; // Use dynamic price for other services
    }

    if (mounted) {
      setState(() {
        _totalPrice = calculatedPrice;
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // AppBar color
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Text/icon color on AppBar
              surface: Theme.of(context).colorScheme.surface, // Background of the picker itself
              onSurface: Theme.of(context).colorScheme.onSurface, // Text/icon color on picker background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // OK/Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // If start date is set after end date, reset end date
          if (_endDate != null && _startDate!.isAfter(_endDate!)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
          // Ensure end date is not before start date
          if (_startDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = _startDate; // Set end date to start date if invalid
          } else {
            _startDate ??= picked; // If start date is null, set it to picked end date
          }
        }
        _calculatePrice(); // Recalculate price on date change
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary, // Header color
              onPrimary: Theme.of(context).colorScheme.onPrimary, // Text/icon color on header
              surface: Theme.of(context).colorScheme.surface, // Background of the picker itself
              onSurface: Theme.of(context).colorScheme.onSurface, // Text/icon color on picker background
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // OK/Cancel button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && mounted) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _navigateToConfirmation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Add null checks for dates
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final selectedService = _availableServices.firstWhere(
      (service) => service.id == _selectedServiceTypeId,
      orElse: () => Service(id: '', name: '', description: '', price: 0.0, durationMinutes: 0), // Fallback
    );

    if (selectedService.name == 'Boarding' && _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an end date for boarding')),
      );
      return;
    }

    if (_totalPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service and dates to calculate price.')),
      );
      return;
    }

    // Find the selected pet to pass its full details
    final selectedPet = _pets.firstWhere(
      (pet) => pet['id'] == _selectedPetId,
      orElse: () => {'id': 'unknown', 'name': 'Unknown', 'type': 'Unknown', 'breed': 'N/A'}, // Fallback with breed
    );

    // Prepare booking details
    final Map<String, dynamic> bookingDetails = {
      'selectedPetId': _selectedPetId,
      'serviceType': selectedService.name, // Use service name from fetched data
      'selectedDate': _startDate?.toIso8601String(),
      'selectedEndDate': _endDate?.toIso8601String(),
      'selectedTime': _startTime?.format(context),
      'specialInstructions': _instructionsController.text.trim().isEmpty ? 'None' : _instructionsController.text.trim(), // FIX: Ensure 'None' if empty
      'totalPrice': _totalPrice,
      'pet': { // Pass the full pet map including breed
        'id': selectedPet['id'],
        'name': selectedPet['name'],
        'type': selectedPet['type'],
        'breed': selectedPet['breed'], // FIX: Include breed here
      },
      'procedures': [], // Assuming procedures are handled elsewhere or not used for now
    };

    context.push('/book/select-pet/${selectedService.name}/schedule/confirm', extra: bookingDetails);
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicators if either pets or services are loading
    if (_isLoadingPets || _isLoadingServices) {
      return Scaffold(
        appBar: AppBar(title: Text('Book a Service')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error if pet or service fetching failed
    if (_petFetchError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book a Service')),
        body: Center(child: Text('Error loading pets: $_petFetchError')),
      );
    }
    if (_serviceFetchError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book a Service')),
        body: Center(child: Text('Error loading services: $_serviceFetchError')),
      );
    }

    // If no pets are added
    if (_pets.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book a Service')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'You need to add a pet first!',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.push('/pets/add'),
                child: const Text('Add a Pet'),
              ),
            ],
          ),
        ),
      );
    }

    // If no services are added by admin
    if (_availableServices.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book a Service')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'No services available for booking yet. Please check back later!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              // Optionally provide a way for admin to add services, or just inform user
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Schedule a Service for Your Pet',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your pet, the service you need, and preferred dates/times.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onBackground.withAlpha((255 * 0.7).round()),
                    ),
              ),
              const SizedBox(height: 24),

              // Pet Selection
              Text(
                '1. Select Your Pet',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Choose Pet',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
                value: _selectedPetId,
                items: _pets
                    .map((pet) => DropdownMenuItem(
                          value: pet['id'] as String,
                          child: Text(
                            '${pet['name']} (${pet['type']})',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPetId = value;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a pet' : null,
              ),
              const SizedBox(height: 32),

              // Service Type Selection with Explanations (Dynamically generated)
              Text(
                '2. Choose a Service Type',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              // Dynamically build service cards
              ..._availableServices.map((service) {
                IconData serviceIcon;
                // Assign icons based on service name (you can expand this logic)
                switch (service.name) {
                  case 'Boarding':
                    serviceIcon = Icons.home;
                    break;
                  case 'Grooming':
                    serviceIcon = Icons.cut;
                    break;
                  case 'Vet Visit':
                    serviceIcon = Icons.local_hospital;
                    break;
                  case 'Paw and nail Care': // Added specific icon for 'Paw and nail Care'
                    serviceIcon = Icons.pets_outlined;
                    break;
                  default:
                    serviceIcon = Icons.miscellaneous_services; // Default icon
                }

                return _buildServiceTypeCard(
                  context,
                  service.name,
                  serviceIcon,
                  service.description,
                  service.id, // Pass service ID
                );
              }).toList(),
              const SizedBox(height: 32),

              // Date & Time Selection
              Text(
                '3. Select Date & Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _startDate == null
                      ? ''
                      : DateFormat('MMM d,yyyy').format(_startDate!),
                ),
                decoration: InputDecoration(
                  labelText: 'Start Date',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                  suffixIcon: _startDate != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _startDate = null;
                              _calculatePrice();
                            });
                          },
                        )
                      : null,
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
                onTap: () => _selectDate(context, true),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please select a start date' : null,
              ),
              const SizedBox(height: 16),

              // End Date (only for Boarding)
              if (_availableServices.any((s) => s.id == _selectedServiceTypeId && s.name == 'Boarding'))
                Column(
                  children: [
                    TextFormField(
                      readOnly: true,
                      controller: TextEditingController(
                        text: _endDate == null
                            ? ''
                            : DateFormat('MMM d,yyyy').format(_endDate!),
                      ),
                      decoration: InputDecoration(
                        labelText: 'End Date (for Boarding)',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
                        suffixIcon: _endDate != null
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _endDate = null;
                                    _calculatePrice();
                                  });
                                },
                              )
                            : null,
                        floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                        ),
                      ),
                      onTap: () => _selectDate(context, false),
                      validator: (value) {
                        final selectedService = _availableServices.firstWhere((s) => s.id == _selectedServiceTypeId);
                        if (selectedService.name == 'Boarding' && (value == null || value.isEmpty)) {
                          return 'Please select an end date for boarding';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),

              // Start Time
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: _startTime == null ? '' : _startTime!.format(context),
                ),
                decoration: InputDecoration(
                  labelText: 'Preferred Time (Optional)',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.access_time, color: Theme.of(context).colorScheme.primary),
                  suffixIcon: _startTime != null
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _startTime = null;
                            });
                          },
                        )
                      : null,
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
                onTap: () => _selectTime(context),
              ),
              const SizedBox(height: 16),

              // Special Instructions
              TextFormField(
                controller: _instructionsController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Special Instructions (e.g., allergies, preferences)',
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes, color: Theme.of(context).colorScheme.primary),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Display Total Price
              Align(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      'Estimated Total Price:',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                    ),
                    Text(
                      'KES ${_totalPrice.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Review and Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _navigateToConfirmation,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Review and Pay'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Service Type Cards
  Widget _buildServiceTypeCard(
      BuildContext context, String title, IconData icon, String description, String serviceId) {
    final bool isSelected = _selectedServiceTypeId == serviceId;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isSelected ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedServiceTypeId = serviceId;
            _calculatePrice();
            // Reset end date if service type changes from Boarding
            final selectedService = _availableServices.firstWhere((s) => s.id == serviceId);
            if (selectedService.name != 'Boarding') {
              _endDate = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.7).round())),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withAlpha((255 * 0.8).round()),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Price: KES ${_availableServices.firstWhere((s) => s.id == serviceId).price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
