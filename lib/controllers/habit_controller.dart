import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/model/streak_entry.dart';
import 'package:streakly/controllers/habit_repository.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:flutter/material.dart';

/// State class for habit management
@immutable
class HabitState {
  final List<Habit> habits;
  final Map<String, int> streaks;
  final Map<String, List<String>>
  completions; // habitId -> list of completion dates
  final List<StreakEntry> streakHistory;
  final bool isLoading;
  final String? error;

  const HabitState({
    this.habits = const [],
    this.streaks = const {},
    this.completions = const {},
    this.streakHistory = const [],
    this.isLoading = false,
    this.error,
  });

  HabitState copyWith({
    List<Habit>? habits,
    Map<String, int>? streaks,
    Map<String, List<String>>? completions,
    List<StreakEntry>? streakHistory,
    bool? isLoading,
    String? error,
  }) {
    return HabitState(
      habits: habits ?? this.habits,
      streaks: streaks ?? this.streaks,
      completions: completions ?? this.completions,
      streakHistory: streakHistory ?? this.streakHistory,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get habit by ID
  Habit? getHabitById(String id) {
    try {
      return habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get streak count for a habit
  int getStreakCount(String habitId) {
    return streaks[habitId] ?? 0;
  }

  /// Check if habit is completed today
  bool isHabitCompletedToday(String habitId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return completions[habitId]?.contains(today) ?? false;
  }

  /// Get habits by type
  List<Habit> getHabitsByType(HabitType type) {
    return habits.where((habit) => habit.type == type).toList();
  }

  /// Get today's due habits
  List<Habit> getTodaysDueHabits() {
    final today = DateTime.now();
    return habits.where((habit) {
      return NotificationService.isHabitDueOnDate(habit, today);
    }).toList();
  }

  /// Get streak history for a specific habit
  List<StreakEntry> getHabitStreakHistory(String habitId) {
    return streakHistory.where((entry) => entry.habitId == habitId).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Get streak entry for a specific habit and date
  StreakEntry? getStreakEntry(String habitId, DateTime date) {
    return streakHistory
        .where(
          (entry) => entry.habitId == habitId && _isSameDay(entry.date, date),
        )
        .firstOrNull;
  }

  /// Check if habit was completed on a specific date
  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    final entry = getStreakEntry(habitId, date);
    return entry?.status == StreakStatus.completed;
  }

  /// Get the longest streak for a habit
  int getLongestStreak(String habitId) {
    final history = getHabitStreakHistory(habitId);
    if (history.isEmpty) return 0;

    int longestStreak = 0;
    int currentStreak = 0;

    for (final entry in history) {
      if (entry.status == StreakStatus.completed) {
        currentStreak++;
        longestStreak = currentStreak > longestStreak
            ? currentStreak
            : longestStreak;
      } else if (entry.status == StreakStatus.missed) {
        currentStreak = 0;
      }
      // Skip doesn't break streak, so we don't reset currentStreak
    }

    return longestStreak;
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Get habits filtered by time of day preference
  List<Habit> getHabitsByTimeOfDay(TimeOfDayPreference timeOfDay) {
    if (timeOfDay == TimeOfDayPreference.anytime) {
      // Return all habits when filtering by anytime
      return habits;
    }
    return habits.where((habit) => habit.timeOfDay == timeOfDay).toList();
  }

  /// Get habits due on a specific day of the week (0 = Sunday, 6 = Saturday)
  List<Habit> getHabitsByDayOfWeek(int dayOfWeek) {
    return habits.where((habit) {
      // Check if habit is due on this day based on its frequency
      switch (habit.frequency.type) {
        case FrequencyType.daily:
          return true; // Daily habits are due every day
        case FrequencyType.weekly:
          return habit.frequency.selectedDays?.contains(dayOfWeek) ?? false;
        case FrequencyType.monthly:
        case FrequencyType.yearly:
        case FrequencyType.longTerm:
          // For these types, we need to check if the specific date matches
          final now = DateTime.now();
          return NotificationService.isHabitDueOnDate(habit, now);
      }
    }).toList();
  }

  /// Get habits filtered by both day of week and time of day
  List<Habit> getHabitsForDayAndTime(
    int dayOfWeek,
    TimeOfDayPreference timeOfDay,
  ) {
    final habitsForDay = getHabitsByDayOfWeek(dayOfWeek);

    if (timeOfDay == TimeOfDayPreference.anytime) {
      return habitsForDay;
    }

    return habitsForDay.where((habit) => habit.timeOfDay == timeOfDay).toList();
  }

  /// Get habits for today filtered by time of day
  List<Habit> getTodaysHabitsByTimeOfDay(TimeOfDayPreference timeOfDay) {
    final today = DateTime.now();
    final todaysHabits = habits.where((habit) {
      return NotificationService.isHabitDueOnDate(habit, today);
    }).toList();

    if (timeOfDay == TimeOfDayPreference.anytime) {
      return todaysHabits;
    }

    return todaysHabits.where((habit) => habit.timeOfDay == timeOfDay).toList();
  }

  /// Get habits grouped by time of day for today
  Map<TimeOfDayPreference, List<Habit>> getTodaysHabitsGroupedByTime() {
    final todaysHabits = getTodaysDueHabits();
    final Map<TimeOfDayPreference, List<Habit>> grouped = {};

    for (final timeOfDay in TimeOfDayPreference.values) {
      if (timeOfDay == TimeOfDayPreference.anytime) {
        grouped[timeOfDay] = todaysHabits;
      } else {
        grouped[timeOfDay] = todaysHabits
            .where((habit) => habit.timeOfDay == timeOfDay)
            .toList();
      }
    }

    return grouped;
  }
}

/// Habit controller using Riverpod
class HabitController extends StateNotifier<HabitState> {
  final HabitRepository _repository;

  HabitController(this._repository) : super(const HabitState()) {
    _loadHabits();
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Load habits from storage
  Future<void> _loadHabits() async {
    if (!mounted) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final habits = await _repository.loadHabits();
      if (!mounted) return;

      final streaks = await _repository.loadHabitStreaks();
      if (!mounted) return;

      final completions = await _repository.loadHabitCompletions();
      if (!mounted) return;

      final streakHistory = await _repository.loadStreakHistory();
      if (!mounted) return;

      // Check for missed days and update streaks
      await _checkForMissedDays(habits, streaks, completions, streakHistory);

      state = state.copyWith(
        habits: habits,
        streaks: streaks,
        completions: completions,
        streakHistory: streakHistory,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load habits: $e',
      );
    }
  }

  /// Check for missed days and update streaks accordingly
  Future<void> _checkForMissedDays(
    List<Habit> habits,
    Map<String, int> streaks,
    Map<String, List<String>> completions,
    List<StreakEntry> streakHistory,
  ) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    for (final habit in habits) {
      // Check if the habit was due yesterday and if it wasn't completed
      if (NotificationService.isHabitDueOnDate(habit, yesterday)) {
        final yesterdayStr = yesterday.toIso8601String().split('T')[0];
        final wasCompletedYesterday =
            completions[habit.id]?.contains(yesterdayStr) ?? false;

        // Check if we already have a streak entry for yesterday
        final existingEntry = streakHistory
            .where(
              (entry) =>
                  entry.habitId == habit.id &&
                  _isSameDay(entry.date, yesterday),
            )
            .firstOrNull;

        if (!wasCompletedYesterday && existingEntry == null) {
          // Habit was missed yesterday, break the streak and record it
          streaks[habit.id] = 0;

          // Add missed entry to streak history
          final missedEntry = StreakEntry(
            habitId: habit.id,
            date: yesterday,
            status: StreakStatus.missed,
            streakCount: 0,
          );
          streakHistory.add(missedEntry);
        }
      }
    }

    // Save updated data
    await _repository.saveHabitStreaks(streaks);
    await _repository.saveStreakHistory(streakHistory);
  }

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    try {
      final updatedHabits = [...state.habits, habit];

      // Save to storage
      await _repository.saveHabits(updatedHabits);

      // Schedule notifications if enabled
      if (habit.hasReminder && habit.reminderTime != null) {
        await NotificationService.scheduleWeeklyHabitReminders(habit);
      }

      // Update state
      state = state.copyWith(habits: updatedHabits, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to add habit: $e');
    }
  }

  /// Update an existing habit
  Future<void> updateHabit(Habit updatedHabit) async {
    try {
      final habitIndex = state.habits.indexWhere(
        (h) => h.id == updatedHabit.id,
      );
      if (habitIndex == -1) {
        state = state.copyWith(error: 'Habit not found');
        return;
      }

      final updatedHabits = [...state.habits];
      updatedHabits[habitIndex] = updatedHabit;

      // Save to storage
      await _repository.saveHabits(updatedHabits);

      // Update notifications
      await NotificationService.cancelAllHabitReminders(updatedHabit.id);
      if (updatedHabit.hasReminder && updatedHabit.reminderTime != null) {
        await NotificationService.scheduleWeeklyHabitReminders(updatedHabit);
      }

      // Update state
      state = state.copyWith(habits: updatedHabits, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update habit: $e');
    }
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    try {
      final updatedHabits = state.habits.where((h) => h.id != habitId).toList();
      final updatedStreaks = Map<String, int>.from(state.streaks)
        ..remove(habitId);
      final updatedCompletions = Map<String, List<String>>.from(
        state.completions,
      )..remove(habitId);

      // Save to storage
      await _repository.saveHabits(updatedHabits);
      await _repository.saveHabitStreaks(updatedStreaks);
      await _repository.saveHabitCompletions(updatedCompletions);

      // Cancel notifications
      await NotificationService.cancelAllHabitReminders(habitId);

      // Update state
      state = state.copyWith(
        habits: updatedHabits,
        streaks: updatedStreaks,
        completions: updatedCompletions,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete habit: $e');
    }
  }

  /// Mark habit as completed for today
  Future<void> completeHabit(String habitId) async {
    try {
      final habit = state.getHabitById(habitId);
      if (habit == null) {
        state = state.copyWith(error: 'Habit not found');
        return;
      }

      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      final updatedCompletions = Map<String, List<String>>.from(
        state.completions,
      );

      // Add today's completion
      if (updatedCompletions[habitId] == null) {
        updatedCompletions[habitId] = [];
      }

      if (!updatedCompletions[habitId]!.contains(todayStr)) {
        updatedCompletions[habitId]!.add(todayStr);

        // Update streak
        final updatedStreaks = Map<String, int>.from(state.streaks);
        updatedStreaks[habitId] = (updatedStreaks[habitId] ?? 0) + 1;

        // Update streak history
        final updatedStreakHistory = List<StreakEntry>.from(
          state.streakHistory,
        );

        // Remove any existing entry for today (in case of re-completion)
        updatedStreakHistory.removeWhere(
          (entry) => entry.habitId == habitId && _isSameDay(entry.date, today),
        );

        // Add completion entry
        final completionEntry = StreakEntry(
          habitId: habitId,
          date: today,
          status: StreakStatus.completed,
          streakCount: updatedStreaks[habitId]!,
        );
        updatedStreakHistory.add(completionEntry);

        // Cancel today's notification if it hasn't been sent yet
        await NotificationService.cancelHabitReminder(
          habitId: habitId,
          scheduledDate: today,
        );

        // Save to storage
        await _repository.saveHabitCompletions(updatedCompletions);
        await _repository.saveHabitStreaks(updatedStreaks);
        await _repository.saveStreakHistory(updatedStreakHistory);

        // Send celebration notification
        await NotificationService.sendCompletionCelebration(
          habit: habit,
          streakCount: updatedStreaks[habitId]!,
        );

        // Update state
        state = state.copyWith(
          completions: updatedCompletions,
          streaks: updatedStreaks,
          streakHistory: updatedStreakHistory,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete habit: $e');
    }
  }

  /// Mark habit as incomplete (for negative habits or unchecking)
  Future<void> uncompleteHabit(String habitId) async {
    try {
      final habit = state.getHabitById(habitId);
      if (habit == null) {
        state = state.copyWith(error: 'Habit not found');
        return;
      }

      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      final updatedCompletions = Map<String, List<String>>.from(
        state.completions,
      );

      // Remove today's completion
      if (updatedCompletions[habitId] != null) {
        updatedCompletions[habitId]!.remove(todayStr);

        // Handle streak logic based on habit type
        final updatedStreaks = Map<String, int>.from(state.streaks);
        final updatedStreakHistory = List<StreakEntry>.from(
          state.streakHistory,
        );

        if (habit.type == HabitType.negative) {
          // For negative habits, unchecking breaks the streak
          updatedStreaks[habitId] = 0;

          // Update streak history - mark as missed
          updatedStreakHistory.removeWhere(
            (entry) =>
                entry.habitId == habitId && _isSameDay(entry.date, today),
          );

          final missedEntry = StreakEntry(
            habitId: habitId,
            date: today,
            status: StreakStatus.missed,
            streakCount: 0,
          );
          updatedStreakHistory.add(missedEntry);
        } else {
          // For regular habits, just decrease streak by 1 (minimum 0)
          updatedStreaks[habitId] = ((updatedStreaks[habitId] ?? 0) - 1)
              .clamp(0, double.infinity)
              .toInt();

          // Remove completion entry from history
          updatedStreakHistory.removeWhere(
            (entry) =>
                entry.habitId == habitId && _isSameDay(entry.date, today),
          );
        }

        // Reschedule notification if the reminder time is still in the future
        if (habit.hasReminder && habit.reminderTime != null) {
          final reminderDateTime = DateTime(
            today.year,
            today.month,
            today.day,
            habit.reminderTime!.hour,
            habit.reminderTime!.minute,
          );

          if (reminderDateTime.isAfter(DateTime.now())) {
            await NotificationService.scheduleWeeklyHabitReminders(habit);
          }
        }

        // Save to storage
        await _repository.saveHabitCompletions(updatedCompletions);
        await _repository.saveHabitStreaks(updatedStreaks);
        await _repository.saveStreakHistory(updatedStreakHistory);

        // Update state
        state = state.copyWith(
          completions: updatedCompletions,
          streaks: updatedStreaks,
          streakHistory: updatedStreakHistory,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to uncomplete habit: $e');
    }
  }

  /// Reset streak for a habit
  Future<void> resetStreak(String habitId) async {
    try {
      final updatedStreaks = Map<String, int>.from(state.streaks);
      updatedStreaks[habitId] = 0;

      await _repository.saveHabitStreaks(updatedStreaks);

      state = state.copyWith(streaks: updatedStreaks, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to reset streak: $e');
    }
  }

  /// Refresh data from storage
  Future<void> refresh() async {
    await _loadHabits();
  }

  /// Clear all data
  Future<void> clearAllData() async {
    try {
      await _repository.saveHabits([]);
      await _repository.saveHabitStreaks({});
      await _repository.saveHabitCompletions({});

      state = const HabitState();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear data: $e');
    }
  }
}

/// Provider for habit controller
final habitControllerProvider =
    StateNotifierProvider<HabitController, HabitState>((ref) {
      final repository = ref.watch(habitRepositoryProvider);
      return HabitController(repository);
    });

/// Convenience providers for specific data
final habitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitControllerProvider).habits;
});

final streaksProvider = Provider<Map<String, int>>((ref) {
  return ref.watch(habitControllerProvider).streaks;
});

final todaysHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitControllerProvider).getTodaysDueHabits();
});

final regularHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitControllerProvider).getHabitsByType(HabitType.regular);
});

final negativeHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitControllerProvider).getHabitsByType(HabitType.negative);
});

final oneTimeHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(habitControllerProvider).getHabitsByType(HabitType.oneTime);
});

/// Provider for habits filtered by time of day
final habitsForTimeOfDayProvider =
    Provider.family<List<Habit>, TimeOfDayPreference>((ref, timeOfDay) {
      return ref.watch(habitControllerProvider).getHabitsByTimeOfDay(timeOfDay);
    });

/// Provider for habits due on a specific day of the week
final habitsForDayOfWeekProvider = Provider.family<List<Habit>, int>((
  ref,
  dayOfWeek,
) {
  return ref.watch(habitControllerProvider).getHabitsByDayOfWeek(dayOfWeek);
});

/// Provider for habits filtered by both day and time
final habitsForDayAndTimeProvider =
    Provider.family<
      List<Habit>,
      ({int dayOfWeek, TimeOfDayPreference timeOfDay})
    >((ref, params) {
      return ref
          .watch(habitControllerProvider)
          .getHabitsForDayAndTime(params.dayOfWeek, params.timeOfDay);
    });

/// Provider for today's habits filtered by time of day
final todaysHabitsByTimeProvider =
    Provider.family<List<Habit>, TimeOfDayPreference>((ref, timeOfDay) {
      return ref
          .watch(habitControllerProvider)
          .getTodaysHabitsByTimeOfDay(timeOfDay);
    });

/// Provider for today's habits grouped by time of day
final todaysHabitsGroupedProvider =
    Provider<Map<TimeOfDayPreference, List<Habit>>>((ref) {
      return ref.watch(habitControllerProvider).getTodaysHabitsGroupedByTime();
    });

/// Provider for morning habits today
final morningHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(todaysHabitsByTimeProvider(TimeOfDayPreference.morning));
});

/// Provider for afternoon habits today
final afternoonHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(todaysHabitsByTimeProvider(TimeOfDayPreference.afternoon));
});

/// Provider for evening habits today
final eveningHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(todaysHabitsByTimeProvider(TimeOfDayPreference.evening));
});

/// Provider for anytime habits today
final anytimeHabitsProvider = Provider<List<Habit>>((ref) {
  return ref.watch(todaysHabitsByTimeProvider(TimeOfDayPreference.anytime));
});
