import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import provider to access PetProvider
import 'package:pawpal/providers/pet_provider.dart'; // Import your PetProvider

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({super.key});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageValueController = TextEditingController(); // Renamed for clarity
  final _notesController = TextEditingController();
  bool _vaccinated = false;

  String? _selectedAgeUnit = 'years'; // Default age unit

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _breedController.dispose();
    _ageValueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      _showSnackBar('User not logged in.', isError: true);
      return;
    }

    final int? ageValue = int.tryParse(_ageValueController.text);
    if (ageValue == null || ageValue < 0) {
      _showSnackBar('Please enter a valid age number.', isError: true);
      return;
    }
    if (_selectedAgeUnit == null) {
      _showSnackBar('Please select an age unit (e.g., years, months).', isError: true);
      return;
    }

    try {
      await Supabase.instance.client.from('pets').insert({
        'owner_id': userId,
        'name': _nameController.text.trim(),
        'type': _typeController.text.trim(),
        'breed': _breedController.text.trim(),
        'age_value': ageValue, // Store the numerical value
        'age_unit': _selectedAgeUnit, // Store the selected unit
        'vaccinated': _vaccinated,
        'notes': _notesController.text.trim(),
      });

      // Notify PetProvider to refresh data on Home Screen
      if (mounted) {
        Provider.of<PetProvider>(context, listen: false).fetchPets();
        _showSnackBar('Pet added successfully!');
        Navigator.pop(context); // Go back to previous screen (e.g., Home or Pets list)
      }
    } catch (e) {
      _showSnackBar('Failed to save pet: $e', isError: true);
      print('Error saving pet: $e'); // For debugging
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Pet'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Tell us about your furry friend!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onBackground,
                    ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "What's You're Pet Name?",
                  // hintText: 'e.g., Max, Bella',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge, color: Theme.of(context).colorScheme.primary),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Pet name is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _typeController,
                decoration: InputDecoration(
                  labelText: 'Type',
                  hintText: 'e.g., Dog, Cat, Bird',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.primary),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Pet type is required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _breedController,
                decoration: InputDecoration(
                  labelText: 'Breed (Optional)',
                  hintText: 'e.g., Golden Retriever, Siamese',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.pets, color: Theme.of(context).colorScheme.primary),
                  floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Age Input with Unit Selection ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.start, // Align label with input
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: _ageValueController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Age',
                        hintText: 'e.g., 3',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake, color: Theme.of(context).colorScheme.primary),
                        floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Age is required';
                        }
                        if (int.tryParse(value) == null || int.parse(value) < 0) {
                          return 'Enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Unit',
                        border: const OutlineInputBorder(),
                        floatingLabelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0),
                        ),
                      ),
                      value: _selectedAgeUnit,
                      items: const [
                        DropdownMenuItem(value: 'days', child: Text('Days')),
                        DropdownMenuItem(value: 'weeks', child: Text('Weeks')),
                        DropdownMenuItem(value: 'months', child: Text('Months')),
                        DropdownMenuItem(value: 'years', child: Text('Years')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAgeUnit = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Unit required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // --- End Age Input ---

              SwitchListTile(
                value: _vaccinated,
                onChanged: (val) => setState(() => _vaccinated = val),
                title: Text(
                  'Vaccinated',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                ),
                subtitle: Text(
                  'Is your pet up-to-date on vaccinations?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                ),
                activeColor: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Additional Notes (Optional)',
                  hintText: 'e.g., specific diet, behavioral quirks',
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

              ElevatedButton(
                onPressed: _savePet,
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
                child: const Text('Save Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
