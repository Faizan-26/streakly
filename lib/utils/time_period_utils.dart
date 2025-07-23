import 'package:streakly/types/time_of_day_type.dart';

class TimePeriodUtils {
  static TimeOfDayPreference getCurrentTimePeriod() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 8 && hour < 14) return TimeOfDayPreference.morning;
    if (hour >= 14 && hour < 19) return TimeOfDayPreference.afternoon;
    if (hour >= 19 && hour < 23) return TimeOfDayPreference.evening;
    return TimeOfDayPreference.anytime;
  }

  static String getTimePeriodRange(TimeOfDayPreference period) {
    switch (period) {
      case TimeOfDayPreference.morning:
        return '08:00 - 14:00';
      case TimeOfDayPreference.afternoon:
        return '14:00 - 19:00';
      case TimeOfDayPreference.evening:
        return '19:00 - 23:00';
      default:
        return 'Anytime';
    }
  }
}

