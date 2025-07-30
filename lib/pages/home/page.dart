import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/table_calender_ui.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/widgets/habit_filter_tabs.dart';
import 'package:streakly/widgets/habits_list.dart';
import 'package:streakly/widgets/streak_indicator.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  TimeOfDayPreference _selectedTimeFilter = TimeOfDayPreference.anytime;
  final Set<String> _expandedHabits = {};

  @override
  void dispose() {
    selectedDate.dispose();
    super.dispose();
  }

  String getDateString(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return "Today";
    } else if (diff.inDays == 1) {
      return "Yesterday";
    } else if (diff.inDays == -1) {
      return "Tomorrow";
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appBarColor = isDark ? darkSurface : lightGrey;
    final textColor = isDark ? Colors.white : darkGreen;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 10),
        child: Container(
          decoration: BoxDecoration(color: appBarColor),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            title: ValueListenableBuilder<DateTime>(
              valueListenable: selectedDate,
              builder: (context, date, child) {
                return Column(
                      key: ValueKey(date.day),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: getDateString(date),
                                style: AppTypography.headlineSmall.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateFormat('EEEE, MMMM d').format(date),
                          style: AppTypography.bodyMedium.copyWith(
                            color: subtitleColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                    .slideY(
                      begin: 0.3,
                      end: 0,
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    )
                    .then()
                    .rotate(
                      begin: 0.02,
                      end: 0,
                      duration: 600.ms,
                      curve: Curves.easeOutBack,
                    )
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.easeOutBack,
                    );
              },
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: StreakIndicator(count: "1", isDark: isDark)
                    .animate()
                    .fadeIn(duration: 600.ms, delay: 200.ms)
                    .scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 500.ms,
                      curve: Curves.elasticOut,
                    ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(color: appBarColor),
              child: HorizontalCalender(
                selectedDate: selectedDate,
                onDaySelected: (p0) {
                  selectedDate.value = p0;
                },
                perfectDays: {
                  DateTime.now(),

                  DateTime.now().add(const Duration(days: 1)),
                  DateTime.now().add(const Duration(days: 2)),
                  DateTime.now().subtract(const Duration(days: 1)),
                  DateTime.now().subtract(const Duration(days: 2)),
                  DateTime.now().subtract(const Duration(days: 3)),
                  DateTime.now().subtract(const Duration(days: 4)),
                  DateTime.now().subtract(const Duration(days: 5)),
                  DateTime.now().subtract(const Duration(days: 6)),

                  DateTime.now().subtract(const Duration(days: 7)),
                },
                progressMap: {
                  DateTime.now(): 0.8,
                  DateTime.now().add(const Duration(days: 3)): 0.6,
                  DateTime.now().subtract(const Duration(days: 12)): 0.4,
                  DateTime.now().subtract(const Duration(days: 10)): 0.2,
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _getResponsivePadding(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TIME FILTER TABS
                    HabitFilterTabs(
                      selectedFilter: _selectedTimeFilter,
                      onFilterChanged: (filter) {
                        setState(() {
                          _selectedTimeFilter = filter;
                        });
                      },
                      isDark: isDark,
                    ),
                    SizedBox(height: _getVerticalSpacing(context)),

                    // HABIT TILES
                    Expanded(
                      child: HabitsList(
                        selectedTimeFilter: _selectedTimeFilter,
                        selectedDate: selectedDate.value,
                        isDark: isDark,
                        expandedHabits: _expandedHabits,
                        onHabitToggle: _handleHabitToggle,
                        onStartGoal: (habitId) =>
                            _startGoal(_getHabitById(habitId)),
                        onFinishGoal: (habitId) =>
                            _finishGoal(_getHabitById(habitId)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Responsive design helpers
  double _getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 375) return 12; // iPhone SE
    if (screenWidth < 414) return 16; // Standard phones
    if (screenWidth < 600) return 20; // Large phones
    return 24; // Tablets
  }

  double _getVerticalSpacing(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return screenWidth < 375 ? 8 : 12;
  }

  // Helper methods for habit management
  Habit? _getHabitById(String habitId) {
    final habitState = ref.read(habitControllerProvider);
    return habitState.getHabitById(habitId);
  }

  void _handleHabitToggle(String habitId) {
    final habit = _getHabitById(habitId);
    if (habit == null) return;

    final habitState = ref.read(habitControllerProvider);
    final hasGoal = habit.goalDuration != null || habit.goalCount != null;
    final isCompleted = habitState.isHabitCompletedToday(habit.id);

    if (hasGoal) {
      setState(() {
        if (_expandedHabits.contains(habit.id)) {
          _expandedHabits.remove(habit.id);
        } else {
          _expandedHabits.add(habit.id);
        }
      });
    } else {
      // Toggle completion for simple habits
      if (isCompleted) {
        ref.read(habitControllerProvider.notifier).uncompleteHabit(habit.id);
      } else {
        ref.read(habitControllerProvider.notifier).completeHabit(habit.id);
      }
    }
  }

  void _startGoal(Habit? habit) {
    if (habit == null) return;
    // TODO: Navigate to timer/goal tracking screen
    // For now, just show a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting ${habit.title}...'),
        backgroundColor: habit.color,
      ),
    );
  }

  void _finishGoal(Habit? habit) {
    if (habit == null) return;
    // Mark habit as completed and close expanded view
    ref.read(habitControllerProvider.notifier).completeHabit(habit.id);
    setState(() {
      _expandedHabits.remove(habit.id);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} completed!'),
        backgroundColor: habit.color,
      ),
    );
  }
}
