import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TempleSelectionPage extends StatefulWidget {
  const TempleSelectionPage({super.key});

  @override
  State<TempleSelectionPage> createState() => _TempleSelectionPageState();
}

class _TempleSelectionPageState extends State<TempleSelectionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<int> _joinedTemples = {};
  String _searchQuery = '';
  bool _isSearching = false;
  bool _isLoading = true;

  final List<Map<String, dynamic>> _allTemples = [
    {
      'name': 'Sri Krishna Temple',
      'location': 'Mathura, UP',
      'deity': 'Lord Krishna',
      'image': Icons.temple_hindu,
      'distance': '2.5 km',
      'rating': 4.8,
    },
    {
      'name': 'Badrinath Temple',
      'location': 'Badrinath, Uttarakhand',
      'deity': 'Lord Vishnu',
      'image': Icons.temple_buddhist,
      'distance': '5.1 km',
      'rating': 4.9,
    },
    {
      'name': 'Tirumala Temple',
      'location': 'Tirupati, AP',
      'deity': 'Lord Venkateswara',
      'image': Icons.temple_hindu,
      'distance': '8.3 km',
      'rating': 4.7,
    },
    {
      'name': 'Somnath Temple',
      'location': 'Prabhas Patan, Gujarat',
      'deity': 'Lord Shiva',
      'image': Icons.account_balance,
      'distance': '12.0 km',
      'rating': 4.6,
    },
    {
      'name': 'Vaishno Devi Temple',
      'location': 'Katra, J&K',
      'deity': 'Goddess Vaishno Devi',
      'image': Icons.temple_hindu,
      'distance': '15.5 km',
      'rating': 4.9,
    },
    {
      'name': 'Kedarnath Temple',
      'location': 'Kedarnath, Uttarakhand',
      'deity': 'Lord Shiva',
      'image': Icons.landscape,
      'distance': '18.2 km',
      'rating': 4.8,
    },
    {
      'name': 'Ram Mandir',
      'location': 'Ayodhya, UP',
      'deity': 'Lord Rama',
      'image': Icons.temple_hindu,
      'distance': '22.0 km',
      'rating': 4.9,
    },
    {
      'name': 'Golden Temple',
      'location': 'Amritsar, Punjab',
      'deity': 'Guru Granth Sahib',
      'image': Icons.mosque,
      'distance': '25.5 km',
      'rating': 4.9,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadJoinedTemples();
  }

  Future<void> _loadJoinedTemples() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedList = prefs.getStringList('joined_temples') ?? [];
    setState(() {
      _joinedTemples = joinedList.map((e) => int.parse(e)).toSet();
      _isLoading = false;
    });
  }

  Future<void> _saveJoinedTemples() async {
    final prefs = await SharedPreferences.getInstance();
    final joinedList = _joinedTemples.map((e) => e.toString()).toList();
    await prefs.setStringList('joined_temples', joinedList);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _toggleJoinTemple(int index) async {
    setState(() {
      if (_joinedTemples.contains(index)) {
        _joinedTemples.remove(index);
      } else {
        _joinedTemples.add(index);
      }
    });
    await _saveJoinedTemples();
    
    if (_joinedTemples.contains(index)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Joined ${_allTemples[index]['name']}!'),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _leaveTemple(int index) async {
    final templeName = _allTemples[index]['name'];
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Temple'),
        content: Text('Are you sure you want to leave $templeName? You will stop receiving notifications from this temple.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _joinedTemples.remove(index);
      });
      await _saveJoinedTemples();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('👋 Left $templeName'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _selectTemple(int index) {
    Navigator.pushReplacementNamed(context, '/user-home');
  }

  List<Map<String, dynamic>> get _filteredTemples {
    if (_searchQuery.isEmpty) return _allTemples;
    return _allTemples.where((temple) {
      final name = temple['name'].toString().toLowerCase();
      final location = temple['location'].toString().toLowerCase();
      final deity = temple['deity'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || location.contains(query) || deity.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _joinedTemplesList {
    return _allTemples.where((temple) {
      final index = _allTemples.indexOf(temple);
      return _joinedTemples.contains(index);
    }).toList();
  }

  List<Map<String, dynamic>> get _availableTemples {
    return _allTemples.where((temple) {
      final index = _allTemples.indexOf(temple);
      return !_joinedTemples.contains(index);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search temples...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value),
              )
            : const Text('Select Temple'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
        ],
        bottom: _isSearching
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'My Temples (${_joinedTemples.length})'),
                  const Tab(text: 'Discover'),
                ],
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return Column(
                        children: [
                          Text(
                            '🙏 Welcome, ${auth.currentUser?.name ?? "Devotee"}!',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _joinedTemples.isEmpty
                                ? 'Join temples to receive updates & notifications'
                                : 'You have joined ${_joinedTemples.length} temple${_joinedTemples.length > 1 ? 's' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _isSearching ? _buildSearchResults() : _buildTabContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMyTemplesTab(),
        _buildDiscoverTab(),
      ],
    );
  }

  Widget _buildMyTemplesTab() {
    final joinedTemplesList = _joinedTemplesList;

    if (joinedTemplesList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.temple_hindu_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No temples joined yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Join temples to receive updates',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _tabController.animateTo(1),
              icon: const Icon(Icons.search),
              label: const Text('Discover Temples'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: joinedTemplesList.length,
      itemBuilder: (context, index) {
        final temple = joinedTemplesList[index];
        final actualIndex = _allTemples.indexOf(temple);
        return _buildTempleCard(
          temple: temple,
          isJoined: true,
          onTap: () => _selectTemple(actualIndex),
          onJoinToggle: () => _toggleJoinTemple(actualIndex),
          onLeave: () => _leaveTemple(actualIndex),
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    final availableTemples = _availableTemples;

    if (availableTemples.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            Text(
              'You\'ve joined all temples!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: availableTemples.length,
      itemBuilder: (context, index) {
        final temple = availableTemples[index];
        final actualIndex = _allTemples.indexOf(temple);
        return _buildTempleCard(
          temple: temple,
          isJoined: false,
          onTap: () {},
          onJoinToggle: () => _toggleJoinTemple(actualIndex),
          onLeave: null,
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final filteredTemples = _filteredTemples;

    if (filteredTemples.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No temples found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredTemples.length,
      itemBuilder: (context, index) {
        final temple = filteredTemples[index];
        final actualIndex = _allTemples.indexOf(temple);
        final isJoined = _joinedTemples.contains(actualIndex);
        return _buildTempleCard(
          temple: temple,
          isJoined: isJoined,
          onTap: isJoined ? () => _selectTemple(actualIndex) : () {},
          onJoinToggle: () => _toggleJoinTemple(actualIndex),
          onLeave: isJoined ? () => _leaveTemple(actualIndex) : null,
        );
      },
    );
  }

  Widget _buildTempleCard({
    required Map<String, dynamic> temple,
    required bool isJoined,
    required VoidCallback onTap,
    required VoidCallback onJoinToggle,
    VoidCallback? onLeave,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      temple['image'] as IconData,
                      size: 36,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          temple['name'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              temple['location'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                temple['deity'] as String,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.accentGold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber[600],
                            ),
                            const SizedBox(width: 2),
                            Text(
                              temple['rating'].toString(),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.directions,
                          size: 16,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          temple['distance'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isJoined)
                    ElevatedButton.icon(
                      onPressed: onJoinToggle,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Join'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    )
                  else ...[
                    // Leave button
                    TextButton.icon(
                      onPressed: onLeave,
                      icon: const Icon(Icons.exit_to_app, size: 16),
                      label: const Text('Leave'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('Go'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ],
              ),
              if (isJoined) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.notifications_active,
                        size: 16,
                        color: AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Notifications enabled',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
