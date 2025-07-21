// File: lib/screens/student/settings/service/settings_performance_manager.dart
import 'dart:async';
import 'package:flutter/foundation.dart';

class SettingsPerformanceManager {
  static Timer? _saveTimer;
  static bool _hasUnsavedChanges = false;
  static final Map<String, dynamic> _pendingChanges = {};
  
  static void scheduleSave(Map<String, dynamic> settings, Function saveCallback) {
    _hasUnsavedChanges = true;
    _pendingChanges.addAll(settings);
    
    // Cancel existing timer
    _saveTimer?.cancel();
    
    // Schedule save after 500ms of inactivity
    _saveTimer = Timer(const Duration(milliseconds: 500), () async {
      if (_hasUnsavedChanges) {
        try {
          await _saveInBackground(_pendingChanges, saveCallback);
          _hasUnsavedChanges = false;
          _pendingChanges.clear();
        } catch (e) {
          debugPrint('Background save failed: $e');
          // Retry after 2 seconds
          Timer(const Duration(seconds: 2), () {
            scheduleSave(_pendingChanges, saveCallback);
          });
        }
      }
    });
  }
  
  static Future<void> _saveInBackground(
    Map<String, dynamic> settings,
    Function saveCallback,
  ) async {
    if (kIsWeb) {
      // Web doesn't support isolates, save directly
      await saveCallback(settings);
    } else {
      // Use compute for background processing
      await compute(_saveSettingsIsolate, {
        'settings': settings,
        'callback': saveCallback,
      });
    }
  }
  
  static Future<void> _saveSettingsIsolate(Map<String, dynamic> params) async {
    final settings = params['settings'] as Map<String, dynamic>;
    final callback = params['callback'] as Function;
    await callback(settings);
  }
  
  static void forceSave() {
    _saveTimer?.cancel();
    if (_hasUnsavedChanges) {
      // Force immediate save
      _saveTimer = Timer(Duration.zero, () async {
        _hasUnsavedChanges = false;
        _pendingChanges.clear();
      });
    }
  }
  
  static void dispose() {
    _saveTimer?.cancel();
    if (_hasUnsavedChanges) {
      // Emergency save on app close
      forceSave();
    }
  }
}
