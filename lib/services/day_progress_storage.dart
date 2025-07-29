import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streakly/model/day_progress.dart';

/// Service to store and retrieve day progress data
class DayProgressStorage {
  static const String _dayProgressKey = 'day_progress_data';

  /// Save day progress to storage
  static Future<void> saveDayProgress(DayProgress dayProgress) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = await getAllDayProgress();

    // Update or add the day progress
    final dateKey = _formatDateKey(dayProgress.date);
    existingData[dateKey] = dayProgress;

    // Convert to map for storage
    final dataToStore = existingData.map(
      (key, value) => MapEntry(key, value.toMap()),
    );

    await prefs.setString(_dayProgressKey, jsonEncode(dataToStore));
  }

  /// Save multiple day progress entries
  static Future<void> saveDayProgressBatch(
    List<DayProgress> dayProgressList,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = await getAllDayProgress();

    // Update or add all day progress entries
    for (final dayProgress in dayProgressList) {
      final dateKey = _formatDateKey(dayProgress.date);
      existingData[dateKey] = dayProgress;
    }

    // Convert to map for storage
    final dataToStore = existingData.map(
      (key, value) => MapEntry(key, value.toMap()),
    );

    await prefs.setString(_dayProgressKey, jsonEncode(dataToStore));
  }

  /// Get day progress for a specific date
  static Future<DayProgress?> getDayProgress(DateTime date) async {
    final allData = await getAllDayProgress();
    final dateKey = _formatDateKey(date);
    return allData[dateKey];
  }

  /// Get all day progress data
  static Future<Map<String, DayProgress>> getAllDayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_dayProgressKey);

    if (jsonString == null) {
      return {};
    }

    try {
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      final Map<String, DayProgress> result = {};

      jsonData.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          result[key] = DayProgress.fromMap(value);
        }
      });

      return result;
    } catch (e) {
      // If there's an error parsing, return empty map
      return {};
    }
  }

  /// Get day progress for a date range
  static Future<Map<DateTime, DayProgress>> getDayProgressForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allData = await getAllDayProgress();
    final result = <DateTime, DayProgress>{};

    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);

    var currentDate = start;
    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      final dateKey = _formatDateKey(currentDate);
      final dayProgress = allData[dateKey];

      if (dayProgress != null) {
        result[currentDate] = dayProgress;
      }

      currentDate = currentDate.add(const Duration(days: 1));
    }

    return result;
  }

  /// Get perfect days (dates where all habits were completed)
  static Future<Set<DateTime>> getPerfectDays() async {
    final allData = await getAllDayProgress();
    final perfectDays = <DateTime>{};

    allData.values.where((dayProgress) => dayProgress.isPerfectDay).forEach((
      dayProgress,
    ) {
      perfectDays.add(dayProgress.normalizedDate);
    });

    return perfectDays;
  }

  /// Get progress percentages for calendar display
  static Future<Map<DateTime, double>> getProgressPercentages() async {
    final allData = await getAllDayProgress();
    final progressMap = <DateTime, double>{};

    for (var dayProgress in allData.values) {
      progressMap[dayProgress.normalizedDate] = dayProgress.progressPercentage;
    }

    return progressMap;
  }

  /// Clear all day progress data
  static Future<void> clearAllDayProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dayProgressKey);
  }

  /// Delete day progress for a specific date
  static Future<void> deleteDayProgress(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = await getAllDayProgress();

    final dateKey = _formatDateKey(date);
    existingData.remove(dateKey);

    // Convert to map for storage
    final dataToStore = existingData.map(
      (key, value) => MapEntry(key, value.toMap()),
    );

    await prefs.setString(_dayProgressKey, jsonEncode(dataToStore));
  }

  /// Format date as a string key for storage
  static String _formatDateKey(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return normalized.toIso8601String().split('T')[0]; // Returns YYYY-MM-DD
  }

  /// Get statistics for a date range
  static Future<Map<String, dynamic>> getStatistics(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final progressData = await getDayProgressForRange(startDate, endDate);

    int totalDays = progressData.length;
    int perfectDays = 0;
    int daysWithProgress = 0;
    double totalProgressPercentage = 0.0;

    for (var dayProgress in progressData.values) {
      if (dayProgress.isPerfectDay) {
        perfectDays++;
      }
      if (dayProgress.hasProgress) {
        daysWithProgress++;
      }
      totalProgressPercentage += dayProgress.progressPercentage;
    }

    return {
      'totalDays': totalDays,
      'perfectDays': perfectDays,
      'daysWithProgress': daysWithProgress,
      'averageProgress': totalDays > 0
          ? totalProgressPercentage / totalDays
          : 0.0,
      'perfectDayPercentage': totalDays > 0 ? perfectDays / totalDays : 0.0,
    };
  }
}
