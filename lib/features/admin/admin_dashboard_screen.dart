import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the user
              await Supabase.instance.client.auth.signOut();
              // Navigate back to the login screen
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, Admin!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onBackground,
                  ),
            ),
            const SizedBox(height: 20),
            Text(
              'This is your central hub for managing the PawPal application.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onBackground.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 30),
            // Admin functionalities will go here
            _buildAdminFunctionCard(
              context,
              icon: Icons.bar_chart,
              title: 'View Reports',
              description: 'Access detailed reports on bookings, users, and services.',
              onTap: () {
                // TODO: Navigate to reports screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reports functionality coming soon!')),
                );
              },
            ),
            _buildAdminFunctionCard(
              context,
              icon: Icons.people,
              title: 'Manage Users',
              description: 'View and manage user accounts and roles.',
              onTap: () {
                // TODO: Navigate to user management screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User management coming soon!')),
                );
              },
            ),
            _buildAdminFunctionCard(
              context,
              icon: Icons.settings,
              title: 'App Settings',
              description: 'Configure application-wide settings and parameters.',
              onTap: () {
                // TODO: Navigate to app settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('App settings coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminFunctionCard(BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
