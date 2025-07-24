import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';

void main() {
  group('Habit Model Tests', () {
    late Habit testHabit;
    late Frequency testFrequency;

    setUp(() {
      testFrequency = Frequency(
        type: FrequencyType.weekly,
        selectedDays: [1, 2, 3, 4, 5], // Monday to Friday
        timesPerPeriod: 5,
      );

      testHabit = Habit(
        id: 'habit_1',
        title: 'Morning Exercise',
        type: HabitType.regular,
        frequency: testFrequency,
        timeOfDay: TimeOfDayPreference.morning,
        goalDuration: const Duration(minutes: 30),
        goalCount: 1,
        startDate: DateTime(2025, 1, 1),
        endDate: DateTime(2025, 12, 31),
        hasReminder: true,
        reminderTime: const TimeOfDay(hour: 7, minute: 0),
        color: Colors.blue,
        icon: Icons.fitness_center,
        category: 'Health',
        isPreset: false,
      );
    });

    test('should create habit with all properties', () {
      expect(testHabit.id, 'habit_1');
      expect(testHabit.title, 'Morning Exercise');
      expect(testHabit.type, HabitType.regular);
      expect(testHabit.frequency.type, FrequencyType.weekly);
      expect(testHabit.timeOfDay, TimeOfDayPreference.morning);
      expect(testHabit.goalDuration, const Duration(minutes: 30));
      expect(testHabit.goalCount, 1);
      expect(testHabit.hasReminder, true);
      expect(testHabit.reminderTime, const TimeOfDay(hour: 7, minute: 0));
      expect(testHabit.color, Colors.blue);
      expect(testHabit.icon, Icons.fitness_center);
      expect(testHabit.category, 'Health');
      expect(testHabit.isPreset, false);
    });

    test('should create habit with minimal required properties', () {
      final minimalHabit = Habit(
        id: 'minimal_habit',
        title: 'Basic Habit',
        type: HabitType.oneTime,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.red,
        icon: Icons.check,
      );

      expect(minimalHabit.id, 'minimal_habit');
      expect(minimalHabit.title, 'Basic Habit');
      expect(minimalHabit.type, HabitType.oneTime);
      expect(minimalHabit.frequency.type, FrequencyType.daily);
      expect(minimalHabit.timeOfDay, isNull);
      expect(minimalHabit.goalDuration, isNull);
      expect(minimalHabit.goalCount, isNull);
      expect(minimalHabit.startDate, isNull);
      expect(minimalHabit.endDate, isNull);
      expect(minimalHabit.hasReminder, false);
      expect(minimalHabit.reminderTime, isNull);
      expect(minimalHabit.category, isNull);
      expect(minimalHabit.isPreset, false);
    });

    test('should convert habit to map correctly', () {
      final map = testHabit.toMap();

      expect(map['id'], 'habit_1');
      expect(map['title'], 'Morning Exercise');
      expect(map['type'], HabitType.regular.index);
      expect(map['frequency'], isA<Map<String, dynamic>>());
      expect(map['timeOfDay'], TimeOfDayPreference.morning.index);
      expect(map['goalDuration'], const Duration(minutes: 30).inMilliseconds);
      expect(map['goalCount'], 1);
      expect(map['startDate'], DateTime(2025, 1, 1).toIso8601String());
      expect(map['endDate'], DateTime(2025, 12, 31).toIso8601String());
      expect(map['hasReminder'], true);
      expect(map['reminderTime'], isA<Map<String, dynamic>>());
      expect(map['color'], Colors.blue.value);
      expect(map['icon'], Icons.fitness_center.codePoint);
      expect(map['category'], 'Health');
      expect(map['isPreset'], false);
    });

    test('should create habit from map correctly', () {
      final map = testHabit.toMap();
      final recreatedHabit = Habit.fromMap(map);

      expect(recreatedHabit.id, testHabit.id);
      expect(recreatedHabit.title, testHabit.title);
      expect(recreatedHabit.type, testHabit.type);
      expect(recreatedHabit.frequency.type, testHabit.frequency.type);
      expect(recreatedHabit.timeOfDay, testHabit.timeOfDay);
      expect(recreatedHabit.goalDuration, testHabit.goalDuration);
      expect(recreatedHabit.goalCount, testHabit.goalCount);
      expect(recreatedHabit.startDate, testHabit.startDate);
      expect(recreatedHabit.endDate, testHabit.endDate);
      expect(recreatedHabit.hasReminder, testHabit.hasReminder);
      expect(recreatedHabit.reminderTime, testHabit.reminderTime);
      expect(recreatedHabit.color.value, testHabit.color.value);
      expect(recreatedHabit.icon.codePoint, testHabit.icon.codePoint);
      expect(recreatedHabit.category, testHabit.category);
      expect(recreatedHabit.isPreset, testHabit.isPreset);
    });

    test('should handle null values in toMap', () {
      final habitWithNulls = Habit(
        id: 'null_habit',
        title: 'Null Test',
        type: HabitType.negative,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.green,
        icon: Icons.close,
      );

      final map = habitWithNulls.toMap();

      expect(map['timeOfDay'], isNull);
      expect(map['goalDuration'], isNull);
      expect(map['goalCount'], isNull);
      expect(map['startDate'], isNull);
      expect(map['endDate'], isNull);
      expect(map['reminderTime'], isNull);
      expect(map['category'], isNull);
    });

    test('should preserve icon details during serialization', () {
      final iconData = Icons.fitness_center;

      final habit = Habit(
        id: 'test_habit',
        title: 'Test Habit',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: iconData,
        hasReminder: false,
      );

      // Serialize to map
      final map = habit.toMap();

      // Verify icon data is stored correctly
      expect(map['icon'], iconData.codePoint);
      expect(map['iconFontFamily'], iconData.fontFamily);
      expect(map['iconFontPackage'], iconData.fontPackage);

      // Deserialize from map
      final recreatedHabit = Habit.fromMap(map);

      // Verify icon is recreated correctly
      expect(recreatedHabit.icon.codePoint, iconData.codePoint);
      expect(
        recreatedHabit.icon.fontFamily,
        iconData.fontFamily ?? 'MaterialIcons',
      );
      expect(recreatedHabit.icon.fontPackage, iconData.fontPackage);
    });
  });

  group('Frequency Model Tests', () {
    test('should create daily frequency', () {
      final frequency = Frequency(type: FrequencyType.daily);

      expect(frequency.type, FrequencyType.daily);
      expect(frequency.selectedDays, isNull);
      expect(frequency.timesPerPeriod, isNull);
      expect(frequency.specificDates, isNull);
    });

    test('should create weekly frequency with selected days', () {
      final frequency = Frequency(
        type: FrequencyType.weekly,
        selectedDays: [1, 2, 3, 4, 5], // Monday to Friday
      );

      expect(frequency.type, FrequencyType.weekly);
      expect(frequency.selectedDays, [1, 2, 3, 4, 5]);
      expect(frequency.timesPerPeriod, isNull);
      expect(frequency.specificDates, isNull);
    });

    test('should create monthly frequency with specific dates', () {
      final frequency = Frequency(
        type: FrequencyType.monthly,
        specificDates: [1, 15, 30], // 1st, 15th, and 30th of each month
      );

      expect(frequency.type, FrequencyType.monthly);
      expect(frequency.selectedDays, isNull);
      expect(frequency.timesPerPeriod, isNull);
      expect(frequency.specificDates, [1, 15, 30]);
    });

    test('should create frequency with times per period', () {
      final frequency = Frequency(
        type: FrequencyType.weekly,
        timesPerPeriod: 3,
      );

      expect(frequency.type, FrequencyType.weekly);
      expect(frequency.selectedDays, isNull);
      expect(frequency.timesPerPeriod, 3);
      expect(frequency.specificDates, isNull);
    });

    test('should convert frequency to map correctly', () {
      final frequency = Frequency(
        type: FrequencyType.weekly,
        selectedDays: [1, 2, 3],
        timesPerPeriod: 3,
        specificDates: [1, 15],
      );

      final map = frequency.toMap();

      expect(map['type'], FrequencyType.weekly.index);
      expect(map['selectedDays'], [1, 2, 3]);
      expect(map['timesPerPeriod'], 3);
      expect(map['specificDates'], [1, 15]);
    });

    test('should create frequency from map correctly', () {
      final originalFrequency = Frequency(
        type: FrequencyType.monthly,
        selectedDays: [0, 6], // Sunday and Saturday
        timesPerPeriod: 2,
        specificDates: [1, 15, 30],
      );

      final map = originalFrequency.toMap();
      final recreatedFrequency = Frequency.fromMap(map);

      expect(recreatedFrequency.type, originalFrequency.type);
      expect(recreatedFrequency.selectedDays, originalFrequency.selectedDays);
      expect(
        recreatedFrequency.timesPerPeriod,
        originalFrequency.timesPerPeriod,
      );
      expect(recreatedFrequency.specificDates, originalFrequency.specificDates);
    });
  });

  group('TimeOfDay Extension Tests', () {
    test('should convert TimeOfDay to map', () {
      const timeOfDay = TimeOfDay(hour: 14, minute: 30);
      final map = timeOfDay.toMap();

      expect(map['hour'], 14);
      expect(map['minute'], 30);
    });

    test('should create TimeOfDay from map', () {
      final map = {'hour': 9, 'minute': 15};
      final timeOfDay = TimeOfDayExtension.fromMap(map);

      expect(timeOfDay.hour, 9);
      expect(timeOfDay.minute, 15);
    });

    test('should handle edge cases for TimeOfDay', () {
      // Test midnight
      const midnight = TimeOfDay(hour: 0, minute: 0);
      final midnightMap = midnight.toMap();
      final recreatedMidnight = TimeOfDayExtension.fromMap(midnightMap);

      expect(recreatedMidnight.hour, 0);
      expect(recreatedMidnight.minute, 0);

      // Test last minute of day
      const lastMinute = TimeOfDay(hour: 23, minute: 59);
      final lastMinuteMap = lastMinute.toMap();
      final recreatedLastMinute = TimeOfDayExtension.fromMap(lastMinuteMap);

      expect(recreatedLastMinute.hour, 23);
      expect(recreatedLastMinute.minute, 59);
    });
  });

  group('Integration Tests', () {
    test('should handle complex habit serialization and deserialization', () {
      final complexFrequency = Frequency(
        type: FrequencyType.monthly,
        selectedDays: [1, 2, 3, 4, 5],
        timesPerPeriod: 20,
        specificDates: [1, 8, 15, 22, 29],
      );

      final complexHabit = Habit(
        id: 'complex_habit_123',
        title: 'Complex Habit with All Features',
        type: HabitType.negative,
        frequency: complexFrequency,
        timeOfDay: TimeOfDayPreference.evening,
        goalDuration: const Duration(hours: 2, minutes: 30, seconds: 45),
        goalCount: 42,
        startDate: DateTime(2025, 7, 24, 10, 30, 0),
        endDate: DateTime(2026, 7, 24, 23, 59, 59),
        hasReminder: true,
        reminderTime: const TimeOfDay(hour: 20, minute: 15),
        color: const Color(0xFF123456),
        icon: Icons.accessibility_new,
        category: 'Personal Development',
        isPreset: true,
      );

      // Convert to map and back
      final map = complexHabit.toMap();
      final recreatedHabit = Habit.fromMap(map);

      // Verify all properties are preserved
      expect(recreatedHabit.id, complexHabit.id);
      expect(recreatedHabit.title, complexHabit.title);
      expect(recreatedHabit.type, complexHabit.type);
      expect(recreatedHabit.frequency.type, complexHabit.frequency.type);
      expect(
        recreatedHabit.frequency.selectedDays,
        complexHabit.frequency.selectedDays,
      );
      expect(
        recreatedHabit.frequency.timesPerPeriod,
        complexHabit.frequency.timesPerPeriod,
      );
      expect(
        recreatedHabit.frequency.specificDates,
        complexHabit.frequency.specificDates,
      );
      expect(recreatedHabit.timeOfDay, complexHabit.timeOfDay);
      expect(recreatedHabit.goalDuration, complexHabit.goalDuration);
      expect(recreatedHabit.goalCount, complexHabit.goalCount);
      expect(recreatedHabit.startDate, complexHabit.startDate);
      expect(recreatedHabit.endDate, complexHabit.endDate);
      expect(recreatedHabit.hasReminder, complexHabit.hasReminder);
      expect(recreatedHabit.reminderTime, complexHabit.reminderTime);
      expect(recreatedHabit.color.value, complexHabit.color.value);
      expect(recreatedHabit.icon.codePoint, complexHabit.icon.codePoint);
      expect(recreatedHabit.category, complexHabit.category);
      expect(recreatedHabit.isPreset, complexHabit.isPreset);
    });
  });
}
