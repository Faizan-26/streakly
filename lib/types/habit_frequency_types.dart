/// Frequency types for habit tracking
/// - daily: Habit is performed every day.
/// - weekly: Habit is performed every week.
/// - monthly: Habit is performed every month.
/// - yearly: Habit is performed every year.
/// - longTerm: Habit is performed over a long period of time.
enum FrequencyType {
  daily,
  weekly,
  monthly,
  yearly,
  longTerm,
}

extension FrequencyTypeExtension on FrequencyType {
  String get name {
    switch (this) {
      case FrequencyType.daily:
        return 'Daily';
      case FrequencyType.weekly:
        return 'Weekly';
      case FrequencyType.monthly:
        return 'Monthly';
      case FrequencyType.yearly:
        return 'Yearly';
      case FrequencyType.longTerm:
        return 'Long Term';
    }
  }
}

extension FrequencyTypeStringExtension on String {
  FrequencyType toFrequencyType() {
    switch (this) {
      case 'Daily':
        return FrequencyType.daily;
      case 'Weekly':
        return FrequencyType.weekly;
      case 'Monthly':
        return FrequencyType.monthly;
      case 'Yearly':
        return FrequencyType.yearly;
      case 'Long Term':
        return FrequencyType.longTerm;
      default:
        throw ArgumentError('Unknown frequency type: $this');
    }
  }
}