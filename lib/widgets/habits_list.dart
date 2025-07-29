import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/types/time_of_day_type.dart';
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
  final Function(String)? onEditHabit;
  final Function(String)? onDeleteHabit;

  const HabitsList({
    super.key,
    required this.selectedTimeFilter,
    required this.selectedDate,
    required this.isDark,
    required this.expandedHabits,
    required this.onHabitToggle,
    required this.onStartGoal,
    required this.onFinishGoal,
    this.onEditHabit,
    this.onDeleteHabit,
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

    // Use the filtered habits provider for better reactivity
    final filteredHabits = ref.watch(
      filteredHabitsProvider((
        selectedDate: selectedDate,
        timeFilter: selectedTimeFilter,
      )),
    );

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
          selectedDate: selectedDate,
          onTap: () => onHabitToggle(habit.id),
          onStartGoal: () => onStartGoal(habit.id),
          onFinishGoal: () => onFinishGoal(habit.id),
          onEditHabit: onEditHabit != null
              ? () => onEditHabit!(habit.id)
              : null,
          onDeleteHabit: onDeleteHabit != null
              ? () => onDeleteHabit!(habit.id)
              : null,
        );
      },
    );
  }
}
