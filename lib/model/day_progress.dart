import 'package:flutter/material.dart';

/// Represents the progress of all habits for a specific day
@immutable
class DayProgress {
  final DateTime date;
  final int totalHabits;
  final int completedHabits;
  final List<String> completedHabitIds;
  final List<String> missedHabitIds;
  final List<String> skippedHabitIds;

  const DayProgress({
    required this.date,
    required this.totalHabits,
    required this.completedHabits,
    required this.completedHabitIds,
    required this.missedHabitIds,
    required this.skippedHabitIds,
  });

  /// Calculate the completion percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalHabits == 0) return 0.0;
    return completedHabits / totalHabits;
  }

  /// Check if this day is a perfect day (all habits completed)
  bool get isPerfectDay {
    return totalHabits > 0 && completedHabits == totalHabits;
  }

  /// Check if any habits were completed on this day
  bool get hasProgress {
    return completedHabits > 0;
  }

  /// Get the normalized date (without time)
  DateTime get normalizedDate {
    return DateTime(date.year, date.month, date.day);
  }

  /// Create DayProgress from a map
  factory DayProgress.fromMap(Map<String, dynamic> map) {
    return DayProgress(
      date: DateTime.parse(map['date'] as String),
      totalHabits: map['totalHabits'] as int,
      completedHabits: map['completedHabits'] as int,
      completedHabitIds: List<String>.from(map['completedHabitIds'] as List),
      missedHabitIds: List<String>.from(map['missedHabitIds'] as List),
      skippedHabitIds: List<String>.from(map['skippedHabitIds'] as List),
    );
  }

  /// Convert DayProgress to a map
  Map<String, dynamic> toMap() {
    return {
      'date': date.toIso8601String(),
      'totalHabits': totalHabits,
      'completedHabits': completedHabits,
      'completedHabitIds': completedHabitIds,
      'missedHabitIds': missedHabitIds,
      'skippedHabitIds': skippedHabitIds,
    };
  }

  DayProgress copyWith({
    DateTime? date,
    int? totalHabits,
    int? completedHabits,
    List<String>? completedHabitIds,
    List<String>? missedHabitIds,
    List<String>? skippedHabitIds,
  }) {
    return DayProgress(
      date: date ?? this.date,
      totalHabits: totalHabits ?? this.totalHabits,
      completedHabits: completedHabits ?? this.completedHabits,
      completedHabitIds: completedHabitIds ?? this.completedHabitIds,
      missedHabitIds: missedHabitIds ?? this.missedHabitIds,
      skippedHabitIds: skippedHabitIds ?? this.skippedHabitIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DayProgress &&
        other.date == date &&
        other.totalHabits == totalHabits &&
        other.completedHabits == completedHabits;
  }

  @override
  int get hashCode {
    return date.hashCode ^ totalHabits.hashCode ^ completedHabits.hashCode;
  }

  @override
  String toString() {
    return 'DayProgress(date: $date, totalHabits: $totalHabits, completedHabits: $completedHabits, progressPercentage: ${progressPercentage.toStringAsFixed(2)})';
  }
}
