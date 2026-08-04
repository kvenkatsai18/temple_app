import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SuperAdminHomePage extends StatefulWidget {
  const SuperAdminHomePage({super.key});

  @override
  State<SuperAdminHomePage> createState() => _SuperAdminHomePageState();
}

class _SuperAdminHomePageState extends State<SuperAdminHomePage> {
  List<Map<String, dynamic>> _temples = [
    {
      'id': '1',
      'name': 'Sri Krishna Temple',
      'location': 'Mathura, UP',
      'deity': 'Lord Krishna',
      'adminName': 'Ramesh Patel',
      'adminEmail': 'ramesh@temple.com',
      'usersCount': 1250,
      'monthlyDonations': 45000,
      'isActive': true,
    },
    {
      'id': '2',
      'name': 'Badrinath Temple',
      'location': 'Badrinath, Uttarakhand',
      'deity': 'Lord Vishnu',
      'adminName': 'Suresh Sharma',
      'adminEmail': 'suresh@temple.com',
      'usersCount': 2100,
      'monthlyDonations': 89000,
      'isActive': true,
    },
    {
      'id': '3',
      'name': 'Tirumala Temple',
      'location': 'Tirupati, AP',
      'deity': 'Lord Venkateswara',
      'adminName': 'Venkatesh Rao',
      'adminEmail': 'venkatesh@temple.com',
      'usersCount': 5200,
      'monthlyDonations': 250000,
      'isActive': true,
    },
    {
      'id': '4',
      'name': 'Somnath Temple',
      'location': 'Prabhas Patan, Gujarat',
      'deity': 'Lord Shiva',
      'adminName': 'Not Assigned',
      'adminEmail': '',
      'usersCount': 890,
      'monthlyDonations': 32000,
      'isActive': false,
    },
  ];

  List<Map<String, dynamic>> _templeAdmins = [
    {'id': '1', 'name': 'Ramesh Patel', 'email': 'ramesh@temple.com', 'temple': 'Sri Krishna Temple', 'status': 'Active'},
    {'id': '2', 'name': 'Suresh Sharma', 'email': 'suresh@temple.com', 'temple': 'Badrinath Temple', 'status': 'Active'},
    {'id': '3', 'name': 'Venkatesh Rao', 'email': 'venkatesh@temple.com', 'temple': 'Tirumala Temple', 'status': 'Active'},
    {'id': '4', 'name': 'Pending...', 'email': 'N/A', 'temple': 'Somnath Temple', 'status': 'Pending'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotificationsDialog();
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && mounted) {
                  Provider.of<AuthProvider>(context, listen: false).signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person, size: 20),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, size: 20),
                    SizedBox(width: 8),
                    Text('Settings'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 20, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('Logout', style: TextStyle(color: AppTheme.errorColor)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B46C1), Color(0xFF9F7AEA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B46C1).withValues(alpha: 0.3),
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
                      const Icon(Icons.verified, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Super Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Temple Management Platform',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.analytics, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Platform Owner',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage temples, admins, and monitor platform performance',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.temple_hindu,
                    title: 'Total Temples',
                    value: '${_temples.length}',
                    color: AppTheme.primaryColor,
                    onTap: () => _showAllTemplesDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.admin_panel_settings,
                    title: 'Temple Admins',
                    value: '${_templeAdmins.where((a) => a['status'] == 'Active').length}',
                    color: const Color(0xFF6B46C1),
                    onTap: () => _showAllAdminsDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.people,
                    title: 'Total Users',
                    value: '${_temples.fold(0, (sum, t) => sum + (t['usersCount'] as int))}',
                    color: const Color(0xFF38A169),
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.currency_rupee,
                    title: 'Monthly Revenue',
                    value: '₹${(_temples.fold(0.0, (sum, t) => sum + (t['monthlyDonations'] as int)).toInt() / 1000).toStringAsFixed(0)}K',
                    color: AppTheme.accentGold,
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.add_business,
                    label: 'Add Temple',
                    color: AppTheme.primaryColor,
                    onTap: () => _showAddTempleDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionCard(
                    icon: Icons.person_add_alt,
                    label: 'Add Admin',
                    color: const Color(0xFF6B46C1),
                    onTap: () => _showAddAdminDialog(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Temples List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Temples',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAllTemplesDialog(),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_temples.length, (index) {
              final temple = _temples[index];
              return _buildTempleCard(temple);
            }),
            const SizedBox(height: 24),

            // Temple Admins List
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Temple Admins',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () => _showAllAdminsDialog(),
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Manage All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(_templeAdmins.length, (index) {
              final admin = _templeAdmins[index];
              return _buildAdminCard(admin);
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
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

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleCard(Map<String, dynamic> temple) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.temple_hindu, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        temple['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 2),
                          Text(
                            temple['location'] as String,
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: temple['isActive'] 
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    temple['isActive'] ? 'Active' : 'Pending',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: temple['isActive'] ? AppTheme.successColor : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildTempleStat(Icons.people, '${temple['usersCount']} users'),
                const SizedBox(width: 16),
                _buildTempleStat(Icons.currency_rupee, '₹${temple['monthlyDonations']}/mo'),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditTempleDialog(temple),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showManageAdminDialog(temple),
                    icon: const Icon(Icons.manage_accounts, size: 16),
                    label: const Text('Admin'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showDeleteTempleDialog(temple),
                  icon: const Icon(Icons.delete_outline, color: AppTheme.errorColor),
                  tooltip: 'Delete Temple',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTempleStat(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAdminCard(Map<String, dynamic> admin) {
    final isPending = admin['status'] == 'Pending';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPending ? Colors.orange.withValues(alpha: 0.2) : AppTheme.primaryColor.withValues(alpha: 0.2),
          child: Icon(
            isPending ? Icons.hourglass_empty : Icons.person,
            color: isPending ? Colors.orange : AppTheme.primaryColor,
          ),
        ),
        title: Text(
          admin['name'] as String,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              admin['temple'] as String,
              style: const TextStyle(fontSize: 12),
            ),
            if (!isPending)
              Text(
                admin['email'] as String,
                style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: admin['status'] == 'Active' 
                    ? AppTheme.successColor.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                admin['status'] as String,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: admin['status'] == 'Active' ? AppTheme.successColor : Colors.orange,
                ),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: (value) {
                if (value == 'edit') {
                  _showEditAdminDialog(admin);
                } else if (value == 'delete') {
                  _showDeleteAdminDialog(admin);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTempleDialog() {
    final nameController = TextEditingController();
    final locationController = TextEditingController();
    final deityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.add_business, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Onboard New Temple'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Temple Name *',
                  prefixIcon: Icon(Icons.temple_hindu),
                  hintText: 'Enter temple name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  prefixIcon: Icon(Icons.location_on),
                  hintText: 'Enter location',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deityController,
                decoration: const InputDecoration(
                  labelText: 'Main Deity',
                  prefixIcon: Icon(Icons.auto_awesome),
                  hintText: 'e.g., Lord Shiva',
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
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty || locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in required fields'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              final newTemple = {
                'id': DateTime.now().millisecondsSinceEpoch.toString(),
                'name': nameController.text,
                'location': locationController.text,
                'deity': deityController.text.isEmpty ? 'General' : deityController.text,
                'adminName': 'Not Assigned',
                'adminEmail': '',
                'usersCount': 0,
                'monthlyDonations': 0,
                'isActive': false,
              };
              
              setState(() {
                _temples.add(newTemple);
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Temple "${nameController.text}" has been onboarded!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Temple'),
          ),
        ],
      ),
    );
  }

  void _showEditTempleDialog(Map<String, dynamic> temple) {
    final nameController = TextEditingController(text: temple['name'] as String);
    final locationController = TextEditingController(text: temple['location'] as String);
    final deityController = TextEditingController(text: temple['deity'] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.edit, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text('Edit ${temple['name']}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Temple Name *',
                  prefixIcon: Icon(Icons.temple_hindu),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location *',
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: deityController,
                decoration: const InputDecoration(
                  labelText: 'Main Deity',
                  prefixIcon: Icon(Icons.auto_awesome),
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
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty || locationController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in required fields'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              setState(() {
                final index = _temples.indexOf(temple);
                if (index != -1) {
                  _temples[index]['name'] = nameController.text;
                  _temples[index]['location'] = locationController.text;
                  _temples[index]['deity'] = deityController.text;
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Temple "${nameController.text}" updated successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showDeleteTempleDialog(Map<String, dynamic> temple) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Delete Temple'),
          ],
        ),
        content: Text('Are you sure you want to delete "${temple['name']}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _temples.remove(temple);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Temple "${temple['name']}" deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  void _showManageAdminDialog(Map<String, dynamic> temple) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    
    final hasAdmin = (temple['adminName'] as String) != 'Not Assigned';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.manage_accounts, color: Color(0xFF6B46C1)),
            const SizedBox(width: 8),
            Expanded(child: Text('Manage Admin - ${temple['name']}')),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasAdmin) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Current Admin',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            Text(
                              temple['adminName'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              temple['adminEmail'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Replace Admin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'No admin assigned to this temple',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Create New Admin',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
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
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in required fields'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              setState(() {
                final index = _temples.indexOf(temple);
                if (index != -1) {
                  _temples[index]['adminName'] = nameController.text;
                  _temples[index]['adminEmail'] = emailController.text;
                  _temples[index]['isActive'] = true;
                }
                
                // Update or add admin to admins list
                final existingAdminIndex = _templeAdmins.indexWhere(
                  (a) => a['temple'] == temple['name']
                );
                if (existingAdminIndex != -1) {
                  _templeAdmins[existingAdminIndex]['name'] = nameController.text;
                  _templeAdmins[existingAdminIndex]['email'] = emailController.text;
                  _templeAdmins[existingAdminIndex]['status'] = 'Active';
                } else {
                  _templeAdmins.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'name': nameController.text,
                    'email': emailController.text,
                    'temple': temple['name'],
                    'status': 'Active',
                  });
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Admin "${nameController.text}" assigned to ${temple['name']}!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.person_add, size: 18),
            label: Text(hasAdmin ? 'Update Admin' : 'Assign Admin'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
          ),
        ],
      ),
    );
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    String? selectedTemple;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_add_alt, color: Color(0xFF6B46C1)),
            SizedBox(width: 8),
            Text('Create Temple Admin'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: Icon(Icons.phone),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedTemple,
                decoration: const InputDecoration(
                  labelText: 'Assign Temple *',
                  prefixIcon: Icon(Icons.temple_hindu),
                ),
                items: _temples.map((temple) {
                  return DropdownMenuItem(
                    value: temple['id'] as String,
                    child: Text(temple['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  selectedTemple = value;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty || selectedTemple == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in all required fields'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              final temple = _temples.firstWhere((t) => t['id'] == selectedTemple);
              
              setState(() {
                _templeAdmins.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'name': nameController.text,
                  'email': emailController.text,
                  'temple': temple['name'],
                  'status': 'Active',
                });
                
                final templeIndex = _temples.indexOf(temple);
                if (templeIndex != -1) {
                  _temples[templeIndex]['adminName'] = nameController.text;
                  _temples[templeIndex]['adminEmail'] = emailController.text;
                  _temples[templeIndex]['isActive'] = true;
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Admin "${nameController.text}" created for ${temple['name']}!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.person_add, size: 18),
            label: const Text('Create Admin'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
          ),
        ],
      ),
    );
  }

  void _showEditAdminDialog(Map<String, dynamic> admin) {
    final nameController = TextEditingController(text: admin['name'] as String);
    final emailController = TextEditingController(text: admin['email'] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.edit, color: Color(0xFF6B46C1)),
            SizedBox(width: 8),
            Text('Edit Admin'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Admin Name *',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: Icon(Icons.email),
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
          ElevatedButton.icon(
            onPressed: () {
              if (nameController.text.isEmpty || emailController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in required fields'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
                return;
              }
              
              setState(() {
                final index = _templeAdmins.indexOf(admin);
                if (index != -1) {
                  _templeAdmins[index]['name'] = nameController.text;
                  _templeAdmins[index]['email'] = emailController.text;
                }
              });
              
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Admin updated successfully!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Save Changes'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B46C1)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAdminDialog(Map<String, dynamic> admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorColor),
            SizedBox(width: 8),
            Text('Delete Admin'),
          ],
        ),
        content: Text('Are you sure you want to delete admin "${admin['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _templeAdmins.remove(admin);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Admin "${admin['name']}" deleted'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            icon: const Icon(Icons.delete, size: 18),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
          ),
        ],
      ),
    );
  }

  void _showAllTemplesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.temple_hindu, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('All Temples'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _temples.length,
            itemBuilder: (context, index) {
              final temple = _temples[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryLight.withValues(alpha: 0.2),
                  child: const Icon(Icons.temple_hindu, color: AppTheme.primaryColor, size: 20),
                ),
                title: Text(temple['name'] as String),
                subtitle: Text(temple['location'] as String),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: temple['isActive'] 
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    temple['isActive'] ? 'Active' : 'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      color: temple['isActive'] ? AppTheme.successColor : Colors.orange,
                    ),
                  ),
                ),
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

  void _showAllAdminsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Color(0xFF6B46C1)),
            SizedBox(width: 8),
            Text('All Temple Admins'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _templeAdmins.length,
            itemBuilder: (context, index) {
              final admin = _templeAdmins[index];
              final isPending = admin['status'] == 'Pending';
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isPending 
                      ? Colors.orange.withValues(alpha: 0.2)
                      : const Color(0xFF6B46C1).withValues(alpha: 0.2),
                  child: Icon(
                    isPending ? Icons.hourglass_empty : Icons.person,
                    color: isPending ? Colors.orange : const Color(0xFF6B46C1),
                    size: 20,
                  ),
                ),
                title: Text(admin['name'] as String),
                subtitle: Text('${admin['temple']} • ${admin['email']}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: admin['status'] == 'Active' 
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    admin['status'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: admin['status'] == 'Active' ? AppTheme.successColor : Colors.orange,
                    ),
                  ),
                ),
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

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.notifications, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('Notifications'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF38A169),
                  child: Icon(Icons.person_add, color: Colors.white, size: 20),
                ),
                title: const Text('New Admin Created'),
                subtitle: const Text('Venkatesh Rao → Tirumala'),
                trailing: const Text('2h ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Icon(Icons.temple_hindu, color: Colors.white, size: 20),
                ),
                title: const Text('New Temple Onboarded'),
                subtitle: const Text('Somnath Temple added'),
                trailing: const Text('1d ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppTheme.accentGold,
                  child: Icon(Icons.currency_rupee, color: Colors.white, size: 20),
                ),
                title: const Text('Revenue Milestone'),
                subtitle: const Text('Donations crossed ₹4L!'),
                trailing: const Text('3d ago', style: TextStyle(color: Colors.grey, fontSize: 12)),
              ),
            ],
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
}
