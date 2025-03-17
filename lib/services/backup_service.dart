import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../database/database.dart';

class BackupService {
  final AppDatabase _database;
  
  // Maximum number of backup files to keep in the private directory
  static const int _maxBackupFiles = 5;

  BackupService(this._database);

  Future<String> createBackup() async {
    try {
      // Get the database file
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'spending_tracker.db'));
      
      if (!await dbFile.exists()) {
        throw Exception('Database file not found');
      }

      // Create backup directory if it doesn't exist
      final backupDir = Directory(p.join(dbFolder.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create();
      }

      // Generate backup filename with timestamp
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupFileName = 'kiwi_backup_$timestamp.db';
      final backupFile = File(p.join(backupDir.path, backupFileName));

      // Copy database file to backup location
      await dbFile.copy(backupFile.path);
      
      // Clean up old backup files
      await _cleanupOldBackups(backupDir);
      
      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
    }
  }

  /// Cleans up old backup files, keeping only the most recent ones
  Future<void> _cleanupOldBackups(Directory backupDir) async {
    try {
      // Get all backup files
      final files = await backupDir.list().where((entity) => 
        entity is File && 
        p.basename(entity.path).startsWith('kiwi_backup_') && 
        entity.path.endsWith('.db')
      ).toList();
      
      // Sort files by last modified time (newest first)
      files.sort((a, b) {
        final aTime = (a as File).lastModifiedSync();
        final bTime = (b as File).lastModifiedSync();
        return bTime.compareTo(aTime);
      });
      
      // Delete older files if we have more than the maximum
      if (files.length > _maxBackupFiles) {
        for (var i = _maxBackupFiles; i < files.length; i++) {
          await (files[i] as File).delete();
          debugPrint('Deleted old backup: ${files[i].path}');
        }
      }
      
      debugPrint('Backup cleanup complete. Keeping ${_maxBackupFiles} most recent backups.');
    } catch (e) {
      // Just log the error but don't rethrow - this is a background operation
      debugPrint('Error cleaning up old backups: $e');
    }
  }

  Future<void> shareBackup(String backupPath) async {
    try {
      final file = XFile(backupPath);
      await Share.shareXFiles([file], text: 'Kiwi Spending Tracker Backup');
    } catch (e) {
      debugPrint('Error sharing backup: $e');
      rethrow;
    }
  }

  Future<void> restoreFromBackup(String backupPath) async {
    try {
      final backupFile = File(backupPath);
      if (!await backupFile.exists()) {
        throw Exception('Backup file not found');
      }

      // Get the database file
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, 'spending_tracker.db'));

      // Close the database connection
      await _database.close();

      // Copy backup file to database location
      await backupFile.copy(dbFile.path);

      // We don't reopen the database here - it needs to be recreated
      // The app should be restarted after restore
    } catch (e) {
      debugPrint('Error restoring backup: $e');
      rethrow;
    }
  }

  Future<String?> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          // Verify it's a database file
          if (file.path!.toLowerCase().endsWith('.db')) {
            return file.path;
          } else {
            debugPrint('Selected file is not a database file: ${file.path}');
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking backup file: $e');
      return null;
    }
  }
  
  /// Gets information about backups stored in the app's private directory
  Future<Map<String, dynamic>> getBackupInfo() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(dbFolder.path, 'backups'));
      
      if (!await backupDir.exists()) {
        return {
          'count': 0,
          'totalSize': 0,
          'oldestBackup': null,
          'newestBackup': null,
        };
      }
      
      // Get all backup files
      final files = await backupDir.list().where((entity) => 
        entity is File && 
        p.basename(entity.path).startsWith('kiwi_backup_') && 
        entity.path.endsWith('.db')
      ).toList();
      
      if (files.isEmpty) {
        return {
          'count': 0,
          'totalSize': 0,
          'oldestBackup': null,
          'newestBackup': null,
        };
      }
      
      // Calculate total size
      int totalSize = 0;
      for (var file in files) {
        totalSize += await (file as File).length();
      }
      
      // Sort files by last modified time
      files.sort((a, b) {
        final aTime = (a as File).lastModifiedSync();
        final bTime = (b as File).lastModifiedSync();
        return aTime.compareTo(bTime);
      });
      
      return {
        'count': files.length,
        'totalSize': totalSize,
        'oldestBackup': files.first.path,
        'newestBackup': files.last.path,
      };
    } catch (e) {
      debugPrint('Error getting backup info: $e');
      return {
        'count': 0,
        'totalSize': 0,
        'oldestBackup': null,
        'newestBackup': null,
        'error': e.toString(),
      };
    }
  }
  
  /// Deletes all backup files from the app's private directory
  Future<bool> deleteAllBackups() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final backupDir = Directory(p.join(dbFolder.path, 'backups'));
      
      if (await backupDir.exists()) {
        await backupDir.delete(recursive: true);
        await backupDir.create(); // Recreate the empty directory
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting all backups: $e');
      return false;
    }
  }
} 