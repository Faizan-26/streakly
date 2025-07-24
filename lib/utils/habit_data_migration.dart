import 'dart:convert';
import 'package:streakly/services/local_storage.dart';

/// Utility class to handle data migration for existing habits
class HabitDataMigration {
  static const String _migrationVersionKey = 'habit_data_migration_version';
  static const int _currentMigrationVersion = 1;

  /// Check if migration is needed and perform it
  static Future<void> migrateIfNeeded() async {
    final currentVersion =
        await LocalStorage.loadData(_migrationVersionKey) as int? ?? 0;

    if (currentVersion < _currentMigrationVersion) {
      await _performMigration(currentVersion);
      await LocalStorage.saveData(
        _migrationVersionKey,
        _currentMigrationVersion,
      );
    }
  }

  /// Perform the actual migration
  static Future<void> _performMigration(int fromVersion) async {
    if (fromVersion < 1) {
      await _migrateToVersion1();
    }
  }

  /// Migration to version 1: Add icon font family support
  static Future<void> _migrateToVersion1() async {
    try {
      final habitDataList =
          await LocalStorage.loadData('habits') as List<String>? ?? [];

      if (habitDataList.isEmpty) return;

      final migratedHabits = <Map<String, dynamic>>[];

      for (final habitJson in habitDataList) {
        try {
          final habitMap = Map<String, dynamic>.from(json.decode(habitJson));

          // Add missing icon font family if not present
          if (habitMap.containsKey('icon') &&
              !habitMap.containsKey('iconFontFamily')) {
            habitMap['iconFontFamily'] = 'MaterialIcons';
            habitMap['iconFontPackage'] = null;
          }

          migratedHabits.add(habitMap);
        } catch (e) {
          // Skip malformed habit data
          continue;
        }
      }

      // Save the migrated habits
      final migratedJsonList = migratedHabits
          .map((habit) => json.encode(habit))
          .toList();

      await LocalStorage.saveData('habits', migratedJsonList);

      print(
        'Successfully migrated ${migratedHabits.length} habits to version 1',
      );
    } catch (e) {
      print('Error during habit data migration: $e');
      // Don't rethrow - migration failure shouldn't break the app
    }
  }
}
