import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:streakly/model/habit_completion.dart';

/// Service for managing habit completion storage
class HabitCompletionStorage {
  static const String _completionsKey = 'habit_completions';

  /// Save all habit completions
  static Future<void> saveCompletions(List<HabitCompletion> completions) async {
    final prefs = await SharedPreferences.getInstance();
    final completionMaps = completions
        .map((completion) => completion.toMap())
        .toList();
    final jsonString = jsonEncode(completionMaps);
    await prefs.setString(_completionsKey, jsonString);
  }

  /// Load all habit completions
  static Future<List<HabitCompletion>> loadCompletions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_completionsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> completionMaps = jsonDecode(jsonString);
      return completionMaps
          .map((map) => HabitCompletion.fromMap(map as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error loading habit completions: $e');
      return [];
    }
  }

  /// Save a single completion (adds or updates existing)
  static Future<void> saveCompletion(HabitCompletion completion) async {
    final completions = await loadCompletions();

    // Remove existing completion for the same habit and date
    completions.removeWhere(
      (existing) =>
          existing.habitId == completion.habitId &&
          existing.isForDate(completion.completedDate),
    );

    // Add the new completion
    completions.add(completion);

    await saveCompletions(completions);
  }

  /// Remove a completion
  static Future<void> removeCompletion(String habitId, DateTime date) async {
    final completions = await loadCompletions();

    completions.removeWhere(
      (completion) =>
          completion.habitId == habitId && completion.isForDate(date),
    );

    await saveCompletions(completions);
  }

  /// Get completions for a specific habit
  static Future<List<HabitCompletion>> getCompletionsForHabit(
    String habitId,
  ) async {
    final completions = await loadCompletions();
    return completions.forHabit(habitId);
  }

  /// Get completions for a specific date
  static Future<List<HabitCompletion>> getCompletionsForDate(
    DateTime date,
  ) async {
    final completions = await loadCompletions();
    return completions.forDate(date);
  }

  /// Check if a habit is completed on a specific date
  static Future<bool> isHabitCompletedOnDate(
    String habitId,
    DateTime date,
  ) async {
    final completions = await loadCompletions();
    return completions.isHabitCompletedOnDate(habitId, date);
  }

  /// Check if a habit is completed today
  static Future<bool> isHabitCompletedToday(String habitId) async {
    final completions = await loadCompletions();
    return completions.isHabitCompletedToday(habitId);
  }

  /// Get completion percentage for a date
  static Future<double> getCompletionPercentageForDate(
    DateTime date,
    List<String> habitIds,
  ) async {
    final completions = await loadCompletions();
    return completions.getCompletionPercentageForDate(date, habitIds);
  }

  /// Get all perfect days
  static Future<Set<DateTime>> getPerfectDays(List<String> habitIds) async {
    final completions = await loadCompletions();
    return completions.getPerfectDays(habitIds);
  }

  /// Clear all completions for a habit (when habit is deleted)
  static Future<void> clearCompletionsForHabit(String habitId) async {
    final completions = await loadCompletions();
    completions.removeWhere((completion) => completion.habitId == habitId);
    await saveCompletions(completions);
  }

  /// Clear all completions
  static Future<void> clearAllCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completionsKey);
  }

  /// Migrate old completion data format if needed
  static Future<void> migrateOldCompletionData(
    Map<String, List<String>> oldCompletions,
  ) async {
    final newCompletions = <HabitCompletion>[];

    for (final entry in oldCompletions.entries) {
      final habitId = entry.key;
      final dateStrings = entry.value;

      for (final dateString in dateStrings) {
        try {
          final date = DateTime.parse(dateString);
          final completion = HabitCompletion.forDate(
            habitId: habitId,
            date: date,
            isDone: true,
          );
          newCompletions.add(completion);
        } catch (e) {
          print('Error migrating completion date: $dateString');
        }
      }
    }

    if (newCompletions.isNotEmpty) {
      await saveCompletions(newCompletions);
    }
  }

  /// Get progress map for calendar display
  static Future<Map<DateTime, double>> getProgressMap(
    List<String> habitIds,
  ) async {
    if (habitIds.isEmpty) return {};

    final completions = await loadCompletions();
    final progressMap = <DateTime, double>{};

    // Group completions by date
    final completionsByDate = <DateTime, List<HabitCompletion>>{};
    for (final completion in completions) {
      if (completion.isDone) {
        completionsByDate
            .putIfAbsent(completion.completedDate, () => [])
            .add(completion);
      }
    }

    // Calculate progress for each date
    for (final entry in completionsByDate.entries) {
      final date = entry.key;
      final dateCompletions = entry.value;

      final completedHabits = dateCompletions.map((c) => c.habitId).toSet();
      final progress = completedHabits.length / habitIds.length;

      progressMap[date] = progress;
    }

    return progressMap;
  }
}
