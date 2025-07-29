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
  void initState() {
    super.initState();
    // Listen to selected date changes to trigger UI updates
    selectedDate.addListener(_onDateChanged);
  }

  void _onDateChanged() {
    if (mounted) {
      setState(() {
        // This will trigger a rebuild when the date changes
      });
    }
  }

  @override
  void dispose() {
    selectedDate.removeListener(_onDateChanged);
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
              child: ValueListenableBuilder<DateTime>(
                valueListenable: selectedDate,
                builder: (context, currentDate, child) {
                  return Consumer(
                    builder: (context, ref, child) {
                      final calendarDataAsync = ref.watch(calendarDataProvider);

                      return calendarDataAsync.when(
                        data: (calendarData) {
                          final perfectDays =
                              calendarData['perfectDays'] as Set<DateTime>;
                          final progressMap =
                              calendarData['progressMap']
                                  as Map<DateTime, double>;

                          return HorizontalCalender(
                            selectedDate: selectedDate,
                            onDaySelected: (p0) {
                              selectedDate.value = p0;
                            },
                            perfectDays: perfectDays,
                            progressMap: progressMap,
                          );
                        },
                        loading: () => HorizontalCalender(
                          selectedDate: selectedDate,
                          onDaySelected: (p0) {
                            selectedDate.value = p0;
                          },
                          perfectDays: {},
                          progressMap: {},
                        ),
                        error: (_, __) => HorizontalCalender(
                          selectedDate: selectedDate,
                          onDaySelected: (p0) {
                            selectedDate.value = p0;
                          },
                          perfectDays: {},
                          progressMap: {},
                        ),
                      );
                    },
                  );
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
                      child: ValueListenableBuilder<DateTime>(
                        valueListenable: selectedDate,
                        builder: (context, currentDate, child) {
                          return HabitsList(
                            selectedTimeFilter: _selectedTimeFilter,
                            selectedDate: currentDate,
                            isDark: isDark,
                            expandedHabits: _expandedHabits,
                            onHabitToggle: _handleHabitToggle,
                            onStartGoal: (habitId) =>
                                _startGoal(_getHabitById(habitId)),
                            onFinishGoal: (habitId) =>
                                _finishGoal(_getHabitById(habitId)),
                            onEditHabit: _editHabit,
                            onDeleteHabit: _deleteHabit,
                          );
                        },
                      ),
                    ),

                    // DEBUG INFO (remove in production)
                    if (true) // Set to false to hide
                      Consumer(
                        builder: (context, ref, child) {
                          final habitState = ref.watch(habitControllerProvider);
                          final filteredHabits = ref.watch(
                            filteredHabitsProvider((
                              selectedDate: selectedDate.value,
                              timeFilter: _selectedTimeFilter,
                            )),
                          );

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[800]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Debug Info:',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total habits: ${habitState.habits.length}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Filtered habits: ${filteredHabits.length}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Selected date: ${getDateString(selectedDate.value)}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Time filter: ${_selectedTimeFilter.name}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Loading: ${habitState.isLoading}',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                                if (habitState.error != null)
                                  Text(
                                    'Error: ${habitState.error}',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: Colors.red,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
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
    final currentSelectedDate = selectedDate.value;
    final isCompleted = habitState.isHabitCompletedOnDate(
      habit.id,
      currentSelectedDate,
    );

    if (hasGoal) {
      setState(() {
        if (_expandedHabits.contains(habit.id)) {
          _expandedHabits.remove(habit.id);
        } else {
          _expandedHabits.add(habit.id);
        }
      });
    } else {
      // Toggle completion for simple habits on the selected date
      final today = DateTime.now();
      final isToday = _isSameDay(currentSelectedDate, today);

      if (isCompleted) {
        if (isToday) {
          ref.read(habitControllerProvider.notifier).uncompleteHabit(habit.id);
        } else {
          ref
              .read(habitControllerProvider.notifier)
              .uncompleteHabitForDate(habit.id, currentSelectedDate);
        }
      } else {
        if (isToday) {
          ref.read(habitControllerProvider.notifier).completeHabit(habit.id);
        } else {
          ref
              .read(habitControllerProvider.notifier)
              .completeHabitForDate(habit.id, currentSelectedDate);
        }
      }
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
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
    // Mark habit as completed for the selected date and close expanded view
    final currentSelectedDate = selectedDate.value;
    final today = DateTime.now();
    final isToday = _isSameDay(currentSelectedDate, today);

    if (isToday) {
      ref.read(habitControllerProvider.notifier).completeHabit(habit.id);
    } else {
      ref
          .read(habitControllerProvider.notifier)
          .completeHabitForDate(habit.id, currentSelectedDate);
    }

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

  void _editHabit(String habitId) {
    // TODO: Navigate to edit habit page
    // For now, just show a placeholder
    final habit = _getHabitById(habitId);
    if (habit != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Edit ${habit.title} (Coming soon...)'),
          backgroundColor: habit.color,
        ),
      );
    }
  }

  void _deleteHabit(String habitId) async {
    final habit = _getHabitById(habitId);
    if (habit == null) return;

    // Delete the habit using the controller
    await ref.read(habitControllerProvider.notifier).deleteHabit(habitId);

    // Remove from expanded habits set
    setState(() {
      _expandedHabits.remove(habitId);
    });

    // Force calendar refresh by invalidating the provider
    ref.invalidate(calendarDataProvider);

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${habit.title} deleted'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implement undo functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Undo feature coming soon...'),
                backgroundColor: Colors.grey,
              ),
            );
          },
        ),
      ),
    );
  }
}
