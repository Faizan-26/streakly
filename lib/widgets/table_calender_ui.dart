import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';

/// HorizontalCalender widget with custom visuals for streaks, perfect days, and progress.
class HorizontalCalender extends StatefulWidget {
  final ValueNotifier<DateTime> selectedDate;
  final Set<DateTime> perfectDays;
  final Map<DateTime, double> progressMap; // 0.0–1.0 for circular progress
  final void Function(DateTime) onDaySelected;

  const HorizontalCalender({
    super.key,
    required this.selectedDate,
    required this.perfectDays,
    required this.progressMap,
    required this.onDaySelected,
  });

  @override
  State<HorizontalCalender> createState() => _HorizontalCalenderState();
}

class _HorizontalCalenderState extends State<HorizontalCalender> {
  @override
  void initState() {
    super.initState();
    // Listen to selectedDate changes to trigger UI updates
    widget.selectedDate.addListener(_onDateChanged);
  }

  @override
  void dispose() {
    widget.selectedDate.removeListener(_onDateChanged);
    super.dispose();
  }

  void _onDateChanged() {
    if (mounted) {
      setState(() {
        // Trigger UI rebuild when date changes
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return _buildCalendar(isDark)
        .animate()
        .fadeIn(duration: 300.ms, curve: Curves.easeInOut)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildCalendar(bool isDark) {
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;

    // Helper to check if a day is perfect
    bool isPerfectDay(DateTime day) =>
        widget.perfectDays.any((d) => isSameDay(d, day));

    double? getProgress(DateTime day) {
      for (final entry in widget.progressMap.entries) {
        if (isSameDay(entry.key, day)) return entry.value;
      }
      return null;
    }

    // Helper to check if a day is in a streak (now same as perfect day)
    bool isStreakDay(DateTime day) => isPerfectDay(day);

    // Helper to check if a day is today
    bool isToday(DateTime day) => isSameDay(day, DateTime.now());

    // Helper to check if a day is selected
    bool isSelected(DateTime day) => isSameDay(day, widget.selectedDate.value);
    DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

    bool isLeftMostPerfectDay(DateTime day) {
      final normalizedStreak = widget.perfectDays.map(normalize).toSet();
      return !normalizedStreak.contains(
        normalize(day).subtract(const Duration(days: 1)),
      );
    }

    bool isRightMostPerfectDay(DateTime day) {
      final normalizedStreak = widget.perfectDays.map(normalize).toSet();
      return !normalizedStreak.contains(
        normalize(day).add(const Duration(days: 1)),
      );
    }

    Widget buildCustomDay(BuildContext context, DateTime day, bool isDark) {
      final progress = getProgress(day);
      final perfect = isPerfectDay(day);
      final streak = isStreakDay(day);
      final today = isToday(day);
      final selected = isSelected(day);

      // Enhanced theming based on dark/light mode
      final subtleTextColor = isDark ? Colors.white70 : Colors.black87;
      final todayGrayColor = isDark
          ? Colors.grey.shade400
          : Colors.grey.shade600;

      return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Main content area with streak lines and day circle/text
              SizedBox(
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Enhanced streak line (left) - extends from left edge to circle center
                    if (streak &&
                        isPerfectDay(day.subtract(const Duration(days: 1))) &&
                        !isLeftMostPerfectDay(day))
                      Positioned(
                        left: 0,
                        right: null,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child:
                              Container(
                                    width:
                                        MediaQuery.of(context).size.width /
                                        7 /
                                        2,
                                    height: isDark ? 14 : 12,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                green.withOpacity(0.6),
                                                green.withOpacity(0.9),
                                              ]
                                            : [green.withOpacity(0.7), green],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .scaleX(
                                    begin: 0,
                                    end: 1,
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  )
                                  .fadeIn(duration: 300.ms),
                        ),
                      ),
                    // Enhanced streak line (right) - extends from circle center to right edge
                    if (streak &&
                        isPerfectDay(day.add(const Duration(days: 1))) &&
                        !isRightMostPerfectDay(day))
                      Positioned(
                        right: 0,
                        left: null,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child:
                              Container(
                                    width:
                                        MediaQuery.of(context).size.width /
                                        7 /
                                        2,
                                    height: isDark ? 14 : 12,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: isDark
                                            ? [
                                                green.withOpacity(0.9),
                                                green.withOpacity(0.6),
                                              ]
                                            : [green, green.withOpacity(0.7)],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .scaleX(
                                    begin: 0,
                                    end: 1,
                                    duration: 400.ms,
                                    curve: Curves.easeOutBack,
                                  )
                                  .fadeIn(duration: 300.ms),
                        ),
                      ),
                    // Enhanced circular progress indicator - keep same as before
                    if (progress != null && progress < 1.0 && progress > 0.0)
                      SizedBox(
                            width: 38,
                            height: 38,
                            child: CircularProgressIndicator(
                              value: progress,
                              strokeWidth: isDark ? 4 : 3,
                              backgroundColor: isDark
                                  ? darkCard.withOpacity(0.5)
                                  : lightGrey.withOpacity(0.8),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isDark ? green.withOpacity(0.9) : green,
                              ),
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 300.ms),
                    // Perfect day circle (blue like in the image)
                    if (perfect)
                      Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isDark ? green : darkGreen,
                              shape: BoxShape.circle,
                            ),
                          )
                          .animate()
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            end: const Offset(1, 1),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          )
                          .fadeIn(duration: 400.ms),
                    // Day number text
                    Center(
                      child: Text(
                        '${day.day}',
                        style: perfect
                            ? AppTypography.labelMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              )
                            : selected
                            ? AppTypography.labelMedium.copyWith(
                                color: green,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              )
                            : today
                            ? AppTypography.labelMedium.copyWith(
                                color: todayGrayColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 0.2,
                              )
                            : AppTypography.bodyMedium.copyWith(
                                color: subtleTextColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              // Green underline for selected dates (appears for all selected dates)
              // Always show underline area to maintain consistent height
              Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 20,
                    height: 3,
                    decoration: BoxDecoration(
                      color: selected
                          ? green
                          : Colors.transparent, // Transparent for non-selected
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                  .animate()
                  .scaleX(
                    begin: selected ? 0 : 1,
                    end: 1,
                    duration: selected ? 300.ms : 0.ms,
                    curve: Curves.easeOutBack,
                  )
                  .fadeIn(duration: selected ? 200.ms : 0.ms),
            ],
          )
          .animate()
          .fadeIn(duration: 400.ms)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOut,
          );
    }

    return TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2100, 12, 31),
      focusedDay: widget.selectedDate.value,
      selectedDayPredicate: (day) => isSelected(day),
      calendarFormat: CalendarFormat.week,
      headerVisible: false,
      daysOfWeekVisible: true,
      onDaySelected: (selected, focused) {
        widget.selectedDate.value = selected;
        widget.onDaySelected(selected);
      },
      calendarStyle: CalendarStyle(
        isTodayHighlighted: false,
        outsideDaysVisible: false,
        // Remove all default decorations
        todayDecoration: const BoxDecoration(),
        selectedDecoration: const BoxDecoration(),
        defaultDecoration: const BoxDecoration(),
        weekendDecoration: const BoxDecoration(),
        // Remove all default text styles
        defaultTextStyle: const TextStyle(color: Colors.transparent),
        weekendTextStyle: const TextStyle(color: Colors.transparent),
        todayTextStyle: const TextStyle(color: Colors.transparent),
        selectedTextStyle: const TextStyle(color: Colors.transparent),
        outsideTextStyle: const TextStyle(color: Colors.transparent),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: AppTypography.labelSmall.copyWith(
          color: isDark ? Colors.white60 : grey,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        weekendStyle: AppTypography.labelSmall.copyWith(
          color: isDark ? Colors.red.shade300 : Colors.red.shade600,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) =>
            buildCustomDay(context, day, isDark),
        todayBuilder: (context, day, focusedDay) =>
            buildCustomDay(context, day, isDark),
        selectedBuilder: (context, day, focusedDay) =>
            buildCustomDay(context, day, isDark),
        outsideBuilder: (context, day, focusedDay) =>
            buildCustomDay(context, day, isDark),
        disabledBuilder: (context, day, focusedDay) =>
            buildCustomDay(context, day, isDark),
        dowBuilder: (context, day) {
          final text = DateFormat.E().format(day).toUpperCase();
          return Center(
            child: Text(
              text,
              style: AppTypography.labelSmall.copyWith(
                color: day.weekday == DateTime.sunday
                    ? (isDark ? Colors.red.shade300 : Colors.red.shade600)
                    : (isDark ? Colors.white60 : grey),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Convenience function to create a horizontal calendar with enhanced theming
  /// This provides a simple way to use the calendar throughout the app
  Widget createHorizontalCalendar({
    required ValueNotifier<DateTime> selectedDate,
    required Set<DateTime> perfectDays,
    required Map<DateTime, double> progressMap,
    required void Function(DateTime) onDaySelected,
    Color? backgroundColor,
    EdgeInsets? padding,
  }) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bgColor = backgroundColor ?? (isDark ? darkSurface : lightGrey);

        return Container(
          padding: padding ?? const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(color: bgColor),
          child: HorizontalCalender(
            selectedDate: selectedDate,
            perfectDays: perfectDays,
            progressMap: progressMap,
            onDaySelected: onDaySelected,
          ),
        );
      },
    );
  }
}
