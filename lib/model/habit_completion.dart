import 'package:flutter/foundation.dart';

/// Model for tracking habit completions on specific dates
@immutable
class HabitCompletion {
  final String id;
  final String habitId;
  final DateTime completedDate;
  final bool isDone;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.completedDate,
    required this.isDone,
    required this.createdAt,
    this.updatedAt,
  });

  /// Create a completion for today
  factory HabitCompletion.today({
    required String habitId,
    required bool isDone,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return HabitCompletion(
      id: '${habitId}_${today.toIso8601String().split('T')[0]}',
      habitId: habitId,
      completedDate: today,
      isDone: isDone,
      createdAt: now,
    );
  }

  /// Create a completion for a specific date
  factory HabitCompletion.forDate({
    required String habitId,
    required DateTime date,
    required bool isDone,
  }) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();

    return HabitCompletion(
      id: '${habitId}_${normalizedDate.toIso8601String().split('T')[0]}',
      habitId: habitId,
      completedDate: normalizedDate,
      isDone: isDone,
      createdAt: now,
    );
  }

  /// Create from map (for storage/retrieval)
  factory HabitCompletion.fromMap(Map<String, dynamic> map) {
    return HabitCompletion(
      id: map['id'] as String,
      habitId: map['habitId'] as String,
      completedDate: DateTime.parse(map['completedDate'] as String),
      isDone: map['isDone'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Convert to map (for storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'habitId': habitId,
      'completedDate': completedDate.toIso8601String(),
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Copy with updated values
  HabitCompletion copyWith({
    String? id,
    String? habitId,
    DateTime? completedDate,
    bool? isDone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HabitCompletion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      completedDate: completedDate ?? this.completedDate,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Mark as updated
  HabitCompletion markAsUpdated() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Get date string for comparison
  String get dateString => completedDate.toIso8601String().split('T')[0];

  /// Check if this completion is for today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return completedDate.isAtSameMomentAs(today);
  }

  /// Check if this completion is for a specific date
  bool isForDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    return completedDate.isAtSameMomentAs(normalizedDate);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HabitCompletion &&
        other.id == id &&
        other.habitId == habitId &&
        other.completedDate == completedDate &&
        other.isDone == isDone;
  }

  @override
  int get hashCode {
    return Object.hash(id, habitId, completedDate, isDone);
  }

  @override
  String toString() {
    return 'HabitCompletion(id: $id, habitId: $habitId, date: $dateString, isDone: $isDone)';
  }
}

/// Extension for managing collections of habit completions
extension HabitCompletionList on List<HabitCompletion> {
  /// Get completions for a specific habit
  List<HabitCompletion> forHabit(String habitId) {
    return where((completion) => completion.habitId == habitId).toList();
  }

  /// Get completions for a specific date
  List<HabitCompletion> forDate(DateTime date) {
    return where((completion) => completion.isForDate(date)).toList();
  }

  /// Get today's completions
  List<HabitCompletion> get forToday {
    return where((completion) => completion.isToday).toList();
  }

  /// Check if a habit is completed on a specific date
  bool isHabitCompletedOnDate(String habitId, DateTime date) {
    return any(
      (completion) =>
          completion.habitId == habitId &&
          completion.isForDate(date) &&
          completion.isDone,
    );
  }

  /// Check if a habit is completed today
  bool isHabitCompletedToday(String habitId) {
    return any(
      (completion) =>
          completion.habitId == habitId &&
          completion.isToday &&
          completion.isDone,
    );
  }

  /// Get completion percentage for a specific date
  double getCompletionPercentageForDate(DateTime date, List<String> habitIds) {
    if (habitIds.isEmpty) return 0.0;

    final completedCount = habitIds
        .where((habitId) => isHabitCompletedOnDate(habitId, date))
        .length;

    return completedCount / habitIds.length;
  }

  /// Get all completed dates for a habit
  List<DateTime> getCompletedDatesForHabit(String habitId) {
    return forHabit(habitId)
        .where((completion) => completion.isDone)
        .map((completion) => completion.completedDate)
        .toList()
      ..sort();
  }

  /// Get all perfect days (days where all habits were completed)
  Set<DateTime> getPerfectDays(List<String> habitIds) {
    if (habitIds.isEmpty) return {};

    final perfectDays = <DateTime>{};

    // Group completions by date
    final completionsByDate = <DateTime, List<HabitCompletion>>{};
    for (final completion in this) {
      if (completion.isDone) {
        completionsByDate
            .putIfAbsent(completion.completedDate, () => [])
            .add(completion);
      }
    }

    // Check each date for perfect completion
    for (final entry in completionsByDate.entries) {
      final date = entry.key;
      final completions = entry.value;

      final completedHabits = completions.map((c) => c.habitId).toSet();
      if (completedHabits.containsAll(habitIds)) {
        perfectDays.add(date);
      }
    }

    return perfectDays;
  }
}
