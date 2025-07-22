import 'package:flutter/material.dart';
import 'package:tracking_app/models/greenhouse.dart';
import 'package:tracking_app/services/greenhouse_service.dart';

class GreenhouseProvider extends ChangeNotifier {
  final GreenhouseService _greenhouseService;
  
  List<Greenhouse> _greenhouses = [];
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Greenhouse> get greenhouses => _greenhouses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GreenhouseProvider(this._greenhouseService);

  Future<void> loadGreenhouses() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final greenhouses = await _greenhouseService.getAllGreenhouses();
      _greenhouses = greenhouses;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Greenhouse?> getGreenhouseById(String id) async {
    try {
      final cached = _greenhouses.firstWhere(
        (g) => g.greenhouseId == id,
        orElse: () => null as Greenhouse,
      );
      
      if (cached != null) return cached;

      final greenhouse = await _greenhouseService.getGreenhouseById(id);

      final index = _greenhouses.indexWhere((g) => g.greenhouseId == id);
      if (index >= 0) {
        _greenhouses[index] = greenhouse;
      } else {
        _greenhouses.add(greenhouse);
      }
      
      notifyListeners();
      return greenhouse;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> createGreenhouse(Greenhouse greenhouse) async {
    try {
      _isLoading = true;
      notifyListeners();

      final created = await _greenhouseService.createGreenhouse(greenhouse);
      _greenhouses.add(created);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGreenhouse(String id, Greenhouse greenhouse) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updated = await _greenhouseService.updateGreenhouse(id, greenhouse);
      
      final index = _greenhouses.indexWhere((g) => g.greenhouseId == id);
      if (index >= 0) {
        _greenhouses[index] = updated;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGreenhouse(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _greenhouseService.deleteGreenhouse(id);
      _greenhouses.removeWhere((g) => g.greenhouseId == id);
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
} 