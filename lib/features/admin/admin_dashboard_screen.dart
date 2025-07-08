// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class AdminDashboardScreen extends StatelessWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = MediaQuery.of(context).size.width > 600;
//     // final availableHeight = MediaQuery.of(context).size.height; // availableHeight is not used

//     // Custom color scheme for admin dashboard
//     // Using distinct colors for a clear visual separation from the main app
//     final ColorScheme adminColorScheme = ColorScheme(
//       brightness: Theme.of(context).brightness,
//       primary: const Color(0xFF4361EE), // A vibrant indigo blue for primary elements
//       onPrimary: Colors.white, // White text/icons on primary
//       secondary: const Color(0xFF4CC9F0), // A bright cyan for accents
//       onSecondary: Colors.black, // Black text/icons on secondary (for better contrast)
//       error: Colors.red[700]!,
//       onError: Colors.white,
//       // Using surface and surfaceVariant for background/card distinction
//       surface: Colors.white, // Pure white for card backgrounds
//       onSurface: const Color(0xFF2B2D42), // Very dark grey for text on white cards
//       surfaceContainerHighest: const Color(0xFFF0F2F5), // A very light, subtle grey for the overall scaffold background
//       onSurfaceVariant: const Color(0xFF495057), // Dark grey for text on the light grey background
//     );

//     // DEBUG PRINT: Check the generated color scheme values
//     debugPrint('--- Admin Color Scheme DEBUG ---');
//     debugPrint('  Primary: ${adminColorScheme.primary}');
//     debugPrint('  OnPrimary: ${adminColorScheme.onPrimary}');
//     debugPrint('  Secondary: ${adminColorScheme.secondary}');
//     debugPrint('  OnSecondary: ${adminColorScheme.onSecondary}');
//     debugPrint('  Surface: ${adminColorScheme.surface}');
//     debugPrint('  OnSurface: ${adminColorScheme.onSurface}');
//     debugPrint('  SurfaceVariant: ${adminColorScheme.surfaceContainerHighest}');
//     debugPrint('  OnSurfaceVariant: ${adminColorScheme.onSurfaceVariant}');
//     debugPrint('--------------------------------');

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
//           // FIXED: Use withAlpha for shadowColor to resolve deprecation
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
//             // FIXED: Use withAlpha for shadowColor to resolve deprecation
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
//         // Ensure text themes inherit these colors where appropriate
//         textTheme: Theme.of(context).textTheme.copyWith(
//           headlineMedium: Theme.of(context).textTheme.headlineMedium?.copyWith(
//             color: adminColorScheme.onSurface, // Default for headlines on surface
//           ),
//           titleMedium: Theme.of(context).textTheme.titleMedium?.copyWith(
//             color: adminColorScheme.onSurfaceVariant, // Default for titles on background
//           ),
//         ),
//       ),
//       child: Scaffold(
//         backgroundColor: adminColorScheme.surfaceContainerHighest, // Overall light grey background
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
//         body: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(
//               horizontal: isDesktop ? 40 : 20,
//               vertical: 20,
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header Section
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Welcome, Admin!',
//                           style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                                 fontWeight: FontWeight.w800,
//                                 color: adminColorScheme.onSurface, // Text on white surface for contrast
//                                 letterSpacing: -0.5,
//                                 fontSize: isDesktop ? 30 : 24,
//                               ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Manage your application efficiently',
//                           style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                                 color: adminColorScheme.onSurfaceVariant, // Text on light grey background
//                                 fontWeight: FontWeight.w400,
//                                 fontSize: isDesktop ? 18 : 16,
//                               ),
//                         ),
//                       ],
//                     ),
//                     if (isDesktop) // Only show on desktop for larger screens
//                       CircleAvatar(
//                         // FIXED: Use withAlpha for backgroundColor to resolve deprecation
//                         backgroundColor: adminColorScheme.primary.withAlpha((255 * 0.1).round()), 
//                         radius: 28,
//                         child: Icon(
//                           Icons.admin_panel_settings,
//                           size: 32,
//                           color: adminColorScheme.primary, // Icon in primary color
//                         ),
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 30),
                
//                 // Stats section with constrained height
//                 SizedBox(
//                   height: isDesktop ? 110 : 100,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: [
//                       _buildStatCard(
//                         context,
//                         title: 'Total Users',
//                         value: '1.2K',
//                         icon: Icons.people_alt,
//                         color: const Color(0xFF5C6BC0), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                       _buildStatCard(
//                         context,
//                         title: 'Monthly Revenue',
//                         value: '\$24.8K',
//                         icon: Icons.bar_chart,
//                         color: const Color(0xFF26A69A), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                       _buildStatCard(
//                         context,
//                         title: 'Bookings',
//                         value: '324',
//                         icon: Icons.calendar_today,
//                         color: const Color(0xFFFF7043), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 30),
                
//                 // Management tools header
//                 Text(
//                   'Management Tools',
//                   style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: adminColorScheme.onSurface, // Text on white surface for contrast
//                         fontSize: isDesktop ? 22 : 20,
//                       ),
//                 ),
//                 const SizedBox(height: 20),
                
//                 // Main grid with flexible height
//                 Expanded(
//                   child: GridView.count(
//                     crossAxisCount: isDesktop ? 4 : 2,
//                     crossAxisSpacing: isDesktop ? 16 : 12,
//                     mainAxisSpacing: isDesktop ? 16 : 12,
//                     childAspectRatio: isDesktop ? 0.9 : 1.0, // Adjusted aspect ratio for smaller cards
//                     children: [
//                       _buildActionCard(
//                         context,
//                         icon: Icons.bar_chart_rounded,
//                         title: 'Analytics',
//                         color: adminColorScheme.primary, // Uses the primary color
//                         isDesktop: isDesktop,
//                       ),
//                       _buildActionCard(
//                         context,
//                         icon: Icons.people,
//                         title: 'Users',
//                         color: const Color(0xFF4CAF50), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                       _buildActionCard(
//                         context,
//                         icon: Icons.pets,
//                         title: 'Pets',
//                         color: const Color(0xFFFF9800), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                       _buildActionCard(
//                         context,
//                         icon: Icons.settings,
//                         title: 'Settings',
//                         color: const Color(0xFF9C27B0), // Custom color for this card
//                         isDesktop: isDesktop,
//                       ),
//                       // Added more cards for desktop view to fill space
//                       if (isDesktop)
//                         _buildActionCard(
//                           context,
//                           icon: Icons.receipt,
//                           title: 'Invoices',
//                           color: const Color(0xFF795548),
//                           isDesktop: isDesktop,
//                         ),
//                       if (isDesktop)
//                         _buildActionCard(
//                           context,
//                           icon: Icons.history,
//                           title: 'Audit Log',
//                           color: const Color(0xFF607D8B),
//                           isDesktop: isDesktop,
//                         ),
//                       if (isDesktop)
//                         _buildActionCard(
//                           context,
//                           icon: Icons.notifications,
//                           title: 'Alerts',
//                           color: const Color(0xFFF44336),
//                           isDesktop: isDesktop,
//                         ),
//                       if (isDesktop)
//                         _buildActionCard(
//                           context,
//                           icon: Icons.help,
//                           title: 'Support',
//                           color: const Color(0xFF00BCD4),
//                           isDesktop: isDesktop,
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildActionCard(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     required Color color,
//     required bool isDesktop,
//   }) {
//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('$title functionality coming soon!'),
//               // FIXED: Use withAlpha for backgroundColor to resolve deprecation
//               backgroundColor: color.withAlpha((255 * 0.9).round()), 
//             ),
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [
//                 // FIXED: Use withAlpha for gradient colors to resolve deprecation
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
//                   // FIXED: Use withAlpha for color to resolve deprecation
//                   color: Colors.white.withAlpha((255 * 0.2).round()), 
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   icon, 
//                   size: isDesktop ? 28 : 32, 
//                   color: Colors.white
//                 ),
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 title,
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
//       width: isDesktop ? 190 : 170,
//       margin: const EdgeInsets.only(right: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white, // Stat cards are white
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             // FIXED: Use withAlpha for shadowColor to resolve deprecation
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
//                   // FIXED: Use withAlpha for color to resolve deprecation
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
//             style: TextStyle( // Changed to TextStyle to allow for desktop sizing
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

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;

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

    // DEBUG PRINT: Check the generated color scheme values
    debugPrint('--- Admin Color Scheme DEBUG ---');
    debugPrint('  Primary: ${adminColorScheme.primary}');
    debugPrint('  OnPrimary: ${adminColorScheme.onPrimary}');
    debugPrint('  Secondary: ${adminColorScheme.secondary}');
    debugPrint('  OnSecondary: ${adminColorScheme.onSecondary}');
    debugPrint('  Surface: ${adminColorScheme.surface}');
    debugPrint('  OnSurface: ${adminColorScheme.onSurface}');
    debugPrint('  SurfaceVariant: ${adminColorScheme.surfaceContainerHighest}');
    debugPrint('  OnSurfaceVariant: ${adminColorScheme.onSurfaceVariant}');
    debugPrint('--------------------------------');

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
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 40 : 20,
              vertical: 20,
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

                // Stats section with constrained height
                SizedBox(
                  height: isDesktop ? 110 : 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildStatCard(
                        context,
                        title: 'Total Users',
                        value: '1.2K',
                        icon: Icons.people_alt,
                        color: const Color(0xFF5C6BC0),
                        isDesktop: isDesktop,
                      ),
                      _buildStatCard(
                        context,
                        title: 'Monthly Revenue',
                        value: '\$24.8K',
                        icon: Icons.bar_chart,
                        color: const Color(0xFF26A69A),
                        isDesktop: isDesktop,
                      ),
                      _buildStatCard(
                        context,
                        title: 'Bookings',
                        value: '324',
                        icon: Icons.calendar_today,
                        color: const Color(0xFFFF7043),
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

                // Main grid with flexible height
                Expanded(
                  child: GridView.count(
                    crossAxisCount: isDesktop ? 4 : 2,
                    crossAxisSpacing: isDesktop ? 16 : 12,
                    mainAxisSpacing: isDesktop ? 16 : 12,
                    childAspectRatio: isDesktop ? 0.9 : 1.0,
                    children: [
                      _buildActionCard(
                        context,
                        icon: Icons.bar_chart_rounded,
                        title: 'Analytics',
                        color: adminColorScheme.primary,
                        isDesktop: isDesktop,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Analytics functionality coming soon!'),
                              backgroundColor: adminColorScheme.primary.withAlpha((255 * 0.9).round()),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.people,
                        title: 'Users',
                        color: const Color(0xFF4CAF50),
                        isDesktop: isDesktop,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('User management functionality coming soon!'),
                              backgroundColor: const Color(0xFF4CAF50).withAlpha((255 * 0.9).round()),
                            ),
                          );
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.pets,
                        title: 'Pets',
                        color: const Color(0xFFFF9800),
                        isDesktop: isDesktop,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Pet management functionality coming soon!'),
                              backgroundColor: const Color(0xFFFF9800).withAlpha((255 * 0.9).round()),
                            ),
                          );
                        },
                      ),
                      // New "Services" Action Card
                      _buildActionCard(
                        context,
                        icon: Icons.miscellaneous_services,
                        title: 'Services',
                        color: const Color(0xFF03A9F4),
                        isDesktop: isDesktop,
                        onTap: () {
                          context.go('/admin_dashboard/services'); // Navigate to the services management screen
                        },
                      ),
                      _buildActionCard(
                        context,
                        icon: Icons.settings,
                        title: 'Settings',
                        color: const Color(0xFF9C27B0),
                        isDesktop: isDesktop,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Settings functionality coming soon!'),
                              backgroundColor: const Color(0xFF9C27B0).withAlpha((255 * 0.9).round()),
                            ),
                          );
                        },
                      ),
                      if (isDesktop)
                        _buildActionCard(
                          context,
                          icon: Icons.receipt,
                          title: 'Invoices',
                          color: const Color(0xFF795548),
                          isDesktop: isDesktop,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Invoices functionality coming soon!'),
                                backgroundColor: const Color(0xFF795548).withAlpha((255 * 0.9).round()),
                              ),
                            );
                          },
                        ),
                      if (isDesktop)
                        _buildActionCard(
                          context,
                          icon: Icons.history,
                          title: 'Audit Log',
                          color: const Color(0xFF607D8B),
                          isDesktop: isDesktop,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Audit Log functionality coming soon!'),
                                backgroundColor: const Color(0xFF607D8B).withAlpha((255 * 0.9).round()),
                              ),
                            );
                          },
                        ),
                      if (isDesktop)
                        _buildActionCard(
                          context,
                          icon: Icons.notifications,
                          title: 'Alerts',
                          color: const Color(0xFFF44336),
                          isDesktop: isDesktop,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Alerts functionality coming soon!'),
                                backgroundColor: const Color(0xFFF44336).withAlpha((255 * 0.9).round()),
                              ),
                            );
                          },
                        ),
                      if (isDesktop)
                        _buildActionCard(
                          context,
                          icon: Icons.help,
                          title: 'Support',
                          color: const Color(0xFF00BCD4),
                          isDesktop: isDesktop,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Support functionality coming soon!'),
                                backgroundColor: const Color(0xFF00BCD4).withAlpha((255 * 0.9).round()),
                              ),
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
    );
  }

  // Refactored _buildActionCard to accept an onTap callback
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
    required String value,
    required IconData icon,
    required Color color,
    required bool isDesktop,
  }) {
    return Container(
      width: isDesktop ? 190 : 170,
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
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 22,
                  fontWeight: FontWeight.w700,
                  color: color,
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
    );
  }
}
