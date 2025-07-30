import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';

/// HorizontalCalender widget with custom visuals for streaks, perfect days, and progress.
Widget horizontalCalender({
  required ValueNotifier<DateTime> selectedDate,
  required Set<DateTime> perfectDays,
  required Map<DateTime, double> progressMap, // 0.0–1.0 for circular progress
  required void Function(DateTime) onDaySelected,
}) {
  bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  // Helper to check if a day is perfect
  bool isPerfectDay(DateTime day) => perfectDays.any((d) => isSameDay(d, day));

  double? getProgress(DateTime day) {
    for (final entry in progressMap.entries) {
      if (isSameDay(entry.key, day)) return entry.value;
    }
    return null;
  }

  // Helper to check if a day is in a streak (now same as perfect day)
  bool isStreakDay(DateTime day) => isPerfectDay(day);

  // Helper to check if a day is today
  bool isToday(DateTime day) => isSameDay(day, DateTime.now());

  // Helper to check if a day is selected
  bool isSelected(DateTime day) => isSameDay(day, selectedDate.value);
  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  bool isLeftMostPerfectDay(DateTime day) {
    final normalizedStreak = perfectDays.map(normalize).toSet();
    return !normalizedStreak.contains(
      normalize(day).subtract(const Duration(days: 1)),
    );
  }

  bool isRightMostPerfectDay(DateTime day) {
    final normalizedStreak = perfectDays.map(normalize).toSet();
    return !normalizedStreak.contains(
      normalize(day).add(const Duration(days: 1)),
    );
  }

  return TableCalendar(
    firstDay: DateTime.utc(2020, 1, 1),
    lastDay: DateTime.utc(2100, 12, 31),
    focusedDay: selectedDate.value,
    selectedDayPredicate: (day) => isSelected(day),
    calendarFormat: CalendarFormat.week,
    headerVisible: false,
    daysOfWeekVisible: true,
    onDaySelected: (selected, focused) {
      selectedDate.value = selected;
      onDaySelected(selected);
    },
    calendarStyle: CalendarStyle(
      outsideDaysVisible: false,
      todayDecoration: BoxDecoration(
        // border: Border.all(color: green, width: 2),
        // shape: BoxShape.circle,
      ),
      selectedDecoration: BoxDecoration(shape: BoxShape.circle),
      defaultTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.black),
      weekendTextStyle: AppTypography.bodyMedium.copyWith(color: Colors.red),
      todayTextStyle: AppTypography.bodyMedium.copyWith(
        color: green,
        fontWeight: FontWeight.bold,
      ),
      selectedTextStyle: AppTypography.bodyMedium.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    ),
    daysOfWeekStyle: DaysOfWeekStyle(
      weekdayStyle: AppTypography.bodySmall.copyWith(color: grey),
      weekendStyle: AppTypography.bodySmall.copyWith(color: Colors.red),
    ),
    calendarBuilders: CalendarBuilders(
      defaultBuilder: (context, day, focusedDay) {
        final progress = getProgress(day);
        final perfect = isPerfectDay(day);
        final streak = isStreakDay(day);
        final today = isToday(day);
        final selected = isSelected(day);

        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            // Streak line (left)
            if (streak &&
                isPerfectDay(day.subtract(const Duration(days: 1))) &&
                !isLeftMostPerfectDay(day))
              Positioned(
                left: 0,
                right: null,
                top: 20,
                bottom: 20,
                child: Container(
                  width: 12,
                  height: 2,
                  color: green.withOpacity(0.7),
                ),
              ),
            // Streak line (right)
            if (streak &&
                isPerfectDay(day.add(const Duration(days: 1))) &&
                !isRightMostPerfectDay(day))
              Positioned(
                right: 0,
                left: null,
                top: 20,
                bottom: 20,
                child: Container(
                  width: 12,
                  height: 2,
                  color: green.withOpacity(0.7),
                ),
              ),
            // Circular progress indicator
            if (progress != null && progress < 1.0 && progress > 0.0)
              SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: lightGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(green),
                ),
              ),
            // Filled circle for perfect day
            if (perfect)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (today)
                      BoxShadow(
                        color: green.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                  ],
                ),
              ),
            // Highlight today (if not perfect)
            if (today && !perfect)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: green, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
            // Day number
            Center(
              child: Text(
                '${day.day}',
                style: perfect
                    ? AppTypography.bodyMedium.copyWith(
                        // color: darkGreen,
                        fontWeight: FontWeight.bold,
                      )
                    : today
                    ? AppTypography.bodyMedium.copyWith(
                        // color: green,
                        fontWeight: FontWeight.bold,
                      )
                    : AppTypography.bodyMedium.copyWith(color: Colors.black),
              ),
            ),
          ],
        );
      },
      todayBuilder: (context, day, focusedDay) =>
          null, // handled in defaultBuilder
      selectedBuilder: (context, day, focusedDay) =>
          null, // handled in defaultBuilder
      dowBuilder: (context, day) {
        final text = DateFormat.E().format(day);
        return Center(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: day.weekday == DateTime.sunday ? Colors.red : grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      },
    ),
  );
}
