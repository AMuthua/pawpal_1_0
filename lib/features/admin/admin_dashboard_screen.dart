// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:pawpal/providers/admin_stats_provider.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
//     });
//   }

//   // Helper function to format large revenue numbers
//   String formatRevenue(num value) {
//     if (value >= 1000000000) {
//       return 'KES ${(value / 1000000000).toStringAsFixed(2)}B';
//     } else if (value >= 1000000) {
//       return 'KES ${(value / 1000000).toStringAsFixed(2)}M';
//     } else if (value >= 1000) {
//       return 'KES ${(value / 1000).toStringAsFixed(2)}K';
//     } else {
//       return 'KES ${value.toStringAsFixed(2)}';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;
//     final adminStatsProvider = Provider.of<AdminStatsProvider>(context);

//     // Modern color scheme
//     const primaryColor = Color(0xFF4361EE);
//     const secondaryColor = Color(0xFF6C5CE7);
//     const accentColor = Color(0xFF00CEC9);
//     const backgroundColor = Color(0xFFF8F9FE);
//     const cardColor = Colors.white;
//     const textColor = Color(0xFF2D3436);
//     const lightTextColor = Color(0xFF636E72);

//     return Theme(
//       data: Theme.of(context).copyWith(
//         scaffoldBackgroundColor: backgroundColor,
//         cardTheme: CardTheme(
//           color: cardColor,
//           elevation: 8,
//           shadowColor: Colors.black.withOpacity(0.1),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           margin: const EdgeInsets.all(8),
//         ),
//         textTheme: Theme.of(context).textTheme.copyWith(
//               headlineMedium: const TextStyle(
//                 fontWeight: FontWeight.w800,
//                 color: textColor,
//               ),
//               titleMedium: TextStyle(
//                 color: lightTextColor,
//                 fontWeight: FontWeight.w500,
//               ),
//               bodyLarge: const TextStyle(
//                 fontWeight: FontWeight.w700,
//                 color: textColor,
//               ),
//             ),
//       ),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Admin Dashboard'),
//           backgroundColor: primaryColor,
//           foregroundColor: Colors.white,
//           elevation: 0,
//           centerTitle: true,
//           actions: [
//             IconButton(
//               icon: const Icon(Icons.logout),
//               onPressed: () async {
//                 await Supabase.instance.client.auth.signOut();
//                 if (context.mounted) context.go('/login');
//               },
//             ),
//           ],
//         ),
//         body: RefreshIndicator(
//           onRefresh: () => adminStatsProvider.fetchAdminStats(),
//           child: SafeArea(
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 return SingleChildScrollView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   child: ConstrainedBox(
//                     constraints: BoxConstraints(minHeight: constraints.maxHeight),
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isDesktop ? 40 : 20,
//                         vertical: 20,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Header Section
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Flexible(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Dashboard Overview',
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .headlineMedium
//                                           ?.copyWith(fontSize: isDesktop ? 32 : 26),
//                                     ),
//                                     const SizedBox(height: 8),
//                                     Text(
//                                       'Manage your application efficiently',
//                                       style: Theme.of(context).textTheme.titleMedium,
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               if (isDesktop)
//                                 const CircleAvatar(
//                                   radius: 32,
//                                   backgroundColor: primaryColor,
//                                   child: Icon(
//                                     Icons.admin_panel_settings,
//                                     size: 30,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 30),

//                           // Stats section
//                           _buildStatsSection(context, adminStatsProvider, isDesktop),
//                           const SizedBox(height: 30),

//                           // Management tools header
//                           Padding(
//                             padding: const EdgeInsets.only(left: 8.0),
//                             child: Text(
//                               'Management Tools',
//                               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                     fontSize: isDesktop ? 24 : 20,
//                                   ),
//                             ),
//                           ),
//                           const SizedBox(height: 20),

//                           // Grid with management tools
//                           _buildToolsGrid(context, isDesktop),
//                           const SizedBox(height: 20),
//                         ],
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatsSection(
//       BuildContext context, AdminStatsProvider adminStatsProvider, bool isDesktop) {
//     return adminStatsProvider.isLoading
//         ? const Center(child: CircularProgressIndicator())
//         : adminStatsProvider.errorMessage != null
//             ? Center(
//                 child: Text(
//                   'Error loading stats: ${adminStatsProvider.errorMessage}',
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               )
//             : SizedBox(
//                 height: isDesktop ? 130 : 110,
//                 child: ListView(
//                   scrollDirection: Axis.horizontal,
//                   physics: const BouncingScrollPhysics(),
//                   children: [
//                     const SizedBox(width: 8),
//                     _buildStatCard(
//                       context,
//                       title: 'Total Users',
//                       value: adminStatsProvider.totalUsers.toString(),
//                       icon: Icons.people_alt,
//                       color: const Color(0xFF5C6BC0),
//                       isDesktop: isDesktop,
//                     ),
//                     const SizedBox(width: 16),
//                     _buildStatCard(
//                       context,
//                       title: 'Total Pets',
//                       value: adminStatsProvider.totalPets.toString(),
//                       icon: Icons.pets,
//                       color: const Color(0xFF26A69A),
//                       isDesktop: isDesktop,
//                     ),
//                     const SizedBox(width: 16),
//                     _buildStatCard(
//                       context,
//                       title: 'Total Bookings',
//                       value: adminStatsProvider.totalBookings.toString(),
//                       icon: Icons.calendar_today,
//                       color: const Color(0xFFFF7043),
//                       isDesktop: isDesktop,
//                     ),
//                     const SizedBox(width: 16),
//                     _buildStatCard(
//                       context,
//                       title: 'Total Revenue',
//                       value: formatRevenue(adminStatsProvider.totalRevenue),
//                       icon: Icons.attach_money,
//                       color: const Color(0xFF7CB342),
//                       isDesktop: isDesktop,
//                     ),
//                     const SizedBox(width: 8),
//                   ],
//                 ),
//               );
//   }

//   Widget _buildToolsGrid(BuildContext context, bool isDesktop) {
//     return GridView.count(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       crossAxisCount: isDesktop ? 4 : 2,
//       crossAxisSpacing: 16,
//       mainAxisSpacing: 16,
//       childAspectRatio: 1.0,
//       children: [
//         _buildActionCard(
//           context,
//           icon: Icons.miscellaneous_services,
//           title: 'Services',
//           color: const Color(0xFF03A9F4),
//           onTap: () => context.go('/admin_dashboard/services'),
//         ),
//         _buildActionCard(
//           context,
//           icon: Icons.event_note,
//           title: 'Bookings',
//           color: const Color(0xFF8E24AA),
//           onTap: () => context.go('/admin_dashboard/bookings'),
//         ),
//         _buildActionCard(
//           context,
//           icon: Icons.people,
//           title: 'Users',
//           color: const Color(0xFFD81B60),
//           onTap: () => ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('User management coming soon!')),
//           ),
//         ),
//         _buildActionCard(
//           context,
//           icon: Icons.settings,
//           title: 'Settings',
//           color: const Color(0xFF607D8B),
//           onTap: () => ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('App settings coming soon!')),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatCard(
//     BuildContext context, {
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required bool isDesktop,
//   }) {
//     return Container(
//       width: isDesktop ? 180 : 160,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(icon, size: 20, color: color),
//               ),
//               const Spacer(),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: isDesktop ? 20 : 18,
//                   fontWeight: FontWeight.w800,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isDesktop ? 14 : 13,
//               fontWeight: FontWeight.w500,
//               color: const Color(0xFF495057),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     VoidCallback? onTap,
//   }) {
//     return Card(
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 color.withOpacity(0.9),
//                 color.withOpacity(0.7),
//               ],
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(icon, size: 28, color: Colors.white),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   title,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                     color: Colors.white,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:provider/provider.dart'; // Import provider
// import 'package:pawpal/providers/admin_stats_provider.dart'; // Import the new provider
// import 'package:postgrest/postgrest.dart'; // Required for CountOption

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   @override
//   void initState() {
//     super.initState();
//     // Trigger initial fetch when the screen loads
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;

//     // Consume AdminStatsProvider
//     final adminStatsProvider = Provider.of<AdminStatsProvider>(context);

//     // Custom color scheme for admin dashboard
//     final ColorScheme adminColorScheme = ColorScheme(
//       brightness: Theme.of(context).brightness,
//       primary: const Color(0xFF4361EE), // A vibrant indigo blue for primary elements
//       onPrimary: Colors.white, // White text/icons on primary
//       secondary: const Color(0xFF4CC9F0), // A bright cyan for accents
//       onSecondary: Colors.black, // Black text/icons on secondary (for better contrast)
//       error: Colors.red[700]!,
//       onError: Colors.white,
//       surface: Colors.white, // Pure white for card backgrounds
//       onSurface: const Color(0xFF2B2D42), // Very dark grey for text on white cards
//       surfaceContainerHighest: const Color(0xFFF0F2F5), // A very light, subtle grey for the overall scaffold background
//       onSurfaceVariant: const Color(0xFF495057), // Dark grey for text on the light grey background
//     );

//     return Theme(
//       data: Theme.of(context).copyWith(
//         colorScheme: adminColorScheme,
//         appBarTheme: AppBarTheme(
//           backgroundColor: adminColorScheme.primary,
//           foregroundColor: Colors.white, // Ensure app bar text/icons are white
//           elevation: 0, // Flat app bar for modern look
//           centerTitle: true,
//           iconTheme: const IconThemeData(color: Colors.white),
//           toolbarHeight: isDesktop ? 70 : null,
//         ),
//         cardTheme: CardTheme(
//           color: adminColorScheme.surface, // White cards
//           elevation: 6, // Stronger shadow for cards
//           shadowColor: Colors.black.withAlpha((255 * 0.26).round()),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 10),
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: adminColorScheme.primary, // Primary color for buttons
//             foregroundColor: adminColorScheme.onPrimary, // White text on buttons
//             padding: EdgeInsets.symmetric(
//               horizontal: isDesktop ? 24 : 16,
//               vertical: isDesktop ? 16 : 12,
//             ),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//             elevation: 4,
//             shadowColor: adminColorScheme.primary.withAlpha((255 * 0.3).round()),
//             textStyle: TextStyle(
//               fontSize: isDesktop ? 14 : 16,
//               fontWeight: FontWeight.w600,
//               letterSpacing: 0.5,
//             ),
//           ),
//         ),
//         textButtonTheme: TextButtonThemeData(
//           style: TextButton.styleFrom(
//             foregroundColor: adminColorScheme.primary, // Primary color for text buttons
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             textStyle: const TextStyle(
//               fontWeight: FontWeight.w600,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         ),
//         textTheme: Theme.of(context).textTheme.copyWith(
//               headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                     color: adminColorScheme.onSurface,
//                   ),
//               titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
//                     color: adminColorScheme.onSurfaceVariant,
//                   ),
//             ),
//       ),
//       child: Scaffold(
//         backgroundColor: adminColorScheme.surfaceContainerHighest,
//         appBar: AppBar(
//           title: const Text('Admin Dashboard'),
//           actions: [
//             IconButton(
//               icon: Icon(Icons.logout, size: isDesktop ? 28 : 24),
//               onPressed: () async {
//                 await Supabase.instance.client.auth.signOut();
//                 if (context.mounted) context.go('/login');
//               },
//               tooltip: 'Logout',
//             ),
//           ],
//         ),
//         body: RefreshIndicator( // Added RefreshIndicator
//           onRefresh: () => adminStatsProvider.fetchAdminStats(), // Call provider's fetch method
//           child: SafeArea(
//             child: Padding(
//               padding: EdgeInsets.symmetric(
//                 horizontal: isDesktop ? 40 : 20,
//                 vertical: 16, // Adjusted from 20 to 16 to prevent overflow
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header Section
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Welcome, Admin!',
//                             style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                   fontWeight: FontWeight.w800,
//                                   color: adminColorScheme.onSurface,
//                                   letterSpacing: -0.5,
//                                   fontSize: isDesktop ? 30 : 24,
//                                 ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Manage your application efficiently',
//                             style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   color: adminColorScheme.onSurfaceVariant,
//                                   fontWeight: FontWeight.w400,
//                                   fontSize: isDesktop ? 18 : 16,
//                                 ),
//                           ),
//                         ],
//                       ),
//                       if (isDesktop)
//                         CircleAvatar(
//                           backgroundColor: adminColorScheme.primary.withAlpha((255 * 0.1).round()),
//                           radius: 28,
//                           child: Icon(
//                             Icons.admin_panel_settings,
//                             size: 32,
//                             color: adminColorScheme.primary,
//                           ),
//                         ),
//                     ],
//                   ),
//                   const SizedBox(height: 30),

//                   // Stats section
//                   adminStatsProvider.isLoading
//                       ? const Center(child: CircularProgressIndicator())
//                       : adminStatsProvider.errorMessage != null
//                           ? Center(
//                               child: Text(
//                                 'Error loading stats: ${adminStatsProvider.errorMessage}',
//                                 style: TextStyle(color: Theme.of(context).colorScheme.error),
//                               ),
//                             )
//                           : SizedBox(
//                               height: isDesktop ? 110 : 100,
//                               child: ListView(
//                                 scrollDirection: Axis.horizontal,
//                                 children: [
//                                   _buildStatCard(
//                                     context,
//                                     title: 'Total Users',
//                                     value: adminStatsProvider.totalUsers.toString(),
//                                     icon: Icons.people_alt,
//                                     color: const Color(0xFF5C6BC0),
//                                     isDesktop: isDesktop,
//                                   ),
//                                   _buildStatCard(
//                                     context,
//                                     title: 'Total Pets',
//                                     value: adminStatsProvider.totalPets.toString(),
//                                     icon: Icons.pets,
//                                     color: const Color(0xFF26A69A),
//                                     isDesktop: isDesktop,
//                                   ),
//                                   _buildStatCard(
//                                     context,
//                                     title: 'Total Bookings',
//                                     value: adminStatsProvider.totalBookings.toString(),
//                                     icon: Icons.calendar_today,
//                                     color: const Color(0xFFFF7043),
//                                     isDesktop: isDesktop,
//                                   ),
//                                   _buildStatCard(
//                                     context,
//                                     title: 'Total Revenue',
//                                     value: 'KES ${adminStatsProvider.totalRevenue.toStringAsFixed(2)}',
//                                     icon: Icons.attach_money,
//                                     color: const Color(0xFF7CB342), // A green shade for revenue
//                                     isDesktop: isDesktop,
//                                   ),
//                                 ],
//                               ),
//                             ),
//                   const SizedBox(height: 30),

//                   // Management tools header
//                   Text(
//                     'Management Tools',
//                     style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: adminColorScheme.onSurface,
//                           fontSize: isDesktop ? 22 : 20,
//                         ),
//                   ),
//                   const SizedBox(height: 20),

//                   // Main grid with flexible height - only Services and Bookings
//                   Expanded( // Wrap GridView in Expanded to prevent overflow
//                     child: GridView.count(
//                       crossAxisCount: isDesktop ? 4 : 2, // 4 columns on desktop, 2 on mobile
//                       crossAxisSpacing: isDesktop ? 16 : 12,
//                       mainAxisSpacing: isDesktop ? 16 : 12,
//                       childAspectRatio: isDesktop ? 0.9 : 1.0, // Adjust aspect ratio for better fit
//                       children: [
//                         // Services Management Card
//                         _buildActionCard(
//                           context,
//                           icon: Icons.miscellaneous_services,
//                           title: 'Services',
//                           color: const Color(0xFF03A9F4),
//                           isDesktop: isDesktop,
//                           onTap: () {
//                             context.go('/admin_dashboard/services');
//                           },
//                         ),
//                         // Bookings Management Card
//                         _buildActionCard(
//                           context,
//                           icon: Icons.event_note, // Icon for bookings
//                           title: 'Bookings',
//                           color: const Color(0xFF8E24AA), // A purple color for bookings
//                           isDesktop: isDesktop,
//                           onTap: () {
//                             context.go('/admin_dashboard/bookings'); // Navigate to the new bookings management screen
//                           },
//                         ),
//                         // NEW: User Management Card
//                         _buildActionCard(
//                           context,
//                           icon: Icons.people,
//                           title: 'Users',
//                           color: const Color(0xFFD81B60), // A strong pink
//                           isDesktop: isDesktop,
//                           onTap: () {
//                             context.go('/admin_dashboard/users'); // Navigate to the new user management screen
//                           },
//                         ),
//                         _buildActionCard(
//                           context,
//                           icon: Icons.settings,
//                           title: 'Settings',
//                           color: const Color(0xFF607D8B), // A blue-grey for settings
//                           isDesktop: isDesktop,
//                           onTap: () {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               const SnackBar(content: Text('App settings coming soon!')),
//                             );
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Refactored _buildActionCard to be more compact for GridView
//   Widget _buildActionCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required bool isDesktop,
//     VoidCallback? onTap, // Added onTap callback
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap, // Use the provided onTap callback
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 color.withAlpha((255 * 0.85).round()),
//                 color.withAlpha((255 * 0.95).round()),
//               ],
//             ),
//           ),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 padding: EdgeInsets.all(isDesktop ? 12 : 14),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withAlpha((255 * 0.2).round()),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon,
//                   size: isDesktop ? 28 : 32,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
//                 textAlign: TextAlign.center, // Center align text
//                 style: TextStyle(
//                   fontSize: isDesktop ? 15 : 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.white,
//                   letterSpacing: 0.5,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     BuildContext context, {
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required bool isDesktop,
//   }) {
//     return Container(
//       width: isDesktop ? 190 : 170, // Adjusted width for more cards in horizontal scroll
//       margin: const EdgeInsets.only(right: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withAlpha((255 * 0.05).round()),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: color.withAlpha((255 * 0.1).round()),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, size: 20, color: color),
//               ),
//               const Spacer(),
//               Text(
//                 value,
//                 style: TextStyle(
//                   fontSize: isDesktop ? 20 : 22,
//                   fontWeight: FontWeight.w700,
//                   color: color,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           Text(
//             title,
//             style: TextStyle(
//               fontSize: isDesktop ? 14 : 15,
//               fontWeight: FontWeight.w500,
//               color: const Color(0xFF495057),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart'; // Import provider
import 'package:pawpal/providers/admin_stats_provider.dart'; // Import the new provider
import 'package:postgrest/postgrest.dart'; // Required for CountOption

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger initial fetch when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
    });
  }

  // Helper function to format large numbers (e.g., 1200 -> 1.2K, 1200000 -> 1.2M)
  String _formatLargeNumber(num value) {
    if (value >= 1000000) {
      // For millions, truncate to one decimal place
      final double millions = (value / 1000000);
      return '${(millions * 10).floor() / 10}M'; // Truncate, then format
    } else if (value >= 1000) {
      // For thousands, truncate to one decimal place
      final double thousands = (value / 1000);
      return '${(thousands * 10).floor() / 10}K'; // Truncate, then format
    } else {
      return value.toString();
    }
  }

  // Helper to show a dialog with the full number
  void _showFullNumberDialog(BuildContext context, String title, num fullValue) {
    String formattedValue;
    if (title == 'Total Revenue') {
      formattedValue = 'KES ${fullValue.toStringAsFixed(2)}';
    } else {
      formattedValue = fullValue.toString();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          formattedValue,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

    // Consume AdminStatsProvider
    final adminStatsProvider = Provider.of<AdminStatsProvider>(context);

    // Custom color scheme for admin dashboard
    final ColorScheme adminColorScheme = ColorScheme(
      brightness: Theme.of(context).brightness,
      primary: const Color(0xFF4361EE), // A vibrant indigo blue for primary elements
      onPrimary: Colors.white, // White text/icons on primary
      secondary: const Color(0xFF4CC9F0), // A bright cyan for accents
      onSecondary: Colors.black, // Black text/icons on secondary (for better contrast)
      error: Colors.red[700]!,
      onError: Colors.white,
      surface: Colors.white, // Pure white for card backgrounds
      onSurface: const Color(0xFF2B2D42), // Very dark grey for text on white cards
      surfaceContainerHighest: const Color(0xFFF0F2F5), // A very light, subtle grey for the overall scaffold background
      onSurfaceVariant: const Color(0xFF495057), // Dark grey for text on the light grey background
    );

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: adminColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: adminColorScheme.primary,
          foregroundColor: Colors.white, // Ensure app bar text/icons are white
          elevation: 0, // Flat app bar for modern look
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
          toolbarHeight: isDesktop ? 70 : null,
        ),
        cardTheme: CardTheme(
          color: adminColorScheme.surface, // White cards
          elevation: 6, // Stronger shadow for cards
          shadowColor: Colors.black.withAlpha((255 * 0.26).round()),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.symmetric(vertical: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: adminColorScheme.primary, // Primary color for buttons
            foregroundColor: adminColorScheme.onPrimary, // White text on buttons
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 24 : 16,
              vertical: isDesktop ? 16 : 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 4,
            shadowColor: adminColorScheme.primary.withAlpha((255 * 0.3).round()),
            textStyle: TextStyle(
              fontSize: isDesktop ? 14 : 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: adminColorScheme.primary, // Primary color for text buttons
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: adminColorScheme.onSurface,
                  ),
              titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: adminColorScheme.onSurfaceVariant,
                  ),
            ),
      ),
      child: Scaffold(
        backgroundColor: adminColorScheme.surfaceContainerHighest,
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
            IconButton(
              icon: Icon(Icons.logout, size: isDesktop ? 28 : 24),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
              tooltip: 'Logout',
            ),
          ],
        ),
        body: RefreshIndicator( // Added RefreshIndicator
          onRefresh: () => adminStatsProvider.fetchAdminStats(), // Call provider's fetch method
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 20,
                vertical: 16, // Adjusted from 20 to 16 to prevent overflow
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Admin!',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: adminColorScheme.onSurface,
                                  letterSpacing: -0.5,
                                  fontSize: isDesktop ? 30 : 24,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage your application efficiently',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: adminColorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                  fontSize: isDesktop ? 18 : 16,
                                ),
                          ),
                        ],
                      ),
                      if (isDesktop)
                        CircleAvatar(
                          backgroundColor: adminColorScheme.primary.withAlpha((255 * 0.1).round()),
                          radius: 28,
                          child: Icon(
                            Icons.admin_panel_settings,
                            size: 32,
                            color: adminColorScheme.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Stats section
                  adminStatsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : adminStatsProvider.errorMessage != null
                            ? Center(
                                child: Text(
                                  'Error loading stats: ${adminStatsProvider.errorMessage}',
                                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                                ),
                              )
                            : SizedBox(
                                height: isDesktop ? 110 : 100,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    _buildStatCard(
                                      context,
                                      title: 'Total Users',
                                      value: adminStatsProvider.totalUsers, // Pass num directly
                                      icon: Icons.people_alt,
                                      color: const Color(0xFF5C6BC0),
                                      isDesktop: isDesktop,
                                    ),
                                    _buildStatCard(
                                      context,
                                      title: 'Total Pets',
                                      value: adminStatsProvider.totalPets, // Pass num directly
                                      icon: Icons.pets,
                                      color: const Color(0xFF26A69A),
                                      isDesktop: isDesktop,
                                    ),
                                    _buildStatCard(
                                      context,
                                      title: 'Total Bookings',
                                      value: adminStatsProvider.totalBookings, // Pass num directly
                                      icon: Icons.calendar_today,
                                      color: const Color(0xFFFF7043),
                                      isDesktop: isDesktop,
                                    ),
                                    _buildStatCard(
                                      context,
                                      title: 'Total Revenue',
                                      value: adminStatsProvider.totalRevenue, // Pass num directly
                                      icon: Icons.attach_money,
                                      color: const Color(0xFF7CB342), // A green shade for revenue
                                      isDesktop: isDesktop,
                                    ),
                                  ],
                                ),
                              ),
                  const SizedBox(height: 30),

                  // Management tools header
                  Text(
                    'Management Tools',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: adminColorScheme.onSurface,
                          fontSize: isDesktop ? 22 : 20,
                        ),
                  ),
                  const SizedBox(height: 20),

                  // Main grid with flexible height - only Services and Bookings
                  Expanded( // Wrap GridView in Expanded to prevent overflow
                    child: GridView.count(
                      crossAxisCount: isDesktop ? 4 : 2, // 4 columns on desktop, 2 on mobile
                      crossAxisSpacing: isDesktop ? 16 : 12,
                      mainAxisSpacing: isDesktop ? 16 : 12,
                      childAspectRatio: isDesktop ? 0.9 : 1.0, // Adjust aspect ratio for better fit
                      children: [
                        // Services Management Card
                        _buildActionCard(
                          context,
                          icon: Icons.miscellaneous_services,
                          title: 'Services',
                          color: const Color(0xFF03A9F4),
                          isDesktop: isDesktop,
                          onTap: () {
                            context.go('/admin_dashboard/services');
                          },
                        ),
                        // Bookings Management Card
                        _buildActionCard(
                          context,
                          icon: Icons.event_note, // Icon for bookings
                          title: 'Bookings',
                          color: const Color(0xFF8E24AA), // A purple color for bookings
                          isDesktop: isDesktop,
                          onTap: () {
                            context.go('/admin_dashboard/bookings'); // Navigate to the new bookings management screen
                          },
                        ),
                        // NEW: User Management Card
                        _buildActionCard(
                          context,
                          icon: Icons.people,
                          title: 'Users',
                          color: const Color(0xFFD81B60), // A strong pink
                          isDesktop: isDesktop,
                          onTap: () {
                            context.go('/admin_dashboard/users'); // Navigate to the new user management screen
                          },
                        ),
                        _buildActionCard(
                          context,
                          icon: Icons.settings,
                          title: 'Settings',
                          color: const Color(0xFF607D8B), // A blue-grey for settings
                          isDesktop: isDesktop,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('App settings coming soon!')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Refactored _buildActionCard to be more compact for GridView
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required bool isDesktop,
    VoidCallback? onTap, // Added onTap callback
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // Use the provided onTap callback
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withAlpha((255 * 0.85).round()),
                color.withAlpha((255 * 0.95).round()),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isDesktop ? 12 : 14),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((255 * 0.2).round()),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: isDesktop ? 28 : 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center, // Center align text
                style: TextStyle(
                  fontSize: isDesktop ? 15 : 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String title,
    required num value, // Changed to num
    required IconData icon,
    required Color color,
    required bool isDesktop,
  }) {
    return Container(
      width: isDesktop ? 190 : 170, // Adjusted width for more cards in horizontal scroll
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((255 * 0.05).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell( // Added InkWell for tap functionality
        onTap: () => _showFullNumberDialog(context, title, value), // Show full number on tap
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha((255 * 0.1).round()),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: color),
                ),
                const Spacer(),
                // FIX: Wrap Text(value) in Expanded to prevent overflow
                Expanded(
                  child: Text(
                    _formatLargeNumber(value), // Use formatted value for display
                    textAlign: TextAlign.right, // Align text to the right within its expanded space
                    style: TextStyle(
                      fontSize: isDesktop ? 20 : 22,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                    maxLines: 1, // Ensure it doesn't wrap
                    overflow: TextOverflow.ellipsis, // Add ellipsis if it still overflows
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: isDesktop ? 14 : 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF495057),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
