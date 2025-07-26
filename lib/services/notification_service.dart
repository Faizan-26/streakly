import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/services/local_storage.dart';
import 'dart:isolate';
import 'dart:ui';
import 'dart:convert';

/// Helper class to manage notification initialization and action handling
class NotificationManager {
  static ReceivePort? _receivePort;
  static bool _isInitialized = false;

  /// Initialize the notification manager with proper listeners
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // Set up listeners for notification actions
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );

    _isInitialized = true;
  }

  /// Handle notification actions (new serialized data format)
  @pragma("vm:entry-point")
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle the action using the NotificationService
    await NotificationService.handleNotificationAction(receivedAction);
  }

  /// Handle notification creation
  @pragma("vm:entry-point")
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Handle notification creation logic here if needed
    debugPrint('Notification created: ${receivedNotification.id}');
  }

  /// Handle notification display
  @pragma("vm:entry-point")
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    // Handle notification display logic here if needed
    debugPrint('Notification displayed: ${receivedNotification.id}');
  }

  /// Handle notification dismissal
  @pragma("vm:entry-point")
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    // Handle notification dismissal logic here if needed
    debugPrint('Notification dismissed: ${receivedAction.id}');
  }

  /// Setup isolate communication for background notifications
  static Future<void> setupIsolateListener() async {
    _receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      _receivePort!.sendPort,
      'notification_action_port',
    );

    // Listen for serialized data (new format requirement)
    _receivePort!.listen((serializedData) {
      try {
        final receivedAction = ReceivedAction().fromMap(
          serializedData as Map<String, dynamic>,
        );
        _onActionReceivedMethod(receivedAction);
      } catch (e) {
        debugPrint('Error parsing notification action: $e');
      }
    });
  }

  /// Send action to isolate (new serialized format)
  static void sendActionToIsolate(ReceivedAction receivedAction) {
    SendPort? sendPort = IsolateNameServer.lookupPortByName(
      'notification_action_port',
    );

    if (sendPort != null) {
      // Convert to serialized data (new requirement)
      dynamic serializedData = receivedAction.toMap();
      sendPort.send(serializedData);
    }
  }

  /// Clean up resources
  static void dispose() {
    _receivePort?.close();
    IsolateNameServer.removePortNameMapping('notification_action_port');
    _isInitialized = false;
  }
}

class NotificationService {
  static const String _habitChannelKey = 'habit_reminders';
  static const String _habitChannelName = 'Habit Reminders';
  static const String _habitChannelDescription =
      'Notifications for habit reminders and tracking';

  /// Initialize the notification service
  static Future<void> initialize() async {
    await AwesomeNotifications().initialize(
      // Use your app icon here - for now using default
      null,
      [
        NotificationChannel(
          channelKey: _habitChannelKey,
          channelName: _habitChannelName,
          channelDescription: _habitChannelDescription,
          defaultColor: const Color(0xFF6366F1),
          ledColor: Colors.white,
          importance: NotificationImportance.High,
          channelShowBadge: true,
          onlyAlertOnce: true,
          playSound: true,
          criticalAlerts: false,
        ),
      ],
      // Channel groups
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'habit_group',
          channelGroupName: 'Habit Notifications',
        ),
      ],
      debug: true,
    );
  }

  /// Request notification permissions
  static Future<bool> requestPermissions() async {
    return await AwesomeNotifications().isNotificationAllowed().then((
      isAllowed,
    ) async {
      if (!isAllowed) {
        return await AwesomeNotifications()
            .requestPermissionToSendNotifications();
      }
      return true;
    });
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  /// Schedule a habit reminder notification
  static Future<bool> scheduleHabitReminder({
    required Habit habit,
    required DateTime scheduledDate,
    String? customMessage,
  }) async {
    if (!habit.hasReminder || habit.reminderTime == null) {
      return false;
    }

    final reminderDateTime = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      habit.reminderTime!.hour,
      habit.reminderTime!.minute,
    );

    // Don't schedule notifications for past times
    if (reminderDateTime.isBefore(DateTime.now())) {
      return false;
    }

    final notificationId = _generateNotificationId(habit.id, scheduledDate);

    final message = customMessage ?? _getHabitReminderMessage(habit);
    final actionButtons = _getActionButtons(habit);

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _habitChannelKey,
        groupKey: 'habit_group',
        title: _getNotificationTitle(habit),
        body: message,
        bigPicture: null, // You can add habit icons here
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        autoDismissible: false,
        backgroundColor: habit.color,
        payload: {
          'habit_id': habit.id,
          'habit_title': habit.title,
          'habit_type': habit.type.name,
          'scheduled_date': scheduledDate.toIso8601String(),
        },
      ),
      schedule: NotificationCalendar(
        year: reminderDateTime.year,
        month: reminderDateTime.month,
        day: reminderDateTime.day,
        hour: reminderDateTime.hour,
        minute: reminderDateTime.minute,
        second: 0,
        millisecond: 0,
        repeats: false,
      ),
      actionButtons: actionButtons,
    );
  }

  /// Schedule a daily reminder notification (for start/end of day)
  static Future<bool> scheduleDailyReminder({
    required String id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required String type,
  }) async {
    final notificationId = id.hashCode;

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _habitChannelKey,
        groupKey: 'daily_reminders',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
        category: NotificationCategory.Reminder,
        wakeUpScreen: true,
        fullScreenIntent: false,
        autoDismissible: true,
        backgroundColor: const Color(0xFF6366F1),
        payload: {'reminder_id': id, 'reminder_type': type},
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true, // Repeat daily
      ),
    );
  }

  /// Schedule recurring habit reminders for a week
  static Future<void> scheduleWeeklyHabitReminders(Habit habit) async {
    if (!habit.hasReminder || habit.reminderTime == null) {
      return;
    }

    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final targetDate = now.add(Duration(days: i));

      // Check if habit should be scheduled for this day based on frequency
      if (_shouldScheduleForDate(habit, targetDate)) {
        await scheduleHabitReminder(habit: habit, scheduledDate: targetDate);
      }
    }
  }

  /// Cancel a specific habit reminder
  static Future<void> cancelHabitReminder({
    required String habitId,
    required DateTime scheduledDate,
  }) async {
    final notificationId = _generateNotificationId(habitId, scheduledDate);
    await AwesomeNotifications().cancel(notificationId);
  }

  /// Cancel all notifications for a specific habit
  static Future<void> cancelAllHabitReminders(String habitId) async {
    final scheduledNotifications = await AwesomeNotifications()
        .listScheduledNotifications();

    for (final notification in scheduledNotifications) {
      final payload = notification.content?.payload;
      if (payload != null && payload['habit_id'] == habitId) {
        await AwesomeNotifications().cancel(notification.content!.id!);
      }
    }
  }

  /// Send an immediate motivational notification
  static Future<bool> sendMotivationalNotification({
    required String habitTitle,
    required String message,
    Color? backgroundColor,
  }) async {
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    return await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: _habitChannelKey,
        title: '🎉 Great job!',
        body: message,
        category: NotificationCategory.Message,
        notificationLayout: NotificationLayout.Default,
        backgroundColor: backgroundColor ?? const Color(0xFF4CAF50),
        payload: {'type': 'motivational', 'habit_title': habitTitle},
      ),
    );
  }

  /// Send habit completion celebration
  static Future<bool> sendCompletionCelebration({
    required Habit habit,
    required int streakCount,
  }) async {
    final messages = [
      '🔥 $streakCount day streak! Keep it up!',
      '⭐ Amazing! You\'re on a $streakCount day streak!',
      '🚀 $streakCount days strong! You\'re unstoppable!',
      '💪 Fantastic! $streakCount consecutive days!',
    ];

    final message = messages[streakCount % messages.length];

    return await sendMotivationalNotification(
      habitTitle: habit.title,
      message: message,
      backgroundColor: habit.color,
    );
  }

  /// Get all scheduled notifications
  static Future<List<NotificationModel>> getScheduledNotifications() async {
    return await AwesomeNotifications().listScheduledNotifications();
  }

  /// Handle notification action buttons
  static Future<void> handleNotificationAction(
    ReceivedAction receivedAction,
  ) async {
    final payload = receivedAction.payload;
    if (payload == null) return;

    final habitId = payload['habit_id'];
    final actionKey = receivedAction.buttonKeyPressed;

    if (habitId != null) {
      switch (actionKey) {
        case 'mark_done':
          // Handle marking habit as done
          await _handleMarkHabitDone(habitId, payload);
          break;
        case 'skip':
          // Handle skipping habit
          await _handleSkipHabit(habitId, payload);
          break;
        case 'snooze':
          // Handle snoozing habit
          await _handleSnoozeHabit(habitId, payload);
          break;
      }
    }
  }

  /// Check if habit should be scheduled for a specific date (public method)
  static bool isHabitDueOnDate(Habit habit, DateTime date) {
    return _shouldScheduleForDate(habit, date);
  }

  /// Generate unique notification ID
  @visibleForTesting
  static int generateNotificationId(String habitId, DateTime date) {
    return _generateNotificationId(habitId, date);
  }

  /// Get notification title based on habit type
  @visibleForTesting
  static String getNotificationTitle(Habit habit) {
    return _getNotificationTitle(habit);
  }

  /// Get habit reminder message
  @visibleForTesting
  static String getHabitReminderMessage(Habit habit) {
    return _getHabitReminderMessage(habit);
  }

  /// Get time of day motivational message
  @visibleForTesting
  static String getTimeOfDayMessage(TimeOfDayPreference timeOfDay) {
    return _getTimeOfDayMessage(timeOfDay);
  }

  /// Get action buttons for notification
  @visibleForTesting
  static List<NotificationActionButton> getActionButtons(Habit habit) {
    return _getActionButtons(habit);
  }

  /// Check if habit should be scheduled for a specific date
  @visibleForTesting
  static bool shouldScheduleForDate(Habit habit, DateTime date) {
    return _shouldScheduleForDate(habit, date);
  }

  /// Generate unique notification ID
  static int _generateNotificationId(String habitId, DateTime date) {
    // Create a unique ID based on habit ID and date
    final dateString =
        '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
    return int.parse(
      '${habitId.hashCode.abs().toString().substring(0, 4)}${dateString.substring(4)}',
    );
  }

  /// Get notification title based on habit type
  static String _getNotificationTitle(Habit habit) {
    switch (habit.type) {
      case HabitType.regular:
        return '⏰ ${habit.title}';
      case HabitType.negative:
        return '🚫 Avoid: ${habit.title}';
      case HabitType.oneTime:
        return '🎯 Goal: ${habit.title}';
    }
  }

  /// Get habit reminder message
  static String _getHabitReminderMessage(Habit habit) {
    final timeOfDayMessage = habit.timeOfDay != null
        ? _getTimeOfDayMessage(habit.timeOfDay!)
        : '';

    switch (habit.type) {
      case HabitType.regular:
        return 'Time for your ${habit.title.toLowerCase()}! $timeOfDayMessage';
      case HabitType.negative:
        return 'Remember to avoid ${habit.title.toLowerCase()} today. $timeOfDayMessage';
      case HabitType.oneTime:
        return 'Don\'t forget to work on: ${habit.title}. $timeOfDayMessage';
    }
  }

  /// Get time of day motivational message
  static String _getTimeOfDayMessage(TimeOfDayPreference timeOfDay) {
    switch (timeOfDay) {
      case TimeOfDayPreference.morning:
        return 'Start your day strong! 💪';
      case TimeOfDayPreference.afternoon:
        return 'Keep the momentum going! 🚀';
      case TimeOfDayPreference.evening:
        return 'Finish strong! ⭐';
      case TimeOfDayPreference.anytime:
        return 'You\'ve got this! 🎯';
    }
  }

  /// Get action buttons for notification
  static List<NotificationActionButton> _getActionButtons(Habit habit) {
    switch (habit.type) {
      case HabitType.regular:
        return [
          NotificationActionButton(
            key: 'mark_done',
            label: '✅ Done',
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'snooze',
            label: '⏰ Snooze',
            autoDismissible: false,
          ),
        ];
      case HabitType.negative:
        return [
          NotificationActionButton(
            key: 'mark_done',
            label: '✅ Avoided',
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'skip',
            label: '❌ Failed',
            autoDismissible: true,
          ),
        ];
      case HabitType.oneTime:
        return [
          NotificationActionButton(
            key: 'mark_done',
            label: '✅ Completed',
            autoDismissible: true,
          ),
          NotificationActionButton(
            key: 'snooze',
            label: '⏰ Later',
            autoDismissible: false,
          ),
        ];
    }
  }

  /// Check if habit should be scheduled for a specific date
  static bool _shouldScheduleForDate(Habit habit, DateTime date) {
    switch (habit.frequency.type) {
      case FrequencyType.daily:
        return true;
      case FrequencyType.weekly:
        if (habit.frequency.selectedDays != null) {
          return habit.frequency.selectedDays!.contains(date.weekday % 7);
        }
        return true;
      case FrequencyType.monthly:
        if (habit.frequency.specificDates != null) {
          return habit.frequency.specificDates!.contains(date.day);
        }
        return date.day == 1; // Default to first of month
      case FrequencyType.yearly:
        return date.day == 1 && date.month == 1; // Default to New Year
      case FrequencyType.longTerm:
        return false; // Long-term goals don't need daily reminders
    }
  }

  /// Handle marking habit as done
  static Future<void> _handleMarkHabitDone(
    String habitId,
    Map<String, String?> payload,
  ) async {
    // This would typically update your habit progress
    // You can integrate this with your habit tracking logic
    print('Habit $habitId marked as done');

    // Optionally send a celebration notification
    // await sendMotivationalNotification(
    //   habitTitle: payload['habit_title'] ?? 'Habit',
    //   message: 'Great job! Keep up the good work! 🎉',
    // );
  }

  /// Handle skipping habit
  static Future<void> _handleSkipHabit(
    String habitId,
    Map<String, String?> payload,
  ) async {
    print('Habit $habitId skipped');
    // Handle skip logic here
  }

  /// Handle snoozing habit
  static Future<void> _handleSnoozeHabit(
    String habitId,
    Map<String, String?> payload,
  ) async {
    print('Habit $habitId snoozed');

    // Reschedule for 15 minutes later
    if (payload['scheduled_date'] != null) {
      final snoozeDate = DateTime.now().add(const Duration(minutes: 15));

      // You would need to get the habit object to reschedule
      // This is a simplified example
      print('Rescheduling for ${snoozeDate.toString()}');
    }
  }

  // MARK: - Notification Settings Management

  /// Save daily notification settings to local storage
  static Future<void> saveDailyNotificationSettings({
    required bool startOfDayEnabled,
    required bool endOfDayEnabled,
    required int wakeUpHour,
    required int wakeUpMinute,
    required int sleepHour,
    required int sleepMinute,
  }) async {
    final settings = {
      'startOfDayEnabled': startOfDayEnabled,
      'endOfDayEnabled': endOfDayEnabled,
      'wakeUpHour': wakeUpHour,
      'wakeUpMinute': wakeUpMinute,
      'sleepHour': sleepHour,
      'sleepMinute': sleepMinute,
      'lastUpdated': DateTime.now().toIso8601String(),
    };

    await LocalStorage.saveData(
      'daily_notification_settings',
      json.encode(settings),
    );
  }

  /// Load daily notification settings from local storage
  static Future<Map<String, dynamic>?> loadDailyNotificationSettings() async {
    final settingsJson = await LocalStorage.loadData(
      'daily_notification_settings',
    );
    if (settingsJson != null) {
      return json.decode(settingsJson as String);
    }
    return null;
  }

  /// Update the enabled/disabled state of start of day notification
  static Future<void> updateStartOfDayNotification(bool enabled) async {
    final settings = await loadDailyNotificationSettings();
    if (settings != null) {
      settings['startOfDayEnabled'] = enabled;
      await LocalStorage.saveData(
        'daily_notification_settings',
        json.encode(settings),
      );

      if (enabled) {
        // Re-schedule the notification
        await scheduleDailyReminder(
          id: 'daily_start',
          title: '🌅 Good Morning!',
          body:
              'Ready to start your day? Check your habits and make today count!',
          hour: settings['wakeUpHour'],
          minute: settings['wakeUpMinute'],
          type: 'start_of_day',
        );
      } else {
        // Cancel the notification
        await cancelDailyReminder('daily_start');
      }
    }
  }

  /// Update the enabled/disabled state of end of day notification
  static Future<void> updateEndOfDayNotification(bool enabled) async {
    final settings = await loadDailyNotificationSettings();
    if (settings != null) {
      settings['endOfDayEnabled'] = enabled;
      await LocalStorage.saveData(
        'daily_notification_settings',
        json.encode(settings),
      );

      if (enabled) {
        // Re-schedule the notification
        await scheduleDailyReminder(
          id: 'daily_end',
          title: '🌙 Day Review',
          body:
              'How did you do today? Mark your completed habits and prepare for tomorrow!',
          hour: settings['sleepHour'],
          minute: settings['sleepMinute'],
          type: 'end_of_day',
        );
      } else {
        // Cancel the notification
        await cancelDailyReminder('daily_end');
      }
    }
  }

  /// Update wake up time and reschedule start of day notification if enabled
  static Future<void> updateWakeUpTime(int hour, int minute) async {
    final settings = await loadDailyNotificationSettings();
    if (settings != null) {
      settings['wakeUpHour'] = hour;
      settings['wakeUpMinute'] = minute;
      settings['lastUpdated'] = DateTime.now().toIso8601String();
      await LocalStorage.saveData(
        'daily_notification_settings',
        json.encode(settings),
      );

      // Reschedule if enabled
      if (settings['startOfDayEnabled'] == true) {
        await scheduleDailyReminder(
          id: 'daily_start',
          title: '🌅 Good Morning!',
          body:
              'Ready to start your day? Check your habits and make today count!',
          hour: hour,
          minute: minute,
          type: 'start_of_day',
        );
      }
    }
  }

  /// Update sleep time and reschedule end of day notification if enabled
  static Future<void> updateSleepTime(int hour, int minute) async {
    final settings = await loadDailyNotificationSettings();
    if (settings != null) {
      settings['sleepHour'] = hour;
      settings['sleepMinute'] = minute;
      settings['lastUpdated'] = DateTime.now().toIso8601String();
      await LocalStorage.saveData(
        'daily_notification_settings',
        json.encode(settings),
      );

      // Reschedule if enabled
      if (settings['endOfDayEnabled'] == true) {
        await scheduleDailyReminder(
          id: 'daily_end',
          title: '🌙 Day Review',
          body:
              'How did you do today? Mark your completed habits and prepare for tomorrow!',
          hour: hour,
          minute: minute,
          type: 'end_of_day',
        );
      }
    }
  }

  /// Cancel a daily reminder notification
  static Future<void> cancelDailyReminder(String id) async {
    final notificationId = id.hashCode;
    await AwesomeNotifications().cancel(notificationId);
  }

  /// Get current notification settings for settings UI
  static Future<Map<String, dynamic>> getNotificationSettingsForUI() async {
    final settings = await loadDailyNotificationSettings();
    if (settings != null) {
      return {
        'startOfDayEnabled': settings['startOfDayEnabled'] ?? true,
        'endOfDayEnabled': settings['endOfDayEnabled'] ?? true,
        'wakeUpHour': settings['wakeUpHour'] ?? 8,
        'wakeUpMinute': settings['wakeUpMinute'] ?? 0,
        'sleepHour': settings['sleepHour'] ?? 23,
        'sleepMinute': settings['sleepMinute'] ?? 0,
      };
    }
    return {
      'startOfDayEnabled': true,
      'endOfDayEnabled': true,
      'wakeUpHour': 8,
      'wakeUpMinute': 0,
      'sleepHour': 23,
      'sleepMinute': 0,
    };
  }
}
