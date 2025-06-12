import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();
  bool _vaccinated = false;

  Future<void> _savePet() async {
    if (!_formKey.currentState!.validate()) return;
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    await Supabase.instance.client.from('pets').insert({
      'owner_id': userId,
      'name': _nameController.text,
      'type': _typeController.text,
      'breed': _breedController.text,
      'age': int.tryParse(_ageController.text) ?? 0,
      'vaccinated': _vaccinated,
      'notes': _notesController.text,
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Pet')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Pet Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _typeController,
                decoration: const InputDecoration(labelText: 'Type (e.g. Dog)'),
              ),
              TextFormField(
                controller: _breedController,
                decoration: const InputDecoration(labelText: 'Breed'),
              ),
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              SwitchListTile(
                value: _vaccinated,
                onChanged: (val) => setState(() => _vaccinated = val),
                title: const Text('Vaccinated'),
              ),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePet,
                child: const Text('Save Pet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
