
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
