import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  int _currentIndex = 0;
  List<Map<String, dynamic>> _poojas = [];
  List<Map<String, dynamic>> _events = [];
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final poojasData = await FirebaseService.getPoojasByTempleAsMaps(templeId);
        final eventsData = await FirebaseService.getEventsByTempleAsMaps(templeId);
        final announcementsData = await FirebaseService.getAnnouncementsByTempleAsMaps(templeId);
        
        if (mounted) {
          setState(() {
            _poojas = poojasData;
            _events = eventsData;
            _announcements = announcementsData;
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

  void _refreshData() {
    _loadData();
  }

  final List<Widget> _pages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temple App'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Temple',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/temple-selection');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Poojas'),
          BottomNavigationBarItem(icon: Icon(Icons.visibility), label: 'Darshan'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donate'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return HomeTab(
          poojas: _poojas,
          events: _events,
          announcements: _announcements,
          isLoading: _isLoading,
          onRefresh: _refreshData,
        );
      case 1:
        return PoojasTab(poojas: _poojas, isLoading: _isLoading);
      case 2:
        return const DarshanTab();
      case 3:
        return const DonationsTab();
      case 4:
        return const ProfileTab();
      default:
        return const SizedBox();
    }
  }
}

class HomeTab extends StatelessWidget {
  final List<Map<String, dynamic>> poojas;
  final List<Map<String, dynamic>> events;
  final List<Map<String, dynamic>> announcements;
  final bool isLoading;
  final VoidCallback onRefresh;

  const HomeTab({
    super.key,
    required this.poojas,
    required this.events,
    required this.announcements,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppTheme.primaryGradient,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Consumer<AuthProvider>(
                      builder: (context, auth, child) {
                        return Text(
                          '🙏 Jai Sri Krishna, ${auth.currentUser?.displayName ?? "Devotee"}!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome to the Divine Temple',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, '/pooja-booking', arguments: {}),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Book Pooja'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickAction(Icons.auto_awesome, 'Book Pooja', () => Navigator.pushNamed(context, '/pooja-booking', arguments: {})),
                      _buildQuickAction(Icons.visibility, 'Darshan', () => Navigator.pushNamed(context, '/darshan-booking')),
                      _buildQuickAction(Icons.volunteer_activism, 'Donate', () => Navigator.pushNamed(context, '/donation')),
                      _buildQuickAction(Icons.event, 'Events', () {}),
                    ],
                  ),
                ],
              ),
            ),
            
            // Today's Pooja Schedule
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Poojas",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (poojas.isEmpty)
                    _buildEmptyState('No poojas available today', Icons.auto_awesome)
                  else
                    ...poojas.take(4).map((pooja) => _buildScheduleCard(
                      pooja['name'] ?? 'Pooja',
                      pooja['timing'] ?? '',
                      Icons.wb_sunny,
                    )),
                ],
              ),
            ),
            
            // Announcements
            if (announcements.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Announcements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...announcements.map((announcement) => _buildAnnouncementCard(
                      announcement['title'] ?? 'Announcement',
                      announcement['message'] ?? '',
                    )),
                  ],
                ),
              ),
            ],
            
            // Upcoming Events
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upcoming Events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (events.isEmpty)
                    _buildEmptyState('No upcoming events', Icons.event)
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final event = events[index];
                          return _buildEventCard(
                            event['name'] ?? 'Event',
                            event['date'] ?? '',
                            AppTheme.primaryColor,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(String title, String time, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryLight.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(time),
      ),
    );
  }

  Widget _buildAnnouncementCard(String title, String message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.warningColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.campaign, color: AppTheme.warningColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (message.isNotEmpty)
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(String title, String date, Color color) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class PoojasTab extends StatelessWidget {
  final List<Map<String, dynamic>> poojas;
  final bool isLoading;

  const PoojasTab({
    super.key,
    required this.poojas,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (poojas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No poojas available',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Temple admin will add poojas soon',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: poojas.length,
      itemBuilder: (context, index) {
        final pooja = poojas[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pooja['name'] ?? 'Pooja',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            pooja['timing'] ?? '',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${pooja['price'] ?? 0}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/pooja-booking', arguments: pooja),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DarshanTab extends StatelessWidget {
  const DarshanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temple Darshan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Book your darshan slot to avoid long queues',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Date',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                return Container(
                  width: 60,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: index == 0 ? AppTheme.primaryColor : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1],
                        style: TextStyle(fontSize: 12, color: index == 0 ? Colors.white : Colors.grey[600]),
                      ),
                      Text(
                        '${date.day}',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: index == 0 ? Colors.white : Colors.black),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Available Slots',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          ...['5:00 AM - 6:00 AM', '7:00 AM - 12:00 PM', '5:00 PM - 6:00 PM', '7:00 PM - 8:00 PM'].map(
            (slot) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.access_time, color: AppTheme.primaryColor),
                title: Text(slot),
                subtitle: const Text('Book your slot'),
                trailing: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                  child: const Text('Book'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonationsTab extends StatelessWidget {
  const DonationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Make a Donation',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Your generous donations help maintain the temple',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          // Donation Categories
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _buildDonationCard('Annadanam', 'Food donation', Icons.restaurant, AppTheme.primaryColor),
              _buildDonationCard('Flowers', 'Temple decoration', Icons.local_florist, AppTheme.accentRed),
              _buildDonationCard('Oil Lamps', 'Deepa Daanam', Icons.lightbulb, AppTheme.accentGold),
              _buildDonationCard('General', 'Temple fund', Icons.volunteer_activism, AppTheme.successColor),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Custom Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(hintText: 'Enter amount', prefixText: '₹ '),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                child: const Text('Donate'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [101, 501, 1001, 5001].map((amount) => ActionChip(label: Text('₹$amount'), onPressed: () {})).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDonationCard(String title, String subtitle, IconData icon, Color color) {
    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          ),
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
                              : 'U',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        auth.currentUser?.displayName ?? 'User',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(auth.currentUser?.email ?? '', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Edit Profile')),
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
                _buildMenuItem(Icons.history, 'Booking History', () {}),
                const Divider(height: 1),
                _buildMenuItem(Icons.card_membership, 'My Poojas', () {}),
                const Divider(height: 1),
                _buildMenuItem(Icons.favorite, 'My Donations', () {}),
                const Divider(height: 1),
                _buildMenuItem(Icons.help, 'Help & Support', () {}),
                const Divider(height: 1),
                _buildMenuItem(Icons.info, 'About', () {}),
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
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
