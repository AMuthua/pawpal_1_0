// lib/providers/pet_provider.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PetProvider extends ChangeNotifier {
  final SupabaseClient _client = Supabase.instance.client;

  List<Map<String, dynamic>> _pets = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalPets => _pets.length; // Convenience getter

  PetProvider() {
    fetchPets(); // Fetch pets when the provider is created
  }

  Future<void> fetchPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not logged in.';
        _pets = []; // Clear pets if user is not logged in
        return;
      }
      final List<Map<String, dynamic>> data =
          await _client.from('pets').select('id, name, type').eq('owner_id', userId);
      
      _pets = data;
    } catch (e) {
      _errorMessage = 'Failed to load pets: $e';
      _pets = []; // Clear pets on error
      print('Error fetching pets in PetProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Notify listeners that loading has finished
    }
  }

  // You can add methods here for adding, updating, deleting pets
  // Example:
  // Future<void> addPet(Map<String, dynamic> newPetData) async {
  //   try {
  //     // ... Supabase insert logic ...
  //     await fetchPets(); // Refresh the list after adding
  //   } catch (e) {
  //     // Handle error
  //   }
  // }
}
