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
      
      return backupFile.path;
    } catch (e) {
      debugPrint('Error creating backup: $e');
      rethrow;
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

  Future<String?> saveBackupToDownloads(String backupPath) async {
    try {
      // For Android 11+ (API level 30+), we need to use a different approach
      // We'll use the share functionality to let the user save the file
      final file = XFile(backupPath);
      await Share.shareXFiles(
        [file], 
        text: 'Save your Kiwi Spending Tracker backup file',
        subject: 'Kiwi Spending Tracker Backup'
      );
      
      // Since we're using the share functionality, we don't know where the user saved it
      return 'File shared for saving. Please check your device storage.';
    } catch (e) {
      debugPrint('Error saving backup to downloads: $e');
      return null;
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
} 