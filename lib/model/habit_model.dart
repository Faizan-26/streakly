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
  final bool isPreset; // isPresent indicates if this habit is a preset habit
  final DateTime createdAt;

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
    required this.createdAt,
    this.category,
    this.isPreset = false,
  });

  // Factory constructor to create a Habit from a map (e.g., from JSON)
  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'] as String,
      title: map['title'] as String,
      type: HabitType.values[map['type'] as int],
      frequency: Frequency.fromMap(map['frequency'] as Map<String, dynamic>),
      timeOfDay: map['timeOfDay'] != null
          ? TimeOfDayPreference.values[map['timeOfDay'] as int]
          : null,
      goalDuration: map['goalDuration'] != null
          ? Duration(milliseconds: map['goalDuration'] as int)
          : null,
      goalCount: map['goalCount'] as int?,
      startDate: map['startDate'] != null
          ? DateTime.parse(map['startDate'] as String)
          : null,
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      hasReminder: map['hasReminder'] as bool,
      reminderTime: map['reminderTime'] != null
          ? TimeOfDayExtension.fromMap(
              map['reminderTime'] as Map<String, dynamic>,
            )
          : null,
      color: Color(map['color'] as int),
      icon: IconData(
        map['icon'] as int,
        fontFamily: map['iconFontFamily'] as String? ?? 'MaterialIcons',
        fontPackage: map['iconFontPackage'] as String?,
      ),
      category: map['category'] as String?,
      isPreset: map['isPreset'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  // Method to convert Habit to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type.index,
      'frequency': frequency.toMap(),
      'timeOfDay': timeOfDay?.index,
      'goalDuration': goalDuration?.inMilliseconds,
      'goalCount': goalCount,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'hasReminder': hasReminder,
      'reminderTime': reminderTime?.toMap(),
      'color': color.value,
      'icon': icon.codePoint,
      'iconFontFamily': icon.fontFamily,
      'iconFontPackage': icon.fontPackage,
      'category': category,
      'isPreset': isPreset,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
// need to rewrite my code 
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

  // Factory constructor to create a Frequency from a map (e.g., from JSON)
  factory Frequency.fromMap(Map<String, dynamic> map) {
    return Frequency(
      type: FrequencyType.values[map['type'] as int],
      selectedDays: (map['selectedDays'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      timesPerPeriod: map['timesPerPeriod'] as int?,
      specificDates: (map['specificDates'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );
  }

  // Method to convert Frequency to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'selectedDays': selectedDays,
      'timesPerPeriod': timesPerPeriod,
      'specificDates': specificDates,
    };
  }
}

extension TimeOfDayExtension on TimeOfDay {
  Map<String, dynamic> toMap() {
    return {'hour': hour, 'minute': minute};
  }

  static TimeOfDay fromMap(Map<String, dynamic> map) {
    return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
  }
}
