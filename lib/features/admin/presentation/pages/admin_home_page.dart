import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/temple_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final stats = await FirebaseService.getTempleStats(templeId);
        if (mounted) {
          setState(() {
            _stats = stats;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAdminTemplesDialog(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = auth.currentUser?.email;
    
    if (userEmail == null) return;
    
    final temples = await FirebaseService.getTemplesByAdminEmail(userEmail);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('My Temples'),
        content: SizedBox(
          width: double.maxFinite,
          child: temples.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('No temples assigned to you yet.'),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: temples.length,
                  itemBuilder: (context, index) {
                    final temple = temples[index];
                    final templeData = temple.data() as Map<String, dynamic>;
                    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
                    final isSelected = templeProvider.selectedTempleId == temple.id;
                    
                    return ListTile(
                      leading: Icon(
                        Icons.temple_hindu,
                        color: isSelected ? AppTheme.primaryColor : Colors.grey,
                      ),
                      title: Text(
                        templeData['name'] ?? 'Unknown Temple',
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(templeData['location'] ?? ''),
                      trailing: isSelected 
                          ? const Icon(Icons.check_circle, color: AppTheme.primaryColor)
                          : null,
                      onTap: () {
                        templeProvider.selectTemple(
                          TempleModel.fromFirestore(temple.id, templeData),
                        );
                        _loadStats();
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'My Temples',
            onPressed: () {
              Navigator.pushNamed(context, '/admin-temples');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStats,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Poojas'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return DashboardTab(stats: _stats, isLoading: _isLoading, onRefresh: _loadStats);
      case 1:
        return const PoojasManageTab();
      case 2:
        return const EventsManageTab();
      case 3:
        return const AnnouncementsManageTab();
      case 4:
        return const ProfileTab();
      default:
        return const SizedBox();
    }
  }
}

class DashboardTab extends StatelessWidget {
  final Map<String, dynamic> stats;
  final bool isLoading;
  final VoidCallback onRefresh;

  const DashboardTab({
    super.key,
    required this.stats,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🙏 Welcome, Admin!',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your temple from here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Stats Grid
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildStatCard(
                    'Total Bookings',
                    '${stats['totalBookings'] ?? 0}',
                    Icons.calendar_today,
                    AppTheme.primaryColor,
                  ),
                  _buildStatCard(
                    'Total Donations',
                    '₹${(stats['totalDonations'] ?? 0).toStringAsFixed(0)}',
                    Icons.currency_rupee,
                    AppTheme.successColor,
                  ),
                  _buildStatCard(
                    'Active Poojas',
                    '${stats['totalPoojas'] ?? 0}',
                    Icons.auto_awesome,
                    AppTheme.accentGold,
                  ),
                  _buildStatCard(
                    'Upcoming Events',
                    '${stats['totalEvents'] ?? 0}',
                    Icons.event,
                    AppTheme.accentRed,
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildActionCard(
                  'Add Pooja',
                  Icons.add_circle,
                  () => Navigator.pushNamed(context, '/add-pooja'),
                ),
                _buildActionCard(
                  'Add Event',
                  Icons.event_available,
                  () => Navigator.pushNamed(context, '/add-event'),
                ),
                _buildActionCard(
                  'Announcement',
                  Icons.campaign,
                  () => Navigator.pushNamed(context, '/create-announcement'),
                ),
                _buildActionCard(
                  'View Bookings',
                  Icons.list_alt,
                  () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PoojasManageTab extends StatelessWidget {
  const PoojasManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Manage Poojas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add, edit, or remove poojas',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-pooja'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Pooja'),
            ),
          ],
        ),
      ),
    );
  }
}

class EventsManageTab extends StatelessWidget {
  const EventsManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Manage Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create and manage temple events',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/add-event'),
              icon: const Icon(Icons.add),
              label: const Text('Add New Event'),
            ),
          ],
        ),
      ),
    );
  }
}

class AnnouncementsManageTab extends StatelessWidget {
  const AnnouncementsManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.campaign, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Manage Announcements',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Create important announcements',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/create-announcement'),
              icon: const Icon(Icons.add),
              label: const Text('Create Announcement'),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          (auth.currentUser?.displayName?.isNotEmpty ?? false)
                              ? auth.currentUser!.displayName![0].toUpperCase()
                              : 'A',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.currentUser?.displayName ?? 'Admin',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(auth.currentUser?.email ?? '', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Temple Admin',
                          style: TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.settings, color: AppTheme.primaryColor),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info, color: AppTheme.primaryColor),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final auth = Provider.of<AuthProvider>(context, listen: false);
                await auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
