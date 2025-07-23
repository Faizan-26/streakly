
/// Tells type of habit
/// - regular: A habit that is performed regularly (e.g., daily, weekly).
/// - negative: A habit that is considered harmful or undesirable initially it is formed user need to break it.
/// - oneTime: A habit that is performed only once.
enum HabitType {
  regular,
  negative,
  oneTime
}

extension HabitTypeExtension on HabitType {
  String get name {
    switch (this) {
      case HabitType.regular:
        return 'Regular';
      case HabitType.negative:
        return 'Negative';
      case HabitType.oneTime:
        return 'One Time';
    }
  }
}

extension HabitTypeStringExtension on String {
  HabitType toHabitType() {
    switch (this) {
      case 'Regular':
        return HabitType.regular;
      case 'Negative':
        return HabitType.negative;
      case 'One Time':
        return HabitType.oneTime;
      default:
        throw ArgumentError('Unknown habit type: $this');
    }
  }
}

