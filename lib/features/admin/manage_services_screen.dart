// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// // Define a simple Service model
// class Service {
//   final String id;
//   final String name;
//   final String description;
//   final double price;
//   final int durationMinutes; // For Boarding, this will represent 'days'

//   Service({
//     required this.id,
//     required this.name,
//     required this.description,
//     required this.price,
//     required this.durationMinutes,
//   });

//   // Factory constructor for creating a Service from a Supabase row (Map)
//   factory Service.fromMap(Map<String, dynamic> data) {
//     return Service(
//       id: data['id'] as String,
//       name: data['name'] as String,
//       description: data['description'] as String,
//       price: (data['price'] as num).toDouble(),
//       durationMinutes: data['duration_minutes'] as int,
//     );
//   }

//   // Method to convert a Service to a Map for Supabase insertion/update
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'price': price,
//       'duration_minutes': durationMinutes,
//     };
//   }
// }

// class ManageServicesScreen extends StatefulWidget {
//   const ManageServicesScreen({super.key});

//   @override
//   State<ManageServicesScreen> createState() => _ManageServicesScreenState();
// }

// class _ManageServicesScreenState extends State<ManageServicesScreen> {
//   final SupabaseClient supabase = Supabase.instance.client;
//   List<Service> _services = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchServices();
//   }

//   Future<void> _fetchServices() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });
//     try {
//       final response = await supabase.from('services').select().order('name', ascending: true);

//       _services = response.map((json) => Service.fromMap(json)).toList();
//     } on PostgrestException catch (e) {
//       _errorMessage = 'Error fetching services: ${e.message}';
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

//   Future<void> _addService(Service service) async {
//     try {
//       await supabase.from('services').insert(service.toMap());
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Service added successfully!')),
//         );
//       }
//       _fetchServices(); // Refresh the list
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error adding service: ${e.message}')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An unexpected error occurred: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _updateService(Service service) async {
//     try {
//       await supabase.from('services').update(service.toMap()).eq('id', service.id);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Service updated successfully!')),
//         );
//       }
//       _fetchServices(); // Refresh the list
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating service: ${e.message}')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An unexpected error occurred: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _deleteService(String serviceId) async {
//     final bool confirmDelete = await showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Confirm Deletion'),
//             content: const Text('Are you sure you want to delete this service?'),
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
//       await supabase.from('services').delete().eq('id', serviceId);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Service deleted successfully!')),
//         );
//       }
//       _fetchServices(); // Refresh the list
//     } on PostgrestException catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error deleting service: ${e.message}')),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('An unexpected error occurred: $e')),
//         );
//       }
//     }
//   }

//   void _showServiceForm({Service? service}) {
//     final isEditing = service != null;
//     final TextEditingController nameController = TextEditingController(text: service?.name ?? '');
//     final TextEditingController descriptionController = TextEditingController(text: service?.description ?? '');
//     final TextEditingController priceController = TextEditingController(text: service?.price.toString() ?? '');
//     final TextEditingController durationController = TextEditingController(text: service?.durationMinutes.toString() ?? '');

//     // NEW: Reactive value for duration label
//     ValueNotifier<String> durationLabel = ValueNotifier<String>('Duration (minutes)');

//     // Initial label setup
//     if (nameController.text.toLowerCase().contains('boarding')) {
//       durationLabel.value = 'Duration (days)';
//     }

//     // Listener for name changes to update duration label
//     nameController.addListener(() {
//       if (nameController.text.toLowerCase().contains('boarding')) {
//         durationLabel.value = 'Duration (days)';
//       } else {
//         durationLabel.value = 'Duration (minutes)';
//       }
//     });

//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: nameController,
//                   decoration: const InputDecoration(labelText: 'Service Name'),
//                 ),
//                 TextField(
//                   controller: descriptionController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                 ),
//                 TextField(
//                   controller: priceController,
//                   decoration: const InputDecoration(labelText: 'Price'),
//                   keyboardType: TextInputType.number,
//                 ),
//                 // NEW: Use ValueListenableBuilder to dynamically update label
//                 ValueListenableBuilder<String>(
//                   valueListenable: durationLabel,
//                   builder: (context, currentLabel, child) {
//                     return TextField(
//                       controller: durationController,
//                       decoration: InputDecoration(labelText: currentLabel), // Dynamic label
//                       keyboardType: TextInputType.number,
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 final String name = nameController.text.trim();
//                 final String description = descriptionController.text.trim();
//                 final double? price = double.tryParse(priceController.text.trim());
//                 final int? duration = int.tryParse(durationController.text.trim());

//                 if (name.isEmpty || description.isEmpty || price == null || duration == null) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(content: Text('Please fill all fields with valid data.')),
//                   );
//                   return;
//                 }

//                 if (isEditing) {
//                   await _updateService(Service(
//                     id: service!.id,
//                     name: name,
//                     description: description,
//                     price: price,
//                     durationMinutes: duration,
//                   ));
//                 } else {
//                   // For new services, generate a UUID for the ID
//                   await _addService(Service(
//                     id: UniqueKey().toString(), // Use a unique key for ID
//                     name: name,
//                     description: description,
//                     price: price,
//                     durationMinutes: duration,
//                   ));
//                 }
//                 if (mounted) Navigator.of(context).pop();
//               },
//               child: Text(isEditing ? 'Update' : 'Add'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manage Services'),
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
//                           onPressed: _fetchServices,
//                           icon: const Icon(Icons.refresh),
//                           label: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 )
//               : _services.isEmpty
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.cleaning_services, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
//                           const SizedBox(height: 20),
//                           Text(
//                             'No services added yet.',
//                             style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                   color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
//                                 ),
//                           ),
//                           const SizedBox(height: 20),
//                           ElevatedButton.icon(
//                             onPressed: () => _showServiceForm(),
//                             icon: const Icon(Icons.add),
//                             label: const Text('Add New Service'),
//                           ),
//                         ],
//                       ),
//                     )
//                   : Padding(
//                       padding: EdgeInsets.all(isDesktop ? 20 : 16),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'All Services',
//                             style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                   color: Theme.of(context).colorScheme.onSurface,
//                                 ),
//                           ),
//                           const SizedBox(height: 16),
//                           Expanded(
//                             child: ListView.builder(
//                               itemCount: _services.length,
//                               itemBuilder: (context, index) {
//                                 final service = _services[index];
//                                 return Card(
//                                   margin: const EdgeInsets.symmetric(vertical: 6), // Reduced vertical margin
//                                   elevation: 3, // Slightly less elevation for a flatter look
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly less rounded corners
//                                   child: Padding(
//                                     padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced padding
//                                     child: Row(
//                                       children: [
//                                         // Service Icon
//                                         Icon(
//                                           Icons.miscellaneous_services, // Generic service icon
//                                           size: 30, // Smaller icon
//                                           color: Theme.of(context).colorScheme.primary,
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 service.name,
//                                                 style: Theme.of(context).textTheme.titleMedium?.copyWith( // Smaller title
//                                                       fontWeight: FontWeight.bold,
//                                                       color: Theme.of(context).colorScheme.onSurface,
//                                                     ),
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               Text(
//                                                 service.description,
//                                                 style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller description
//                                                       color: Theme.of(context).colorScheme.onSurfaceVariant,
//                                                     ),
//                                                 maxLines: 2,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               const SizedBox(height: 6),
//                                               Row(
//                                                 children: [
//                                                   Icon(Icons.attach_money, size: 16, color: Colors.green[700]), // Smaller icon
//                                                   Text(
//                                                     'KES ${service.price.toStringAsFixed(2)}',
//                                                     style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
//                                                           fontWeight: FontWeight.bold,
//                                                           color: Colors.green[700],
//                                                         ),
//                                                   ),
//                                                   const SizedBox(width: 12), // Reduced spacing
//                                                   Icon(Icons.timer, size: 16, color: Theme.of(context).colorScheme.secondary), // Smaller icon
//                                                   Text(
//                                                     '${service.durationMinutes} ${service.name.toLowerCase().contains('boarding') ? 'days' : 'mins'}', // Dynamic unit
//                                                     style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
//                                                           fontWeight: FontWeight.bold,
//                                                           color: Theme.of(context).colorScheme.secondary,
//                                                         ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ),
//                                         Column(
//                                           mainAxisAlignment: MainAxisAlignment.center, // Center icons vertically
//                                           children: [
//                                             IconButton(
//                                               icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 22), // Smaller icon
//                                               onPressed: () => _showServiceForm(service: service),
//                                               tooltip: 'Edit Service',
//                                             ),
//                                             IconButton(
//                                               icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 22), // Smaller icon
//                                               onPressed: () => _deleteService(service.id),
//                                               tooltip: 'Delete Service',
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () => _showServiceForm(),
//         icon: const Icon(Icons.add),
//         label: const Text('Add Service'),
//         backgroundColor: Theme.of(context).colorScheme.secondary,
//         foregroundColor: Theme.of(context).colorScheme.onSecondary,
//       ),
//     );
//   }
// }





import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pawpal/services/pdf_receipt_service.dart' as pdf_service; // Import the aliased PDF service

// Define a simple Service model
class Service {
  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
  });

  // Factory constructor for creating a Service from a Supabase row (Map)
  factory Service.fromMap(Map<String, dynamic> data) {
    return Service(
      id: data['id'] as String,
      name: data['name'] as String,
      description: data['description'] as String,
      price: (data['price'] as num).toDouble(),
      durationMinutes: data['duration_minutes'] as int,
    );
  }

  // Method to convert a Service to a Map for Supabase insertion/update
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
    };
  }
}

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Service> _services = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Filter state variables for services (if you want to add filters later)
  // For now, _services will just hold all fetched services.
  // If filters are implemented, this list would be the *filtered* list.

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      
      final response = await supabase.from('services').select().order('name', ascending: true);

      _services = response.map((json) => Service.fromMap(json)).toList();
    } on PostgrestException catch (e) {
      _errorMessage = 'Error fetching services: ${e.message}';
      debugPrint(_errorMessage);
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      debugPrint(_errorMessage);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addService(Service service) async {
    try {
      
      await supabase.from('services').insert(service.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully!')),
        );
      }
      _fetchServices(); 
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding service: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _updateService(Service service) async {
    try {
      // Replace 'services' with your actual Supabase table name and 'id' column
      await supabase.from('services').update(service.toMap()).eq('id', service.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service updated successfully!')),
        );
      }
      _fetchServices(); // Refresh the list
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating service: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  Future<void> _deleteService(String serviceId) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this service?'),
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
      // Replace 'services' with your actual Supabase table name and 'id' column
      await supabase.from('services').delete().eq('id', serviceId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service deleted successfully!')),
        );
      }
      _fetchServices(); // Refresh the list
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting service: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
    }
  }

  void _showServiceForm({Service? service}) {
    final isEditing = service != null;
    final TextEditingController nameController = TextEditingController(text: service?.name ?? '');
    final TextEditingController descriptionController = TextEditingController(text: service?.description ?? '');
    final TextEditingController priceController = TextEditingController(text: service?.price.toString() ?? '');
    final TextEditingController durationController = TextEditingController(text: service?.durationMinutes.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Service Name'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: durationController,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final String name = nameController.text.trim();
                final String description = descriptionController.text.trim();
                final double? price = double.tryParse(priceController.text.trim());
                final int? duration = int.tryParse(durationController.text.trim());

                if (name.isEmpty || description.isEmpty || price == null || duration == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields with valid data.')),
                  );
                  return;
                }

                if (isEditing) {
                  await _updateService(Service(
                    id: service!.id,
                    name: name,
                    description: description,
                    price: price,
                    durationMinutes: duration,
                  ));
                } else {
                  // For new services, generate a UUID for the ID
                  await _addService(Service(
                    id: UniqueKey().toString(), // Use a unique key for ID
                    name: name,
                    description: description,
                    price: price,
                    durationMinutes: duration,
                  ));
                }
                if (mounted) Navigator.of(context).pop();
              },
              child: Text(isEditing ? 'Update' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  // NEW: Method to export current services list to PDF
  void _exportServicesToPdf() async {
    if (_services.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No services to export!')),
      );
      return;
    }
    try {
      // Call the new service report generation function
      await pdf_service.generateAndHandleServiceReport(_services);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service report generated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate service report: $e')),
        );
      }
      debugPrint('Error generating service report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/admin_dashboard'); // Navigate back to the admin dashboard
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf), // PDF icon
            onPressed: _exportServicesToPdf,
            tooltip: 'Export to PDF',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchServices,
            tooltip: 'Refresh Services',
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
                          onPressed: _fetchServices,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _services.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cleaning_services, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
                          const SizedBox(height: 20),
                          Text(
                            'No services added yet.',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
                                ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => _showServiceForm(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add New Service'),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.all(isDesktop ? 20 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Services',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _services.length,
                              itemBuilder: (context, index) {
                                final service = _services[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(vertical: 6), // Reduced vertical margin
                                  elevation: 3, // Slightly less elevation for a flatter look
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Slightly less rounded corners
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), // Reduced padding
                                    child: Row(
                                      children: [
                                        // Service Icon
                                        Icon(
                                          Icons.miscellaneous_services, // Generic service icon
                                          size: 30, // Smaller icon
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.name,
                                                style: Theme.of(context).textTheme.titleMedium?.copyWith( // Smaller title
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.onSurface,
                                                    ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                service.description,
                                                style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller description
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  Icon(Icons.attach_money, size: 16, color: Colors.green[700]), // Smaller icon
                                                  Text(
                                                    'KES ${service.price.toStringAsFixed(2)}',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.green[700],
                                                        ),
                                                  ),
                                                  const SizedBox(width: 12), // Reduced spacing
                                                  Icon(Icons.timer, size: 16, color: Theme.of(context).colorScheme.secondary), // Smaller icon
                                                  Text(
                                                    '${service.durationMinutes} mins',
                                                    style: Theme.of(context).textTheme.bodySmall?.copyWith( // Smaller text
                                                          fontWeight: FontWeight.bold,
                                                          color: Theme.of(context).colorScheme.secondary,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center, // Center icons vertically
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary, size: 22), // Smaller icon
                                              onPressed: () => _showServiceForm(service: service),
                                              tooltip: 'Edit Service',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 22), // Smaller icon
                                              onPressed: () => _deleteService(service.id),
                                              tooltip: 'Delete Service',
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showServiceForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add Service'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.onSecondary,
      ),
    );
  }
}
