import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DonationPage extends StatefulWidget {
  final String? donationType;
  
  const DonationPage({super.key, this.donationType});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _amountController = TextEditingController();
  String? _selectedCategory;
  int _selectedAmount = 0;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Annadanam', 'subtitle': 'Food donation', 'icon': Icons.restaurant, 'color': AppTheme.primaryColor},
    {'name': 'Flowers', 'subtitle': 'Temple decoration', 'icon': Icons.local_florist, 'color': AppTheme.accentRed},
    {'name': 'Oil Lamps', 'subtitle': 'Deepa Daanam', 'icon': Icons.lightbulb, 'color': AppTheme.accentGold},
    {'name': 'General', 'subtitle': 'Temple fund', 'icon': Icons.volunteer_activism, 'color': AppTheme.successColor},
  ];

  final List<int> _quickAmounts = [101, 501, 1001, 5001, 10001];

  @override
  void initState() {
    super.initState();
    if (widget.donationType != null) {
      _selectedCategory = widget.donationType;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
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
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['name'];
                return Card(
                  color: isSelected ? (cat['color'] as Color).withValues(alpha: 0.1) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? cat['color'] as Color : Colors.transparent,
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
                          Icon(
                            cat['icon'] as IconData, 
                            size: 32, 
                            color: cat['color'] as Color,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            cat['name'] as String,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? cat['color'] as Color : null,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            cat['subtitle'] as String,
                            style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
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
                    '₹$amount',
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
              decoration: const InputDecoration(
                hintText: 'Enter amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
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
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
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
                      ? 'Donate ₹$_selectedAmount' 
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

  void _processDonation() {
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
            Text('Donation: ₹$_selectedAmount'),
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
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your donation!'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
