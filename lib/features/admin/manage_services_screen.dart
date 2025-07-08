// TODO Implement this library.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Replace 'services' with your actual Supabase table name
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
      // Replace 'services' with your actual Supabase table name
      await supabase.from('services').insert(service.toMap());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service added successfully!')),
        );
      }
      _fetchServices(); // Refresh the list
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
                  await _addService(Service(
                    id: DateTime.now().millisecondsSinceEpoch.toString(), // Simple unique ID for example
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
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                service.name,
                                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                service.description,
                                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                                    ),
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Icon(Icons.attach_money, size: 18, color: Colors.green[700]),
                                                  Text(
                                                    'KES ${service.price.toStringAsFixed(2)}',
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.green[700],
                                                        ),
                                                  ),
                                                  const SizedBox(width: 20),
                                                  Icon(Icons.timer, size: 18, color: Theme.of(context).colorScheme.secondary),
                                                  Text(
                                                    '${service.durationMinutes} mins',
                                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                              onPressed: () => _showServiceForm(service: service),
                                              tooltip: 'Edit Service',
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
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
