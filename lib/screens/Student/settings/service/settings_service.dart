import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsService extends ChangeNotifier {
  static SettingsService? _instance;
  static SettingsService get instance => _instance ??= SettingsService._();
  
  SettingsService._();

  static const String _settingsKey = 'app_settings_v6';
  static const String _checksumKey = 'settings_checksum_v6';
  static const int _currentVersion = 6;

  // REMOVED: All subscription-related settings
  static Map<String, dynamic> get _defaultSettings => {
    'version': _currentVersion,
    'notifications': {
      'pushEnabled': true,
      'emailEnabled': true,
      'courseReminders': true,
      'liveClassReminders': true,
      'assignmentDeadlines': true,
      'achievementNotifications': true,
      'quietHours': {
        'enabled': false,
        'startTime': '22:00',
        'endTime': '08:00',
      },
    },
    'learning': {
      'autoPlay': true,
      'playbackSpeed': 1.0,
      'subtitlesEnabled': true,
      'downloadQuality': 'medium',
      'studyReminders': {
        'enabled': true,
        'frequency': 'daily',
        'time': '19:00',
      },
      'progressTracking': true,
      'analyticsSharing': true,
    },
    'privacy': {
      'profileVisibility': 'private',
      'showOnlineStatus': false,
      'shareProgress': false,
      'dataCollection': true,
      'crashReporting': true,
    },
    'storage': {
      'maxCacheSize': 500,
      'autoDeleteDownloads': false,
      'downloadOnWifiOnly': true,
    },
    'account': {
      'language': 'en',
      'timezone': 'auto',
      'currency': 'INR',
      'twoFactorEnabled': false,
    },
    // REMOVED: subscription, billing, payment settings
  };

  Map<String, dynamic> _settings = {};
  bool _isInitialized = false;

  // Real-time sync variables
  RealtimeChannel? _settingsChannel;
  bool _isRealTimeEnabled = false;

  // Getters (unchanged)
  bool get pushNotificationsEnabled => _getSetting(['notifications', 'pushEnabled'], true);
  bool get emailNotificationsEnabled => _getSetting(['notifications', 'emailEnabled'], true);
  bool get courseRemindersEnabled => _getSetting(['notifications', 'courseReminders'], true);
  bool get liveClassRemindersEnabled => _getSetting(['notifications', 'liveClassReminders'], true);
  bool get assignmentDeadlinesEnabled => _getSetting(['notifications', 'assignmentDeadlines'], true);
  bool get achievementNotificationsEnabled => _getSetting(['notifications', 'achievementNotifications'], true);
  
  bool get autoPlayEnabled => _getSetting(['learning', 'autoPlay'], true);
  double get playbackSpeed => _getSetting(['learning', 'playbackSpeed'], 1.0);
  bool get subtitlesEnabled => _getSetting(['learning', 'subtitlesEnabled'], true);
  String get downloadQuality => _getSetting(['learning', 'downloadQuality'], 'medium');
  bool get progressTrackingEnabled => _getSetting(['learning', 'progressTracking'], true);
  bool get analyticsSharing => _getSetting(['learning', 'analyticsSharing'], true);
  
  String get profileVisibility => _getSetting(['privacy', 'profileVisibility'], 'private');
  bool get showOnlineStatus => _getSetting(['privacy', 'showOnlineStatus'], false);
  bool get shareProgress => _getSetting(['privacy', 'shareProgress'], false);
  bool get dataCollection => _getSetting(['privacy', 'dataCollection'], true);
  bool get crashReporting => _getSetting(['privacy', 'crashReporting'], true);
  
  int get maxCacheSize => _getSetting(['storage', 'maxCacheSize'], 500);
  bool get autoDeleteDownloads => _getSetting(['storage', 'autoDeleteDownloads'], false);
  bool get downloadOnWifiOnly => _getSetting(['storage', 'downloadOnWifiOnly'], true);
  
  String get language => _getSetting(['account', 'language'], 'en');
  String get timezone => _getSetting(['account', 'timezone'], 'auto');
  String get currency => _getSetting(['account', 'currency'], 'INR');
  bool get twoFactorEnabled => _getSetting(['account', 'twoFactorEnabled'], false);

  T _getSetting<T>(List<String> path, T defaultValue) {
    try {
      dynamic current = _settings;
      for (String key in path) {
        if (current is Map<String, dynamic> && current.containsKey(key)) {
          current = current[key];
        } else {
          return defaultValue;
        }
      }
      return current is T ? current : defaultValue;
    } catch (e) {
      debugPrint('Error getting setting ${path.join('.')}: $e');
      return defaultValue;
    }
  }

  Future<void> _setSetting(List<String> path, dynamic value) async {
    try {
      Map<String, dynamic> current = _settings;
      
      for (int i = 0; i < path.length - 1; i++) {
        String key = path[i];
        if (!current.containsKey(key) || current[key] is! Map<String, dynamic>) {
          current[key] = <String, dynamic>{};
        }
        current = current[key] as Map<String, dynamic>;
      }
      
      current[path.last] = value;
      
      await _saveSettings();
      
      // Sync to Supabase in real-time
      if (_isRealTimeEnabled) {
        await _syncToSupabase();
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting ${path.join('.')}: $e');
      throw Exception('Failed to update setting');
    }
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _loadSettings();
      await _initializeRealTime();
      _isInitialized = true;
    } catch (e) {
      debugPrint('Settings initialization failed: $e');
      await _resetToDefaults();
      _isInitialized = true;
    }
  }

  Future<void> _initializeRealTime() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Create or update user settings in Supabase
      await _syncToSupabase();

      // Subscribe to real-time changes
      _settingsChannel = Supabase.instance.client
          .channel('user_settings_${user.id}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'user_settings',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: user.id,
            ),
            callback: _handleRealTimeUpdate,
          )
          .subscribe();

      _isRealTimeEnabled = true;
      debugPrint('Real-time settings sync enabled');
    } catch (e) {
      debugPrint('Failed to initialize real-time sync: $e');
      // Continue without real-time sync
    }
  }

  void _handleRealTimeUpdate(PostgresChangePayload payload) {
    try {
      final newSettings = payload.newRecord!['settings'] as Map<String, dynamic>;
      final serverTimestamp = DateTime.parse(payload.newRecord!['updated_at']);
      final localTimestamp = DateTime.now().subtract(const Duration(seconds: 5));

      // Only update if server change is newer (avoid infinite loops)
      if (serverTimestamp.isAfter(localTimestamp)) {
        _settings = _mergeWithDefaults(newSettings);
        _saveSettingsLocally(); // Save without triggering sync
        notifyListeners();
        debugPrint('Settings updated from real-time sync');
      }
        } catch (e) {
      debugPrint('Error handling real-time update: $e');
    }
  }

  Future<void> _syncToSupabase() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      await Supabase.instance.client
          .from('user_settings')
          .upsert({
            'user_id': user.id,
            'settings': _settings,
            'updated_at': DateTime.now().toIso8601String(),
          });

      debugPrint('Settings synced to Supabase');
    } catch (e) {
      debugPrint('Failed to sync settings to Supabase: $e');
      // Continue with local storage only
    }
  }

  Future<void> _loadSettings() async {
    // Try to load from Supabase first
    await _loadFromSupabase();
    
    // Fallback to local storage
    if (_settings.isEmpty) {
      await _loadFromLocal();
    }

    if (_settings.isEmpty) {
      _settings = _deepCopy(_defaultSettings);
      await _saveSettings();
    }
  }

  Future<void> _loadFromSupabase() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('user_settings')
          .select('settings')
          .eq('user_id', user.id)
          .maybeSingle();

      if (response != null && response['settings'] != null) {
        _settings = _mergeWithDefaults(response['settings']);
        await _saveSettingsLocally(); // Cache locally
        debugPrint('Settings loaded from Supabase');
      }
    } catch (e) {
      debugPrint('Failed to load settings from Supabase: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    final storedChecksum = prefs.getString(_checksumKey);

    if (settingsJson == null) return;

    final calculatedChecksum = _calculateChecksum(settingsJson);
    if (storedChecksum != calculatedChecksum) {
      debugPrint('Settings checksum mismatch - data may be corrupted');
      return;
    }

    try {
      final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
      
      final version = decoded['version'] ?? 1;
      if (version < _currentVersion) {
        _settings = await _migrateSettings(decoded, version);
      } else {
        _settings = _mergeWithDefaults(decoded);
      }
      
      debugPrint('Settings loaded from local storage');
    } catch (e) {
      debugPrint('Failed to parse local settings: $e');
    }
  }

  Map<String, dynamic> _deepCopy(Map<String, dynamic> original) {
    Map<String, dynamic> copy = {};
    original.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        copy[key] = _deepCopy(value);
      } else if (value is List) {
        copy[key] = List.from(value);
      } else {
        copy[key] = value;
      }
    });
    return copy;
  }

  Map<String, dynamic> _mergeWithDefaults(Map<String, dynamic> stored) {
    final merged = _deepCopy(_defaultSettings);
    
    void mergeRecursive(Map<String, dynamic> target, Map<String, dynamic> source) {
      source.forEach((key, value) {
        if (target.containsKey(key)) {
          if (value is Map<String, dynamic> && target[key] is Map<String, dynamic>) {
            mergeRecursive(target[key], value);
          } else {
            target[key] = value;
          }
        }
      });
    }
    
    mergeRecursive(merged, stored);
    return merged;
  }

  Future<Map<String, dynamic>> _migrateSettings(
    Map<String, dynamic> oldSettings,
    int fromVersion,
  ) async {
    debugPrint('Migrating settings from version $fromVersion to $_currentVersion');
    
    switch (fromVersion) {
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        // Remove subscription-related settings
        oldSettings.remove('subscription');
        oldSettings.remove('billing');
        oldSettings.remove('payment');
        oldSettings.remove('theme');
        oldSettings.remove('accessibility');
        oldSettings['version'] = _currentVersion;
        break;
    }
    
    return _mergeWithDefaults(oldSettings);
  }

  Future<void> _saveSettings() async {
    await Future.wait([
      _saveSettingsLocally(),
      if (_isRealTimeEnabled) _syncToSupabase(),
    ]);
  }

  Future<void> _saveSettingsLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = jsonEncode(_settings);
      final checksum = _calculateChecksum(settingsJson);
      
      await Future.wait([
        prefs.setString(_settingsKey, settingsJson),
        prefs.setString(_checksumKey, checksum),
      ]);
    } catch (e) {
      debugPrint('Failed to save settings locally: $e');
      throw Exception('Settings save failed');
    }
  }

  String _calculateChecksum(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }

  Future<void> _resetToDefaults() async {
    _settings = _deepCopy(_defaultSettings);
    await _saveSettings();
    notifyListeners();
  }

  // Update methods (unchanged)
  Future<void> updateNotificationSetting(String key, bool value) async {
    await _setSetting(['notifications', key], value);
  }

  Future<void> updateLearningPreference(String key, dynamic value) async {
    await _setSetting(['learning', key], value);
  }

  Future<void> updatePrivacySetting(String key, dynamic value) async {
    await _setSetting(['privacy', key], value);
  }

  Future<void> updateStorageSetting(String key, dynamic value) async {
    await _setSetting(['storage', key], value);
  }

  Future<void> updateAccountSetting(String key, dynamic value) async {
    await _setSetting(['account', key], value);
  }

  Future<void> updateQuietHours({
    required bool enabled,
    String? startTime,
    String? endTime,
  }) async {
    await _setSetting(['notifications', 'quietHours', 'enabled'], enabled);
    if (startTime != null) {
      await _setSetting(['notifications', 'quietHours', 'startTime'], startTime);
    }
    if (endTime != null) {
      await _setSetting(['notifications', 'quietHours', 'endTime'], endTime);
    }
  }

  Future<void> updateStudyReminders({
    required bool enabled,
    String? frequency,
    String? time,
  }) async {
    await _setSetting(['learning', 'studyReminders', 'enabled'], enabled);
    if (frequency != null) {
      await _setSetting(['learning', 'studyReminders', 'frequency'], frequency);
    }
    if (time != null) {
      await _setSetting(['learning', 'studyReminders', 'time'], time);
    }
  }

  // Utility methods
  Map<String, dynamic> getAllSettings() => _deepCopy(_settings);
  
  Map<String, dynamic> getQuietHours() => _getSetting(['notifications', 'quietHours'], {
    'enabled': false,
    'startTime': '22:00',
    'endTime': '08:00',
  });
  
  Map<String, dynamic> getStudyReminders() => _getSetting(['learning', 'studyReminders'], {
    'enabled': true,
    'frequency': 'daily',
    'time': '19:00',
  });
  
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
    await prefs.remove(_checksumKey);
    
    // Clear from Supabase
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client
            .from('user_settings')
            .delete()
            .eq('user_id', user.id);
      }
    } catch (e) {
      debugPrint('Failed to clear settings from Supabase: $e');
    }
    
    await _resetToDefaults();
  }

  @override
  void dispose() {
    _settingsChannel?.unsubscribe();
    super.dispose();
  }
}
