import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:pawpal/providers/admin_stats_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminStatsProvider>(context, listen: false).fetchAdminStats();
    });
  }

  // Helper function to format large revenue numbers
  String formatRevenue(num value) {
    if (value >= 1000000000) {
      return 'KES ${(value / 1000000000).toStringAsFixed(2)}B';
    } else if (value >= 1000000) {
      return 'KES ${(value / 1000000).toStringAsFixed(2)}M';
    } else if (value >= 1000) {
      return 'KES ${(value / 1000).toStringAsFixed(2)}K';
    } else {
      return 'KES ${value.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 600;
    final adminStatsProvider = Provider.of<AdminStatsProvider>(context);

    // Modern color scheme
    const primaryColor = Color(0xFF4361EE);
    const secondaryColor = Color(0xFF6C5CE7);
    const accentColor = Color(0xFF00CEC9);
    const backgroundColor = Color(0xFFF8F9FE);
    const cardColor = Colors.white;
    const textColor = Color(0xFF2D3436);
    const lightTextColor = Color(0xFF636E72);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: backgroundColor,
        cardTheme: CardTheme(
          color: cardColor,
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(8),
        ),
        textTheme: Theme.of(context).textTheme.copyWith(
              headlineMedium: const TextStyle(
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
              titleMedium: TextStyle(
                color: lightTextColor,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: const TextStyle(
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () => adminStatsProvider.fetchAdminStats(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
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
                              Flexible(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dashboard Overview',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(fontSize: isDesktop ? 32 : 26),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Manage your application efficiently',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                              ),
                              if (isDesktop)
                                const CircleAvatar(
                                  radius: 32,
                                  backgroundColor: primaryColor,
                                  child: Icon(
                                    Icons.admin_panel_settings,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 30),

                          // Stats section
                          _buildStatsSection(context, adminStatsProvider, isDesktop),
                          const SizedBox(height: 30),

                          // Management tools header
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              'Management Tools',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    fontSize: isDesktop ? 24 : 20,
                                  ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Grid with management tools
                          _buildToolsGrid(context, isDesktop),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(
      BuildContext context, AdminStatsProvider adminStatsProvider, bool isDesktop) {
    return adminStatsProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : adminStatsProvider.errorMessage != null
            ? Center(
                child: Text(
                  'Error loading stats: ${adminStatsProvider.errorMessage}',
                  style: const TextStyle(color: Colors.red),
                ),
              )
            : SizedBox(
                height: isDesktop ? 130 : 110,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    const SizedBox(width: 8),
                    _buildStatCard(
                      context,
                      title: 'Total Users',
                      value: adminStatsProvider.totalUsers.toString(),
                      icon: Icons.people_alt,
                      color: const Color(0xFF5C6BC0),
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'Total Pets',
                      value: adminStatsProvider.totalPets.toString(),
                      icon: Icons.pets,
                      color: const Color(0xFF26A69A),
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'Total Bookings',
                      value: adminStatsProvider.totalBookings.toString(),
                      icon: Icons.calendar_today,
                      color: const Color(0xFFFF7043),
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      context,
                      title: 'Total Revenue',
                      value: formatRevenue(adminStatsProvider.totalRevenue),
                      icon: Icons.attach_money,
                      color: const Color(0xFF7CB342),
                      isDesktop: isDesktop,
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              );
  }

  Widget _buildToolsGrid(BuildContext context, bool isDesktop) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: isDesktop ? 4 : 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.0,
      children: [
        _buildActionCard(
          context,
          icon: Icons.miscellaneous_services,
          title: 'Services',
          color: const Color(0xFF03A9F4),
          onTap: () => context.go('/admin_dashboard/services'),
        ),
        _buildActionCard(
          context,
          icon: Icons.event_note,
          title: 'Bookings',
          color: const Color(0xFF8E24AA),
          onTap: () => context.go('/admin_dashboard/bookings'),
        ),
        _buildActionCard(
          context,
          icon: Icons.people,
          title: 'Users',
          color: const Color(0xFFD81B60),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User management coming soon!')),
          ),
        ),
        _buildActionCard(
          context,
          icon: Icons.settings,
          title: 'Settings',
          color: const Color(0xFF607D8B),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('App settings coming soon!')),
          ),
        ),
      ],
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
      width: isDesktop ? 180 : 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: isDesktop ? 20 : 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 14 : 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF495057),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.7),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 28, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
