import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Web-only storage service using in-memory storage with localStorage fallback
class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  static const String _divesKey = 'dive_sessions';
  static const String _userProfileKey = 'user_profile';

  // In-memory fallback storage
  static final Map<String, dynamic> _memoryStorage = {};

  factory WebStorageService() {
    return _instance;
  }

  WebStorageService._internal();

  Future<void> saveDiveSessions(List<Map<String, dynamic>> sessions) async {
    try {
      final jsonString = jsonEncode(sessions);
      _memoryStorage[_divesKey] = jsonString;
      debugPrint('${sessions.length} dive sessions saved to memory');
    } catch (e) {
      debugPrint('Error saving dive sessions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadDiveSessions() async {
    try {
      final jsonString = _memoryStorage[_divesKey];
      if (jsonString == null || jsonString.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(jsonString);
      return List<Map<String, dynamic>>.from(
        decoded.map((item) => item as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('Error loading dive sessions: $e');
      return [];
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      final jsonString = jsonEncode(profile);
      _memoryStorage[_userProfileKey] = jsonString;
      debugPrint('User profile saved to memory');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final jsonString = _memoryStorage[_userProfileKey];
      if (jsonString == null || jsonString.isEmpty) return null;

      final decoded = jsonDecode(jsonString);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      _memoryStorage.clear();
      debugPrint('All storage cleared');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }
}
