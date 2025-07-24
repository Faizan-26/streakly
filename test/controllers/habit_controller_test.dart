import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';

void main() {
  group('Habit Controller Tests', () {
    late ProviderContainer container;
    late Map<String, Object> mockPreferences;

    setUpAll(() {
      // Initialize Flutter bindings for SharedPreferences
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      // Fresh preferences for each test
      mockPreferences = <String, Object>{};

      // Mock SharedPreferences
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            (MethodCall methodCall) async {
              if (methodCall.method == 'getAll') {
                return Map<String, Object>.from(mockPreferences);
              }
              if (methodCall.method == 'setStringList') {
                mockPreferences[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return true;
              }
              if (methodCall.method == 'setString') {
                mockPreferences[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return true;
              }
              if (methodCall.method == 'setBool') {
                mockPreferences[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return true;
              }
              if (methodCall.method == 'setInt') {
                mockPreferences[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return true;
              }
              if (methodCall.method == 'setDouble') {
                mockPreferences[methodCall.arguments['key']] =
                    methodCall.arguments['value'];
                return true;
              }
              if (methodCall.method == 'remove') {
                mockPreferences.remove(methodCall.arguments['key']);
                return true;
              }
              if (methodCall.method == 'clear') {
                mockPreferences.clear();
                return true;
              }
              return null;
            },
          );

      // Create a fresh container for each test
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
      // Clean up method channel
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/shared_preferences'),
            null,
          );
    });

    test('should initialize with empty state', () async {
      // Initialize the controller and wait for it to load
      container.read(habitControllerProvider.notifier);

      // Wait for initialization to complete
      await Future.delayed(Duration(milliseconds: 200));

      final state = container.read(habitControllerProvider);

      expect(state.habits, isEmpty);
      expect(state.streaks, isEmpty);
      expect(state.completions, isEmpty);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('should add a new habit', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 200));

      final habit = Habit(
        id: 'test_habit',
        title: 'Test Habit',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: Icons.star,
        hasReminder: false,
      );

      await controller.addHabit(habit);

      // Wait for the state to update
      await Future.delayed(Duration(milliseconds: 50));

      final state = container.read(habitControllerProvider);
      expect(state.habits.length, 1);
      expect(state.habits.first.title, 'Test Habit');
      expect(state.error, isNull);
    });

    test('should complete a habit and update streak', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 200));

      final habit = Habit(
        id: 'test_habit',
        title: 'Test Habit',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: Icons.star,
        hasReminder: false,
      );

      await controller.addHabit(habit);
      await controller.completeHabit('test_habit');

      final state = container.read(habitControllerProvider);
      expect(state.getStreakCount('test_habit'), 1);
      expect(state.isHabitCompletedToday('test_habit'), true);
    });

    test('should uncomplete a habit and decrease streak', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 200));

      final habit = Habit(
        id: 'test_habit',
        title: 'Test Habit',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: Icons.star,
        hasReminder: false,
      );

      await controller.addHabit(habit);
      await controller.completeHabit('test_habit');
      await controller.uncompleteHabit('test_habit');

      final state = container.read(habitControllerProvider);
      expect(state.getStreakCount('test_habit'), 0);
      expect(state.isHabitCompletedToday('test_habit'), false);
    });

    test('should delete a habit', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 200));

      final habit = Habit(
        id: 'test_habit',
        title: 'Test Habit',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: Icons.star,
        hasReminder: false,
      );

      await controller.addHabit(habit);
      await controller.deleteHabit('test_habit');

      final state = container.read(habitControllerProvider);
      expect(state.habits, isEmpty);
      expect(state.streaks['test_habit'], isNull);
      expect(state.completions['test_habit'], isNull);
    });

    test('should handle negative habits correctly', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Wait for initialization
      await Future.delayed(Duration(milliseconds: 200));

      final negativeHabit = Habit(
        id: 'negative_habit',
        title: 'Avoid Smoking',
        type: HabitType.negative,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.red,
        icon: Icons.smoke_free,
        hasReminder: false,
      );

      await controller.addHabit(negativeHabit);
      await controller.completeHabit('negative_habit'); // Mark as avoided

      final state = container.read(habitControllerProvider);
      expect(state.getStreakCount('negative_habit'), 1);
      expect(state.isHabitCompletedToday('negative_habit'), true);

      // Uncompleting (failing to avoid) should reset streak to 0
      await controller.uncompleteHabit('negative_habit');

      // Wait for state to update
      await Future.delayed(Duration(milliseconds: 50));

      final updatedState = container.read(habitControllerProvider);
      expect(updatedState.getStreakCount('negative_habit'), 0);
    });

    test('should filter habits by type', () async {
      final controller = container.read(habitControllerProvider.notifier);

      // Clear any existing habits
      final currentState = container.read(habitControllerProvider);
      for (final habit in currentState.habits) {
        await controller.deleteHabit(habit.id);
      }

      // Wait for initialization and clear operations
      await Future.delayed(Duration(milliseconds: 200));

      final regularHabit = Habit(
        id: 'regular_habit',
        title: 'Exercise',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.blue,
        icon: Icons.fitness_center,
        hasReminder: false,
      );

      final negativeHabit = Habit(
        id: 'negative_habit',
        title: 'Avoid Junk Food',
        type: HabitType.negative,
        frequency: Frequency(type: FrequencyType.daily),
        color: Colors.red,
        icon: Icons.no_food,
        hasReminder: false,
      );

      await controller.addHabit(regularHabit);
      await controller.addHabit(negativeHabit);

      final state = container.read(habitControllerProvider);
      final regularHabits = state.getHabitsByType(HabitType.regular);
      final negativeHabits = state.getHabitsByType(HabitType.negative);

      expect(regularHabits.isNotEmpty, true); // At least one regular habit
      expect(regularHabits.any((h) => h.title == 'Exercise'), true);
      expect(negativeHabits.isNotEmpty, true); // At least one negative habit
      expect(negativeHabits.any((h) => h.title == 'Avoid Junk Food'), true);
    });
  });
}
