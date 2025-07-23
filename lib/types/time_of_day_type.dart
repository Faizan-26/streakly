// Time of day
enum TimeOfDayPreference {
  anytime,
  morning,
  afternoon,
  evening,
}


extension TimeOfDayPreferenceExtension on TimeOfDayPreference {
  String get name {
    switch (this) {
      case TimeOfDayPreference.anytime:
        return 'Anytime';
      case TimeOfDayPreference.morning:
        return 'Morning';
      case TimeOfDayPreference.afternoon:
        return 'Afternoon';
      case TimeOfDayPreference.evening:
        return 'Evening';
    }
  }
}

extension TimeOfDayPreferenceStringExtension on String {
  TimeOfDayPreference toTimeOfDayPreference() {
    switch (this) {
      case 'Anytime':
        return TimeOfDayPreference.anytime;
      case 'Morning':
        return TimeOfDayPreference.morning;
      case 'Afternoon':
        return TimeOfDayPreference.afternoon;
      case 'Evening':
        return TimeOfDayPreference.evening;
      default:
        throw ArgumentError('Unknown time of day preference: $this');
    }
  }
}