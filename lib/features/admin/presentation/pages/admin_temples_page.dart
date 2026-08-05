import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/temple_model.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class AdminTemplesPage extends StatefulWidget {
  const AdminTemplesPage({super.key});

  @override
  State<AdminTemplesPage> createState() => _AdminTemplesPageState();
}

class _AdminTemplesPageState extends State<AdminTemplesPage> {
  List<TempleModel> _adminTemples = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdminTemples();
  }

  Future<void> _loadAdminTemples() async {
    setState(() => _isLoading = true);
    
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userEmail = auth.currentUser?.email;
    
    if (userEmail != null) {
      try {
        final temples = await FirebaseService.getTemplesByAdminEmailAsModels(userEmail);
        if (mounted) {
          setState(() {
            _adminTemples = temples;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Temples'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _adminTemples.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.temple_hindu,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'No Temples Assigned',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'You are not assigned as an admin to any temple yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadAdminTemples,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _adminTemples.length,
                  itemBuilder: (context, index) {
                    final temple = _adminTemples[index];
                    return _buildTempleCard(context, temple);
                  },
                ),
    );
  }

  Widget _buildTempleCard(BuildContext context, TempleModel temple) {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final isSelected = templeProvider.selectedTempleId == temple.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected 
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () {
          templeProvider.selectTemple(temple);
          Navigator.pop(context);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : AppTheme.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.temple_hindu,
                  color: isSelected ? Colors.white : AppTheme.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            temple.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Selected',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            temple.location,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (temple.deity != null && temple.deity!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppTheme.accentGold,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            temple.deity!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentGold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.arrow_forward_ios,
                size: 16,
                color: isSelected ? AppTheme.primaryColor : Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
