import 'package:streakly/model/habit_model.dart';
import 'package:streakly/model/habit_completion.dart';
import 'package:streakly/model/day_progress.dart';
import 'package:streakly/model/streak_entry.dart';
import 'package:streakly/types/habit_frequency_types.dart';

/// Service to calculate daily progress for habits
class DayProgressService {
  /// Calculate progress for a specific date using the new completion system
  static DayProgress calculateDayProgressFromCompletions(
    DateTime date,
    List<Habit> allHabits,
    List<HabitCompletion> completions,
  ) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Get habits that were due on this date
    final dueHabits = _getHabitsForDate(normalizedDate, allHabits);

    // Get completions for this date
    final dayCompletions = completions.forDate(normalizedDate);

    // Categorize habit completions
    final completedHabitIds = <String>[];
    final missedHabitIds = <String>[];
    final skippedHabitIds = <String>[]; // Not used in new system

    for (final habit in dueHabits) {
      final completion = dayCompletions
          .where((c) => c.habitId == habit.id && c.isDone)
          .firstOrNull;

      if (completion != null) {
        completedHabitIds.add(habit.id);
      } else {
        // Check if date is in the past to mark as missed
        final today = DateTime.now();
        final todayNormalized = DateTime(today.year, today.month, today.day);

        if (normalizedDate.isBefore(todayNormalized)) {
          missedHabitIds.add(habit.id);
        }
        // If it's today or future, don't mark as missed yet
      }
    }

    return DayProgress(
      date: normalizedDate,
      totalHabits: dueHabits.length,
      completedHabits: completedHabitIds.length,
      completedHabitIds: completedHabitIds,
      missedHabitIds: missedHabitIds,
      skippedHabitIds: skippedHabitIds,
    );
  }

  /// Calculate progress for a specific date (legacy method for backward compatibility)
  static DayProgress calculateDayProgress(
    DateTime date,
    List<Habit> allHabits,
    List<StreakEntry> streakEntries,
  ) {
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Get habits that were due on this date
    final dueHabits = _getHabitsForDate(normalizedDate, allHabits);

    // Get streak entries for this date
    final dayEntries = streakEntries.where((entry) {
      final entryDate = DateTime(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      return entryDate == normalizedDate;
    }).toList();

    // Categorize habit completions
    final completedHabitIds = <String>[];
    final missedHabitIds = <String>[];
    final skippedHabitIds = <String>[];

    for (final habit in dueHabits) {
      final entry = dayEntries.where((e) => e.habitId == habit.id).firstOrNull;

      if (entry != null) {
        switch (entry.status) {
          case StreakStatus.completed:
            completedHabitIds.add(habit.id);
            break;
          case StreakStatus.missed:
            missedHabitIds.add(habit.id);
            break;
          case StreakStatus.skipped:
            skippedHabitIds.add(habit.id);
            break;
        }
      } else {
        // No entry means the habit was missed (if the date is in the past)
        final today = DateTime.now();
        final todayNormalized = DateTime(today.year, today.month, today.day);

        if (normalizedDate.isBefore(todayNormalized)) {
          missedHabitIds.add(habit.id);
        }
      }
    }

    return DayProgress(
      date: normalizedDate,
      totalHabits: dueHabits.length,
      completedHabits: completedHabitIds.length,
      completedHabitIds: completedHabitIds,
      missedHabitIds: missedHabitIds,
      skippedHabitIds: skippedHabitIds,
    );
  }

  /// Get habits that are due on a specific date
  static List<Habit> _getHabitsForDate(DateTime date, List<Habit> allHabits) {
    return allHabits.where((habit) {
      // Check if habit existed on this date
      final habitStartDate = DateTime(
        habit.createdAt.year,
        habit.createdAt.month,
        habit.createdAt.day,
      );

      if (date.isBefore(habitStartDate)) {
        return false; // Habit didn't exist yet
      }

      // Check if habit is due on this date based on frequency
      return _isHabitDueOnDate(habit, date);
    }).toList();
  }

  /// Check if a habit is due on a specific date
  static bool _isHabitDueOnDate(Habit habit, DateTime date) {
    switch (habit.frequency.type) {
      case FrequencyType.daily:
        return true; // Daily habits are always due

      case FrequencyType.weekly:
        final dayOfWeek = date.weekday % 7; // Convert to 0-6 format
        return habit.frequency.selectedDays?.contains(dayOfWeek) ?? true;

      case FrequencyType.monthly:
        return _isMonthlyHabitDue(habit, date);

      case FrequencyType.yearly:
        if (habit.startDate != null) {
          return date.month == habit.startDate!.month &&
              date.day == habit.startDate!.day;
        }
        return false;

      case FrequencyType.longTerm:
        final endDate = habit.endDate;
        return endDate == null ||
            date.isBefore(endDate.add(const Duration(days: 1)));
    }
  }

  /// Check if a monthly habit is due on a specific date
  static bool _isMonthlyHabitDue(Habit habit, DateTime date) {
    if (habit.frequency.specificDates != null &&
        habit.frequency.specificDates!.isNotEmpty) {
      return habit.frequency.specificDates!.contains(date.day);
    }

    // If no specific dates, assume it's due on the day of the month when created
    return date.day == habit.createdAt.day;
  }
}
