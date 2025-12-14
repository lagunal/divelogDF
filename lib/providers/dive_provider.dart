import 'package:flutter/foundation.dart';
import 'package:divelogtest/models/dive_session.dart';
import 'package:divelogtest/services/dive_service.dart';

class DiveProvider extends ChangeNotifier {
  final DiveService _diveService = DiveService();
  
  List<DiveSession> _allDives = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  List<DiveSession> get allDives => List.unmodifiable(_allDives);
  List<DiveSession> get recentDives => _allDives.take(3).toList();
  Map<String, dynamic> get statistics => Map.unmodifiable(_statistics);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  Future<void> initialize(String userId) async {
    if (_isInitialized) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _diveService.initialize();
      await _diveService.loadSampleData(userId);
      await _loadAllData(userId);
      _isInitialized = true;
    } catch (e) {
      _error = 'Error al inicializar: $e';
      debugPrint('Error initializing DiveProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAllData(String userId) async {
    try {
      _allDives = await _diveService.getAllDiveSessions();
      _statistics = await _diveService.getStatistics(userId);
    } catch (e) {
      debugPrint('Error loading dive data: $e');
      rethrow;
    }
  }

  Future<void> refreshData(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadAllData(userId);
    } catch (e) {
      _error = 'Error al actualizar datos: $e';
      debugPrint('Error refreshing data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDive(DiveSession session) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSession = await _diveService.createDiveSession(session);
      _allDives.insert(0, newSession);
      await _updateStatistics(session.userId);
    } catch (e) {
      _error = 'Error al crear inmersión: $e';
      debugPrint('Error creating dive: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDive(DiveSession session) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedSession = await _diveService.updateDiveSession(session);
      final index = _allDives.indexWhere((d) => d.id == session.id);
      if (index != -1) {
        _allDives[index] = updatedSession;
        _allDives.sort((a, b) => b.horaEntrada.compareTo(a.horaEntrada));
      }
      await _updateStatistics(session.userId);
    } catch (e) {
      _error = 'Error al actualizar inmersión: $e';
      debugPrint('Error updating dive: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDive(String id, String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _diveService.deleteDiveSession(id);
      _allDives.removeWhere((d) => d.id == id);
      await _updateStatistics(userId);
    } catch (e) {
      _error = 'Error al eliminar inmersión: $e';
      debugPrint('Error deleting dive: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _updateStatistics(String userId) async {
    try {
      _statistics = await _diveService.getStatistics(userId);
    } catch (e) {
      debugPrint('Error updating statistics: $e');
    }
  }

  Future<List<String>> getUniqueLocations() async {
    return await _diveService.getUniqueLocations();
  }

  Future<List<String>> getUniqueOperators() async {
    return await _diveService.getUniqueOperators();
  }

  DiveSession? getDiveById(String id) {
    try {
      return _allDives.firstWhere((dive) => dive.id == id);
    } catch (e) {
      return null;
    }
  }
}
