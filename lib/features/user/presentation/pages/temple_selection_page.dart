import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class TempleSelectionPage extends StatelessWidget {
  const TempleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final temples = [
      {
        'name': 'Sri Krishna Temple',
        'location': 'Mathura, UP',
        'deity': 'Lord Krishna',
        'image': Icons.temple_hindu,
      },
      {
        'name': 'Badrinath Temple',
        'location': 'Badrinath, Uttarakhand',
        'deity': 'Lord Vishnu',
        'image': Icons.temple_buddhist,
      },
      {
        'name': 'Tirumala Temple',
        'location': 'Tirupati, AP',
        'deity': 'Lord Venkateswara',
        'image': Icons.temple_hindu,
      },
      {
        'name': 'Somnath Temple',
        'location': 'Prabhas Patan, Gujarat',
        'deity': 'Lord Shiva',
        'image': Icons.account_balance,
      },
      {
        'name': 'Vaishno Devi Temple',
        'location': 'Katra, J&K',
        'deity': 'Goddess Vaishno Devi',
        'image': Icons.temple_hindu,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Temple'),
        centerTitle: true,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.primaryGradient,
            ),
            child: Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return Text(
                  '🙏 Welcome, ${auth.currentUser?.name ?? "Devotee"}!',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose your temple to continue',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: temples.length,
              itemBuilder: (context, index) {
                final temple = temples[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/user-home');
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
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
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
