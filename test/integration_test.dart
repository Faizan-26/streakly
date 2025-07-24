import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/services/local_storage.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/utils/time_period_utils.dart';
import 'dart:convert';

void main() {
  group('Integration Tests - All Components Working Together', () {
    setUp(() {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test(
      'should save and load complete habit data using LocalStorage',
      () async {
        // Create a complex habit with all features
        final frequency = Frequency(
          type: FrequencyType.weekly,
          selectedDays: [1, 2, 3, 4, 5], // Monday to Friday
          timesPerPeriod: 5,
          specificDates: [1, 15], // Optional additional data
        );

        final habit = Habit(
          id: 'integration_test_habit',
          title: 'Complete Integration Test Habit',
          type: HabitType.regular,
          frequency: frequency,
          timeOfDay: TimeOfDayPreference.morning,
          goalDuration: const Duration(hours: 1, minutes: 30),
          goalCount: 2,
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 12, 31),
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 8, minute: 30),
          color: Colors.green,
          icon: Icons.fitness_center,
          category: 'Health & Fitness',
          isPreset: false,
        );

        // Save habit using LocalStorage
        const key = 'test_habit';
        await LocalStorage.saveData(key, habit.toMap());

        // Load habit data
        final loadedData = await LocalStorage.loadData(key);
        expect(loadedData, isNotNull);

        // Convert back to habit object
        final decodedMap = json.decode(loadedData as String);
        final loadedHabit = Habit.fromMap(decodedMap);

        // Verify all properties are preserved
        expect(loadedHabit.id, habit.id);
        expect(loadedHabit.title, habit.title);
        expect(loadedHabit.type, habit.type);
        expect(loadedHabit.frequency.type, habit.frequency.type);
        expect(
          loadedHabit.frequency.selectedDays,
          habit.frequency.selectedDays,
        );
        expect(
          loadedHabit.frequency.timesPerPeriod,
          habit.frequency.timesPerPeriod,
        );
        expect(
          loadedHabit.frequency.specificDates,
          habit.frequency.specificDates,
        );
        expect(loadedHabit.timeOfDay, habit.timeOfDay);
        expect(loadedHabit.goalDuration, habit.goalDuration);
        expect(loadedHabit.goalCount, habit.goalCount);
        expect(loadedHabit.startDate, habit.startDate);
        expect(loadedHabit.endDate, habit.endDate);
        expect(loadedHabit.hasReminder, habit.hasReminder);
        expect(loadedHabit.reminderTime, habit.reminderTime);
        expect(loadedHabit.color.value, habit.color.value);
        expect(loadedHabit.icon.codePoint, habit.icon.codePoint);
        expect(loadedHabit.category, habit.category);
        expect(loadedHabit.isPreset, habit.isPreset);
      },
    );

    test('should save and load multiple habits', () async {
      // Create multiple habits with different configurations
      final habits = [
        Habit(
          id: 'habit_1',
          title: 'Morning Exercise',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: TimeOfDayPreference.morning,
          color: Colors.blue,
          icon: Icons.fitness_center,
        ),
        Habit(
          id: 'habit_2',
          title: 'Quit Smoking',
          type: HabitType.negative,
          frequency: Frequency(
            type: FrequencyType.weekly,
            selectedDays: [0, 1, 2, 3, 4, 5, 6], // Every day
          ),
          timeOfDay: TimeOfDayPreference.anytime,
          color: Colors.red,
          icon: Icons.smoke_free,
        ),
        Habit(
          id: 'habit_3',
          title: 'Complete Project',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          timeOfDay: TimeOfDayPreference.afternoon,
          goalDuration: const Duration(days: 30),
          color: Colors.green,
          icon: Icons.check_circle,
        ),
      ];

      // Save all habits
      const key = 'habits_list';
      final habitsMapList = habits.map((habit) => habit.toMap()).toList();
      await LocalStorage.saveData(key, habitsMapList);

      // Load habits
      final loadedData = await LocalStorage.loadData(key);
      expect(loadedData, isNotNull);

      final decodedList = json.decode(loadedData as String) as List<dynamic>;
      final loadedHabits = decodedList
          .map((map) => Habit.fromMap(map as Map<String, dynamic>))
          .toList();

      // Verify all habits are preserved
      expect(loadedHabits.length, habits.length);

      for (int i = 0; i < habits.length; i++) {
        final original = habits[i];
        final loaded = loadedHabits[i];

        expect(loaded.id, original.id);
        expect(loaded.title, original.title);
        expect(loaded.type, original.type);
        expect(loaded.frequency.type, original.frequency.type);
        expect(loaded.timeOfDay, original.timeOfDay);
        expect(loaded.color.value, original.color.value);
        expect(loaded.icon.codePoint, original.icon.codePoint);
      }
    });

    test(
      'should integrate with TimePeriodUtils for habit scheduling',
      () async {
        // Create a habit with morning preference
        final morningHabit = Habit(
          id: 'morning_habit',
          title: 'Morning Meditation',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: TimeOfDayPreference.morning,
          reminderTime: const TimeOfDay(hour: 8, minute: 0),
          color: Colors.purple,
          icon: Icons.self_improvement,
        );

        // Save the habit
        await LocalStorage.saveData('morning_habit', morningHabit.toMap());

        // Get the time range for the habit's preferred time
        final timeRange = TimePeriodUtils.getTimePeriodRange(
          morningHabit.timeOfDay!,
        );
        expect(timeRange, '08:00 - 14:00');

        // Check if current time matches habit preference
        final currentPeriod = TimePeriodUtils.getCurrentTimePeriod();
        final isOptimalTime = currentPeriod == morningHabit.timeOfDay;
        expect(isOptimalTime, isA<bool>());

        // Load and verify the habit
        final loadedData = await LocalStorage.loadData('morning_habit');
        final decodedMap = json.decode(loadedData as String);
        final loadedHabit = Habit.fromMap(decodedMap);

        expect(loadedHabit.timeOfDay, TimeOfDayPreference.morning);
        expect(loadedHabit.reminderTime, const TimeOfDay(hour: 8, minute: 0));
      },
    );

    test('should handle complex frequency configurations', () async {
      // Test different frequency types and their serialization
      final frequencyTestCases = [
        Frequency(type: FrequencyType.daily),
        Frequency(
          type: FrequencyType.weekly,
          selectedDays: [1, 3, 5], // Monday, Wednesday, Friday
        ),
        Frequency(type: FrequencyType.monthly, specificDates: [1, 15, 30]),
        Frequency(
          type: FrequencyType.yearly,
          timesPerPeriod: 12, // Once per month
        ),
        Frequency(type: FrequencyType.longTerm, timesPerPeriod: 1),
      ];

      for (int i = 0; i < frequencyTestCases.length; i++) {
        final frequency = frequencyTestCases[i];
        final habit = Habit(
          id: 'frequency_test_$i',
          title: 'Test Habit ${frequency.type.name}',
          type: HabitType.regular,
          frequency: frequency,
          color: Colors.amber,
          icon: Icons.schedule,
        );

        // Save and load the habit
        final key = 'frequency_habit_$i';
        await LocalStorage.saveData(key, habit.toMap());

        final loadedData = await LocalStorage.loadData(key);
        final decodedMap = json.decode(loadedData as String);
        final loadedHabit = Habit.fromMap(decodedMap);

        // Verify frequency is preserved
        expect(loadedHabit.frequency.type, frequency.type);
        expect(loadedHabit.frequency.selectedDays, frequency.selectedDays);
        expect(loadedHabit.frequency.timesPerPeriod, frequency.timesPerPeriod);
        expect(loadedHabit.frequency.specificDates, frequency.specificDates);
      }
    });

    test('should handle all habit types and time preferences', () async {
      final allCombinations = <Map<String, dynamic>>[];

      // Generate all combinations of HabitType and TimeOfDayPreference
      for (final habitType in HabitType.values) {
        for (final timePreference in TimeOfDayPreference.values) {
          final habit = Habit(
            id: 'combo_${habitType.name}_${timePreference.name}',
            title: '${habitType.name} ${timePreference.name} Habit',
            type: habitType,
            frequency: Frequency(type: FrequencyType.daily),
            timeOfDay: timePreference,
            color: Colors.teal,
            icon: Icons.star,
          );

          allCombinations.add(habit.toMap());
        }
      }

      // Save all combinations
      await LocalStorage.saveData('all_combinations', allCombinations);

      // Load and verify
      final loadedData = await LocalStorage.loadData('all_combinations');
      final decodedList = json.decode(loadedData as String) as List<dynamic>;

      expect(
        decodedList.length,
        HabitType.values.length * TimeOfDayPreference.values.length,
      );
      expect(
        decodedList.length,
        3 * 4,
      ); // 3 habit types × 4 time preferences = 12

      // Verify each combination can be properly deserialized
      for (final map in decodedList) {
        final habit = Habit.fromMap(map as Map<String, dynamic>);
        expect(habit.type, isIn(HabitType.values));
        expect(habit.timeOfDay, isIn(TimeOfDayPreference.values));
        expect(habit.frequency.type, FrequencyType.daily);
      }
    });

    test('should handle habit data removal and updates', () async {
      // Create initial habit
      final originalHabit = Habit(
        id: 'updatable_habit',
        title: 'Original Title',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        timeOfDay: TimeOfDayPreference.morning,
        color: Colors.blue,
        icon: Icons.star,
        category: 'Original Category',
      );

      const key = 'updatable_habit';

      // Save original habit
      await LocalStorage.saveData(key, originalHabit.toMap());

      // Verify it's saved
      final loadedOriginal = await LocalStorage.loadData(key);
      expect(loadedOriginal, isNotNull);

      // Update the habit (simulate editing)
      final updatedHabit = Habit(
        id: originalHabit.id,
        title: 'Updated Title',
        type: HabitType.negative, // Changed type
        frequency: Frequency(
          type: FrequencyType.weekly,
          selectedDays: [1, 2, 3, 4, 5], // Changed frequency
        ),
        timeOfDay: TimeOfDayPreference.evening, // Changed time
        goalDuration: const Duration(minutes: 45), // Added goal
        color: Colors.red, // Changed color
        icon: Icons.favorite, // Changed icon
        category: 'Updated Category',
      );

      // Save updated habit
      await LocalStorage.saveData(key, updatedHabit.toMap());

      // Load and verify update
      final loadedUpdatedData = await LocalStorage.loadData(key);
      final decodedUpdatedMap = json.decode(loadedUpdatedData as String);
      final loadedUpdatedHabit = Habit.fromMap(decodedUpdatedMap);

      expect(loadedUpdatedHabit.title, 'Updated Title');
      expect(loadedUpdatedHabit.type, HabitType.negative);
      expect(loadedUpdatedHabit.frequency.type, FrequencyType.weekly);
      expect(loadedUpdatedHabit.timeOfDay, TimeOfDayPreference.evening);
      expect(loadedUpdatedHabit.goalDuration, const Duration(minutes: 45));
      expect(loadedUpdatedHabit.color.value, Colors.red.value);
      expect(loadedUpdatedHabit.category, 'Updated Category');

      // Remove the habit
      await LocalStorage.removeData(key);

      // Verify it's removed
      final removedHabit = await LocalStorage.loadData(key);
      expect(removedHabit, isNull);
    });

    test('should demonstrate real-world usage scenario', () async {
      // Simulate a user creating a comprehensive habit tracking system

      // 1. Create different types of habits
      final habits = [
        // Regular morning routine
        Habit(
          id: 'morning_routine',
          title: 'Morning Routine',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: TimeOfDayPreference.morning,
          goalDuration: const Duration(minutes: 30),
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 7, minute: 0),
          color: Colors.orange,
          icon: Icons.wb_sunny,
          category: 'Wellness',
        ),

        // Negative habit to break
        Habit(
          id: 'reduce_screen_time',
          title: 'Reduce Screen Time',
          type: HabitType.negative,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: TimeOfDayPreference.evening,
          goalDuration: const Duration(hours: 2), // Max 2 hours
          color: Colors.red,
          icon: Icons.phone_android,
          category: 'Digital Wellness',
        ),

        // One-time goal
        Habit(
          id: 'learn_language',
          title: 'Complete Language Course',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          timeOfDay: TimeOfDayPreference.anytime,
          startDate: DateTime(2025, 1, 1),
          endDate: DateTime(2025, 6, 30),
          color: Colors.green,
          icon: Icons.language,
          category: 'Education',
        ),
      ];

      // 2. Save all habits as a user's habit list
      const habitsKey = 'user_habits';
      final habitsMapList = habits.map((h) => h.toMap()).toList();
      await LocalStorage.saveData(habitsKey, habitsMapList);

      // 3. Save user preferences
      const preferencesKey = 'user_preferences';
      final preferences = {
        'defaultReminderTime': const TimeOfDay(hour: 9, minute: 0).toMap(),
        'preferredTimeOfDay': TimeOfDayPreference.morning.index,
        'notificationsEnabled': true,
        'weekStartsOn': 1, // Monday
      };
      await LocalStorage.saveData(preferencesKey, preferences);

      // 4. Simulate loading data on app startup
      final loadedHabitsData = await LocalStorage.loadData(habitsKey);
      final loadedPreferencesData = await LocalStorage.loadData(preferencesKey);

      expect(loadedHabitsData, isNotNull);
      expect(loadedPreferencesData, isNotNull);

      // 5. Deserialize habits
      final decodedHabitsList =
          json.decode(loadedHabitsData as String) as List<dynamic>;
      final loadedHabits = decodedHabitsList
          .map((map) => Habit.fromMap(map as Map<String, dynamic>))
          .toList();

      expect(loadedHabits.length, 3);

      // 6. Verify habit types are correctly loaded
      final regularHabits = loadedHabits
          .where((h) => h.type == HabitType.regular)
          .toList();
      final negativeHabits = loadedHabits
          .where((h) => h.type == HabitType.negative)
          .toList();
      final oneTimeHabits = loadedHabits
          .where((h) => h.type == HabitType.oneTime)
          .toList();

      expect(regularHabits.length, 1);
      expect(negativeHabits.length, 1);
      expect(oneTimeHabits.length, 1);

      // 7. Verify preferences
      final decodedPreferences =
          json.decode(loadedPreferencesData as String) as Map<String, dynamic>;
      expect(decodedPreferences['notificationsEnabled'], true);
      expect(
        decodedPreferences['preferredTimeOfDay'],
        TimeOfDayPreference.morning.index,
      );

      // 8. Test time period integration
      for (final habit in loadedHabits) {
        if (habit.timeOfDay != null) {
          final timeRange = TimePeriodUtils.getTimePeriodRange(
            habit.timeOfDay!,
          );
          expect(timeRange, isNotEmpty);
        }
      }

      // 9. Simulate habit completion tracking
      const progressKey = 'habit_progress';
      final progressData = {
        'morning_routine': {
          '2025-07-24': true,
          '2025-07-23': true,
          '2025-07-22': false,
        },
        'reduce_screen_time': {'2025-07-24': true, '2025-07-23': false},
        'learn_language': {'completed': false, 'progress_percentage': 75},
      };

      await LocalStorage.saveData(progressKey, progressData);
      final loadedProgress = await LocalStorage.loadData(progressKey);
      expect(loadedProgress, isNotNull);

      // Verify progress data
      final decodedProgress =
          json.decode(loadedProgress as String) as Map<String, dynamic>;
      expect(decodedProgress['morning_routine']['2025-07-24'], true);
      expect(decodedProgress['learn_language']['progress_percentage'], 75);
    });
  });
}
