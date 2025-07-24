import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/controllers/ui_controller.dart';
import 'package:streakly/pages/add_habit_page.dart';
import 'package:streakly/widgets/habit_card.dart';
import 'package:streakly/types/habit_type.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitState = ref.watch(habitControllerProvider);
    final todaysHabits = ref.watch(todaysHabitsProvider);
    final uiState = ref.watch(uiControllerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: const Text(
          'Today\'s Habits',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                ref.read(habitControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: habitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : habitState.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${habitState.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.read(habitControllerProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : todaysHabits.isEmpty
          ? _buildEmptyState(context, ref)
          : _buildHabitsList(todaysHabits, ref),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddHabit(context),
        backgroundColor: const Color(0xFF4F46E5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNavigation(context, ref, uiState),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.track_changes, size: 80, color: Colors.grey[600]),
          const SizedBox(height: 16),
          Text(
            'No habits for today',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first habit to get started',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddHabit(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Habit'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitsList(List habits, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          final habit = habits[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: HabitCard(
              habit: habit,
              onTap: () => _showHabitDetails(context, ref, habit.id),
              onComplete: () => ref
                  .read(habitControllerProvider.notifier)
                  .completeHabit(habit.id),
              onUncomplete: () => ref
                  .read(habitControllerProvider.notifier)
                  .uncompleteHabit(habit.id),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    WidgetRef ref,
    UIState uiState,
  ) {
    return BottomNavigationBar(
      currentIndex: uiState.currentTabIndex,
      onTap: (index) =>
          ref.read(uiControllerProvider.notifier).changeTab(index),
      backgroundColor: const Color(0xFF2A2A2A),
      selectedItemColor: const Color(0xFF4F46E5),
      unselectedItemColor: Colors.grey[600],
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Today'),
        BottomNavigationBarItem(icon: Icon(Icons.list), label: 'All Habits'),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'Statistics',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }

  void _navigateToAddHabit(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddHabitPage()));
  }

  void _showHabitDetails(BuildContext context, WidgetRef ref, String habitId) {
    final habit = ref.read(habitControllerProvider).getHabitById(habitId);
    if (habit == null) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildHabitDetailsSheet(context, ref, habit),
    );
  }

  Widget _buildHabitDetailsSheet(BuildContext context, WidgetRef ref, habit) {
    final habitState = ref.watch(habitControllerProvider);
    final streakCount = habitState.getStreakCount(habit.id);
    final isCompleted = habitState.isHabitCompletedToday(habit.id);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Habit title and icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(habit.icon, color: habit.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getHabitTypeText(habit.type),
                        style: TextStyle(color: Colors.grey[400], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Streak info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '$streakCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Day Streak',
                    style: TextStyle(color: Colors.grey[400], fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isCompleted
                        ? () {
                            ref
                                .read(habitControllerProvider.notifier)
                                .uncompleteHabit(habit.id);
                            Navigator.of(context).pop();
                          }
                        : () {
                            ref
                                .read(habitControllerProvider.notifier)
                                .completeHabit(habit.id);
                            Navigator.of(context).pop();
                          },
                    icon: Icon(isCompleted ? Icons.undo : Icons.check),
                    label: Text(isCompleted ? 'Undo' : 'Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCompleted
                          ? Colors.orange
                          : const Color(0xFF4F46E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _navigateToEditHabit(context, habit);
                    },
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.grey),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getHabitTypeText(HabitType type) {
    switch (type) {
      case HabitType.regular:
        return 'Regular habit';
      case HabitType.negative:
        return 'Avoid habit';
      case HabitType.oneTime:
        return 'One-time goal';
    }
  }

  void _navigateToEditHabit(BuildContext context, habit) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddHabitPage(editingHabit: habit),
      ),
    );
  }
}
