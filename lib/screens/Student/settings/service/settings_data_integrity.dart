// File: lib/screens/student/settings/service/settings_data_integrity.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class SettingsDataIntegrity {
  static const String _settingsFileName = 'app_settings.json';
  static const String _backupFileName = 'app_settings_backup.json';
  static const String _tempFileName = 'app_settings_temp.json';
  
  static Future<void> atomicSave(Map<String, dynamic> settings) async {
    final directory = await getApplicationDocumentsDirectory();
    final settingsFile = File('${directory.path}/$_settingsFileName');
    final backupFile = File('${directory.path}/$_backupFileName');
    final tempFile = File('${directory.path}/$_tempFileName');
    
    try {
      // 1. Create backup of current settings
      if (await settingsFile.exists()) {
        await settingsFile.copy(backupFile.path);
      }
      
      // 2. Write to temporary file first
      final settingsJson = jsonEncode(settings);
      final checksum = _calculateChecksum(settingsJson);
      
      final dataWithChecksum = {
        'data': settings,
        'checksum': checksum,
        'timestamp': DateTime.now().toIso8601String(),
        'version': settings['version'],
      };
      
      await tempFile.writeAsString(jsonEncode(dataWithChecksum));
      
      // 3. Verify the temporary file
      final verification = await _verifyFile(tempFile);
      if (!verification) {
        throw Exception('Temporary file verification failed');
      }
      
      // 4. Atomic move (rename) temp file to actual file
      await tempFile.rename(settingsFile.path);
      
      // 5. Clean up backup after successful write
      if (await backupFile.exists()) {
        await backupFile.delete();
      }
      
    } catch (e) {
      // Restore from backup if save failed
      if (await backupFile.exists()) {
        await backupFile.copy(settingsFile.path);
        await backupFile.delete();
      }
      
      // Clean up temp file
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
      
      throw Exception('Atomic save failed: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> atomicLoad() async {
    final directory = await getApplicationDocumentsDirectory();
    final settingsFile = File('${directory.path}/$_settingsFileName');
    final backupFile = File('${directory.path}/$_backupFileName');
    
    // Try to load main file first
    if (await settingsFile.exists()) {
      final result = await _loadAndVerifyFile(settingsFile);
      if (result != null) return result;
    }
    
    // Fallback to backup file
    if (await backupFile.exists()) {
      final result = await _loadAndVerifyFile(backupFile);
      if (result != null) {
        // Restore backup to main file
        await backupFile.copy(settingsFile.path);
        return result;
      }
    }
    
    return null;
  }
  
  static Future<Map<String, dynamic>?> _loadAndVerifyFile(File file) async {
    try {
      final content = await file.readAsString();
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      
      final data = parsed['data'] as Map<String, dynamic>;
      final storedChecksum = parsed['checksum'] as String;
      final calculatedChecksum = _calculateChecksum(jsonEncode(data));
      
      if (storedChecksum != calculatedChecksum) {
        throw Exception('Checksum mismatch');
      }
      
      return data;
    } catch (e) {
      debugPrint('File verification failed: $e');
      return null;
    }
  }
  
  static Future<bool> _verifyFile(File file) async {
    try {
      final content = await file.readAsString();
      final parsed = jsonDecode(content);
      return parsed['data'] != null && parsed['checksum'] != null;
    } catch (e) {
      return false;
    }
  }
  
  static String _calculateChecksum(String data) {
    return sha256.convert(utf8.encode(data)).toString();
  }
}
