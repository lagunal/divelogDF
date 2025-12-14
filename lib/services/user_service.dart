import 'package:divelogtest/models/user_profile.dart';
import 'package:divelogtest/services/storage_service.dart';
import 'package:divelogtest/services/dive_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final _uuid = const Uuid();
  final _storageService = StorageService();
  UserProfile? _currentUser;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    await _loadFromStorage();
    _isInitialized = true;
  }

  Future<void> _loadFromStorage() async {
    try {
      // Get user profile from storage
      // In a real app, you'd track which user is currently logged in
      // For now, this is a placeholder for loading the current user
    } catch (e) {
      debugPrint('Error loading user profile from storage: $e');
      _currentUser = null;
    }
  }

  Future<void> _saveToStorage() async {
    if (_currentUser == null) return;
    try {
      await _storageService.saveUserProfile(_currentUser!.toJson());
    } catch (e) {
      debugPrint('Error saving user profile to storage: $e');
      rethrow;
    }
  }

  Future<UserProfile> createUserProfile({
    required String name,
    required String email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    await initialize();
    
    final now = DateTime.now();
    _currentUser = UserProfile(
      id: _uuid.v4(),
      name: name,
      email: email,
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      totalDives: 0,
      totalBottomTime: 0.0,
      deepestDive: 0.0,
      createdAt: now,
      updatedAt: now,
    );
    
    await _saveToStorage();
    return _currentUser!;
  }

  Future<UserProfile?> getUserProfile() async {
    await initialize();
    return _currentUser;
  }

  Future<UserProfile> updateUserProfile({
    String? name,
    String? email,
    String? certificationLevel,
    String? certificationNumber,
    DateTime? certificationDate,
  }) async {
    await initialize();
    
    if (_currentUser == null) {
      throw Exception('No user profile found. Create a profile first.');
    }
    
    _currentUser = _currentUser!.copyWith(
      name: name,
      email: email,
      certificationLevel: certificationLevel,
      certificationNumber: certificationNumber,
      certificationDate: certificationDate,
      updatedAt: DateTime.now(),
    );
    
    await _saveToStorage();
    return _currentUser!;
  }

  Future<UserProfile> updateUserStatistics() async {
    await initialize();
    
    if (_currentUser == null) {
      throw Exception('No user profile found. Create a profile first.');
    }

    final diveService = DiveService();
    final stats = await diveService.getStatistics(_currentUser!.id);
    
    _currentUser = _currentUser!.copyWith(
      totalDives: stats['totalDives'] as int,
      totalBottomTime: stats['totalBottomTime'] as double,
      deepestDive: stats['deepestDive'] as double,
      updatedAt: DateTime.now(),
    );
    
    await _saveToStorage();
    return _currentUser!;
  }

  Future<void> createDefaultUserIfNeeded() async {
    await initialize();
    
    if (_currentUser == null) {
      await createUserProfile(
        name: 'Usuario Demo',
        email: 'demo@divelogapp.com',
        certificationLevel: 'Open Water Diver',
      );
      debugPrint('Default user profile created');
    }
  }

  Future<void> deleteUserProfile() async {
    await initialize();
    _currentUser = null;
    await _storageService.saveUserProfile({});
  }

  String? getCurrentUserId() => _currentUser?.id;

  bool get hasUserProfile => _currentUser != null;
}
