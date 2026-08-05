import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/temple_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class SuperAdminHomePage extends StatefulWidget {
  const SuperAdminHomePage({super.key});

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TempleProvider>(context, listen: false).loadTemples();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Provider.of<TempleProvider>(context, listen: false).loadTemples(),
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.temple_hindu), label: 'Temples'),
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings), label: 'Admins'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget? _buildFAB() {
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton.extended(
          onPressed: () => _showAddTempleDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Temple'),
          backgroundColor: AppTheme.primaryColor,
        );
      case 2:
        return FloatingActionButton.extended(
          onPressed: () => _showAddAdminDialog(context),
          icon: const Icon(Icons.person_add),
          label: const Text('Add Admin'),
          backgroundColor: AppTheme.primaryColor,
        );
      default:
        return null;
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return DashboardTab(onTabSwitch: (index) => setState(() => _currentIndex = index));
      case 1:
        return const TemplesTab();
      case 2:
        return const AdminsTab();
      case 3:
        return const UsersTab();
      case 4:
        return const ProfileTab();
      default:
        return const SizedBox();
    }
  }

  void _showAddTempleDialog(BuildContext context) {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final deityController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Temple'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Temple Name *')),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location *')),
              TextField(controller: deityController, decoration: const InputDecoration(labelText: 'Deity')),
              TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill required fields')));
                return;
              }
              try {
                final temple = TempleModel(
                  id: '', name: nameController.text, location: locationController.text,
                  deity: deityController.text.isEmpty ? null : deityController.text,
                  address: addressController.text.isEmpty ? null : addressController.text,
                  phone: phoneController.text.isEmpty ? null : phoneController.text,
                  email: emailController.text.isEmpty ? null : emailController.text,
                  description: descriptionController.text.isEmpty ? null : descriptionController.text, isActive: true,
                );
                await FirebaseService.addTemple(temple.toFirestore());
                if (context.mounted) {
                  Provider.of<TempleProvider>(context, listen: false).loadTemples();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Temple added successfully!')));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog(BuildContext context) {
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    String? selectedTempleId;
    final temples = Provider.of<TempleProvider>(context, listen: false).temples;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Temple Admin'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter the email of an existing user to promote them to Admin', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'User Email *', hintText: 'user@example.com'), keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Admin Display Name *')),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedTempleId,
                  decoration: const InputDecoration(labelText: 'Select Temple *'),
                  items: temples.map((temple) => DropdownMenuItem(value: temple.id, child: Text(temple.name, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) => setDialogState(() => selectedTempleId = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (emailController.text.isEmpty || nameController.text.isEmpty || selectedTempleId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                try {
                  final templeName = temples.firstWhere((t) => t.id == selectedTempleId).name;
                  final email = emailController.text.toLowerCase();
                  
                  print('🔍 DEBUG SUPER ADMIN: Adding admin with email=$email');
                  
                  // 1. First, check if user already exists in users collection
                  final existingUsers = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: email)
                      .get();
                  
                  print('🔍 DEBUG SUPER ADMIN: Found ${existingUsers.docs.length} existing users');
                  
                  if (existingUsers.docs.isNotEmpty) {
                    // User exists - update their role to temple_admin
                    await existingUsers.docs.first.reference.update({
                      'role': 'temple_admin',
                      'templeId': selectedTempleId,
                      'templeName': templeName,
                    });
                    print('🔍 DEBUG SUPER ADMIN: Updated existing user to temple_admin');
                  }
                  
                  // 2. Use FirebaseService.addAdmin to create admin record
                  final adminId = await FirebaseService.addAdmin(
                    email,
                    nameController.text,
                    selectedTempleId!,
                    templeName,
                  );
                  print('🔍 DEBUG SUPER ADMIN: Created admin in admins collection with id=$adminId');
                  
                  // 3. Also update temple with admin info
                  await FirebaseFirestore.instance.collection('temples').doc(selectedTempleId).update({
                    'adminId': adminId,
                    'adminName': nameController.text,
                    'adminEmail': email,
                  });
                  print('🔍 DEBUG SUPER ADMIN: Updated temple with admin info');
                  
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      SnackBar(content: Text('Admin added! They will go to ${templeName} Admin Dashboard when they sign in.'))
                    );
                    setState(() {}); // Refresh
                  }
                } catch (e) {
                  print('🔍 DEBUG SUPER ADMIN ERROR: $e');
                  if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
              child: const Text('Add Admin'),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  final Function(int) onTabSwitch;
  
  const DashboardTab({super.key, required this.onTabSwitch});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  int _totalAdmins = 0;
  int _totalUsers = 0;
  int _totalBookings = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);
    
    try {
      // Get total admins count
      final adminsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'temple_admin')
          .get();
      
      // Get total users count
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      
      // Get total bookings count (across all temples)
      final bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .get();
      
      if (mounted) {
        setState(() {
          _totalAdmins = adminsSnapshot.size;
          _totalUsers = usersSnapshot.size;
          _totalBookings = bookingsSnapshot.size;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, child) => Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🙏 Welcome, Super Admin!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(auth.currentUser?.email ?? '', style: const TextStyle(fontSize: 14, color: Colors.white70)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Quick Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<TempleProvider>(
              builder: (context, provider, child) => _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: [
                        _buildStatCard('Total Temples', '${provider.temples.length}', Icons.temple_hindu, AppTheme.primaryColor),
                        _buildStatCard('Active Admins', '$_totalAdmins', Icons.admin_panel_settings, AppTheme.accentGold),
                        _buildStatCard('Total Users', '$_totalUsers', Icons.people, AppTheme.successColor),
                        _buildStatCard('Total Bookings', '$_totalBookings', Icons.calendar_today, AppTheme.accentRed),
                      ],
                    ),
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
              childAspectRatio: 1.5,
              children: [
                _buildActionCard(context, 'Add Temple', Icons.add_business, () => widget.onTabSwitch(1)),
                _buildActionCard(context, 'Add Admin', Icons.person_add, () => widget.onTabSwitch(2)),
                _buildActionCard(context, 'View Reports', Icons.analytics, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reports feature coming soon!'))
                  );
                }),
                _buildActionCard(context, 'Settings', Icons.settings, () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings feature coming soon!'))
                  );
                }),
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
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class TemplesTab extends StatelessWidget {
  const TemplesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TempleProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.temples.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.temple_hindu, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No Temples Added', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Tap the + button to add temples', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.temples.length,
          itemBuilder: (context, index) {
            final temple = provider.temples[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.primaryLight.withValues(alpha: 0.2), shape: BoxShape.circle),
                  child: const Icon(Icons.temple_hindu, color: AppTheme.primaryColor),
                ),
                title: Text(temple.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(temple.location),
                    if (temple.deity != null && temple.deity!.isNotEmpty) Text(temple.deity!, style: const TextStyle(color: AppTheme.accentGold)),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 20), SizedBox(width: 8), Text('Edit')])),
                    const PopupMenuItem(value: 'admins', child: Row(children: [Icon(Icons.admin_panel_settings, size: 20), SizedBox(width: 8), Text('Manage Admins')])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 20, color: Colors.red), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))])),
                  ],
                  onSelected: (value) {
                    if (value == 'delete') _showDeleteConfirmation(context, temple);
                  },
                ),
                isThreeLine: true,
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, TempleModel temple) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Temple'),
        content: Text('Are you sure you want to delete "${temple.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await Provider.of<TempleProvider>(context, listen: false).deleteTemple(temple.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Temple deleted')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class AdminsTab extends StatelessWidget {
  const AdminsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'temple_admin').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final admins = snapshot.data?.docs ?? [];
        
        if (admins.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.admin_panel_settings, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No Admins Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Tap the + button to add admins', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: admins.length,
          itemBuilder: (context, index) {
            final admin = admins[index];
            final data = admin.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text((data['name'] ?? 'A')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(data['name'] ?? 'Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteAdminConfirmation(context, admin.id, data['name'] ?? 'Admin'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteAdminConfirmation(BuildContext context, String adminId, String adminName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete admin "$adminName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('users').doc(adminId).delete();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Admin deleted')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class UsersTab extends StatelessWidget {
  const UsersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'user').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        
        final users = snapshot.data?.docs ?? [];
        
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('No Users Yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Users will appear here once they register', style: TextStyle(color: Colors.grey[600])),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            final data = user.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.successColor,
                  child: Text((data['name'] ?? 'U')[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
                ),
                title: Text(data['name'] ?? 'User', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(data['email'] ?? ''),
              ),
            );
          },
        );
      },
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
            builder: (context, auth, child) => Card(
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
                            : 'S',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(auth.currentUser?.displayName ?? 'Super Admin', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(auth.currentUser?.email ?? '', style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.accentGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text('Super Admin', style: TextStyle(color: AppTheme.accentGold, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
            ),
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
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
