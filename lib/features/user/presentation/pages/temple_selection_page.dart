import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/temple_model.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class TempleSelectionPage extends StatefulWidget {
  const TempleSelectionPage({super.key});

  @override
  State<TempleSelectionPage> createState() => _TempleSelectionPageState();
}

class _TempleSelectionPageState extends State<TempleSelectionPage> {
  @override
  void initState() {
    super.initState();
    // Load temples from Firebase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TempleProvider>(context, listen: false).loadTemples();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Temple'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TempleProvider>(
        builder: (context, templeProvider, child) {
          if (templeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (templeProvider.temples.isEmpty) {
            return Center(
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
                      'No Temples Available',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Temples will appear here once the Super Admin adds them.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => templeProvider.loadTemples(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: templeProvider.temples.length,
            itemBuilder: (context, index) {
              final temple = templeProvider.temples[index];
              return _buildTempleCard(context, temple, templeProvider);
            },
          );
        },
      ),
    );
  }

  Widget _buildTempleCard(BuildContext context, TempleModel temple, TempleProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          provider.selectTemple(temple);
          Navigator.pushReplacementNamed(context, '/user-home');
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
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.temple_hindu,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      temple.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
  }
}
