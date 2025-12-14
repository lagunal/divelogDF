import 'package:flutter/foundation.dart';
import 'package:divelogtest/services/database_helper.dart';

// Import web storage conditionally
import 'storage_service_web.dart' if (dart.library.html) 'storage_service_web.dart' as web_storage;

class StorageService {
  final _dbHelper = kIsWeb ? null : DatabaseHelper();
  final _webStorage = kIsWeb ? web_storage.WebStorageService() : null;

  Future<void> saveDiveSessions(List<Map<String, dynamic>> sessions) async {
    try {
      if (kIsWeb) {
        await _webStorage!.saveDiveSessions(sessions);
      } else {
        for (var session in sessions) {
          await _dbHelper!.insertDiveSession(session);
        }
      }
      debugPrint('${sessions.length} dive sessions saved');
    } catch (e) {
      debugPrint('Error saving dive sessions: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> loadDiveSessions() async {
    try {
      if (kIsWeb) {
        return await _webStorage!.loadDiveSessions();
      } else {
        return await _dbHelper!.getAllDiveSessions();
      }
    } catch (e) {
      debugPrint('Error loading dive sessions: $e');
      return [];
    }
  }

  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    try {
      if (kIsWeb) {
        await _webStorage!.saveUserProfile(profile);
      } else {
        await _dbHelper!.saveUserProfile(profile);
      }
      debugPrint('User profile saved');
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUserProfile(String userId) async {
    try {
      if (kIsWeb) {
        return await _webStorage!.loadUserProfile(userId);
      } else {
        return await _dbHelper!.getUserProfile(userId);
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
      return null;
    }
  }

  Future<void> clearAll() async {
    try {
      if (kIsWeb) {
        await _webStorage!.clearAll();
      } else {
        await _dbHelper!.clearAll();
      }
      debugPrint('All storage cleared');
    } catch (e) {
      debugPrint('Error clearing storage: $e');
      rethrow;
    }
  }
}
