/*
  This is the official booking page where you select the services:
    1. The UI needs to be refreshed and explain to the client what they are doing
    2. Touch on on the contrast of fonts.

*/ 



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';



// class BookServiceScreen extends StatefulWidget {
//   const BookServiceScreen({super.key});

//   @override
//   State<BookServiceScreen> createState() => _BookServiceScreenState();
// }

// class _BookServiceScreenState extends State<BookServiceScreen> {
//   final SupabaseClient _client = Supabase.instance.client;
//   final _formKey = GlobalKey<FormState>();

//   // Form fields
//   String? _selectedServiceType;
//   String? _selectedPetId;
//   DateTime? _startDate;
//   DateTime? _endDate; // Used for boarding
//   TimeOfDay? _startTime; // Used for services with specific times
//   final TextEditingController _instructionsController = TextEditingController();

//   // Data for dropdowns
//   List<Map<String, dynamic>> _pets = [];
//   bool _isLoadingPets = true;
//   String? _petFetchError;

//   // Price Calculation State
//   double _totalPrice = 0.0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchPets();
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
//       // print('Error fetching pets: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingPets = false;
//         });
//       }
//     }
//   }

//   void _calculatePrice() {
//     double calculatedPrice = 0.0;
//     if (_selectedServiceType == null) {
//       _totalPrice = 0.0;
//       return;
//     }

//     switch (_selectedServiceType) {
//       case 'Boarding':
//         if (_startDate != null && _endDate != null) {
//           final difference = _endDate!.difference(_startDate!).inDays;
//           // Add 1 to include both start and end day for pricing
//           calculatedPrice = (difference + 1) * 388.0; // KES 388 per day
//         }
//         break;
//       case 'Grooming':
//         calculatedPrice = 1000.0; // KES 1000 flat rate
//         break;
//       case 'Vet Visit':
//         calculatedPrice = 750.0; // KES 750 flat rate
//         break;
//       default:
//         calculatedPrice = 0.0;
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
//             _startDate ??= picked;
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
//     );
//     if (picked != null && mounted) {
//       setState(() {
//         _startTime = picked;
//       });
//     }
//   }

//   void _navigateToConfirmation() {
//   if (!_formKey.currentState!.validate()) {
//     return;
//   }

//   // Add null checks for dates
//   if (_startDate == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select a start date')),
//     );
//     return;
//   }

//   if (_selectedServiceType == 'Boarding' && _endDate == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select an end date for boarding')),
//     );
//     return;
//   }

//   if (_totalPrice <= 0) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please select a service and dates to calculate price.')),
//     );
//     return;
//   }

//   // Prepare booking details
//   final Map<String, dynamic> bookingDetails = {
//     'selectedPetId': _selectedPetId,
//     'serviceType': _selectedServiceType,
//     'startDate': _startDate?.toIso8601String(),
//     'endDate': _endDate?.toIso8601String(),
//     'startTime': _startTime?.format(context),
//     'specialInstructions': _instructionsController.text.trim(),
//     'totalPrice': _totalPrice,
//     'petName': _pets.firstWhere(
//       (pet) => pet['id'] == _selectedPetId,
//       orElse: () => {'name': 'Unknown', 'type': 'Unknown'},
//     )['name'],
//     'petType': _pets.firstWhere(
//       (pet) => pet['id'] == _selectedPetId,
//       orElse: () => {'name': 'Unknown', 'type': 'Unknown'},
//     )['type'],
//   };

//   // Navigate to confirmation screen
//   context.push('/booking_confirmation', extra: bookingDetails);
// }


//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Book a Service'),
//       ),
//       body: _isLoadingPets
//           ? const Center(child: CircularProgressIndicator())
//           : _petFetchError != null
//               ? Center(child: Text(_petFetchError!))
//               : _pets.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text('You need to add a pet first!'),
//                           const SizedBox(height: 16),
//                           ElevatedButton(
//                             onPressed: () => context.push('/pets/add'),
//                             child: const Text('Add a Pet'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : SingleChildScrollView(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Form(
//                         key: _formKey,
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Service Details',
//                               style: Theme.of(context).textTheme.headlineSmall,
//                             ),
//                             const SizedBox(height: 16),

//                             // Pet Selection
//                             DropdownButtonFormField<String>(
//                               decoration: const InputDecoration(
//                                 labelText: 'Select Your Pet',
//                                 border: OutlineInputBorder(),
//                                 prefixIcon: Icon(Icons.pets),
//                               ),
//                               value: _selectedPetId,
//                               items: _pets
//                                   .map((pet) => DropdownMenuItem(
//                                         value: pet['id'] as String,
//                                         child: Text('${pet['name']} (${pet['type']})'),
//                                       ))
//                                   .toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedPetId = value;
//                                 });
//                               },
//                               validator: (value) =>
//                                   value == null ? 'Please select a pet' : null,
//                             ),
//                             const SizedBox(height: 16),

//                             // Service Type Selection
//                             DropdownButtonFormField<String>(
//                               decoration: const InputDecoration(
//                                 labelText: 'Select Service Type',
//                                 border: OutlineInputBorder(),
//                                 prefixIcon: Icon(Icons.category),
//                               ),
//                               value: _selectedServiceType,
//                               items: const [
//                                 DropdownMenuItem(value: 'Boarding', child: Text('Boarding')),
//                                 DropdownMenuItem(value: 'Grooming', child: Text('Grooming')),
//                                 DropdownMenuItem(value: 'Vet Visit', child: Text('Vet Visit')),
//                               ],
//                               onChanged: (value) {
//                                 setState(() {
//                                   _selectedServiceType = value;
//                                   // Reset dates/times if service type changes, as they might be irrelevant
//                                   if (value != 'Boarding') {
//                                     _endDate = null;
//                                   }
//                                   // _startTime = null; // Maybe keep if all services can have a time
//                                   _calculatePrice(); // Recalculate when service type changes
//                                 });
//                               },
//                               validator: (value) =>
//                                   value == null ? 'Please select a service type' : null,
//                             ),
//                             const SizedBox(height: 16),

//                             // Start Date
//                             TextFormField(
//                               readOnly: true,
//                               controller: TextEditingController(
//                                 text: _startDate == null
//                                     ? ''
//                                     : DateFormat('MMM d, yyyy').format(_startDate!),
//                               ),
//                               decoration: InputDecoration(
//                                 labelText: 'Start Date',
//                                 border: const OutlineInputBorder(),
//                                 prefixIcon: const Icon(Icons.calendar_today),
//                                 suffixIcon: IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: () {
//                                     setState(() {
//                                       _startDate = null;
//                                       _calculatePrice();
//                                     });
//                                   },
//                                 ),
//                               ),
//                               onTap: () => _selectDate(context, true),
//                               validator: (value) =>
//                                   value == null || value.isEmpty ? 'Please select a start date' : null,
//                             ),
//                             const SizedBox(height: 16),

//                             // End Date (only for Boarding)
//                             if (_selectedServiceType == 'Boarding')
//                               Column(
//                                 children: [
//                                   TextFormField(
//                                     readOnly: true,
//                                     controller: TextEditingController(
//                                       text: _endDate == null
//                                           ? ''
//                                           : DateFormat('MMM d, yyyy').format(_endDate!),
//                                     ),
//                                     decoration: InputDecoration(
//                                       labelText: 'End Date (for Boarding)',
//                                       border: const OutlineInputBorder(),
//                                       prefixIcon: const Icon(Icons.calendar_today),
//                                       suffixIcon: IconButton(
//                                         icon: const Icon(Icons.clear),
//                                         onPressed: () {
//                                           setState(() {
//                                             _endDate = null;
//                                             _calculatePrice();
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     onTap: () => _selectDate(context, false),
//                                     validator: (value) {
//                                       if (_selectedServiceType == 'Boarding' &&
//                                           (value == null || value.isEmpty)) {
//                                         return 'Please select an end date for boarding';
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   const SizedBox(height: 16),
//                                 ],
//                               ),

//                             // Start Time
//                             TextFormField(
//                               readOnly: true,
//                               controller: TextEditingController(
//                                 text: _startTime == null ? '' : _startTime!.format(context),
//                               ),
//                               decoration: InputDecoration(
//                                 labelText: 'Preferred Time (Optional)',
//                                 border: const OutlineInputBorder(),
//                                 prefixIcon: const Icon(Icons.access_time),
//                                 suffixIcon: IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: () {
//                                     setState(() {
//                                       _startTime = null;
//                                     });
//                                   },
//                                 ),
//                               ),
//                               onTap: () => _selectTime(context),
//                             ),
//                             const SizedBox(height: 16),

//                             // Special Instructions
//                             TextFormField(
//                               controller: _instructionsController,
//                               maxLines: 3,
//                               decoration: const InputDecoration(
//                                 labelText: 'Special Instructions (e.g., allergies, preferences)',
//                                 border: OutlineInputBorder(),
//                                 alignLabelWithHint: true,
//                                 prefixIcon: Icon(Icons.notes),
//                               ),
//                             ),
//                             const SizedBox(height: 24),

//                             // Display Total Price
//                             Align(
//                               alignment: Alignment.center,
//                               child: Column(
//                                 children: [
//                                   Text(
//                                     'Total Price:',
//                                     style: Theme.of(context).textTheme.titleLarge,
//                                   ),
//                                   Text(
//                                     'KES ${_totalPrice.toStringAsFixed(2)}',
//                                     style: Theme.of(context).textTheme.displaySmall?.copyWith(
//                                           fontWeight: FontWeight.bold,
//                                           color: Theme.of(context).colorScheme.primary,
//                                         ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                             const SizedBox(height: 24),

//                             // Book Now and Pay Button
//                             // SizedBox(
//                             //   width: double.infinity,
//                             //   child: ElevatedButton.icon(
//                             //     onPressed: _bookAndPay,
//                             //     icon: const Icon(Icons.payment),
//                             //     label: const Text('Book Now and Pay'),
//                             //     style: ElevatedButton.styleFrom(
//                             //       padding: const EdgeInsets.symmetric(vertical: 16),
//                             //       backgroundColor: Theme.of(context).colorScheme.primary,
//                             //       foregroundColor: Colors.white,
//                             //       textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             //             fontWeight: FontWeight.bold,
//                             //           ),
//                             //       shape: RoundedRectangleBorder(
//                             //         borderRadius: BorderRadius.circular(12),
//                             //       ),
//                             //     ),
//                             //   ),
//                             // ),

//                           SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 onPressed: _navigateToConfirmation,
//                                 icon: const Icon(Icons.arrow_forward),
//                                 label: const Text('Review and Pay'),
//                                 style: ElevatedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 16),
//                                   backgroundColor: Theme.of(context).colorScheme.primary,
//                                   foregroundColor: Colors.white,
//                                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                 ),
//                               ),
//                             ),  
//                           ],
//                         ),
//                       ),
//                     ),
//     );
//   }
// }



// New code

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class BookServiceScreen extends StatefulWidget {
  const BookServiceScreen({super.key});

  @override
  State<BookServiceScreen> createState() => _BookServiceScreenState();
}

class _BookServiceScreenState extends State<BookServiceScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String? _selectedServiceType;
  String? _selectedPetId;
  DateTime? _startDate;
  DateTime? _endDate; // Used for boarding
  TimeOfDay? _startTime; // Used for services with specific times
  final TextEditingController _instructionsController = TextEditingController();

  // Data for dropdowns
  List<Map<String, dynamic>> _pets = [];
  bool _isLoadingPets = true;
  String? _petFetchError;

  // Price Calculation State
  double _totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchPets();
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
      final List<Map<String, dynamic>> data =
          await _client.from('pets').select('id, name, type').eq('owner_id', userId);
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
      print('Error fetching pets: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingPets = false;
        });
      }
    }
  }

  void _calculatePrice() {
    double calculatedPrice = 0.0;
    if (_selectedServiceType == null) {
      _totalPrice = 0.0;
      return;
    }

    switch (_selectedServiceType) {
      case 'Boarding':
        if (_startDate != null && _endDate != null) {
          final difference = _endDate!.difference(_startDate!).inDays;
          calculatedPrice = (difference + 1) * 388.0; // KES 388 per day
        }
        break;
      case 'Grooming':
        calculatedPrice = 1000.0; // KES 1000 flat rate
        break;
      case 'Vet Visit':
        calculatedPrice = 750.0; // KES 750 flat rate
        break;
      default:
        calculatedPrice = 0.0;
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

    if (_selectedServiceType == 'Boarding' && _endDate == null) {
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

    // Prepare booking details
    final Map<String, dynamic> bookingDetails = {
      'selectedPetId': _selectedPetId,
      'serviceType': _selectedServiceType,
      'selectedDate': _startDate?.toIso8601String(), // Renamed to selectedDate for consistency
      'selectedEndDate': _endDate?.toIso8601String(), // Renamed to selectedEndDate for consistency
      'selectedTime': _startTime?.format(context), // Renamed to selectedTime for consistency
      'specialInstructions': _instructionsController.text.trim(),
      'totalPrice': _totalPrice,
      // Pass pet details for receipt generation directly
      'pet': _pets.firstWhere(
        (pet) => pet['id'] == _selectedPetId,
        orElse: () => {'name': 'Unknown', 'type': 'Unknown'},
      ),
      // Assuming procedures are not selected here, but calculated/added later
      // If procedures are selected here, you'd add them to this map.
      // For now, the receipt service will show "No specific procedures listed."
      'procedures': [], // Initialize as empty list if not selected here
    };

    context.push('/booking_confirmation', extra: bookingDetails);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: _isLoadingPets
          ? const Center(child: CircularProgressIndicator())
          : _petFetchError != null
              ? Center(child: Text(_petFetchError!))
              : _pets.isEmpty
                  ? Center(
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
                    )
                  : SingleChildScrollView(
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
                                    color: Theme.of(context).colorScheme.onBackground, // Ensure good contrast
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Choose your pet, the service you need, and preferred dates/times.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7), // Softer text
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
                                          style: TextStyle(color: Theme.of(context).colorScheme.onSurface), // Ensure dropdown text color
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

                            // Service Type Selection with Explanations
                            Text(
                              '2. Choose a Service Type',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onBackground,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            _buildServiceTypeCard(
                              context,
                              'Boarding',
                              Icons.home,
                              'Overnight stay for your pet in a safe and caring environment.',
                              'Boarding',
                            ),
                            _buildServiceTypeCard(
                              context,
                              'Grooming',
                              Icons.cut,
                              'Professional bathing, hair trimming, and nail care.',
                              'Grooming',
                            ),
                            _buildServiceTypeCard(
                              context,
                              'Vet Visit',
                              Icons.local_hospital,
                              'Consultation with a veterinarian for health check-ups or concerns.',
                              'Vet Visit',
                            ),
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
                            if (_selectedServiceType == 'Boarding')
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
                                      if (_selectedServiceType == 'Boarding' &&
                                          (value == null || value.isEmpty)) {
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
      BuildContext context, String title, IconData icon, String description, String serviceValue) {
    final bool isSelected = _selectedServiceType == serviceValue;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: isSelected ? 8 : 2, // More elevation if selected
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // More rounded
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 3) // Highlight selected
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedServiceType = serviceValue;
            _calculatePrice();
            // Reset end date if service type changes from Boarding
            if (serviceValue != 'Boarding') {
              _endDate = null;
            }
          });
        },
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
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
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
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
