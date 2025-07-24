import 'package:flutter/material.dart';

/// Represents a single streak entry in the history
@immutable
class StreakEntry {
  final String habitId;
  final DateTime date;
  final StreakStatus status;
  final int streakCount; // The streak count at this date

  const StreakEntry({
    required this.habitId,
    required this.date,
    required this.status,
    required this.streakCount,
  });

  /// Create StreakEntry from a map
  factory StreakEntry.fromMap(Map<String, dynamic> map) {
    return StreakEntry(
      habitId: map['habitId'] as String,
      date: DateTime.parse(map['date'] as String),
      status: StreakStatus.values[map['status'] as int],
      streakCount: map['streakCount'] as int,
    );
  }

  /// Convert StreakEntry to a map
  Map<String, dynamic> toMap() {
    return {
      'habitId': habitId,
      'date': date.toIso8601String(),
      'status': status.index,
      'streakCount': streakCount,
    };
  }

  StreakEntry copyWith({
    String? habitId,
    DateTime? date,
    StreakStatus? status,
    int? streakCount,
  }) {
    return StreakEntry(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      streakCount: streakCount ?? this.streakCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StreakEntry &&
        other.habitId == habitId &&
        other.date == date &&
        other.status == status &&
        other.streakCount == streakCount;
  }

  @override
  int get hashCode {
    return habitId.hashCode ^
        date.hashCode ^
        status.hashCode ^
        streakCount.hashCode;
  }
}

/// Status of a habit on a particular day
enum StreakStatus {
  completed, // Habit was completed
  missed, // Habit was missed (streak broken)
  skipped, // Habit was intentionally skipped (doesn't break streak)
}

extension StreakStatusExtension on StreakStatus {
  String get displayName {
    switch (this) {
      case StreakStatus.completed:
        return 'Completed';
      case StreakStatus.missed:
        return 'Missed';
      case StreakStatus.skipped:
        return 'Skipped';
    }
  }

  Color get color {
    switch (this) {
      case StreakStatus.completed:
        return Colors.green;
      case StreakStatus.missed:
        return Colors.red;
      case StreakStatus.skipped:
        return Colors.orange;
    }
  }

  IconData get icon {
    switch (this) {
      case StreakStatus.completed:
        return Icons.check_circle;
      case StreakStatus.missed:
        return Icons.cancel;
      case StreakStatus.skipped:
        return Icons.pause_circle;
    }
  }
}
