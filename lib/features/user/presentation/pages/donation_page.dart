import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class DonationPage extends StatefulWidget {
  final String? donationType;
  
  const DonationPage({super.key, this.donationType});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  String? _selectedCategory;
  int _selectedAmount = 0;
  bool _isLoading = true;

  // Live categories from Firebase
  List<Map<String, dynamic>> _categories = [];
  
  // Default icons for categories without custom icons
  final List<IconData> _defaultIcons = [
    Icons.restaurant, Icons.local_florist, Icons.lightbulb, Icons.volunteer_activism,
    Icons.handshake, Icons.water_drop, Icons.home, Icons.medical_services,
  ];
  final List<Color> _categoryColors = [
    AppTheme.primaryColor, AppTheme.accentRed, AppTheme.accentGold, AppTheme.successColor,
    Colors.purple, Colors.blue, Colors.orange, Colors.teal,
  ];

  final List<int> _quickAmounts = [101, 501, 1001, 5001, 10001];

  @override
  void initState() {
    super.initState();
    if (widget.donationType != null) {
      _selectedCategory = widget.donationType;
    }
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId != null) {
      try {
        final docs = await FirebaseService.getDonationCategoriesByTemple(templeId);
        if (mounted) {
          setState(() {
            _categories = docs.map((doc) => {
              ...doc.data() as Map<String, dynamic>,
              'id': doc.id,
            }).toList();
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
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Make Donation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              color: AppTheme.successColor.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, color: AppTheme.successColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your generous donations help maintain the temple and support community services.',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Select Category
            const Text(
              'Select Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _categories.isEmpty
                    ? Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.category_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No donation categories available'),
                                const SizedBox(height: 8),
                                Text(
                                  'The temple admin will add categories soon',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.5,
                        ),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final colorIndex = index % _categoryColors.length;
                          final color = _categoryColors[colorIndex];
                          final icon = _defaultIcons[colorIndex];
                          final isSelected = _selectedCategory == cat['name'];
                          
                          return Card(
                            color: isSelected ? color.withValues(alpha: 0.1) : null,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected ? color : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              onTap: () => setState(() => _selectedCategory = cat['name']),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icon, size: 32, color: color),
                                    const SizedBox(height: 4),
                                    Text(
                                      cat['name'] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? color : null,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cat['description'] != null && cat['description'].toString().isNotEmpty)
                                      Text(
                                        cat['description'],
                                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            const SizedBox(height: 24),
            
            // Quick Amounts
            const Text(
              'Select Amount',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickAmounts.map((amount) {
                final isSelected = _selectedAmount == amount;
                return ChoiceChip(
                  label: Text(
                    '\$$amount',
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppTheme.primaryColor,
                  onSelected: (selected) {
                    setState(() {
                      _selectedAmount = selected ? amount : 0;
                      _amountController.clear();
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            
            // Custom Amount
            const Text(
              'Or Enter Custom Amount',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixText: '\$ ',
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  _selectedAmount = int.tryParse(value) ?? 0;
                });
              },
            ),
            const SizedBox(height: 24),
            
            // Name and Phone
            const Text(
              'Your Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Donate Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _selectedAmount > 0 && _selectedCategory != null 
                    ? _processDonation 
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successColor,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.favorite),
                label: Text(
                  _selectedAmount > 0 
                      ? 'Donate \$$_selectedAmount'
                      : 'Select Amount',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _processDonation() async {
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    final userId = authProvider.currentUser?.uid;
    
    if (templeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a temple first'), backgroundColor: Colors.red),
      );
      return;
    }

    // Save donation to Firebase
    try {
      await FirebaseService.createDonation({
        'templeId': templeId,
        'userId': userId ?? 'anonymous',
        'category': _selectedCategory,
        'amount': _selectedAmount.toDouble(),
        'donorName': _nameController.text.trim().isEmpty ? 'Anonymous' : _nameController.text.trim(),
        'donorPhone': _phoneController.text.trim(),
        'message': _messageController.text.trim(),
        'status': 'completed',
        'createdAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.favorite, color: AppTheme.successColor),
                SizedBox(width: 8),
                Text('Thank You!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Donation: \$$_selectedAmount'),
                Text('Category: $_selectedCategory'),
                const SizedBox(height: 8),
                const Text(
                  'Your donation has been received. May Lord bless you! 🙏',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}
