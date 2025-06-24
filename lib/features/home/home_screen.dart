
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'package:intl/intl.dart';


// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen>  {

//   void _logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();
//     if (context.mounted) {
//       context.go('/login');
//     }
//   }

//   // Fetches the user's display name from their profile
//   Future<String?> _getDisplayName() async {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return null;

//     try {
//       final response = await Supabase.instance.client
//           .from('profiles')
//           .select('display_name') // Using 'name' as per the profile loggedd in
//           .eq('id', userId)
//           .single();

//       return response['display_name'] as String?;
//     } catch (e) {
//       // Error handling without a logger: simply return null
//       // print('Error fetching display name: $e');
//       return null;
//     }
//   }

//   // NEW: Fetches the total number of pets for the current user
// //   Future<int> _getTotalPets() async {
// //   final userId = Supabase.instance.client.auth.currentUser?.id;
// //   if (userId == null) return 0; // Return 0 if no user

// //   try {
// //     final count = await Supabase.instance.client
// //         .from('pets')
// //         .eq('owner_id', userId)
// //         .count(); // ❌ This is incorrect — Supabase doesn't have .count() like this

// //     return count;
// //   } catch (e) {
// //     return 0;
// //   }
// // }

// Future<int> _getTotalPets() async {
//   final userId = Supabase.instance.client.auth.currentUser?.id;
//   if (userId == null) return 0;

//   try {
//     final List pets = await Supabase.instance.client
//         .from('pets')
//         .select('id')
//         .eq('owner_id', userId);

//     return pets.length;
//   } catch (e) {
//     return 0;
//   }
// }




//   // NEW: Fetches the number of upcoming approved bookings for the current user
//   Future<int> _getUpcomingBookingsCount() async {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return 0;

//     try {
//       final today = DateTime.now().toIso8601String().substring(0, 10);

//       // Corrected: Call .count() directly after filters
//       final count = await Supabase.instance.client
//           .from('bookings')
//           .eq('owner_id', userId)
//           .gt('start_date', today)
//           .eq('status', 'approved')
//           .count(); // This directly returns the count as an integer

//       return count;
//     } catch (e) {
//       // print('Error fetching upcoming bookings count: $e');
//       return 0;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Guest';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Pet Dashboard'),
//         // actions: [
//         //   IconButton(
//         //     onPressed: () => _logout(context),
//         //     icon: const Icon(Icons.logout),
//         //     tooltip: 'Logout',
//         //   ),
//         // ],
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             FutureBuilder<String?>(
//               future: _getDisplayName(),
//               builder: (context, snapshot) {
//                 final displayName = snapshot.data ?? userEmail;
//                 return UserAccountsDrawerHeader(
//                   accountName: Text(
//                     displayName,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   accountEmail: Text(userEmail),
//                   currentAccountPicture: const CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
//                   ),
//                   decoration: BoxDecoration(
//                     color: Theme.of(context).primaryColor,
//                   ),
//                 );
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.home),
//               title: const Text('Home'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.go('/');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.pets),
//               title: const Text('Book a Pet Service'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.push('/book');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.folder_shared),
//               title: const Text('Manage Pet Profiles'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.push('/pets');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.history),
//               title: const Text('My Bookings'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.push('/my_bookings');
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.support_agent),
//               title: const Text('Customer Support'),
//               onTap: () {
//                 Navigator.pop(context);
//                 context.push('/support');
//               },
//             ),
//             const Divider(),
//             ListTile(
//               leading: const Icon(Icons.logout),
//               title: const Text('Logout'),
//               onTap: () => _logout(context),
//             ),
//           ],
//         ),
//       ),
//     body: RefreshIndicator(
//       onRefresh: () async {
//         setState(() {}); // Triggers FutureBuilder rebuilds
//       },
//       child: SingleChildScrollView(
//         physics: const AlwaysScrollableScrollPhysics(),
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Welcome Message
//             FutureBuilder<String?>(
//               future: _getDisplayName(),
//               builder: (context, snapshot) {
//                 final name = snapshot.data ?? " "; // which was formerly ...snapshot.data ?? userEmail; 
//                 // now there's a null showing instead of the email. 

//                 return Text(
//                   'Hello $name 👋🏻',
//                   style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: Theme.of(context).primaryColor,
//                       ),
//                 );
//               },
//             ),
//             const SizedBox(height: 24),

//             // --- Dashboard Cards/Widgets ---

//             // Quick Actions Section
//             Text(
//               'Would you like to?',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             Card(
//               elevation: 4,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     ListTile(
//                       leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.secondary),
//                       title: const Text('Book a New Service'),
//                       subtitle: const Text('Schedule boarding, grooming, or vet visits'),
//                       trailing: const Icon(Icons.arrow_forward_ios),
//                       onTap: () => context.push('/book'),
//                     ),
//                     const Divider(),
//                     ListTile(
//                       leading: Icon(Icons.add_box, color: Theme.of(context).colorScheme.secondary),
//                       title: const Text('Add a New Pet'),
//                       subtitle: const Text('Register a new furry friend'),
//                       trailing: const Icon(Icons.arrow_forward_ios),
//                       onTap: () => context.push('/pets/add'), // Assuming you'll have an Add Pet route
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Summary Section
//             Text(
//               'Your Pet Overview',
//               style: Theme.of(context).textTheme.titleLarge,
//             ),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.pets, size: 40, color: Colors.orange),
//                           const SizedBox(height: 8),
//                           FutureBuilder<int>(
//                               future: _getTotalPets(),
//                               builder: (context, snapshot) {
//                                 if (snapshot.connectionState == ConnectionState.waiting) {
//                                   return const CircularProgressIndicator();
//                                 } else if (snapshot.hasError) {
//                                   return const Text('Error');
//                                 } else {
//                                   return Text(
//                                     '${snapshot.data ?? 0}',
//                                     style: Theme.of(context).textTheme.displaySmall,
//                                   );
//                                 }
//                               },
//                             ),
//                           const SizedBox(height: 4),
//                           const Text('Total Pets', style: TextStyle(fontSize: 16)),
//                           const SizedBox(height: 8),
//                           ElevatedButton.icon(
//                             onPressed: () => context.push('/pets'),
//                             icon: const Icon(Icons.visibility),
//                             label: const Text('View Pets'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).colorScheme.secondary,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: Card(
//                     elevation: 4,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(Icons.event_note, size: 40, color: Colors.green),
//                           const SizedBox(height: 8),
//                           FutureBuilder<int>(
//                             future: _getUpcomingBookingsCount(),
//                             builder: (context, snapshot) {
//                               if (snapshot.connectionState == ConnectionState.waiting) {
//                                 return const CircularProgressIndicator();
//                               } else if (snapshot.hasError) {
//                                 return const Text('Error', style: TextStyle(fontSize: 24));
//                               } else {
//                                 return Text(
//                                   '${snapshot.data ?? 0}', // Display upcoming bookings count
//                                   style: Theme.of(context).textTheme.displaySmall,
//                                 );
//                               }
//                             },
//                           ),
//                           const SizedBox(height: 4),
//                           const Text('Upcoming Bookings', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
//                           const SizedBox(height: 8),
//                           ElevatedButton.icon(
//                             onPressed: () => context.push('/my_bookings'),
//                             icon: const Icon(Icons.list_alt),
//                             label: const Text('View All'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Theme.of(context).colorScheme.secondary,
//                               foregroundColor: Colors.white,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       )
//     ),
//     );
//   }
// }

// extension on SupabaseQueryBuilder {
//   eq(String s, String userId) {}
// }



// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   // State variables for bookings count
//   int _upcomingBookingsCount = 0;
//   bool _isLoadingBookingsCount = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUpcomingBookingsCount();
//   }

//   void _logout(BuildContext context) async {
//     await Supabase.instance.client.auth.signOut();
//     if (context.mounted) context.go('/login');
//   }

//   Future<String?> _getDisplayName() async {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return null;

//     try {
//       final response = await Supabase.instance.client
//           .from('profiles')
//           .select('display_name')
//           .eq('id', userId)
//           .single();
//       return response['display_name'] as String?;
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<int> _getTotalPets() async {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return 0;

//     try {
//       final countResult = await Supabase.instance.client
//           .from('pets')
//           .select('id', count: CountMethod.exact)
//           .eq('owner_id', userId);
//       return countResult.count;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<void> _fetchUpcomingBookingsCount() async {
//     if (!mounted) return;

//     setState(() => _isLoadingBookingsCount = true);

//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) {
//         if (mounted) setState(() => _upcomingBookingsCount = 0);
//         return;
//       }

//       final List<Map<String, dynamic>> data = await Supabase.instance.client
//           .from('bookings')
//           .select('id, start_date, end_date')
//           .eq('owner_id', userId);

//       final now = DateTime.now();
//       int count = 0;

//       for (var booking in data) {
//         final startDate = DateTime.parse(booking['start_date']);
//         final endDate = booking['end_date'] != null
//             ? DateTime.parse(booking['end_date'])
//             : startDate;
        
//         if (!endDate.isBefore(now)) count++;
//       }

//       if (mounted) setState(() => _upcomingBookingsCount = count);
//     } catch (e) {
//       if (mounted) setState(() => _upcomingBookingsCount = 0);
//     } finally {
//       if (mounted) setState(() => _isLoadingBookingsCount = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Guest';

//     return Scaffold(
//       appBar: AppBar(title: const Text('Your Pet Dashboard')),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             FutureBuilder<String?>(
//               future: _getDisplayName(),
//               builder: (context, snapshot) {
//                 final displayName = snapshot.data ?? userEmail;
//                 return UserAccountsDrawerHeader(
//                   accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
//                   accountEmail: Text(userEmail),
//                   currentAccountPicture: const CircleAvatar(
//                     backgroundColor: Colors.white,
//                     child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
//                   ),
//                   decoration: BoxDecoration(color: Theme.of(context).primaryColor),
//                 );
//               },
//             ),
//             _buildDrawerItem(Icons.home, 'Home', () => context.go('/')),
//             _buildDrawerItem(Icons.pets, 'Book a Pet Service', () => context.push('/book')),
//             _buildDrawerItem(Icons.folder_shared, 'Manage Pet Profiles', () => context.push('/pets')),
//             _buildDrawerItem(Icons.history, 'My Bookings', () => context.push('/my_bookings')),
//             _buildDrawerItem(Icons.support_agent, 'Customer Support', () => context.push('/support')),
//             const Divider(),
//             _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
//           ],
//         ),
//       ),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           setState(() {});
//           await _fetchUpcomingBookingsCount();
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               FutureBuilder<String?>(
//                 future: _getDisplayName(),
//                 builder: (context, snapshot) {
//                   final name = snapshot.data ?? userEmail;
//                   return Text(
//                     'Hello $name 👋🏻',
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                           color: Theme.of(context).primaryColor,
//                         ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 24),
//               _buildQuickActionsCard(context),
//               const SizedBox(height: 24),
//               Text('Your Pet Overview', style: Theme.of(context).textTheme.titleLarge),
//               const SizedBox(height: 16),
//               _buildSummaryCards(context),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon),
//       title: Text(title),
//       onTap: () {
//         Navigator.pop(context);
//         onTap();
//       },
//     );
//   }

//   Widget _buildQuickActionsCard(BuildContext context) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             ListTile(
//               leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.secondary),
//               title: const Text('Book a New Service'),
//               subtitle: const Text('Schedule boarding, grooming, or vet visits'),
//               trailing: const Icon(Icons.arrow_forward_ios),
//               onTap: () => context.push('/book'),
//             ),
//             const Divider(),
//             ListTile(
//               leading: Icon(Icons.add_box, color: Theme.of(context).colorScheme.secondary),
//               title: const Text('Add a New Pet'),
//               subtitle: const Text('Register a new furry friend'),
//               trailing: const Icon(Icons.arrow_forward_ios),
//               onTap: () => context.push('/pets/add'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSummaryCards(BuildContext context) {
//     return Row(
//       children: [
//         _buildSummaryCard(
//           icon: Icons.pets,
//           color: Colors.orange,
//           valueFuture: _getTotalPets(),
//           label: 'Total Pets',
//           buttonLabel: 'View Pets',
//           onPressed: () => context.push('/pets'),
//         ),
//         const SizedBox(width: 16),
//         _buildSummaryCard(
//           icon: Icons.event_note,
//           color: Colors.green,
//           value: _upcomingBookingsCount,
//           isLoading: _isLoadingBookingsCount,
//           label: 'Upcoming Bookings',
//           buttonLabel: 'View All',
//           onPressed: () => context.push('/my_bookings'),
//         ),
//       ],
//     );
//   }

//   Widget _buildSummaryCard({
//     required IconData icon,
//     required Color color,
//     String? label,
//     String? buttonLabel,
//     VoidCallback? onPressed,
//     Future<int>? valueFuture,
//     int? value,
//     bool isLoading = false,
//   }) {
//     return Expanded(
//       child: Card(
//         elevation: 4,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(icon, size: 40, color: color),
//               const SizedBox(height: 8),
//               if (valueFuture != null)
//                 FutureBuilder<int>(
//                   future: valueFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const CircularProgressIndicator();
//                     }
//                     return Text(
//                       '${snapshot.data ?? 0}',
//                       style: Theme.of(context).textTheme.displaySmall,
//                     );
//                   },
//                 )
//               else if (isLoading)
//                 const CircularProgressIndicator()
//               else
//                 Text('$value', style: Theme.of(context).textTheme.displaySmall),
//               const SizedBox(height: 4),
//               Text(label ?? '', style: const TextStyle(fontSize: 16)),
//               const SizedBox(height: 8),
//               if (buttonLabel != null && onPressed != null)
//                 ElevatedButton.icon(
//                   onPressed: onPressed,
//                   icon: Icon(icon == Icons.pets ? Icons.visibility : Icons.list_alt),
//                   label: Text(buttonLabel),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Theme.of(context).colorScheme.secondary,
//                     foregroundColor: Colors.white,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State variables for bookings count
  int _upcomingBookingsCount = 0;
  bool _isLoadingBookingsCount = true;

  @override
  void initState() {
    super.initState();
    _fetchUpcomingBookingsCount();
  }

  void _logout(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) context.go('/login');
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
      return response['display_name'] as String?;
    } catch (e) {
      return null;
    }
  }

  // FIXED: Use simple select + length instead of count method
  Future<int> _getTotalPets() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return 0;

    try {
      final response = await Supabase.instance.client
          .from('pets')
          .select()
          .eq('owner_id', userId);
        
      return response.length;
    } catch (e) {
      return 0;
    }
  }

  Future<void> _fetchUpcomingBookingsCount() async {
    if (!mounted) return;

    setState(() => _isLoadingBookingsCount = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        if (mounted) setState(() => _upcomingBookingsCount = 0);
        return;
      }

      final List<Map<String, dynamic>> data = await Supabase.instance.client
          .from('bookings')
          .select('id, start_date, end_date')
          .eq('owner_id', userId);

      final now = DateTime.now();
      int count = 0;

      for (var booking in data) {
        final startDate = DateTime.parse(booking['start_date']);
        final endDate = booking['end_date'] != null
            ? DateTime.parse(booking['end_date'])
            : startDate;
        
        if (!endDate.isBefore(now)) count++;
      }

      if (mounted) setState(() => _upcomingBookingsCount = count);
    } catch (e) {
      if (mounted) setState(() => _upcomingBookingsCount = 0);
    } finally {
      if (mounted) setState(() => _isLoadingBookingsCount = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Guest';

    return Scaffold(
      appBar: AppBar(title: const Text('Your Pet Dashboard')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<String?>(
              future: _getDisplayName(),
              builder: (context, snapshot) {
                final displayName = snapshot.data ?? userEmail;
                return UserAccountsDrawerHeader(
                  accountName: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  accountEmail: Text(userEmail),
                  currentAccountPicture: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 40, color: Colors.blueAccent),
                  ),
                  decoration: BoxDecoration(color: Theme.of(context).primaryColor),
                );
              },
            ),
            _buildDrawerItem(Icons.home, 'Home', () => context.go('/')),
            _buildDrawerItem(Icons.pets, 'Book a Pet Service', () => context.push('/book')),
            _buildDrawerItem(Icons.folder_shared, 'Manage Pet Profiles', () => context.push('/pets')),
            // FIXED: Use original route name with underscore
            _buildDrawerItem(Icons.history, 'My Bookings', () => context.push('/my_bookings')),
            _buildDrawerItem(Icons.support_agent, 'Customer Support', () => context.push('/support')),
            const Divider(),
            _buildDrawerItem(Icons.logout, 'Logout', () => _logout(context)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          await _fetchUpcomingBookingsCount();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<String?>(
                future: _getDisplayName(),
                builder: (context, snapshot) {
                  final name = snapshot.data ?? userEmail;
                  return Text(
                    'Hello $name 👋🏻',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildQuickActionsCard(context),
              const SizedBox(height: 24),
              Text('Your Pet Overview', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              _buildSummaryCards(context),
            ],
          ),
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  Widget _buildQuickActionsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Book a New Service'),
              subtitle: const Text('Schedule boarding, grooming, or vet visits'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.push('/book'),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.add_box, color: Theme.of(context).colorScheme.secondary),
              title: const Text('Add a New Pet'),
              subtitle: const Text('Register a new furry friend'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => context.push('/pets/add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Row(
      children: [
        _buildSummaryCard(
          icon: Icons.pets,
          color: Colors.orange,
          valueFuture: _getTotalPets(),
          label: 'Total Pets',
          buttonLabel: 'View Pets',
          onPressed: () => context.push('/pets'),
        ),
        const SizedBox(width: 16),
        _buildSummaryCard(
          icon: Icons.event_note,
          color: Colors.green,
          value: _upcomingBookingsCount,
          isLoading: _isLoadingBookingsCount,
          label: 'Your Pet Schedule',
          buttonLabel: 'View All',
          // FIXED: Use original route name with underscore
          onPressed: () => context.push('/my_bookings'),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required Color color,
    String? label,
    String? buttonLabel,
    VoidCallback? onPressed,
    Future<int>? valueFuture,
    int? value,
    bool isLoading = false,
  }) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 8),
              if (valueFuture != null)
                FutureBuilder<int>(
                  future: valueFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    return Text(
                      '${snapshot.data ?? 0}',
                      style: Theme.of(context).textTheme.displaySmall,
                    );
                  },
                )
              else if (isLoading)
                const CircularProgressIndicator()
              else
                Text('$value', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 4),
              Text(label ?? '', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              if (buttonLabel != null && onPressed != null)
                ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(icon == Icons.pets ? Icons.visibility : Icons.list_alt),
                  label: Text(buttonLabel),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
