import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/model/streak_entry.dart';
import 'package:streakly/services/local_storage.dart';
import 'dart:convert';

/// Repository for habit data management
class HabitRepository {
  static const String _habitsKey = 'habits';
  static const String _habitStreaksKey = 'habit_streaks';
  static const String _habitCompletionsKey = 'habit_completions';
  static const String _streakHistoryKey = 'streak_history';

  /// Save all habits to local storage
  Future<void> saveHabits(List<Habit> habits) async {
    final habitsJson = habits.map((habit) => habit.toMap()).toList();
    await LocalStorage.saveData(_habitsKey, json.encode(habitsJson));
  }

  /// Load all habits from local storage
  Future<List<Habit>> loadHabits() async {
    try {
      final data = await LocalStorage.loadData(_habitsKey);
      if (data == null) return [];

      final List<dynamic> habitsJson = json.decode(data);
      return habitsJson.map((json) => Habit.fromMap(json)).toList();
    } catch (e) {
      print('Error loading habits: $e');
      return [];
    }
  }

  /// Save habit streaks
  Future<void> saveHabitStreaks(Map<String, int> streaks) async {
    await LocalStorage.saveData(_habitStreaksKey, json.encode(streaks));
  }

  /// Load habit streaks
  Future<Map<String, int>> loadHabitStreaks() async {
    try {
      final data = await LocalStorage.loadData(_habitStreaksKey);
      if (data == null) return {};

      final Map<String, dynamic> streaksJson = json.decode(data);
      return streaksJson.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      print('Error loading habit streaks: $e');
      return {};
    }
  }

  /// Save habit completions (date-based tracking)
  Future<void> saveHabitCompletions(
    Map<String, List<String>> completions,
  ) async {
    await LocalStorage.saveData(_habitCompletionsKey, json.encode(completions));
  }

  /// Load habit completions
  Future<Map<String, List<String>>> loadHabitCompletions() async {
    try {
      final data = await LocalStorage.loadData(_habitCompletionsKey);
      if (data == null) return {};

      final Map<String, dynamic> completionsJson = json.decode(data);
      return completionsJson.map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
    } catch (e) {
      print('Error loading habit completions: $e');
      return {};
    }
  }

  /// Save streak history to local storage
  Future<void> saveStreakHistory(List<StreakEntry> streakHistory) async {
    final historyJson = streakHistory.map((entry) => entry.toMap()).toList();
    await LocalStorage.saveData(_streakHistoryKey, json.encode(historyJson));
  }

  /// Load streak history from local storage
  Future<List<StreakEntry>> loadStreakHistory() async {
    try {
      final data = await LocalStorage.loadData(_streakHistoryKey);
      if (data == null) return [];

      final List<dynamic> historyJson = json.decode(data);
      return historyJson.map((json) => StreakEntry.fromMap(json)).toList();
    } catch (e) {
      print('Error loading streak history: $e');
      return [];
    }
  }

  /// Get streak history for a specific habit
  Future<List<StreakEntry>> getHabitStreakHistory(String habitId) async {
    final allHistory = await loadStreakHistory();
    return allHistory.where((entry) => entry.habitId == habitId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Add a streak entry to history
  Future<void> addStreakEntry(StreakEntry entry) async {
    final currentHistory = await loadStreakHistory();

    // Remove existing entry for the same habit and date if it exists
    currentHistory.removeWhere(
      (existing) =>
          existing.habitId == entry.habitId &&
          _isSameDay(existing.date, entry.date),
    );

    // Add the new entry
    currentHistory.add(entry);

    // Save updated history
    await saveStreakHistory(currentHistory);
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}

/// Provider for habit repository
final habitRepositoryProvider = Provider<HabitRepository>((ref) {
  return HabitRepository();
});
