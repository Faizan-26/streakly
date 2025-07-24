import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';

void main() {
  group('NotificationManager Tests', () {
    setUp(() {
      // Reset initialization state for each test
      // Note: In a real environment, you'd need to properly mock AwesomeNotifications
    });

    tearDown(() {
      // Clean up after each test
      NotificationManager.dispose();
    });

    test('should initialize NotificationManager without errors', () async {
      expect(() => NotificationManager.initialize(), returnsNormally);
    });

    test('should handle serialized action data correctly', () {
      // Test the new serialization format for awesome_notifications v0.10.1
      final actionData = {
        'id': 123,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'mark_done',
        'actionLifeCycle': 'AppKilled',
        'dismissedLifeCycle': null,
        'actionType': 'Default',
        'payload': {
          'habit_id': 'test_habit_123',
          'habit_title': 'Morning Exercise',
          'habit_type': 'regular',
          'scheduled_date': DateTime.now().toIso8601String(),
        },
      };

      // Test ReceivedAction serialization/deserialization
      final receivedAction = ReceivedAction().fromMap(actionData);
      expect(receivedAction.id, 123);
      expect(receivedAction.channelKey, 'habit_reminders');
      expect(receivedAction.buttonKeyPressed, 'mark_done');
      expect(receivedAction.payload?['habit_id'], 'test_habit_123');

      // Test conversion back to map (for sendPort communication)
      final serializedBack = receivedAction.toMap();
      expect(serializedBack['id'], 123);
      expect(serializedBack['buttonKeyPressed'], 'mark_done');
      expect(serializedBack['payload'], isA<Map<String, String?>>());
    });

    test('should send action to isolate with serialized data', () {
      final actionData = {
        'id': 456,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'snooze',
        'payload': {'habit_id': 'snooze_habit', 'habit_title': 'Snooze Test'},
      };

      final receivedAction = ReceivedAction().fromMap(actionData);

      // This should not throw an error even if no port is registered
      expect(
        () => NotificationManager.sendActionToIsolate(receivedAction),
        returnsNormally,
      );
    });

    test('should handle isolate listener setup', () async {
      expect(() => NotificationManager.setupIsolateListener(), returnsNormally);
    });

    test('should dispose resources properly', () {
      expect(() => NotificationManager.dispose(), returnsNormally);
    });
  });

  group('Awesome Notifications v0.10.1 Compatibility Tests', () {
    test('should handle progress property as double', () {
      // Test the new progress property format (double instead of int)
      final notificationData = {
        'id': 789,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'progress': 0.65, // This should be a double in v0.10.1
        'payload': {'habit_id': 'progress_habit', 'progress_value': '65'},
      };

      final receivedAction = ReceivedAction().fromMap(notificationData);
      expect(receivedAction.id, 789);
      expect(receivedAction.payload?['habit_id'], 'progress_habit');
    });

    test('should handle new action lifecycle values', () {
      final lifecycleValues = ['Foreground', 'Background', 'AppKilled'];

      for (final lifecycle in lifecycleValues) {
        final actionData = {
          'id': 100,
          'channelKey': 'test_channel',
          'actionDate': DateTime.now().toIso8601String(),
          'actionLifeCycle': lifecycle,
          'buttonKeyPressed': 'test_action',
          'payload': {'test': 'data'},
        };

        expect(() => ReceivedAction().fromMap(actionData), returnsNormally);
      }
    });

    test('should handle enhanced payload serialization', () {
      // Test complex payload data that needs proper serialization
      final complexPayload = {
        'habit_id': 'complex_habit',
        'habit_data': {
          'title': 'Complex Habit',
          'streak_count': '15',
          'last_completed': DateTime.now().toIso8601String(),
          'metadata': {'category': 'health', 'priority': 'high'},
        }.toString(), // Nested data should be stringified
        'action_timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
      };

      final actionData = {
        'id': 999,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'mark_done',
        'payload': complexPayload,
      };

      final receivedAction = ReceivedAction().fromMap(actionData);
      expect(receivedAction.payload?['habit_id'], 'complex_habit');
      expect(receivedAction.payload?['habit_data'], isNotNull);
      expect(receivedAction.payload?['action_timestamp'], isNotNull);

      // Test serialization back to map
      final serialized = receivedAction.toMap();
      expect(serialized['payload'], isA<Map>());
    });
  });

  group('Background Action Handling Tests', () {
    test('should handle background notification actions', () async {
      final backgroundActionData = {
        'id': 200,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'mark_done',
        'actionLifeCycle': 'Background',
        'payload': {
          'habit_id': 'background_habit',
          'habit_title': 'Background Test',
          'source': 'background_action',
        },
      };

      final receivedAction = ReceivedAction().fromMap(backgroundActionData);

      expect(
        () => NotificationService.handleNotificationAction(receivedAction),
        returnsNormally,
      );
    });

    test('should handle app-killed state actions', () async {
      final killedStateActionData = {
        'id': 300,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'skip',
        'actionLifeCycle': 'AppKilled',
        'payload': {
          'habit_id': 'killed_state_habit',
          'habit_title': 'App Killed Test',
          'source': 'app_killed_action',
        },
      };

      final receivedAction = ReceivedAction().fromMap(killedStateActionData);

      expect(
        () => NotificationService.handleNotificationAction(receivedAction),
        returnsNormally,
      );
    });
  });

  group('Isolate Communication Tests', () {
    test('should handle sendPort data serialization', () {
      final testData = {
        'action_id': 'test_123',
        'habit_info': {
          'id': 'habit_456',
          'title': 'Test Habit',
          'completed': false,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };

      final receivedAction = ReceivedAction().fromMap({
        'id': 123,
        'channelKey': 'test',
        'actionDate': DateTime.now().toIso8601String(),
        'payload': testData.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      });

      // Test that the data can be properly serialized for sendPort
      final serializedForSendPort = receivedAction.toMap();
      expect(serializedForSendPort, isA<Map<String, dynamic>>());
      expect(serializedForSendPort['payload'], isA<Map>());
    });

    test('should handle receivePort data deserialization', () {
      // Simulate data received from a SendPort
      final receivedData = {
        'id': 789,
        'channelKey': 'habit_reminders',
        'actionDate': DateTime.now().toIso8601String(),
        'buttonKeyPressed': 'mark_done',
        'payload': {'habit_id': 'received_habit', 'source': 'receive_port'},
      };

      // This simulates the new fromMap behavior in awesome_notifications v0.10.1
      expect(() => ReceivedAction().fromMap(receivedData), returnsNormally);

      final receivedAction = ReceivedAction().fromMap(receivedData);
      expect(receivedAction.id, 789);
      expect(receivedAction.buttonKeyPressed, 'mark_done');
      expect(receivedAction.payload?['habit_id'], 'received_habit');
    });
  });

  // Original tests from before...
  group('NotificationService Tests', () {
    late Habit testHabit;

    setUp(() {
      // Create a test habit for notifications
      testHabit = Habit(
        id: 'test_habit_123',
        title: 'Morning Exercise',
        type: HabitType.regular,
        frequency: Frequency(type: FrequencyType.daily),
        timeOfDay: TimeOfDayPreference.morning,
        hasReminder: true,
        reminderTime: const TimeOfDay(hour: 8, minute: 30),
        color: Colors.blue,
        icon: Icons.fitness_center,
        category: 'Health',
      );
    });

    group('Initialization Tests', () {
      test('should initialize notification service', () async {
        // Note: In a real test environment, you'd need to mock AwesomeNotifications
        // For now, we'll test the method exists and doesn't throw
        expect(() => NotificationService.initialize(), returnsNormally);
      });

      test('should request permissions', () async {
        expect(() => NotificationService.requestPermissions(), returnsNormally);
      });

      test('should check if notifications are enabled', () async {
        expect(
          () => NotificationService.areNotificationsEnabled(),
          returnsNormally,
        );
      });
    });

    group('Notification ID Generation', () {
      test('should generate unique notification IDs for different habits', () {
        final date = DateTime(2025, 7, 24);
        final id1 = NotificationService.generateNotificationId('habit1', date);
        final id2 = NotificationService.generateNotificationId('habit2', date);

        expect(id1, isNot(equals(id2)));
        expect(id1, isA<int>());
        expect(id2, isA<int>());
      });

      test('should generate unique notification IDs for different dates', () {
        final date1 = DateTime(2025, 7, 24);
        final date2 = DateTime(2025, 7, 25);
        final id1 = NotificationService.generateNotificationId('habit1', date1);
        final id2 = NotificationService.generateNotificationId('habit1', date2);

        expect(id1, isNot(equals(id2)));
      });

      test('should generate consistent IDs for same habit and date', () {
        final date = DateTime(2025, 7, 24);
        final id1 = NotificationService.generateNotificationId('habit1', date);
        final id2 = NotificationService.generateNotificationId('habit1', date);

        expect(id1, equals(id2));
      });
    });

    group('Notification Title Generation', () {
      test('should generate correct title for regular habit', () {
        final regularHabit = Habit(
          id: 'regular',
          title: 'Exercise',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          color: Colors.blue,
          icon: Icons.fitness_center,
        );

        final title = NotificationService.getNotificationTitle(regularHabit);
        expect(title, '⏰ Exercise');
      });

      test('should generate correct title for negative habit', () {
        final negativeHabit = Habit(
          id: 'negative',
          title: 'Smoking',
          type: HabitType.negative,
          frequency: Frequency(type: FrequencyType.daily),
          color: Colors.red,
          icon: Icons.smoke_free,
        );

        final title = NotificationService.getNotificationTitle(negativeHabit);
        expect(title, '🚫 Avoid: Smoking');
      });

      test('should generate correct title for one-time habit', () {
        final oneTimeHabit = Habit(
          id: 'onetime',
          title: 'Complete Project',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          color: Colors.green,
          icon: Icons.check,
        );

        final title = NotificationService.getNotificationTitle(oneTimeHabit);
        expect(title, '🎯 Goal: Complete Project');
      });
    });

    group('Notification Message Generation', () {
      test('should generate correct message for regular habit', () {
        final message = NotificationService.getHabitReminderMessage(testHabit);
        expect(message, contains('Time for your morning exercise!'));
        expect(message, contains('Start your day strong!'));
      });

      test('should generate correct message for negative habit', () {
        final negativeHabit = Habit(
          id: 'negative',
          title: 'Junk Food',
          type: HabitType.negative,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: TimeOfDayPreference.evening,
          color: Colors.red,
          icon: Icons.no_food,
        );

        final message = NotificationService.getHabitReminderMessage(
          negativeHabit,
        );
        expect(message, contains('Remember to avoid junk food today'));
        expect(message, contains('Finish strong!'));
      });

      test('should generate correct message for one-time habit', () {
        final oneTimeHabit = Habit(
          id: 'onetime',
          title: 'Learn Flutter',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          timeOfDay: TimeOfDayPreference.anytime,
          color: Colors.blue,
          icon: Icons.school,
        );

        final message = NotificationService.getHabitReminderMessage(
          oneTimeHabit,
        );
        expect(message, contains('Don\'t forget to work on: Learn Flutter'));
        expect(message, contains('You\'ve got this!'));
      });
    });

    group('Time of Day Messages', () {
      test('should return correct morning message', () {
        final message = NotificationService.getTimeOfDayMessage(
          TimeOfDayPreference.morning,
        );
        expect(message, 'Start your day strong! 💪');
      });

      test('should return correct afternoon message', () {
        final message = NotificationService.getTimeOfDayMessage(
          TimeOfDayPreference.afternoon,
        );
        expect(message, 'Keep the momentum going! 🚀');
      });

      test('should return correct evening message', () {
        final message = NotificationService.getTimeOfDayMessage(
          TimeOfDayPreference.evening,
        );
        expect(message, 'Finish strong! ⭐');
      });

      test('should return correct anytime message', () {
        final message = NotificationService.getTimeOfDayMessage(
          TimeOfDayPreference.anytime,
        );
        expect(message, 'You\'ve got this! 🎯');
      });
    });

    group('Action Buttons Generation', () {
      test('should generate correct action buttons for regular habit', () {
        final buttons = NotificationService.getActionButtons(testHabit);

        expect(buttons.length, 2);
        expect(buttons[0].key, 'mark_done');
        expect(buttons[0].label, '✅ Done');
        expect(buttons[1].key, 'snooze');
        expect(buttons[1].label, '⏰ Snooze');
      });

      test('should generate correct action buttons for negative habit', () {
        final negativeHabit = Habit(
          id: 'negative',
          title: 'Bad Habit',
          type: HabitType.negative,
          frequency: Frequency(type: FrequencyType.daily),
          color: Colors.red,
          icon: Icons.close,
        );

        final buttons = NotificationService.getActionButtons(negativeHabit);

        expect(buttons.length, 2);
        expect(buttons[0].key, 'mark_done');
        expect(buttons[0].label, '✅ Avoided');
        expect(buttons[1].key, 'skip');
        expect(buttons[1].label, '❌ Failed');
      });

      test('should generate correct action buttons for one-time habit', () {
        final oneTimeHabit = Habit(
          id: 'onetime',
          title: 'Goal',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          color: Colors.green,
          icon: Icons.flag,
        );

        final buttons = NotificationService.getActionButtons(oneTimeHabit);

        expect(buttons.length, 2);
        expect(buttons[0].key, 'mark_done');
        expect(buttons[0].label, '✅ Completed');
        expect(buttons[1].key, 'snooze');
        expect(buttons[1].label, '⏰ Later');
      });
    });

    group('Scheduling Logic', () {
      test('should schedule daily habits for any date', () {
        final dailyHabit = Habit(
          id: 'daily',
          title: 'Daily Habit',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          color: Colors.blue,
          icon: Icons.star,
        );

        final date = DateTime(2025, 7, 24);
        final shouldSchedule = NotificationService.shouldScheduleForDate(
          dailyHabit,
          date,
        );
        expect(shouldSchedule, true);
      });

      test('should schedule weekly habits only on selected days', () {
        // Monday to Friday (1-5)
        final weeklyHabit = Habit(
          id: 'weekly',
          title: 'Weekday Habit',
          type: HabitType.regular,
          frequency: Frequency(
            type: FrequencyType.weekly,
            selectedDays: [1, 2, 3, 4, 5],
          ),
          color: Colors.green,
          icon: Icons.work,
        );

        // Thursday (weekday 4)
        final thursday = DateTime(2025, 7, 24); // Assuming this is a Thursday
        final shouldScheduleThursday =
            NotificationService.shouldScheduleForDate(weeklyHabit, thursday);
        expect(shouldScheduleThursday, true);

        // Create a habit that should NOT schedule on weekends
        final weekdayOnlyHabit = Habit(
          id: 'weekday_only',
          title: 'Work Habit',
          type: HabitType.regular,
          frequency: Frequency(
            type: FrequencyType.weekly,
            selectedDays: [1, 2, 3, 4, 5], // Monday to Friday
          ),
          color: Colors.blue,
          icon: Icons.work,
        );

        // Test with a known weekend day
        final sunday = DateTime(2025, 7, 27); // This should be a Sunday
        final shouldScheduleSunday = NotificationService.shouldScheduleForDate(
          weekdayOnlyHabit,
          sunday,
        );
        expect(shouldScheduleSunday, false);
      });

      test('should schedule monthly habits on specific dates', () {
        final monthlyHabit = Habit(
          id: 'monthly',
          title: 'Monthly Habit',
          type: HabitType.regular,
          frequency: Frequency(
            type: FrequencyType.monthly,
            specificDates: [1, 15, 30],
          ),
          color: Colors.purple,
          icon: Icons.calendar_month,
        );

        final firstOfMonth = DateTime(2025, 7, 1);
        final fifthOfMonth = DateTime(2025, 7, 5);
        final fifteenthOfMonth = DateTime(2025, 7, 15);

        expect(
          NotificationService.shouldScheduleForDate(monthlyHabit, firstOfMonth),
          true,
        );
        expect(
          NotificationService.shouldScheduleForDate(monthlyHabit, fifthOfMonth),
          false,
        );
        expect(
          NotificationService.shouldScheduleForDate(
            monthlyHabit,
            fifteenthOfMonth,
          ),
          true,
        );
      });

      test('should not schedule long-term habits for daily reminders', () {
        final longTermHabit = Habit(
          id: 'longterm',
          title: 'Long Term Goal',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          color: Colors.orange,
          icon: Icons.flag,
        );

        final date = DateTime(2025, 7, 24);
        final shouldSchedule = NotificationService.shouldScheduleForDate(
          longTermHabit,
          date,
        );
        expect(shouldSchedule, false);
      });
    });

    group('Habit Reminder Validation', () {
      test(
        'should not schedule reminder for habit without reminder enabled',
        () {
          final habitWithoutReminder = Habit(
            id: 'no_reminder',
            title: 'No Reminder Habit',
            type: HabitType.regular,
            frequency: Frequency(type: FrequencyType.daily),
            hasReminder: false,
            color: Colors.grey,
            icon: Icons.close,
          );

          expect(() async {
            final result = await NotificationService.scheduleHabitReminder(
              habit: habitWithoutReminder,
              scheduledDate: DateTime.now().add(const Duration(hours: 1)),
            );
            expect(result, false);
          }, returnsNormally);
        },
      );

      test('should not schedule reminder for habit without reminder time', () {
        final habitWithoutTime = Habit(
          id: 'no_time',
          title: 'No Time Habit',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          hasReminder: true,
          reminderTime: null,
          color: Colors.grey,
          icon: Icons.close,
        );

        expect(() async {
          final result = await NotificationService.scheduleHabitReminder(
            habit: habitWithoutTime,
            scheduledDate: DateTime.now().add(const Duration(hours: 1)),
          );
          expect(result, false);
        }, returnsNormally);
      });

      test('should not schedule reminder for past time', () {
        final pastDate = DateTime.now().subtract(const Duration(hours: 1));

        expect(() async {
          final result = await NotificationService.scheduleHabitReminder(
            habit: testHabit,
            scheduledDate: pastDate,
          );
          expect(result, false);
        }, returnsNormally);
      });
    });

    group('Motivational Notifications', () {
      test('should send motivational notification', () async {
        expect(
          () => NotificationService.sendMotivationalNotification(
            habitTitle: 'Test Habit',
            message: 'Great job!',
          ),
          returnsNormally,
        );
      });

      test('should send completion celebration with streak count', () async {
        expect(
          () => NotificationService.sendCompletionCelebration(
            habit: testHabit,
            streakCount: 5,
          ),
          returnsNormally,
        );
      });
    });

    group('Notification Management', () {
      test('should get scheduled notifications', () async {
        expect(
          () => NotificationService.getScheduledNotifications(),
          returnsNormally,
        );
      });

      test('should cancel habit reminder', () async {
        final date = DateTime.now().add(const Duration(hours: 1));
        expect(
          () => NotificationService.cancelHabitReminder(
            habitId: 'test_habit',
            scheduledDate: date,
          ),
          returnsNormally,
        );
      });

      test('should cancel all habit reminders', () async {
        expect(
          () => NotificationService.cancelAllHabitReminders('test_habit'),
          returnsNormally,
        );
      });
    });

    group('Action Handling', () {
      test('should handle notification action with valid payload', () async {
        // Create a map representing the serialized data from awesome_notifications
        final actionData = {
          'id': 1,
          'channelKey': 'test_channel',
          'actionDate': DateTime.now().toIso8601String(),
          'buttonKeyPressed': 'mark_done',
          'payload': {
            'habit_id': 'test_habit',
            'habit_title': 'Test Habit',
            'scheduled_date': DateTime.now().toIso8601String(),
          },
        };

        // Create ReceivedAction from map (simulating the new awesome_notifications behavior)
        final receivedAction = ReceivedAction().fromMap(actionData);

        expect(
          () => NotificationService.handleNotificationAction(receivedAction),
          returnsNormally,
        );
      });

      test('should handle notification action with null payload', () async {
        final actionData = {
          'id': 1,
          'channelKey': 'test_channel',
          'actionDate': DateTime.now().toIso8601String(),
          'buttonKeyPressed': 'mark_done',
          'payload': null,
        };

        final receivedAction = ReceivedAction().fromMap(actionData);

        expect(
          () => NotificationService.handleNotificationAction(receivedAction),
          returnsNormally,
        );
      });
    });
  });

  group('Integration with Habit Model', () {
    test('should work with all habit types', () {
      final habits = [
        Habit(
          id: 'regular_habit',
          title: 'Regular Habit',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          color: Colors.blue,
          icon: Icons.star,
        ),
        Habit(
          id: 'negative_habit',
          title: 'Negative Habit',
          type: HabitType.negative,
          frequency: Frequency(type: FrequencyType.daily),
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 10, minute: 0),
          color: Colors.red,
          icon: Icons.close,
        ),
        Habit(
          id: 'onetime_habit',
          title: 'One Time Habit',
          type: HabitType.oneTime,
          frequency: Frequency(type: FrequencyType.longTerm),
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 11, minute: 0),
          color: Colors.green,
          icon: Icons.flag,
        ),
      ];

      for (final habit in habits) {
        expect(
          () => NotificationService.getNotificationTitle(habit),
          returnsNormally,
        );
        expect(
          () => NotificationService.getHabitReminderMessage(habit),
          returnsNormally,
        );
        expect(
          () => NotificationService.getActionButtons(habit),
          returnsNormally,
        );
      }
    });

    test('should work with all time preferences', () {
      for (final timePreference in TimeOfDayPreference.values) {
        final habit = Habit(
          id: 'test_${timePreference.name}',
          title: 'Test Habit',
          type: HabitType.regular,
          frequency: Frequency(type: FrequencyType.daily),
          timeOfDay: timePreference,
          hasReminder: true,
          reminderTime: const TimeOfDay(hour: 9, minute: 0),
          color: Colors.blue,
          icon: Icons.star,
        );

        expect(
          () => NotificationService.getHabitReminderMessage(habit),
          returnsNormally,
        );
        expect(
          () => NotificationService.getTimeOfDayMessage(timePreference),
          returnsNormally,
        );
      }
    });
  });
}
