// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart'; // Import provider to access PetProvider
// import 'package:pawpal/providers/pet_provider.dart'; // Import your PetProvider

// class AddPetScreen extends StatefulWidget {
//   const AddPetScreen({super.key});

//   @override
//   State<AddPetScreen> createState() => _AddPetScreenState();
// }

// class _AddPetScreenState extends State<AddPetScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _typeController = TextEditingController();
//   final _breedController = TextEditingController();
//   final _ageValueController = TextEditingController(); // Renamed for clarity
//   final _notesController = TextEditingController();
//   bool _vaccinated = false;

//   String? _selectedAgeUnit = 'years'; // Default age unit

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _typeController.dispose();
//     _breedController.dispose();
//     _ageValueController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   Future<void> _savePet() async {
//     if (!_formKey.currentState!.validate()) return;

//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) {
//       _showSnackBar('User not logged in.', isError: true);
//       return;
//     }

//     final int? ageValue = int.tryParse(_ageValueController.text);
//     if (ageValue == null || ageValue < 0) {
//       _showSnackBar('Please enter a valid age number.', isError: true);
//       return;
//     }
//     if (_selectedAgeUnit == null) {
//       _showSnackBar('Please select an age unit (e.g., years, months).', isError: true);
//       return;
//     }

//     try {
//       await Supabase.instance.client.from('pets').insert({
//         'owner_id': userId,
//         'name': _nameController.text.trim(),
//         'type': _typeController.text.trim(),
//         'breed': _breedController.text.trim(),
//         'age_value': ageValue, // Store the numerical value
//         'age_unit': _selectedAgeUnit, // Store the selected unit
//         'vaccinated': _vaccinated,
//         'notes': _notesController.text.trim(),
//       });

//       // Notify PetProvider to refresh data on Home Screen
//       if (mounted) {
//         Provider.of<PetProvider>(context, listen: false).fetchPets();
//         _showSnackBar('Pet added successfully!');
//         Navigator.pop(context); // Go back to previous screen (e.g., Home or Pets list)
//       }
//     } catch (e) {
//       _showSnackBar('Failed to save pet: $e', isError: true);
//       print('Error saving pet: $e'); // For debugging
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Pet'),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//         foregroundColor: Theme.of(context).colorScheme.onPrimary,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             children: [
//               Text(
//                 'Tell us about your furry friend!',
//                 style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                       fontWeight: FontWeight.bold,
//                       color: Theme.of(context).colorScheme.onSurface,
//                     ),
//               ),
//               const SizedBox(height: 24),

//               TextFormField(
//                 controller: _nameController,
//                 decoration: InputDecoration(
//                   labelText: "What's You're Pet Name?",
//                   // hintText: 'e.g., Max, Bella',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.badge, color: Theme.of(context).colorScheme.primary),
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Pet name is required' : null,
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: _typeController,
//                 decoration: InputDecoration(
//                   labelText: 'Type',
//                   hintText: 'e.g., Dog, Cat, Bird',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//                 validator: (value) =>
//                     value == null || value.isEmpty ? 'Pet type is required' : null,
//               ),
//               const SizedBox(height: 16),

//               TextFormField(
//                 controller: _breedController,
//                 decoration: InputDecoration(
//                   labelText: 'Breed (Optional)',
//                   hintText: 'e.g., Golden Retriever, Siamese',
//                   border: const OutlineInputBorder(),
//                   prefixIcon: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
//                   floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                   focusedBorder: OutlineInputBorder(
//                     borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               // --- Age Input with Unit Selection ---
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start, // Align label with input
//                 children: [
//                   Expanded(
//                     flex: 3,
//                     child: TextFormField(
//                       controller: _ageValueController,
//                       keyboardType: TextInputType.number,
//                       decoration: InputDecoration(
//                         labelText: 'Age',
//                         hintText: 'e.g., 3',
//                         border: const OutlineInputBorder(),
//                         prefixIcon: Icon(Icons.cake, color: Theme.of(context).colorScheme.primary),
//                         floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                         ),
//                       ),
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Age is required';
//                         }
//                         if (int.tryParse(value) == null || int.parse(value) < 0) {
//                           return 'Enter a valid number';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     flex: 2,
//                     child: DropdownButtonFormField<String>(
//                       decoration: InputDecoration(
//                         labelText: 'Unit',
//                         border: const OutlineInputBorder(),
//                         floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
//                         focusedBorder: OutlineInputBorder(
//                           borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
//                         ),
//                       ),
//                       value: _selectedAgeUnit,
//                       items: const [
//                         DropdownMenuItem(value: 'days', child: Text('Days')),
//                         DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
//                         DropdownMenuItem(value: 'months', child: Text('Months')),
//                         DropdownMenuItem(value: 'years', child: Text('Years')),
//                       ],
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedAgeUnit = value;
//                         });
//                       },
//                       validator: (value) =>
//                           value == null ? 'Unit required' : null,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               // --- End Age Input ---

//               SwitchListTile(
//                 value: _vaccinated,
//                 onChanged: (val) => setState(() => _vaccinated = val),
//                 title: Text(
//                   'Vaccinated',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurface,
//                       ),
//                 ),
//                 subtitle: Text(
//                   'Is your pet up-to-date on vaccinations?',
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
//                       ),
//                 ),
//                 activeColor: Theme.of(context).colorScheme.primary,
//               ),
//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _notesController,
//                 maxLines: 3,
//                 decoration: InputDecoration(
//                   labelText: 'Additional Notes (Optional)',
//                   hintText: 'e.g., specific diet, behavioral quirks',
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

//               ElevatedButton(
//                 onPressed: _savePet,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   backgroundColor: Theme.of(context).colorScheme.primary,
//                   foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                   textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 child: const Text('Save Pet'),
//               ),
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
import 'package:provider/provider.dart'; // Import provider
import 'package:pawpal/providers/pet_provider.dart'; // NEW: Import PetProvider

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final SupabaseClient _client = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  String? _selectedType;
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  List<Map<String, dynamic>> _pets = [];
  bool _isLoadingPets = true;
  String? _petFetchError;

  @override
  void initState() {
    super.initState();
    _fetchPets();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _notesController.dispose();
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
          await _client.from('pets').select().eq('owner_id', userId);
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

  Future<void> _addPet() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to add a pet.')),
        );
        context.go('/login');
      }
      return;
    }

    try {
      await _client.from('pets').insert({
        'owner_id': userId,
        'name': _nameController.text.trim(),
        'type': _selectedType,
        'breed': _breedController.text.trim(),
        'notes': _notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet added successfully!')),
        );
        _nameController.clear();
        _breedController.clear();
        _notesController.clear();
        setState(() {
          _selectedType = null;
        });
        _fetchPets(); // Refresh the list of pets on this screen

        // NEW: Notify PetProvider to refresh its data
        Provider.of<PetProvider>(context, listen: false).fetchPets();
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add pet: ${e.message}')),
        );
      }
      debugPrint('Error adding pet: ${e.message}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
      debugPrint('Unexpected error adding pet: $e');
    }
  }

  Future<void> _deletePet(String petId) async {
    final bool confirmDelete = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: const Text('Are you sure you want to delete this pet? This action cannot be undone.'),
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
      await _client.from('pets').delete().eq('id', petId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet deleted successfully!')),
        );
        _fetchPets(); // Refresh the list of pets on this screen

        // NEW: Notify PetProvider to refresh its data
        Provider.of<PetProvider>(context, listen: false).fetchPets();
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete pet: ${e.message}')),
        );
      }
      debugPrint('Error deleting pet: ${e.message}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred: $e')),
        );
      }
      debugPrint('Unexpected error deleting pet: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add a New Pet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Pet Name',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
                      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please enter pet name' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Pet Type',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                    ),
                    value: _selectedType,
                    items: const [
                      DropdownMenuItem(value: 'Dog', child: Text('Dog')),
                      DropdownMenuItem(value: 'Cat', child: Text('Cat')),
                      DropdownMenuItem(value: 'Bird', child: Text('Bird')),
                      DropdownMenuItem(value: 'Rabbit', child: Text('Rabbit')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Please select pet type' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _breedController,
                    decoration: InputDecoration(
                      labelText: 'Breed (Optional)',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(Icons.pets_sharp, color: Theme.of(context).colorScheme.primary),
                      floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Notes (e.g., allergies, temperament)',
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addPet,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Pet'),
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
            const SizedBox(height: 32),
            Text(
              'My Registered Pets',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 16),
            _isLoadingPets
                ? const Center(child: CircularProgressIndicator())
                : _petFetchError != null
                    ? Center(child: Text('Error: $_petFetchError'))
                    : _pets.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                Icon(Icons.pets_outlined, size: 60, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
                                const SizedBox(height: 10),
                                Text(
                                  'No pets added yet.',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
                                      ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _pets.length,
                            itemBuilder: (context, index) {
                              final pet = _pets[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                                    child: Icon(Icons.pets, color: Theme.of(context).colorScheme.secondary),
                                  ),
                                  title: Text(
                                    pet['name'] as String,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Type: ${pet['type'] as String} - Breed: ${pet['breed'] as String? ?? 'N/A'}',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                                        onPressed: () {
                                          context.go('/pets/${pet['id']}');
                                        },
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                        onPressed: () => _deletePet(pet['id']),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ],
        ),
      ),
    );
  }
}
