import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/model/habit_completion.dart';
import 'package:streakly/model/streak_entry.dart';
import 'package:streakly/controllers/habit_repository.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/services/habit_completion_storage.dart';
import 'package:streakly/services/day_progress_service.dart';
import 'package:streakly/services/day_progress_storage.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:flutter/material.dart';

/// State class for habit management
@immutable
class HabitState {
  final List<Habit> habits;
  final Map<String, int> streaks;
  final List<HabitCompletion> completions; // New completion system
  final List<StreakEntry> streakHistory;
  final bool isLoading;
  final String? error;

  const HabitState({
    this.habits = const [],
    this.streaks = const {},
    this.completions = const [],
    this.streakHistory = const [],
    this.isLoading = false,
    this.error,
  });

  HabitState copyWith({
    List<Habit>? habits,
    Map<String, int>? streaks,
    List<HabitCompletion>? completions,
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
    return completions.isHabitCompletedToday(habitId);
  }

  /// Check if habit is completed on a specific date
  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    return completions.isHabitCompletedOnDate(habitId, date);
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

      final completions = await HabitCompletionStorage.loadCompletions();
      if (!mounted) return;

      final streakHistory = await _repository.loadStreakHistory();
      if (!mounted) return;

      // Migrate old completion data if necessary
      final oldCompletions = await _repository.loadHabitCompletions();
      if (oldCompletions.isNotEmpty && completions.isEmpty) {
        await HabitCompletionStorage.migrateOldCompletionData(oldCompletions);
        final migratedCompletions =
            await HabitCompletionStorage.loadCompletions();
        if (!mounted) return;

        state = state.copyWith(
          habits: habits,
          streaks: streaks,
          completions: migratedCompletions,
          streakHistory: streakHistory,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          habits: habits,
          streaks: streaks,
          completions: completions,
          streakHistory: streakHistory,
          isLoading: false,
        );
      }

      // Check for missed days and update streaks
      await _checkForMissedDays(
        habits,
        streaks,
        state.completions,
        streakHistory,
      );

      // Initialize day progress for the past month
      await _initializeDayProgress(habits, streakHistory);
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
    List<HabitCompletion> completions,
    List<StreakEntry> streakHistory,
  ) async {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    for (final habit in habits) {
      // Check if the habit was due yesterday and if it wasn't completed
      if (NotificationService.isHabitDueOnDate(habit, yesterday)) {
        final wasCompletedYesterday = completions.isHabitCompletedOnDate(
          habit.id,
          yesterday,
        );

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

  /// Initialize day progress for the past month
  Future<void> _initializeDayProgress(
    List<Habit> habits,
    List<StreakEntry> streakHistory,
  ) async {
    try {
      final now = DateTime.now();
      final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

      // Generate list of dates from one month ago to today
      final dates = <DateTime>[];
      for (
        DateTime date = oneMonthAgo;
        date.isBefore(now.add(const Duration(days: 1)));
        date = date.add(const Duration(days: 1))
      ) {
        dates.add(DateTime(date.year, date.month, date.day));
      }

      // Calculate and save day progress for all dates
      final dayProgressList = dates
          .map(
            (date) => DayProgressService.calculateDayProgress(
              date,
              habits,
              streakHistory,
            ),
          )
          .toList();

      await DayProgressStorage.saveDayProgressBatch(dayProgressList);
    } catch (e) {
      // Handle error silently for now
      print('Failed to initialize day progress: $e');
    }
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

      // Update day progress for today and recent days
      final today = DateTime.now();
      final datesToUpdate = List.generate(
        30, // Update last 30 days to ensure calendar is properly refreshed
        (index) => today.subtract(Duration(days: index)),
      );
      await updateDayProgressBatch(datesToUpdate);
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
      final updatedCompletions = state.completions
          .where((completion) => completion.habitId != habitId)
          .toList();

      // Save to storage
      await _repository.saveHabits(updatedHabits);
      await _repository.saveHabitStreaks(updatedStreaks);
      await HabitCompletionStorage.clearCompletionsForHabit(habitId);

      // Cancel notifications
      await NotificationService.cancelAllHabitReminders(habitId);

      // Update state
      state = state.copyWith(
        habits: updatedHabits,
        streaks: updatedStreaks,
        completions: updatedCompletions,
        error: null,
      );

      // Update day progress for recent days since habit affects progress calculation
      final today = DateTime.now();
      final datesToUpdate = List.generate(
        30, // Update last 30 days to ensure calendar is refreshed
        (index) => today.subtract(Duration(days: index)),
      );
      await updateDayProgressBatch(datesToUpdate);
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
      final completion = HabitCompletion.today(habitId: habitId, isDone: true);

      // Check if already completed today
      if (state.completions.isHabitCompletedToday(habitId)) {
        return; // Already completed
      }

      // Update completions
      final updatedCompletions = [...state.completions];

      // Remove any existing completion for today (in case we're updating)
      updatedCompletions.removeWhere((c) => c.habitId == habitId && c.isToday);

      // Add new completion
      updatedCompletions.add(completion);

      // Update streak
      final updatedStreaks = Map<String, int>.from(state.streaks);
      updatedStreaks[habitId] = (updatedStreaks[habitId] ?? 0) + 1;

      // Update streak history
      final updatedStreakHistory = List<StreakEntry>.from(state.streakHistory);

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
      await HabitCompletionStorage.saveCompletion(completion);
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

      // Update day progress for today
      await updateDayProgress(today);
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

      // Check if habit is completed today
      if (!state.completions.isHabitCompletedToday(habitId)) {
        return; // Already not completed
      }

      // Remove today's completion
      final updatedCompletions = state.completions
          .where(
            (completion) =>
                !(completion.habitId == habitId && completion.isToday),
          )
          .toList();

      // Handle streak logic based on habit type
      final updatedStreaks = Map<String, int>.from(state.streaks);
      final updatedStreakHistory = List<StreakEntry>.from(state.streakHistory);

      if (habit.type == HabitType.negative) {
        // For negative habits, unchecking breaks the streak
        updatedStreaks[habitId] = 0;

        // Update streak history - mark as missed
        updatedStreakHistory.removeWhere(
          (entry) => entry.habitId == habitId && _isSameDay(entry.date, today),
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
          (entry) => entry.habitId == habitId && _isSameDay(entry.date, today),
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
      await HabitCompletionStorage.removeCompletion(habitId, today);
      await _repository.saveHabitStreaks(updatedStreaks);
      await _repository.saveStreakHistory(updatedStreakHistory);

      // Update state
      state = state.copyWith(
        completions: updatedCompletions,
        streaks: updatedStreaks,
        streakHistory: updatedStreakHistory,
        error: null,
      );

      // Update day progress for today
      await updateDayProgress(today);
    } catch (e) {
      state = state.copyWith(error: 'Failed to uncomplete habit: $e');
    }
  }

  /// Mark habit as completed for a specific date
  Future<void> completeHabitForDate(String habitId, DateTime date) async {
    try {
      final habit = state.getHabitById(habitId);
      if (habit == null) {
        state = state.copyWith(error: 'Habit not found');
        return;
      }

      final normalizedDate = DateTime(date.year, date.month, date.day);
      final completion = HabitCompletion.forDate(
        habitId: habitId,
        date: normalizedDate,
        isDone: true,
      );

      // Check if already completed for this date
      if (state.completions.isHabitCompletedOnDate(habitId, normalizedDate)) {
        return; // Already completed
      }

      // Update completions
      final updatedCompletions = [...state.completions];

      // Remove any existing completion for this date
      updatedCompletions.removeWhere(
        (c) => c.habitId == habitId && c.isForDate(normalizedDate),
      );

      // Add new completion
      updatedCompletions.add(completion);

      // Update streak if this is today or a recent date
      final updatedStreaks = Map<String, int>.from(state.streaks);
      final today = DateTime.now();
      final isToday = _isSameDay(normalizedDate, today);

      if (isToday) {
        updatedStreaks[habitId] = (updatedStreaks[habitId] ?? 0) + 1;
      }

      // Save to storage
      await HabitCompletionStorage.saveCompletion(completion);
      if (isToday) {
        await _repository.saveHabitStreaks(updatedStreaks);
      }

      // Update state
      state = state.copyWith(
        completions: updatedCompletions,
        streaks: updatedStreaks,
        error: null,
      );

      // Update day progress for the date
      await updateDayProgress(normalizedDate);
    } catch (e) {
      state = state.copyWith(error: 'Failed to complete habit for date: $e');
    }
  }

  /// Mark habit as incomplete for a specific date
  Future<void> uncompleteHabitForDate(String habitId, DateTime date) async {
    try {
      final habit = state.getHabitById(habitId);
      if (habit == null) {
        state = state.copyWith(error: 'Habit not found');
        return;
      }

      final normalizedDate = DateTime(date.year, date.month, date.day);

      // Check if habit is completed for this date
      if (!state.completions.isHabitCompletedOnDate(habitId, normalizedDate)) {
        return; // Already not completed
      }

      // Remove completion for this date
      final updatedCompletions = state.completions
          .where(
            (completion) =>
                !(completion.habitId == habitId &&
                    completion.isForDate(normalizedDate)),
          )
          .toList();

      // Update streak if this is today
      final updatedStreaks = Map<String, int>.from(state.streaks);
      final today = DateTime.now();
      final isToday = _isSameDay(normalizedDate, today);

      if (isToday) {
        updatedStreaks[habitId] = ((updatedStreaks[habitId] ?? 0) - 1)
            .clamp(0, double.infinity)
            .toInt();
      }

      // Save to storage
      await HabitCompletionStorage.removeCompletion(habitId, normalizedDate);
      if (isToday) {
        await _repository.saveHabitStreaks(updatedStreaks);
      }

      // Update state
      state = state.copyWith(
        completions: updatedCompletions,
        streaks: updatedStreaks,
        error: null,
      );

      // Update day progress for the date
      await updateDayProgress(normalizedDate);
    } catch (e) {
      state = state.copyWith(error: 'Failed to uncomplete habit for date: $e');
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
      await HabitCompletionStorage.clearAllCompletions();

      state = const HabitState();
    } catch (e) {
      state = state.copyWith(error: 'Failed to clear data: $e');
    }
  }

  /// Calculate and save day progress for a specific date
  Future<void> updateDayProgress(DateTime date) async {
    try {
      final dayProgress =
          DayProgressService.calculateDayProgressFromCompletions(
            date,
            state.habits,
            state.completions,
          );
      await DayProgressStorage.saveDayProgress(dayProgress);
    } catch (e) {
      // Handle error silently for now
      print('Failed to update day progress: $e');
    }
  }

  /// Calculate and save day progress for multiple dates
  Future<void> updateDayProgressBatch(List<DateTime> dates) async {
    try {
      final dayProgressList = dates
          .map(
            (date) => DayProgressService.calculateDayProgressFromCompletions(
              date,
              state.habits,
              state.completions,
            ),
          )
          .toList();

      await DayProgressStorage.saveDayProgressBatch(dayProgressList);
    } catch (e) {
      // Handle error silently for now
      print('Failed to update day progress batch: $e');
    }
  }

  /// Get calendar data (perfect days and progress) for display
  Future<Map<String, dynamic>> getCalendarData() async {
    try {
      final perfectDays = await DayProgressStorage.getPerfectDays();
      final progressPercentages =
          await DayProgressStorage.getProgressPercentages();

      return {'perfectDays': perfectDays, 'progressMap': progressPercentages};
    } catch (e) {
      return {'perfectDays': <DateTime>{}, 'progressMap': <DateTime, double>{}};
    }
  }

  /// Debug method to log current habit state
  void debugLogHabits() {
    print('Current habits loaded: ${state.habits.length}');
    for (final habit in state.habits) {
      print(
        'Habit: ${habit.title}, Type: ${habit.type}, TimeOfDay: ${habit.timeOfDay}, Frequency: ${habit.frequency.type}',
      );
    }
    print('Completions: ${state.completions.length} total completions');
    for (final completion in state.completions) {
      print(
        '  - ${completion.habitId}: ${completion.dateString} (${completion.isDone})',
      );
    }
    print('Streaks: ${state.streaks}');
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

/// Provider for completions data
final completionsProvider = Provider<List<HabitCompletion>>((ref) {
  return ref.watch(habitControllerProvider).completions;
});

/// Provider for streak history data
final streakHistoryProvider = Provider<List<StreakEntry>>((ref) {
  return ref.watch(habitControllerProvider).streakHistory;
});

/// Provider for calendar data (perfect days and progress percentages)
final calendarDataProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  // Watch habit state and completion data to auto-refresh when anything changes
  ref.watch(habitControllerProvider);
  ref.watch(completionsProvider);
  ref.watch(streakHistoryProvider);

  final controller = ref.watch(habitControllerProvider.notifier);
  return await controller.getCalendarData();
});

/// Provider for filtered habits based on date and time preference
final filteredHabitsProvider =
    Provider.family<
      List<Habit>,
      ({DateTime selectedDate, TimeOfDayPreference timeFilter})
    >((ref, params) {
      final habitState = ref.watch(habitControllerProvider);
      final selectedDate = params.selectedDate;
      final timeFilter = params.timeFilter;

      // Get all habits
      List<Habit> habits = habitState.habits.toList();

      // Apply time-based filtering
      if (timeFilter != TimeOfDayPreference.anytime) {
        habits = habits
            .where(
              (habit) =>
                  habit.timeOfDay == timeFilter || habit.timeOfDay == null,
            )
            .toList();
      }

      // Apply date-based filtering
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final selected = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
      );

      habits = habits.where((habit) {
        // Always show habits for today
        if (_isSameDay(selected, today)) {
          return true;
        }

        // Check if habit was created before the selected date
        if (habit.createdAt.isAfter(selected.add(const Duration(days: 1)))) {
          return false;
        }

        // For other dates, check if habit is valid
        return _isHabitValidForDate(habit, selected);
      }).toList();

      return habits;
    });

// Helper functions for the provider
bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

bool _isHabitValidForDate(Habit habit, DateTime date) {
  switch (habit.frequency.type) {
    case FrequencyType.daily:
      return true;
    case FrequencyType.weekly:
      final dayOfWeek = date.weekday % 7;
      return habit.frequency.selectedDays?.contains(dayOfWeek) ?? true;
    case FrequencyType.monthly:
      if (habit.frequency.specificDates != null &&
          habit.frequency.specificDates!.isNotEmpty) {
        return habit.frequency.specificDates!.contains(date.day);
      }
      return true;
    case FrequencyType.yearly:
      if (habit.startDate != null) {
        return date.month == habit.startDate!.month &&
            date.day == habit.startDate!.day;
      }
      return true;
    case FrequencyType.longTerm:
      final startDate = habit.createdAt;
      final endDate = habit.endDate;
      return date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          (endDate == null ||
              date.isBefore(endDate.add(const Duration(days: 1))));
  }
}
