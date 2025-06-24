import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SelectPetForBookingScreen extends StatefulWidget {
  final String serviceType; // We'll pass the selected service type here

  const SelectPetForBookingScreen({super.key, required this.serviceType});

  @override
  State<SelectPetForBookingScreen> createState() => _SelectPetForBookingScreenState();
}

class _SelectPetForBookingScreenState extends State<SelectPetForBookingScreen> {
  late final SupabaseClient _client;
  List<Map<String, dynamic>> _pets = [];
  bool _loading = true;
  String? _selectedPetId; // Stores the ID of the selected pet

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
    _loadPets();
  }

  Future<void> _loadPets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() => _loading = false);
      }
      return;
    }

    setState(() => _loading = true);

    try {
      final response = await _client
          .from('pets')
          .select()
          .eq('owner_id', userId)
          .order('name', ascending: true); // Order by name for better UX

      if (mounted) {
        setState(() {
          _pets = List<Map<String, dynamic>>.from(response);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
      // Handle error, e.g., show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading pets: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Pet for ${widget.serviceType}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _pets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No pets found. Please add a pet first.'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/pets/add'),
                        child: const Text('Add a Pet'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _pets.length,
                        itemBuilder: (context, index) {
                          final pet = _pets[index];
                          final petId = pet['id'] as String;
                          final petName = pet['name'] as String? ?? 'Unnamed Pet';
                          final petType = pet['type'] as String? ?? 'Unknown Type';
                          final petBreed = pet['breed'] as String? ?? 'Unknown Breed';

                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: RadioListTile<String>(
                              title: Text(petName),
                              subtitle: Text('$petType - $petBreed'),
                              value: petId,
                              groupValue: _selectedPetId,
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedPetId = value;
                                });
                              },
                              secondary: CircleAvatar(
                                // You can display pet image here if available in your data
                                child: Text(petName[0]), // First letter of pet name
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _selectedPetId == null
                            ? null // Disable button if no pet is selected
                            : () {
                                // Pass both serviceType and selectedPetId to the next screen
                                context.push(
                                  '/book/select-pet/${widget.serviceType}/schedule',
                                  extra: {
                                    'selectedPetId': _selectedPetId!,
                                  },
                                );
                              }, // <--- This is the part that changed
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50), // Make button wide
                        ),
                        child: const Text('Continue to Schedule'),
                      ),
                    ),
                  ],
                ),
    );
  }
}