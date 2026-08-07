import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/temple_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';
import 'add_pooja_page.dart';
import 'add_event_page.dart';
import 'create_announcement_page.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temple Admin'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Temple',
            onPressed: () => _showTempleSelector(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Consumer<TempleProvider>(
            builder: (context, templeProvider, child) {
              if (templeProvider.selectedTempleId == null) {
                return Container(
                  width: double.infinity,
                  color: AppTheme.accentGold.withValues(alpha: 0.1),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber, color: AppTheme.accentGold),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Please select a temple to manage',
                          style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w500),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _showTempleSelector(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGold,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Select Temple'),
                      ),
                    ],
                  ),
                );
              }
              return Container(
                width: double.infinity,
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Managing: ${templeProvider.selectedTemple?.name ?? "Unknown"}',
                        style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _showTempleSelector(context),
                      child: const Text('Change'),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Poojas'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library), label: 'Gallery'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const AdminDashboardTab();
      case 1:
        return const AdminPoojasTab();
      case 2:
        return const AdminBookingsTab();
      case 3:
        return const AdminGalleryTab();
      case 4:
        return const AdminDonationsTab();
      case 5:
        return const AdminProfileTab();
      default:
        return const SizedBox();
    }
  }

  void _showTempleSelector(BuildContext context) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = auth.currentUser?.email;
    
    if (userEmail == null) return;
    
    final temples = await FirebaseService.getTemplesByAdminEmail(userEmail);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Temple'),
        content: SizedBox(
          width: double.maxFinite,
          child: temples.isEmpty
              ? const Center(child: Text('No temples assigned to you.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: temples.length,
                  itemBuilder: (context, index) {
                    final temple = temples[index];
                    final templeData = temple.data() as Map<String, dynamic>;
                    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
                    final isSelected = templeProvider.selectedTempleId == temple.id;
                    
                    return ListTile(
                      leading: Icon(Icons.temple_hindu, color: isSelected ? AppTheme.primaryColor : Colors.grey),
                      title: Text(templeData['name'] ?? 'Unknown'),
                      subtitle: Text(templeData['location'] ?? ''),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primaryColor) : null,
                      onTap: () {
                        templeProvider.selectTemple(TempleModel.fromFirestore(temple.id, templeData));
                        Navigator.pop(context);
                        setState(() {}); // Refresh to load new temple data
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Admin Dashboard Tab
class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentPoojas = [];
  List<Map<String, dynamic>> _recentEvents = [];
  List<Map<String, dynamic>> _recentAnnouncements = [];

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
        final stats = await FirebaseService.getTempleStats(templeId);
        final poojas = await FirebaseService.getPoojasByTempleAsMaps(templeId);
        final events = await FirebaseService.getEventsByTempleAsMaps(templeId);
        final announcements = await FirebaseService.getAnnouncementsByTempleAsMaps(templeId);
        
        if (mounted) {
          setState(() {
            _stats = stats;
            _recentPoojas = poojas.take(3).toList();
            _recentEvents = events.take(3).toList();
            _recentAnnouncements = announcements.take(3).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => _loadData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        '🙏 Welcome, ${auth.currentUser?.displayName?.split(' ').first ?? 'Admin'}!',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Manage your temple from here',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            if (_isLoading)
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
                  _buildStatCard('Total Bookings', '${_stats['totalBookings'] ?? 0}', Icons.calendar_today, AppTheme.primaryColor),
                  _buildStatCard('Total Donations', '\$${((_stats['totalDonations'] ?? 0).toDouble()).toStringAsFixed(0)}', Icons.attach_money, AppTheme.successColor),
                  _buildStatCard('Active Poojas', '${_stats['totalPoojas'] ?? 0}', Icons.auto_awesome, AppTheme.accentGold),
                  _buildStatCard('Upcoming Events', '${_stats['totalEvents'] ?? 0}', Icons.event, AppTheme.accentRed),
                ],
              ),

            const SizedBox(height: 24),

            const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
              children: [
                _buildActionCard('Add Pooja', Icons.add_circle, () => _navigateToAddPooja()),
                _buildActionCard('Add Event', Icons.event_available, () => _navigateToAddEvent()),
                _buildActionCard('Announcement', Icons.campaign, () => _navigateToCreateAnnouncement()),
                _buildActionCard('Add Gallery', Icons.add_photo_alternate, () => _showGalleryUploadDialog()),
              ],
            ),

            const SizedBox(height: 24),

            if (_recentPoojas.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Recent Poojas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              ..._recentPoojas.map((pooja) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.auto_awesome)),
                  title: Text(pooja['name'] ?? ''),
                  subtitle: Text('\$${pooja['price']} \u2022 ${pooja['timing']}'),
                  trailing: Chip(
                    label: Text(
                      pooja['isActive'] == true ? 'Active' : 'Inactive',
                      style: const TextStyle(fontSize: 10),
                    ),
                    backgroundColor: pooja['isActive'] == true ? Colors.green[100] : Colors.grey[200],
                  ),
                ),
              )),
              const SizedBox(height: 16),
            ],

            if (_recentEvents.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Upcoming Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              ..._recentEvents.map((event) {
                DateTime eventDate = DateTime.tryParse(event['eventDate'] ?? '') ?? DateTime.now();
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.event)),
                    title: Text(event['name'] ?? ''),
                    subtitle: Text(DateFormat('dd MMM, hh:mm a').format(eventDate)),
                    trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToAddPooja() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddPoojaPage()),
    );
    if (result == true) _loadData();
  }

  void _navigateToAddEvent() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEventPage()),
    );
    if (result == true) _loadData();
  }

  void _navigateToCreateAnnouncement() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateAnnouncementPage()),
    );
    if (result == true) _loadData();
  }

  void _showGalleryUploadDialog() {
    final urlController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Gallery Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Image description...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.isNotEmpty) {
                final templeProvider = Provider.of<TempleProvider>(context, listen: false);
                final templeId = templeProvider.selectedTempleId;
                if (templeId != null) {
                  await FirebaseService.addGalleryImage(templeId, {
                    'imageUrl': urlController.text,
                    'description': descController.text,
                    'isActive': true,
                  });
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Image added to gallery!')),
                    );
                  }
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
                decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Poojas Tab - FULLY FUNCTIONAL
class AdminPoojasTab extends StatefulWidget {
  const AdminPoojasTab({super.key});

  @override
  State<AdminPoojasTab> createState() => _AdminPoojasTabState();
}

class _AdminPoojasTabState extends State<AdminPoojasTab> {
  List<Map<String, dynamic>> _poojas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPoojas();
  }

  Future<void> _loadPoojas() async {
    setState(() => _isLoading = true);
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final poojas = await FirebaseService.getPoojasByTempleAsMaps(templeId);
        if (mounted) {
          setState(() {
            _poojas = poojas;
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePooja(String poojaId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pooja'),
        content: const Text('Are you sure you want to delete this pooja?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService.deletePooja(poojaId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pooja deleted!')),
        );
        _loadPoojas();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _poojas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Poojas Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Add your first pooja to get started', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddPoojaPage()),
                          );
                          if (result == true) _loadPoojas();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Pooja'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadPoojas(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _poojas.length,
                    itemBuilder: (context, index) {
                      final pooja = _poojas[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                          ),
                          title: Text(pooja['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('\$${pooja['''price''']} \u2022 ${pooja['''timing''']}'),
                              Text('${pooja['bookedSlots'] ?? 0}/${pooja['availableSlots']} slots booked', style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          trailing: PopupMenuButton(
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 20),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 20, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddPoojaPage(
                                      pooja: pooja,
                                      poojaId: pooja['id'],
                                    ),
                                  ),
                                ).then((result) {
                                  if (result == true) _loadPoojas();
                                });
                              } else if (value == 'delete') {
                                _deletePooja(pooja['id']);
                              }
                            },
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPoojaPage()),
          );
          if (result == true) _loadPoojas();
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// Admin Bookings Tab - FULLY FUNCTIONAL
class AdminBookingsTab extends StatefulWidget {
  const AdminBookingsTab({super.key});

  @override
  State<AdminBookingsTab> createState() => _AdminBookingsTabState();
}

class _AdminBookingsTabState extends State<AdminBookingsTab> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final bookings = await FirebaseService.getBookingsByTemple(templeId);
        if (mounted) {
          setState(() {
            _bookings = bookings.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Bookings Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Bookings will appear here when users book poojas', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadBookings(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      final bookingDate = booking['bookingDate'] ?? '';
                      final bookingTime = booking['bookingTime'] ?? '';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppTheme.primaryColor),
                          ),
                          title: Text(
                            booking['poojaName'] ?? 'Pooja',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('👤 ${booking['userName'] ?? 'Unknown'}'),
                              Text('📅 $bookingDate • 🕐 $bookingTime'),
                              Text('💰 \$${(booking['''poojaPrice'''] ?? 0).toStringAsFixed(0)}'),
                              if (booking['userPhone'] != null) ...[
                                Text('📞 ${booking['userPhone']}'),
                              ],
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking['status']).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (booking['status'] ?? 'confirmed').toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(booking['status']),
                              ),
                            ),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'confirmed':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.accentGold;
      case 'cancelled':
        return AppTheme.errorColor;
      default:
        return Colors.grey;
    }
  }
}

// Admin Gallery Tab - FULLY FUNCTIONAL
class AdminGalleryTab extends StatefulWidget {
  const AdminGalleryTab({super.key});

  @override
  State<AdminGalleryTab> createState() => _AdminGalleryTabState();
}

class _AdminGalleryTabState extends State<AdminGalleryTab> {
  List<Map<String, dynamic>> _images = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _isLoading = true);
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final docs = await FirebaseService.getGalleryByTemple(templeId);
        if (mounted) {
          setState(() {
            _images = docs.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddImageDialog() {
    final urlController = TextEditingController();
    final descController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Gallery Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'Image URL *',
                hintText: 'https://...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Temple Exterior',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (urlController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an image URL')),
                );
                return;
              }
              final templeProvider = Provider.of<TempleProvider>(context, listen: false);
              final templeId = templeProvider.selectedTempleId;
              if (templeId != null) {
                await FirebaseService.addGalleryImage(templeId, {
                  'imageUrl': urlController.text.trim(),
                  'description': descController.text.trim(),
                  'isActive': true,
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Image added to gallery!')),
                  );
                  _loadImages();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteImage(String imageId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('Are you sure you want to delete this image?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FirebaseService.deleteGalleryImage(imageId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image deleted!')),
        );
        _loadImages();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _images.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_library, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('No Gallery Images', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Add photos to showcase your temple', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddImageDialog,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Photos'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadImages(),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _images.length,
                    itemBuilder: (context, index) {
                      final image = _images[index];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Colors.grey[200],
                              child: image['imageUrl'] != null
                                  ? Image.network(image['imageUrl'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 50, color: Colors.grey))
                                  : const Icon(Icons.image, size: 50, color: Colors.grey),
                            ),
                            Positioned(
                              top: 4,
                              right: 4,
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                                style: IconButton.styleFrom(backgroundColor: Colors.red.withValues(alpha: 0.8)),
                                onPressed: () => _deleteImage(image['id']),
                              ),
                            ),
                            if (image['description'] != null && image['description'].toString().isNotEmpty)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black54,
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    image['description'],
                                    style: const TextStyle(color: Colors.white, fontSize: 11),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddImageDialog,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
    );
  }
}

// Admin Donations Tab - FULLY FUNCTIONAL
class AdminDonationsTab extends StatefulWidget {
  const AdminDonationsTab({super.key});

  @override
  State<AdminDonationsTab> createState() => _AdminDonationsTabState();
}

class _AdminDonationsTabState extends State<AdminDonationsTab> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _donations = [];
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
        final categories = await FirebaseService.getDonationCategoriesByTemple(templeId);
        final donations = await FirebaseService.getDonationsByTemple(templeId);
        if (mounted) {
          setState(() {
            _categories = categories.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
            _donations = donations.map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id}).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddCategoryDialog() {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Donation Category'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
                  hintText: 'e.g., Temple Maintenance',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price (\$',
                  hintText: 'e.g., 100',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a category name')),
                );
                return;
              }
              final templeProvider = Provider.of<TempleProvider>(context, listen: false);
              final templeId = templeProvider.selectedTempleId;
              if (templeId != null) {
                await FirebaseService.addDonationCategory(templeId, {
                  'name': nameController.text.trim(),
                  'price': double.tryParse(priceController.text.trim()) ?? 0.0,
                  'description': descController.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Category added!')),
                  );
                  _loadData();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCategory(String categoryId) async {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    if (templeId == null) return;
    await FirebaseService.deleteDonationCategory(templeId, categoryId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category deleted!')),
      );
      _loadData();
    }
  }

  double get _totalDonations {
    return _donations.fold(0.0, (sum, d) => sum + ((d['amount'] ?? 0) as num).toDouble());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Donation Summary Card
                    Card(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.attach_money, color: AppTheme.successColor, size: 40),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Donations', style: TextStyle(color: Colors.grey)),
                                Text(
                                  '\$${_totalDonations.toStringAsFixed(0)}',
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.successColor),
                                ),
                                Text('${_donations.length} donations received', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Donation Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton.icon(
                          onPressed: _showAddCategoryDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    if (_categories.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.category, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No categories yet'),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _showAddCategoryDialog,
                                  child: const Text('Add First Category'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...(_categories.map((cat) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.category, color: AppTheme.accentGold, size: 20),
                          ),
                          title: Text(cat['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(cat['description'] ?? 'No description'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(cat['id']),
                          ),
                        ),
                      ))),

                    const SizedBox(height: 24),
                    const Text('Recent Donations', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    if (_donations.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.volunteer_activism, size: 50, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No donations yet'),
                              ],
                            ),
                          ),
                        ),
                      )
                      else
                        ...(_donations.take(10).map((donation) => Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.successColor.withValues(alpha: 0.1),
                              child: const Icon(Icons.attach_money, color: AppTheme.successColor),
                            ),
                            title: Text('\$${(donation['''amount'''] ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${donation['donorName'] ?? 'Anonymous'} • ${donation['category'] ?? 'General'}'),
                            trailing: Chip(
                              label: Text(
                                donation['status'] ?? 'pending',
                                style: const TextStyle(fontSize: 10),
                              ),
                              backgroundColor: Colors.green[100],
                            ),
                          ),
                        ))),
                  ],
                ),
              ),
            ),
    );
  }
}

// Admin Darshan Tab - FULLY FUNCTIONAL
class AdminDarshanTab extends StatefulWidget {
  const AdminDarshanTab({super.key});

  @override
  State<AdminDarshanTab> createState() => _AdminDarshanTabState();
}

class _AdminDarshanTabState extends State<AdminDarshanTab> {
  final _streamUrlController = TextEditingController();
  bool _isLoading = false;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final temple = templeProvider.selectedTemple;
    if (temple != null) {
      _streamUrlController.text = temple.liveStreamUrl ?? '';
      _isLive = temple.isLive ?? false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _saveStreamUrl() async {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseService.updateLiveDarshan(templeId, _streamUrlController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Live stream settings saved!')),
        );
        _loadSettings();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live Darshan Settings
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _isLive ? Colors.red.withValues(alpha: 0.1) : AppTheme.accentRed.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.live_tv,
                            color: _isLive ? Colors.red : AppTheme.accentRed,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Live Streaming', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                _isLive ? 'Currently LIVE' : 'Not streaming',
                                style: TextStyle(fontSize: 12, color: _isLive ? Colors.red : Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isLive,
                          onChanged: (value) {
                            setState(() => _isLive = value);
                            _saveStreamUrl();
                          },
                          activeThumbColor: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _streamUrlController,
                      decoration: InputDecoration(
                        labelText: 'YouTube/Vimeo Stream URL',
                        hintText: 'https://youtube.com/live/...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveStreamUrl,
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Save Stream URL'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Temple Info Settings
            const Text('Temple Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer<TempleProvider>(
              builder: (context, templeProvider, child) {
                final temple = templeProvider.selectedTemple;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoTile('Temple Name', temple?.name ?? 'Not selected'),
                        const Divider(),
                        _buildInfoTile('Location', temple?.location ?? 'Not set'),
                        const Divider(),
                        _buildInfoTile('Deity', temple?.deity ?? 'Not set'),
                        const Divider(),
                        _buildInfoTile('Phone', temple?.phone ?? 'Not set'),
                        const Divider(),
                        _buildInfoTile('Email', temple?.email ?? 'Not set'),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Temple Timings
            const Text('Temple Timings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Consumer<TempleProvider>(
              builder: (context, templeProvider, child) {
                final timings = templeProvider.selectedTemple?.timings;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildTimingRow('Morning Open', timings?['morningOpen'] ?? '5:00 AM'),
                        const Divider(),
                        _buildTimingRow('Morning Close', timings?['morningClose'] ?? '12:00 PM'),
                        const Divider(),
                        _buildTimingRow('Evening Open', timings?['eveningOpen'] ?? '3:00 PM'),
                        const Divider(),
                        _buildTimingRow('Evening Close', timings?['eveningClose'] ?? '9:00 PM'),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => _showTimingsDialog(),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Timings'),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTimingsDialog() {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final timings = templeProvider.selectedTemple?.timings;
    
    final morningOpenCtrl = TextEditingController(text: timings?['morningOpen'] ?? '5:00 AM');
    final morningCloseCtrl = TextEditingController(text: timings?['morningClose'] ?? '12:00 PM');
    final eveningOpenCtrl = TextEditingController(text: timings?['eveningOpen'] ?? '3:00 PM');
    final eveningCloseCtrl = TextEditingController(text: timings?['eveningClose'] ?? '9:00 PM');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Temple Timings'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: morningOpenCtrl, decoration: const InputDecoration(labelText: 'Morning Open (e.g., 5:00 AM)')),
              const SizedBox(height: 8),
              TextField(controller: morningCloseCtrl, decoration: const InputDecoration(labelText: 'Morning Close (e.g., 12:00 PM)')),
              const SizedBox(height: 8),
              TextField(controller: eveningOpenCtrl, decoration: const InputDecoration(labelText: 'Evening Open (e.g., 3:00 PM)')),
              const SizedBox(height: 8),
              TextField(controller: eveningCloseCtrl, decoration: const InputDecoration(labelText: 'Evening Close (e.g., 9:00 PM)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final templeId = templeProvider.selectedTempleId;
              if (templeId != null) {
                await FirebaseService.updateTempleTimings(templeId, {
                  'morningOpen': morningOpenCtrl.text.trim(),
                  'morningClose': morningCloseCtrl.text.trim(),
                  'eveningOpen': eveningOpenCtrl.text.trim(),
                  'eveningClose': eveningCloseCtrl.text.trim(),
                });
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Timings updated!')),
                  );
                  _loadSettings();
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Flexible(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTimingRow(String label, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(time, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// Admin Profile Tab
class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

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
                      Text(auth.currentUser?.displayName ?? 'Admin', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(auth.currentUser?.email ?? '', style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text('Temple Admin', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w500)),
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
                  leading: const Icon(Icons.help, color: AppTheme.primaryColor),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Contact: support@templeapp.com')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info, color: AppTheme.primaryColor),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Temple App',
                      applicationVersion: '1.0.0',
                      applicationLegalese: '© 2024 Temple App. All rights reserved.',
                    );
                  },
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
