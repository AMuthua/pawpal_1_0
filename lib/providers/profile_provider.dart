// TODO Implement this library.

    import 'package:flutter/material.dart';
    import 'package:supabase_flutter/supabase_flutter.dart';

    class ProfileProvider extends ChangeNotifier {
      final SupabaseClient _client = Supabase.instance.client;
      Map<String, dynamic>? _userProfile;
      String? _userRole;
      bool _isLoading = false;
      String? _errorMessage;

      Map<String, dynamic>? get userProfile => _userProfile;
      String? get userRole => _userRole;
      bool get isLoading => _isLoading;
      String? get errorMessage => _errorMessage;

      ProfileProvider() {
        // Listen for auth state changes to automatically fetch profile
        _client.auth.onAuthStateChange.listen((data) {
          final AuthChangeEvent event = data.event;
          if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.initialSession) {
            fetchUserProfile();
          } else if (event == AuthChangeEvent.signedOut) {
            _userProfile = null;
            _userRole = null;
            notifyListeners();
          }
        });
      }

      Future<void> fetchUserProfile() async {
        if (_isLoading) return;
        _isLoading = true;
        _errorMessage = null;
        notifyListeners();

        try {
          final user = _client.auth.currentUser;
          if (user == null) {
            _userProfile = null;
            _userRole = null;
            return;
          }

          final response = await _client
              .from('profiles') // Ensure this matches your Supabase table name
              .select('*') // Select all profile fields
              .eq('id', user.id)
              .single();

          _userProfile = response;
          _userRole = response['role'] as String? ?? 'user'; // Default to 'user'
        } catch (e) {
          _errorMessage = 'Failed to fetch profile: $e';
          print('Error fetching user profile in ProfileProvider: $e');
          _userProfile = null;
          _userRole = null;
        } finally {
          _isLoading = false;
          notifyListeners();
        }
      }
    }
    