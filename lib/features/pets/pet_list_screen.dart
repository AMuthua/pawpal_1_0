import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetListScreen extends StatefulWidget {
  const PetListScreen({super.key});

  @override
  State<PetListScreen> createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  late final SupabaseClient _client;

  @override
  void initState() {
    super.initState();
    _client = Supabase.instance.client;
  }

  Future<List<Map<String, dynamic>>> _fetchPets() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final response = await _client
        .from('pets')
        .select()
        .eq('owner_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/pets/add'),
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchPets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final pets = snapshot.data ?? [];

          if (pets.isEmpty) {
            return const Center(child: Text('No pets added yet.'));
          }

          return ListView.builder(
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: const Icon(Icons.pets),
                title: Text(pet['name'] ?? 'Unnamed'),
                subtitle: Text('${pet['type'] ?? 'Type'} - ${pet['breed'] ?? 'Breed'}'),
                trailing: pet['vaccinated'] == true
                    ? const Icon(Icons.verified, color: Colors.green)
                    : const Icon(Icons.warning, color: Colors.redAccent),
              );
            },
          );
        },
      ),
    );
  }
}
