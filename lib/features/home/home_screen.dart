// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

// // This function handles the logout functionality >> Returning you to login page 
//   void _logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();
//     if (context.mounted) context.go('/login');
//   }

// Future<String?> _getDisplayName() async {
//   final userId = Supabase.instance.client.auth.currentUser?.id;
//   if (userId == null) return null;

//   final response = await Supabase.instance.client
//       .from('profiles')
//       .select('display_name')
//       .eq('id', userId)
//       .single();

//   return response['display_name'];
// }


//   @override
//   Widget build(BuildContext context) {
//     final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Dashboard'),
//         actions: [
//           IconButton(
//             onPressed: () => _logout(context),
//             icon: const Icon(Icons.logout),
//             tooltip: 'Logout',
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             FutureBuilder<String?>(
//                 future: _getDisplayName(),
//                 builder: (context, snapshot) {
//                   final name = snapshot.data ?? userEmail;
//                   return Text(
//                     'Welcome, $name',
//                     style: Theme.of(context).textTheme.headlineSmall,
//                   );
//                 },
//               ),
//             const SizedBox(height: 20),



import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      context.go('/login'); // Navigate to login page after logout
    }
  }

  Future<String?> _getDisplayName() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
        final response = await Supabase.instance.client
      .from('profiles')
      .select('display_name')
      .eq('id', userId)
      .single();

  return response['display_name'];
    } catch (e) {
      // Handle error, e.g., if profile not found or network error
      // print('Error fetching display name: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        actions: [
          // The logout button can stay here or be moved purely to the drawer
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      // --- START: Add the Drawer here ---
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero, // Important for full-width drawer content
          children: <Widget>[
            // Drawer Header with User Info
            FutureBuilder<String?>(
              future: _getDisplayName(),
              builder: (context, snapshot) {
                final displayName = snapshot.data ?? userEmail; // Use name if available, else email
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blueAccent), // Placeholder for user avatar
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor, // Use your app's primary color
                  ),
                );
              },
            ),
            // Navigation List Tiles
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/'); // Navigate back to the root of the app (HomeScreen)
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets),
              title: const Text('Book a Pet Service'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/book'); // Navigate to the booking page
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_shared), // Icon for managing profiles
              title: const Text('Manage Pet Profiles'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/pets'); // Navigate to the pet profiles page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history), // New: View past bookings/history
              title: const Text('My Bookings'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/my_bookings'); // You'll need to define this route
              },
            ),
            ListTile(
              leading: const Icon(Icons.support_agent),
              title: const Text('Customer Support'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                context.go('/support'); // Navigate to the support page
              },
            ),
            const Divider(), // A visual separator
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () => _logout(context), // Use the existing logout function
            ),
          ],
        ),
      ),
      // --- END: Add the Drawer here ---

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the welcome message
            FutureBuilder<String?>(
              future: _getDisplayName(),
              builder: (context, snapshot) {
                final name = snapshot.data ?? userEmail;
                return Text(
                  'Welcome, $name',
                  style: Theme.of(context).textTheme.headlineSmall,
                );
              },
            ),
            const SizedBox(height: 20),



            ElevatedButton.icon(
              onPressed: () {
                context.go('/book'); // we'll make this page next
              },
              icon: const Icon(Icons.pets),
              label: const Text('Book a Pet Service'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                context.go('/pets'); // to be implemented
              },
              icon: const Icon(Icons.info),
              label: const Text('Manage Pet Profile'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {
                context.go('/support'); // to be implemented
              },
              icon: const Icon(Icons.support_agent),
              label: const Text('Customer Support'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
