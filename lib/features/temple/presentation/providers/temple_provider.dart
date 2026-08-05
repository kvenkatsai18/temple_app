import 'package:flutter/material.dart';
import '../../../../data/models/temple_model.dart';
import '../../../../data/services/firebase_service.dart';

class TempleProvider extends ChangeNotifier {
  List<TempleModel> _temples = [];
  TempleModel? _selectedTemple;
  bool _isLoading = false;
  String? _error;

  List<TempleModel> get temples => _temples;
  TempleModel? get selectedTemple => _selectedTemple;
  String? get selectedTempleId => _selectedTemple?.id;
  bool get isLoading => _isLoading;
  String? get error => _error;

  TempleProvider() {
    loadTemples();
  }

  Future<void> loadTemples() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final docs = await FirebaseService.getAllTemples();
      _temples = docs.map((doc) => TempleModel.fromFirestore(doc.id, doc.data() as Map<String, dynamic>)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load temples: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectTemple(TempleModel temple) {
    _selectedTemple = temple;
    notifyListeners();
  }

  void clearSelection() {
    _selectedTemple = null;
    notifyListeners();
  }

  Future<void> addTemple(TempleModel temple) async {
    try {
      await FirebaseService.addTemple(temple.toFirestore());
      await loadTemples();
    } catch (e) {
      _error = 'Failed to add temple: $e';
      notifyListeners();
    }
  }

  Future<void> updateTemple(TempleModel temple) async {
    try {
      await FirebaseService.updateTemple(temple.id, temple.toFirestore());
      await loadTemples();
    } catch (e) {
      _error = 'Failed to update temple: $e';
      notifyListeners();
    }
  }

  Future<void> deleteTemple(String templeId) async {
    try {
      await FirebaseService.deleteTemple(templeId);
      await loadTemples();
    } catch (e) {
      _error = 'Failed to delete temple: $e';
      notifyListeners();
    }
  }

  // Seed temples for demo/testing
  Future<void> seedTemples() async {
    _isLoading = true;
    notifyListeners();

    try {
      await FirebaseService.seedTemples();
      await loadTemples();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to seed temples: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}
