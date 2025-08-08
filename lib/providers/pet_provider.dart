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
  int get totalPets => _pets.length; // Getter for total number of pets

  PetProvider() {
    fetchPets(); // Fetch pets when the provider is initialized
  }

  Future<void> fetchPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notify listeners that loading has started

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        _errorMessage = 'User not logged in.';
        _pets = []; // Clear pets if no user
        _isLoading = false;
        notifyListeners();
        return;
      }

      final List<Map<String, dynamic>> data =
          await _client.from('pets').select('id, name, type, breed').eq('owner_id', userId);

      _pets = data;
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Failed to load pets: $e';
      _pets = [];
      _isLoading = false;
      debugPrint('Error fetching pets in PetProvider: $e');
    } finally {
      notifyListeners(); // Notify listeners regardless of success or failure
    }
  }

  // You can add methods here for adding/updating/deleting pets
  // and then call fetchPets() or manually update _pets list and notifyListeners()
  // For simplicity, we'll just call fetchPets() after external changes for now.
}
