import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/services/notification_service.dart';
import 'package:streakly/pages/home_page.dart';
import 'package:streakly/utils/habit_data_migration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run data migration for existing habits
  await HabitDataMigration.migrateIfNeeded();

  // Initialize notification services
  await NotificationService.initialize();
  await NotificationManager.initialize();
  await NotificationManager.setupIsolateListener();

  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Streakly - Habit Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
