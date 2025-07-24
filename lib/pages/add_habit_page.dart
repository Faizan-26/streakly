import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/habit_controller.dart';
import 'package:streakly/controllers/ui_controller.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  final Habit? editingHabit;

  const AddHabitPage({super.key, this.editingHabit});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  late TextEditingController _titleController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.editingHabit != null;
    _titleController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isEditing) {
        ref
            .read(habitFormControllerProvider.notifier)
            .initializeWithHabit(widget.editingHabit!);
        _titleController.text = widget.editingHabit!.title;
      } else {
        ref.read(habitFormControllerProvider.notifier).reset();
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(habitFormControllerProvider);
    final formController = ref.read(habitFormControllerProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          _isEditing ? 'Edit Habit' : 'Create Habit',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isEditing)
            IconButton(
              onPressed: () => _showDeleteDialog(context),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title input
            _buildSectionTitle('Habit Name'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              onChanged: (value) => formController.updateTitle(value),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter habit name',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),

            const SizedBox(height: 24),

            // Habit type selection
            _buildSectionTitle('Habit Type'),
            const SizedBox(height: 8),
            _buildHabitTypeSelector(formState, formController),

            const SizedBox(height: 24),

            // Icon and color selection
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Icon'),
                      const SizedBox(height: 8),
                      _buildIconSelector(formState, formController),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Color'),
                      const SizedBox(height: 8),
                      _buildColorSelector(formState, formController),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Frequency selection
            _buildSectionTitle('Repeat'),
            const SizedBox(height: 8),
            _buildFrequencySelector(formState, formController),

            const SizedBox(height: 24),

            // Time of day selection
            _buildSectionTitle('Time of Day'),
            const SizedBox(height: 8),
            _buildTimeOfDaySelector(formState, formController),

            const SizedBox(height: 24),

            // Reminder toggle
            _buildReminderSection(formState, formController),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Color(0xFF2A2A2A),
          border: Border(top: BorderSide(color: Color(0xFF3A3A3A))),
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: formState.isValid ? () => _saveHabit(context) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isEditing ? 'Update Habit' : 'Create Habit',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildHabitTypeSelector(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    return Row(
      children: HabitType.values.map((type) {
        final isSelected = formState.habitType == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => formController.updateHabitType(type),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF2A2A2A),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4F46E5)
                        : Colors.transparent,
                  ),
                ),
                child: Text(
                  _getHabitTypeText(type),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[400],
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIconSelector(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    final icons = [
      Icons.fitness_center,
      Icons.book,
      Icons.water_drop,
      Icons.bedtime,
      Icons.directions_run,
      Icons.restaurant,
      Icons.psychology,
      Icons.work,
      Icons.music_note,
      Icons.brush,
      Icons.school,
      Icons.favorite,
    ];

    return GestureDetector(
      onTap: () => _showIconPicker(context, icons, formController),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(formState.icon, color: formState.color, size: 24),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.purple,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
    ];

    return GestureDetector(
      onTap: () => _showColorPicker(context, colors, formController),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: formState.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencySelector(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    return GestureDetector(
      onTap: () => _showFrequencyPicker(context, formController),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getFrequencyText(formState.frequency),
              style: const TextStyle(color: Colors.white),
            ),
            const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeOfDaySelector(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    return Wrap(
      spacing: 8,
      children: [
        _buildTimeOfDayChip('Anytime', null, formState, formController),
        _buildTimeOfDayChip(
          'Morning',
          TimeOfDayPreference.morning,
          formState,
          formController,
        ),
        _buildTimeOfDayChip(
          'Afternoon',
          TimeOfDayPreference.afternoon,
          formState,
          formController,
        ),
        _buildTimeOfDayChip(
          'Evening',
          TimeOfDayPreference.evening,
          formState,
          formController,
        ),
      ],
    );
  }

  Widget _buildTimeOfDayChip(
    String label,
    TimeOfDayPreference? preference,
    HabitFormState formState,
    HabitFormController formController,
  ) {
    final isSelected = formState.timeOfDay == preference;
    return GestureDetector(
      onTap: () => formController.updateTimeOfDay(preference),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[400],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSection(
    HabitFormState formState,
    HabitFormController formController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Reminder'),
            Switch(
              value: formState.hasReminder,
              onChanged: (value) => formController.toggleReminder(value),
              activeColor: const Color(0xFF4F46E5),
            ),
          ],
        ),
        if (formState.hasReminder) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _pickTime(context, formController),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formState.reminderTime != null
                        ? _formatTime(formState.reminderTime!)
                        : 'Select time',
                    style: TextStyle(
                      color: formState.reminderTime != null
                          ? Colors.white
                          : Colors.grey[500],
                    ),
                  ),
                  const Icon(Icons.access_time, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getHabitTypeText(HabitType type) {
    switch (type) {
      case HabitType.regular:
        return 'Regular';
      case HabitType.negative:
        return 'Avoid';
      case HabitType.oneTime:
        return 'Goal';
    }
  }

  String _getFrequencyText(Frequency frequency) {
    switch (frequency.type) {
      case FrequencyType.daily:
        return 'Everyday';
      case FrequencyType.weekly:
        if (frequency.selectedDays?.isNotEmpty == true) {
          return 'Specific days in week';
        }
        return 'Weekly';
      case FrequencyType.monthly:
        return 'Monthly';
      case FrequencyType.yearly:
        return 'Yearly';
      case FrequencyType.longTerm:
        return 'Long-term habit';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime(
    BuildContext context,
    HabitFormController formController,
  ) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      formController.updateReminderTime(time);
    }
  }

  void _showIconPicker(
    BuildContext context,
    List<IconData> icons,
    HabitFormController formController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Icon',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    formController.updateIcon(icons[index]);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A3A),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icons[index], color: Colors.white, size: 24),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker(
    BuildContext context,
    List<Color> colors,
    HabitFormController formController,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Color',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: colors.map((color) {
                return GestureDetector(
                  onTap: () {
                    formController.updateColor(color);
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showFrequencyPicker(
    BuildContext context,
    HabitFormController formController,
  ) {
    // Navigate to frequency selection page (simplified for now)
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FrequencySelectionPage(
          onFrequencySelected: (frequency) {
            formController.updateFrequency(frequency);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  Future<void> _saveHabit(BuildContext context) async {
    final formState = ref.read(habitFormControllerProvider);
    final habitController = ref.read(habitControllerProvider.notifier);

    if (_isEditing) {
      final updatedHabit = formState.toHabit(id: widget.editingHabit!.id);
      await habitController.updateHabit(updatedHabit);
    } else {
      final newHabit = formState.toHabit();
      await habitController.addHabit(newHabit);
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          'Delete Habit',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await ref
                  .read(habitControllerProvider.notifier)
                  .deleteHabit(widget.editingHabit!.id);
              if (mounted) {
                Navigator.of(context).pop(); // Close dialog
                Navigator.of(context).pop(); // Go back to previous screen
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// Simplified frequency selection page
class FrequencySelectionPage extends StatelessWidget {
  final Function(Frequency) onFrequencySelected;

  const FrequencySelectionPage({super.key, required this.onFrequencySelected});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Habit Days',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFrequencyOption(
              context,
              'Everyday',
              'Do this habit every day',
              () => onFrequencySelected(Frequency(type: FrequencyType.daily)),
            ),
            _buildFrequencyOption(
              context,
              'Specific days in week',
              'Choose which days of the week',
              () {
                // For now, default to weekdays
                onFrequencySelected(
                  Frequency(
                    type: FrequencyType.weekly,
                    selectedDays: [1, 2, 3, 4, 5], // Monday to Friday
                  ),
                );
              },
            ),
            _buildFrequencyOption(
              context,
              'X days per week',
              'Set a target number of days per week',
              () => onFrequencySelected(
                Frequency(type: FrequencyType.weekly, timesPerPeriod: 3),
              ),
            ),
            _buildFrequencyOption(
              context,
              'Long-term habit',
              'For goals and one-time habits',
              () =>
                  onFrequencySelected(Frequency(type: FrequencyType.longTerm)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(
    BuildContext context,
    String title,
    String description,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
