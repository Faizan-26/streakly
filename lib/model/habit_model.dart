
// Habit model
import 'package:flutter/material.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';

class Habit {
  final String id;
  final String title;
  final HabitType type;
  final Frequency frequency;
  final TimeOfDayPreference? timeOfDay;
  final Duration? goalDuration;
  final int? goalCount;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool hasReminder;
  final TimeOfDay? reminderTime;
  final Color color;
  final IconData icon;
  final String? category;
  final bool isPreset;

  Habit({
    required this.id,
    required this.title,
    required this.type,
    required this.frequency,
    this.timeOfDay,
    this.goalDuration,
    this.goalCount,
    this.startDate,
    this.endDate,
    this.hasReminder = false,
    this.reminderTime,
    required this.color,
    required this.icon,
    this.category,
    this.isPreset = false,
  });


  
}



// Frequency model
class Frequency {
  final FrequencyType type;
  final List<int>? selectedDays; // For weekly (0-6 for Sun-Sat)
  final int? timesPerPeriod; // For x times per week/month/year
  final List<int>? specificDates; // For monthly (1-31)

  Frequency({
    required this.type,
    this.selectedDays,
    this.timesPerPeriod,
    this.specificDates,
  });
}