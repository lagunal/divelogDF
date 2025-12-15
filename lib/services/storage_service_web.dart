import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Web-only storage service using SharedPreferences for persistence
class WebStorageService {
  static final WebStorageService _instance = WebStorageService._internal();
  static const String _divesKey = 'dive_sessions';
  static const String _userProfileKey = 'user_profile';

  factory WebStorageService() {
    return _instance;
  }

  WebStorageService._internal();

  Future<void> saveDiveSessions(List<Map<String, dynamic>> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(sessions);
      await prefs.setString(_divesKey, jsonString);
      debugPrint('${sessions.length} dive sessions saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving dive sessions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadDiveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_divesKey);
      
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
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(profile);
      await prefs.setString(_userProfileKey, jsonString);
      debugPrint('User profile saved to SharedPreferences');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_userProfileKey);
      
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      debugPrint('All SharedPreferences cleared');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }
}
