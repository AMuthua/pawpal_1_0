import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';


class BookServiceScreen extends StatelessWidget {
  const BookServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Pet Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose a service type:',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Service Card for Boarding
            _ServiceCard(
              icon: Icons.hotel,
              iconColor: Colors.blueAccent,
              title: 'Pet Boarding',
              description: 'Comfortable stays for your furry friends.',
              onTap: () {
                // TODO: Navigate to Boarding booking details screen
                // For now, let's just show a snackbar or navigate to a generic next step
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Boarding selected! (Next step coming soon)')),
                );
                // We'll define a specific route for each service later, or pass a parameter.
                // For example: context.go('/book/boarding');
              },
            ),
            const SizedBox(height: 16),

            // Service Card for Grooming
            _ServiceCard(
              icon: Icons.cut,
              iconColor: Colors.pinkAccent,
              title: 'Grooming',
              description: 'Keep your pet looking and feeling great.',
              onTap: () {
                // TODO: Navigate to Grooming booking details screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Grooming selected! (Next step coming soon)')),
                );
              },
            ),
            const SizedBox(height: 16),

            // Service Card for Veterinary Services
            _ServiceCard(
              icon: Icons.local_hospital,
              iconColor: Colors.redAccent,
              title: 'Veterinary Services',
              description: 'Routine checkups, vaccinations, and medical care.',
              onTap: () {
                // TODO: Navigate to Veterinary booking details screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veterinary selected! (Next step coming soon)')),
                );
              },
            ),
            const SizedBox(height: 16),

            // TODO: Add more service types as needed (e.g., Dog Walking, Pet Sitting)
          ],
        ),
      ),
    );
  }
}

// Helper Widget for Service Cards
class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell( // Use InkWell for tap effect on the card
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}