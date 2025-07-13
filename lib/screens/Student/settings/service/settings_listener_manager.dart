// File: lib/screens/student/settings/service/settings_listener_manager.dart
import 'package:flutter/foundation.dart';

class SettingsListenerManager {
  static final Map<String, Set<VoidCallback>> _listeners = {};
  static final Map<String, DateTime> _lastAccess = {};
  
  static void addListener(String key, VoidCallback listener) {
    _listeners.putIfAbsent(key, () => <VoidCallback>{});
    _listeners[key]!.add(listener);
    _lastAccess[key] = DateTime.now();
  }
  
  static void removeListener(String key, VoidCallback listener) {
    _listeners[key]?.remove(listener);
    if (_listeners[key]?.isEmpty ?? false) {
      _listeners.remove(key);
      _lastAccess.remove(key);
    }
  }
  
  static void notifyListeners(String key) {
    final listeners = _listeners[key];
    if (listeners != null) {
      for (final listener in List.from(listeners)) {
        try {
          listener();
        } catch (e) {
          debugPrint('Listener error: $e');
          // Remove broken listeners
          listeners.remove(listener);
        }
      }
      _lastAccess[key] = DateTime.now();
    }
  }
  
  static void cleanup() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _lastAccess.forEach((key, lastAccess) {
      if (now.difference(lastAccess).inMinutes > 30) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _listeners.remove(key);
      _lastAccess.remove(key);
    }
  }
  
  static void dispose() {
    _listeners.clear();
    _lastAccess.clear();
  }
}
