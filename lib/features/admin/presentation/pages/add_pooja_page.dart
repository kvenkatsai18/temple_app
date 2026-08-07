import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/services/firebase_service.dart';
import '../../../temple/presentation/providers/temple_provider.dart';

class AddPoojaPage extends StatefulWidget {
  final Map<String, dynamic>? pooja; // For editing
  final String? poojaId;
  
  const AddPoojaPage({super.key, this.pooja, this.poojaId});

  @override
  State<AddPoojaPage> createState() => _AddPoojaPageState();
}

class _AddPoojaPageState extends State<AddPoojaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _slotsController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;
  
  TimeOfDay _startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 7, minute: 0);

  @override
  void initState() {
    super.initState();
    if (widget.pooja != null) {
      _nameController.text = widget.pooja!['name'] ?? '';
      _parseTiming(widget.pooja!['timing'] ?? '');
      _priceController.text = (widget.pooja!['price'] ?? '').toString();
      _descriptionController.text = widget.pooja!['description'] ?? '';
      _durationController.text = (widget.pooja!['duration'] ?? 60).toString();
      _slotsController.text = (widget.pooja!['availableSlots'] ?? 50).toString();
      _isActive = widget.pooja!['isActive'] ?? true;
    } else {
      _durationController.text = '60';
      _slotsController.text = '50';
    }
  }

  void _parseTiming(String timing) {
    // Parse timing like "5:00 AM - 6:00 AM" or "05:00 - 06:00"
    final parts = timing.split(' - ');
    if (parts.length == 2) {
      _startTimeController.text = parts[0].trim();
      _endTimeController.text = parts[1].trim();
      _startTime = _parseTimeOfDay(parts[0].trim());
      _endTime = _parseTimeOfDay(parts[1].trim());
    }
  }

  TimeOfDay _parseTimeOfDay(String timeStr) {
    try {
      final isPM = timeStr.toUpperCase().contains('PM');
      final isAM = timeStr.toUpperCase().contains('AM');
      final cleanTime = timeStr.replaceAll(RegExp(r'[APMapm\s]'), '');
      final timeParts = cleanTime.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = timeParts.length > 1 ? int.parse(timeParts[1]) : 0;
      
      if (isPM && hour != 12) hour += 12;
      if (isAM && hour == 12) hour = 0;
      
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 6, minute: 0);
    }
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getTimingString() {
    return '${_formatTimeOfDay(_startTime)} - ${_formatTimeOfDay(_endTime)}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _slotsController.dispose();
    super.dispose();
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
        _startTimeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
        _endTimeController.text = _formatTimeOfDay(picked);
      });
    }
  }

  Future<void> _savePooja() async {
    if (!_formKey.currentState!.validate()) return;
    
    final templeProvider = Provider.of<TempleProvider>(context, listen: false);
    final templeId = templeProvider.selectedTempleId;
    
    if (templeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a temple first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final poojaData = {
        'name': _nameController.text.trim(),
        'timing': _getTimingString(),
        'price': double.parse(_priceController.text.trim()),
        'description': _descriptionController.text.trim(),
        'duration': int.parse(_durationController.text.trim()),
        'availableSlots': int.parse(_slotsController.text.trim()),
        'bookedSlots': widget.pooja?['bookedSlots'] ?? 0,
        'isActive': _isActive,
        'createdAt': widget.pooja?['createdAt'] ?? DateTime.now().toIso8601String(),
      };

      if (widget.poojaId != null) {
        await FirebaseService.updatePooja(widget.poojaId!, poojaData);
      } else {
        await FirebaseService.addPooja(templeId, poojaData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.poojaId != null ? 'Pooja updated successfully!' : 'Pooja added successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pooja != null ? 'Edit Pooja' : 'Add New Pooja'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Pooja Name *',
                  hintText: 'e.g., Suprabhatha Seva',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.auto_awesome),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter pooja name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Easy Time Selection
              const Text(
                'Pooja Timing *',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectStartTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Start Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, 
                                  color: AppTheme.primaryColor, 
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_startTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: Colors.grey),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectEndTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'End Time',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time, 
                                  color: AppTheme.primaryColor, 
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _formatTimeOfDay(_endTime),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Scheduled: ${_getTimingString()}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (\$) *',
                        hintText: '100',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        hintText: '60',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slotsController,
                decoration: const InputDecoration(
                  labelText: 'Available Slots',
                  hintText: '50',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event_seat),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of the pooja',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active Status'),
                subtitle: Text(_isActive ? 'Pooja is available for booking' : 'Pooja is not available'),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeThumbColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _savePooja,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.pooja != null ? 'Update Pooja' : 'Add Pooja',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
