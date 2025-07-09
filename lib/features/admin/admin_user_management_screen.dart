import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminUserManagementScreen extends StatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  State<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _userProfiles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllUserProfiles();
  }

  Future<void> _fetchAllUserProfiles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // Fetch all profiles, including id, display_name, email, role, and phone_number
      final List<Map<String, dynamic>> data = await supabase
          .from('profiles')
          .select('id, display_name, email, role, phone_number')
          .order('created_at', ascending: false); // Order by most recent users first

      _userProfiles = data;
    } on PostgrestException catch (e) {
      _errorMessage = 'Error fetching user profiles: ${e.message}';
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

  Future<void> _updateUserProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await supabase.from('profiles').update(updates).eq('id', userId);
      if (mounted) {
        _showSnackBar('User profile updated successfully!');
      }
      _fetchAllUserProfiles(); // Refresh the list
    } on PostgrestException catch (e) {
      if (mounted) {
        _showSnackBar('Error updating profile: ${e.message}', isError: true);
      }
      debugPrint('Error updating user profile: ${e.message}');
    } catch (e) {
      if (mounted) {
        _showSnackBar('An unexpected error occurred: $e', isError: true);
      }
      debugPrint('Unexpected error updating user profile: $e');
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  void _showEditProfileDialog(Map<String, dynamic> userProfile) {
    final TextEditingController displayNameController = TextEditingController(text: userProfile['display_name'] ?? '');
    final TextEditingController emailController = TextEditingController(text: userProfile['email'] ?? '');
    final TextEditingController phoneNumberController = TextEditingController(text: userProfile['phone_number'] ?? '');
    String selectedRole = userProfile['role'] ?? 'user'; // Default to 'user'

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: displayNameController,
                  decoration: const InputDecoration(labelText: 'Display Name'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'user', child: Text('User')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      selectedRole = value;
                    }
                  },
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
                final Map<String, dynamic> updates = {
                  'display_name': displayNameController.text.trim(),
                  'email': emailController.text.trim(),
                  'phone_number': phoneNumberController.text.trim(),
                  'role': selectedRole,
                };
                await _updateUserProfile(userProfile['id'], updates);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Save'),
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
        title: const Text('Manage Users'),
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
                          onPressed: _fetchAllUserProfiles,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _userProfiles.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_alt, size: 80, color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.5).round())),
                          const SizedBox(height: 20),
                          Text(
                            'No user profiles found.',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha((255 * 0.7).round()),
                                ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchAllUserProfiles,
                      child: Padding(
                        padding: EdgeInsets.all(isDesktop ? 20 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'All User Profiles',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _userProfiles.length,
                                itemBuilder: (context, index) {
                                  final user = _userProfiles[index];
                                  final String displayName = user['display_name'] ?? 'N/A';
                                  final String email = user['email'] ?? 'N/A';
                                  final String role = user['role'] ?? 'user';
                                  final String phoneNumber = user['phone_number'] ?? 'N/A';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    elevation: 4,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            displayName,
                                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          _buildDetailRow(context, Icons.email, 'Email:', email),
                                          _buildDetailRow(context, Icons.phone, 'Phone:', phoneNumber),
                                          _buildDetailRow(context, Icons.person_outline, 'Role:', role.toUpperCase()),
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () => _showEditProfileDialog(user),
                                              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
                                              label: Text('Edit Profile', style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                                            ),
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
                    ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}