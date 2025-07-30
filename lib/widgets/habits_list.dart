import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/widgets/habit_card.dart';
import 'package:streakly/widgets/empty_state.dart';
import 'package:streakly/widgets/error_state.dart';

class HabitsList extends ConsumerWidget {
  final TimeOfDayPreference selectedTimeFilter;
  final DateTime selectedDate;
  final bool isDark;
  final Set<String> expandedHabits;
  final Function(String) onHabitToggle;
  final Function(String) onStartGoal;
  final Function(String) onFinishGoal;

  const HabitsList({
    super.key,
    required this.selectedTimeFilter,
    required this.selectedDate,
    required this.isDark,
    required this.expandedHabits,
    required this.onHabitToggle,
    required this.onStartGoal,
    required this.onFinishGoal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitControllerProvider);

    if (habitState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (habitState.error != null) {
      return ErrorState(error: habitState.error!, isDark: isDark);
    }

    // Get filtered habits with improved date logic
    final filteredHabits = _getFilteredHabits(habitState);

    if (filteredHabits.isEmpty) {
      return EmptyState(selectedTimeFilter: selectedTimeFilter, isDark: isDark);
    }

    final screenWidth = MediaQuery.of(context).size.width;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        bottom: 120,
        top: 4,
        left: screenWidth > 600 ? 8 : 0,
        right: screenWidth > 600 ? 8 : 0,
      ),
      itemCount: filteredHabits.length,
      itemBuilder: (context, index) {
        final habit = filteredHabits[index];
        final isExpanded = expandedHabits.contains(habit.id);

        return HabitCard(
          habit: habit,
          habitState: habitState,
          isDark: isDark,
          index: index,
          isExpanded: isExpanded,
          onTap: () => onHabitToggle(habit.id),
          onStartGoal: () => onStartGoal(habit.id),
          onFinishGoal: () => onFinishGoal(habit.id),
        );
      },
    );
  }

  List<dynamic> _getFilteredHabits(HabitState habitState) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    // Start with time-filtered habits
    List<dynamic> habits = selectedTimeFilter == TimeOfDayPreference.anytime
        ? habitState.habits
        : habitState.habits
              .where((habit) => habit.timeOfDay == selectedTimeFilter)
              .toList();

    // Apply date-based filtering
    habits = habits.where((habit) {
      // Always show habits for today
      if (_isSameDay(selected, today)) {
        return true;
      }

      // For future dates, show all habits unless they have specific restrictions
      if (selected.isAfter(today)) {
        return _isHabitValidForFutureDate(habit, selected);
      }

      // For past dates, only show habits that were actually due on that date
      if (selected.isBefore(today)) {
        return _isHabitValidForPastDate(habit, selected);
      }

      return false;
    }).toList();

    return habits;
  }

  bool _isHabitValidForFutureDate(dynamic habit, DateTime date) {
    // For future dates, check if habit should be available based on frequency
    switch (habit.frequency.type) {
      case FrequencyType.daily:
        return true; // Daily habits are always valid for future dates

      case FrequencyType.weekly:
        // Check if the day of week is included
        final dayOfWeek = date.weekday % 7; // Convert to 0-6 (Sunday = 0)
        return habit.frequency.selectedDays?.contains(dayOfWeek) ?? false;

      case FrequencyType.monthly:
        // Check if it's the right day of month or week pattern
        return _isMonthlyHabitDue(habit, date);

      case FrequencyType.yearly:
        // Check if it's the right date of year
        return _isYearlyHabitDue(habit, date);

      case FrequencyType.longTerm:
        // Long-term habits are available for future dates within their range
        final endDate = habit.frequency.endDate;
        return endDate == null ||
            date.isBefore(endDate) ||
            _isSameDay(date, endDate);
    }

    return false; // Default fallback
  }

  bool _isHabitValidForPastDate(dynamic habit, DateTime date) {
    // For past dates, only show if the habit was actually due on that date
    // AND it's set to "every day" OR it was within the habit's active period

    // Check if habit was created before this date
    if (habit.createdAt.isAfter(date)) {
      return false; // Habit didn't exist yet
    }

    // Check if habit is set to "every day" (daily frequency)
    if (habit.frequency.type == FrequencyType.daily) {
      return true; // Daily habits show in past
    }

    // For other frequencies, check if the habit was actually due on that specific date
    switch (habit.frequency.type) {
      case FrequencyType.weekly:
        final dayOfWeek = date.weekday % 7;
        return habit.frequency.selectedDays?.contains(dayOfWeek) ?? false;

      case FrequencyType.monthly:
        return _isMonthlyHabitDue(habit, date);

      case FrequencyType.yearly:
        return _isYearlyHabitDue(habit, date);

      case FrequencyType.longTerm:
        final startDate = habit.createdAt;
        final endDate = habit.frequency.endDate;
        return date.isAfter(startDate) &&
            (endDate == null ||
                date.isBefore(endDate) ||
                _isSameDay(date, endDate));

      default:
        return false;
    }
  }

  bool _isMonthlyHabitDue(dynamic habit, DateTime date) {
    // Implement monthly habit logic based on your frequency model
    // This is a simplified version - you may need to adjust based on your actual implementation
    return true; // Placeholder - implement based on your monthly frequency logic
  }

  bool _isYearlyHabitDue(dynamic habit, DateTime date) {
    // Implement yearly habit logic based on your frequency model
    // This is a simplified version - you may need to adjust based on your actual implementation
    return true; // Placeholder - implement based on your yearly frequency logic
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
