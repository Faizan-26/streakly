import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/model/habit_model.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/types/habit_frequency_types.dart';
import 'package:streakly/types/habit_type.dart';
import 'package:streakly/types/time_of_day_type.dart';
import 'package:streakly/widgets/icon_library_bottomsheet.dart';
import 'package:streakly/controllers/habit_controller.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 6;

  // Form data
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _goalCountController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  HabitType _selectedType = HabitType.regular;
  FrequencyType _selectedFrequency = FrequencyType.daily;
  TimeOfDayPreference _selectedTimeOfDay =
      TimeOfDayPreference.anytime; // Default to anytime
  Duration? _goalDuration;
  final List<int> _selectedDays = [];
  int? _timesPerPeriod;
  final List<int> _specificDates = [];
  bool _hasReminder = false;
  final List<TimeOfDay> _reminderTimes = []; // Multiple reminder times
  Color _selectedColor = green;
  IconData _selectedIcon = Icons.star;
  DateTime? _startDate;
  DateTime? _endDate;

  // Goal type selection
  String _goalType = 'none'; // 'none', 'duration', 'count'

  // Predefined colors for habit
  final List<Color> _habitColors = [
    green,
    Colors.blue,
    Colors.purple,
    Colors.orange,
    Colors.red,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    accentOrange,
    darkGreen,
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _goalCountController.dispose();
    _categoryController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    // Validate current step before proceeding
    if (!_validateCurrentStep()) {
      return;
    }

    if (_currentStep < _totalSteps - 1) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Basic info
        if (_titleController.text.trim().isEmpty) {
          _showSnackBar('Please enter a habit title');
          return false;
        }
        return true;
      case 1: // Habit type - always valid since we have default
        return true;
      case 2: // Frequency
        if (_selectedFrequency == FrequencyType.weekly &&
            _selectedDays.isEmpty) {
          _showSnackBar('Please select at least one day for weekly habit');
          return false;
        }
        if (_selectedFrequency == FrequencyType.monthly &&
            _specificDates.isEmpty) {
          _showSnackBar('Please select at least one date for monthly habit');
          return false;
        }
        return true;
      case 3: // Goals
        if (_goalType == 'duration' && _goalDuration == null) {
          _showSnackBar('Please set a duration goal');
          return false;
        }
        if (_goalType == 'count' && _goalCountController.text.trim().isEmpty) {
          _showSnackBar('Please set a count goal');
          return false;
        }
        return true;
      case 4: // Customization - always valid since we have defaults
        return true;
      case 5: // Reminders
        if (_hasReminder && _reminderTimes.isEmpty) {
          _showSnackBar('Please set at least one reminder time');
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _saveHabit() async {
    HapticFeedback.heavyImpact();

    if (_titleController.text.isEmpty) {
      _showSnackBar('Please enter a habit title');
      return;
    }

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text,
      type: _selectedType,
      frequency: Frequency(
        type: _selectedFrequency,
        selectedDays: _selectedDays.isNotEmpty ? _selectedDays : null,
        timesPerPeriod: _timesPerPeriod,
        specificDates: _specificDates.isNotEmpty ? _specificDates : null,
      ),
      timeOfDay: _selectedTimeOfDay,
      goalDuration: _goalDuration,
      goalCount: _goalCountController.text.isNotEmpty
          ? int.tryParse(_goalCountController.text)
          : null,
      startDate: _startDate ?? DateTime.now(),
      endDate: _endDate,
      hasReminder: _hasReminder,
      reminderTime: _reminderTimes.isNotEmpty ? _reminderTimes.first : null,
      color: _selectedColor,
      icon: _selectedIcon,
      category: _categoryController.text.isNotEmpty
          ? _categoryController.text
          : null,
      isPreset: false,
      createdAt: DateTime.now(),
    );

    try {
      // Save habit using the controller
      await ref.read(habitControllerProvider.notifier).addHabit(habit);

      // Show success message
      _showSnackBar('Habit created successfully!');

      // Return to previous screen
      Navigator.pop(context, habit);
    } catch (e) {
      // Show error message
      _showSnackBar('Failed to create habit: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _selectedColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showIconPicker(bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      builder: (BuildContext bottomSheetContext) => IconLibraryBottomSheet(
        onIconSelected: (selectedIcon) {
          HapticFeedback.selectionClick();
          // Use the parent context to update state, not the bottom sheet context
          if (mounted) {
            setState(() {
              _selectedIcon = selectedIcon;
            });
          }
        },
        selectedIcon: _selectedIcon,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? darkBackground : softWhite;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : darkGreen,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Create New Habit',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(isDark),

          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildBasicInfoStep(isDark),
                _buildHabitTypeStep(isDark),
                _buildFrequencyStep(isDark),
                _buildGoalStep(isDark),
                _buildCustomizationStep(isDark),
                _buildReminderStep(isDark),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: List.generate(_totalSteps, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;

          return Expanded(
            child:
                Container(
                  margin: EdgeInsets.only(
                    right: index < _totalSteps - 1 ? 8 : 0,
                  ),
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? _selectedColor
                        : isDark
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ).animate().scaleX(
                  begin: isCompleted ? 1 : 0,
                  end: 1,
                  duration: 300.ms,
                  curve: Curves.easeOut,
                ),
          );
        }),
      ),
    );
  }

  Widget _buildBasicInfoStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s start with the basics',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Give your habit a clear, motivating name',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Habit title
          _buildTextField(
            controller: _titleController,
            label: 'Habit Title',
            hint: 'e.g., "Drink 8 glasses of water"',
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Category (optional)
          _buildTextField(
            controller: _categoryController,
            label: 'Category (Optional)',
            hint: 'e.g., Health, Productivity, Learning',
            isDark: isDark,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildHabitTypeStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What type of habit is this?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type that best describes your habit',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          ...HabitType.values.map(
            (type) => _buildOptionCard(
              title: type.name,
              subtitle: _getHabitTypeDescription(type),
              isSelected: _selectedType == type,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedType = type;
                });
              },
              isDark: isDark,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildFrequencyStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How often do you want to do this?',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a realistic frequency for your habit',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          ...FrequencyType.values.map(
            (frequency) => Column(
              children: [
                _buildOptionCard(
                  title: frequency.name,
                  subtitle: _getFrequencyDescription(frequency),
                  isSelected: _selectedFrequency == frequency,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedFrequency = frequency;
                      // Reset specific selections when changing frequency type
                      _selectedDays.clear();
                      _specificDates.clear();
                      _timesPerPeriod = null;
                    });
                  },
                  isDark: isDark,
                ),

                // Animated expansion for weekly selector
                if (_selectedFrequency == frequency &&
                    frequency == FrequencyType.weekly)
                  Container(
                        margin: const EdgeInsets.only(top: 16, bottom: 16),
                        child: _buildAnimatedWeeklySelector(isDark),
                      )
                      .animate()
                      .slideY(
                        begin: -0.5,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 300.ms),

                // Animated expansion for monthly selector
                if (_selectedFrequency == frequency &&
                    frequency == FrequencyType.monthly)
                  Container(
                        margin: const EdgeInsets.only(top: 16, bottom: 16),
                        child: _buildAnimatedMonthlySelector(isDark),
                      )
                      .animate()
                      .slideY(
                        begin: -0.5,
                        end: 0,
                        duration: 400.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 300.ms),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildGoalStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set your goal',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Define what success looks like for this habit',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Time of day preference
          Text(
            'Preferred Time',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: TimeOfDayPreference.values.map((timeOfDay) {
              final isSelected = _selectedTimeOfDay == timeOfDay;
              return _buildChip(
                label: timeOfDay.name,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedTimeOfDay = timeOfDay;
                  });
                },
                isDark: isDark,
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Goal type selection
          Text(
            'Goal Type',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildChip(
                label: 'No specific goal',
                isSelected: _goalType == 'none',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _goalType = 'none';
                    _goalDuration = null;
                    _goalCountController.clear();
                  });
                },
                isDark: isDark,
              ),
              _buildChip(
                label: 'Duration goal',
                isSelected: _goalType == 'duration',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _goalType = 'duration';
                    _goalCountController.clear();
                  });
                },
                isDark: isDark,
              ),
              _buildChip(
                label: 'Count goal',
                isSelected: _goalType == 'count',
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _goalType = 'count';
                    _goalDuration = null;
                  });
                },
                isDark: isDark,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Duration goal (only show if duration is selected)
          if (_goalType == 'duration')
            _buildDurationSelector(isDark)
                .animate()
                .slideY(begin: -0.5, end: 0, duration: 300.ms)
                .fadeIn(duration: 200.ms),

          // Count goal (only show if count is selected)
          if (_goalType == 'count')
            _buildCountGoalSelector(isDark)
                .animate()
                .slideY(begin: -0.5, end: 0, duration: 300.ms)
                .fadeIn(duration: 200.ms),

          const SizedBox(height: 24),

          // Start and end dates with iOS style
          _buildIOSDateSelectors(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildCustomizationStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customize your habit',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a color and icon to make it yours',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Color selector
          Text(
            'Color',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _habitColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child:
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                                color: isDark ? Colors.white : darkGreen,
                                width: 3,
                              )
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24,
                            )
                          : null,
                    ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // Icon selector
          Text(
            'Icon',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Selected icon display and browse button
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_selectedIcon, color: Colors.white, size: 28),
              ).animate().scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 300.ms,
                curve: Curves.bounceOut,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showIconPicker(isDark);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.grey.shade800
                          : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          color: _selectedColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Browse Icons',
                          style: AppTypography.bodyMedium.copyWith(
                            color: _selectedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: _selectedColor,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildReminderStep(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set up reminders',
            style: AppTypography.headlineMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay consistent with gentle reminders',
            style: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 32),

          // Reminder toggle
          _buildSwitchTile(
            title: 'Enable Reminders',
            subtitle: 'Get notified when it\'s time for your habit',
            value: _hasReminder,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              setState(() {
                _hasReminder = value;
              });
            },
            isDark: isDark,
          ),

          if (_hasReminder) ...[
            const SizedBox(height: 24),
            _buildTimeSelector(isDark),
          ],

          const SizedBox(height: 32),

          // Preview card
          _buildPreviewCard(isDark),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyLarge.copyWith(
            color: isDark ? Colors.white : darkGreen,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: isDark ? Colors.white38 : Colors.grey.shade500,
            ),
            filled: true,
            fillColor: isDark ? darkCard : lightGrey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(20),
          ),
          onChanged: (value) {
            HapticFeedback.selectionClick();
          },
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isSelected
                  ? _selectedColor.withOpacity(0.1)
                  : isDark
                  ? darkCard
                  : lightGrey,
              borderRadius: BorderRadius.circular(16),
              border: isSelected
                  ? Border.all(color: _selectedColor, width: 2)
                  : null,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? Colors.white : darkGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: _selectedColor, size: 24),
              ],
            ),
          ),
        ),
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 200.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? _selectedColor
                : isDark
                ? darkCard
                : lightGrey,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: isSelected
                  ? Colors.white
                  : isDark
                  ? Colors.white70
                  : darkGreen,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedWeeklySelector(bool isDark) {
    final days = [
      {
        'name': 'Sun',
        'color': isDark ? Colors.red.shade300 : Colors.red.shade500,
      },
      {
        'name': 'Mon',
        'color': isDark ? Colors.blue.shade300 : Colors.blue.shade500,
      },
      {
        'name': 'Tue',
        'color': isDark ? Colors.green.shade300 : Colors.green.shade500,
      },
      {
        'name': 'Wed',
        'color': isDark ? Colors.orange.shade300 : Colors.orange.shade500,
      },
      {
        'name': 'Thu',
        'color': isDark ? Colors.purple.shade300 : Colors.purple.shade500,
      },
      {
        'name': 'Fri',
        'color': isDark ? Colors.teal.shade300 : Colors.teal.shade500,
      },
      {
        'name': 'Sat',
        'color': isDark ? Colors.pink.shade300 : Colors.pink.shade500,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkCard : lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Days',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // Circular day selector with animations
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(7, (index) {
                final day = days[index];
                final isSelected = _selectedDays.contains(index);

                return Container(
                  margin: EdgeInsets.only(
                    right: index < 6 ? 12 : 0,
                    left: index == 0 ? 4 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        if (isSelected) {
                          _selectedDays.remove(index);
                        } else {
                          _selectedDays.add(index);
                        }
                      });
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? day['color'] as Color
                                : (isDark
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300),
                            border: isSelected
                                ? Border.all(color: _selectedColor, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              day['name'] as String,
                              style: AppTypography.labelMedium.copyWith(
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                          ? Colors.white70
                                          : Colors.grey.shade600),
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 200.ms,
                          curve: Curves.bounceOut,
                        ),
                        if (isSelected)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: day['color'] as Color,
                            ),
                          ).animate().scale(
                            begin: const Offset(0, 0),
                            end: const Offset(1, 1),
                            duration: 200.ms,
                            curve: Curves.elasticOut,
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          if (_selectedDays.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
                  'Selected: ${_selectedDays.map((i) => days[i]['name']).join(', ')}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: _selectedColor,
                    fontWeight: FontWeight.w600,
                  ),
                )
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.5, end: 0, duration: 200.ms),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimatedMonthlySelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkCard : lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Dates',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showIOSDatePicker(isDark);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: _selectedColor),
                  const SizedBox(width: 12),
                  Text(
                    'Add Date',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _selectedColor,
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.add, color: _selectedColor),
                ],
              ),
            ),
          ),

          if (_specificDates.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Selected Dates',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _specificDates.map((date) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _selectedColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$date',
                        style: AppTypography.bodyMedium.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _specificDates.remove(date);
                          });
                        },
                        child: Icon(
                          Icons.close,
                          color: _selectedColor,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(
                  begin: const Offset(0, 0),
                  end: const Offset(1, 1),
                  duration: 200.ms,
                  curve: Curves.elasticOut,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  void _showIOSDatePicker(bool isDark) {
    int? tempSelectedDate;

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Container(
        height: 350,
        decoration: BoxDecoration(
          color: isDark ? darkCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[600] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Select Date',
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark ? Colors.white : darkGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CupertinoButton(
                    child: Text(
                      'Done',
                      style: TextStyle(
                        color: _selectedColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      if (tempSelectedDate != null) {
                        setState(() {
                          if (!_specificDates.contains(tempSelectedDate!)) {
                            _specificDates.add(tempSelectedDate!);
                            _specificDates.sort();
                          }
                        });
                      }
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Date picker
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: DateTime.now(),
                minimumDate: DateTime.now(),
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                onDateTimeChanged: (date) {
                  tempSelectedDate = date.day;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(bool isDark) {
    int hours = _goalDuration?.inHours ?? 0;
    int minutes = (_goalDuration?.inMinutes ?? 0) % 60;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration Goal',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? darkCard : lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Duration',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                      style: AppTypography.titleMedium.copyWith(
                        color: _selectedColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Circular wheel picker for duration
              GestureDetector(
                onTap: () => _showDurationWheelPicker(isDark, _goalDuration),
                child: Container(
                  height: 120,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _selectedColor.withOpacity(0.1),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                        style: AppTypography.headlineMedium.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'duration',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Tap to change',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Time',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Material(
          color: Colors.transparent,
          child: Column(
            children: [
              // Add reminder button
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  _showIOSTimePicker(isDark);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? darkCard : lightGrey,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _reminderTimes.isNotEmpty
                          ? _selectedColor.withOpacity(0.3)
                          : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: _selectedColor,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _reminderTimes.isEmpty
                              ? 'Add reminder time'
                              : 'Add another reminder',
                          style: AppTypography.bodyLarge.copyWith(
                            color: _selectedColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: isDark ? Colors.white38 : Colors.grey.shade400,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),

              // Display added reminder times
              if (_reminderTimes.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...(_reminderTimes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final time = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _selectedColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _selectedColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              color: _selectedColor,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                time.format(context),
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark ? Colors.white : darkGreen,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _reminderTimes.removeAt(index);
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: _selectedColor,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList()),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showIOSTimePicker(bool isDark) {
    TimeOfDay tempTime = const TimeOfDay(hour: 9, minute: 0);

    showCupertinoModalPopup(
      context: context,
      builder: (context) => Material(
        child: Container(
          height: 350,
          decoration: BoxDecoration(
            color: isDark ? darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[600] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Add Reminder',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? Colors.white : darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    CupertinoButton(
                      child: Text(
                        'Add',
                        style: TextStyle(
                          color: _selectedColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          if (!_reminderTimes.contains(tempTime)) {
                            _reminderTimes.add(tempTime);
                            _reminderTimes.sort((a, b) {
                              final aMinutes = a.hour * 60 + a.minute;
                              final bMinutes = b.hour * 60 + b.minute;
                              return aMinutes.compareTo(bMinutes);
                            });
                          }
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Time picker
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cupertinoOverrideTheme: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.time,
                    initialDateTime: DateTime(
                      2024,
                      1,
                      1,
                      tempTime.hour,
                      tempTime.minute,
                    ),
                    onDateTimeChanged: (dateTime) {
                      tempTime = TimeOfDay(
                        hour: dateTime.hour,
                        minute: dateTime.minute,
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkCard : lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark ? Colors.white : darkGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? Colors.white70 : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _selectedColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? darkCard : lightGrey,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: AppTypography.titleMedium.copyWith(
              color: isDark ? Colors.white : darkGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(_selectedIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _titleController.text.isEmpty
                          ? 'Your Habit Title'
                          : _titleController.text,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? Colors.white : darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_selectedFrequency.name} • ${_selectedType.name}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().scale(
      begin: const Offset(0.95, 0.95),
      end: const Offset(1, 1),
      duration: 300.ms,
      curve: Curves.easeOut,
    );
  }

  Widget _buildNavigationButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: _selectedColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Back',
                  style: AppTypography.titleMedium.copyWith(
                    color: _selectedColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _currentStep == _totalSteps - 1
                  ? _saveHabit
                  : _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: _selectedColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: Text(
                _currentStep == _totalSteps - 1 ? 'Create Habit' : 'Next',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHabitTypeDescription(HabitType type) {
    switch (type) {
      case HabitType.regular:
        return 'Build positive habits that you want to do regularly';
      case HabitType.negative:
        return 'Break bad habits that you want to stop doing';
      case HabitType.oneTime:
        return 'Complete a specific goal or task once';
    }
  }

  String _getFrequencyDescription(FrequencyType frequency) {
    switch (frequency) {
      case FrequencyType.daily:
        return 'Every day';
      case FrequencyType.weekly:
        return 'Specific days of the week';
      case FrequencyType.monthly:
        return 'Specific days of the month';
      case FrequencyType.yearly:
        return 'Once a year';
      case FrequencyType.longTerm:
        return 'Over an extended period';
    }
  }

  Widget _buildIOSDateSelectors(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: _buildIOSDateSelector(
                label: 'Start Date',
                date: _startDate,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  _showIOSDatePicker(isDark);
                },
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildIOSDateSelector(
                label: 'End Date (Optional)',
                date: _endDate,
                onTap: () async {
                  HapticFeedback.lightImpact();
                  _showIOSDatePicker(isDark);
                },
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIOSDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? Colors.white70 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? darkCard : lightGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: date != null
                      ? _selectedColor.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: date != null
                        ? _selectedColor
                        : (isDark ? Colors.white38 : Colors.grey.shade500),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      date != null
                          ? '${date.day}/${date.month}/${date.year}'
                          : 'Select date',
                      style: AppTypography.bodyMedium.copyWith(
                        color: date != null
                            ? (isDark ? Colors.white : darkGreen)
                            : (isDark ? Colors.white38 : Colors.grey.shade500),
                        fontWeight: date != null
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCountGoalSelector(bool isDark) {
    int currentCount = _goalCountController.text.isNotEmpty
        ? int.tryParse(_goalCountController.text) ?? 1
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Goal Count',
          style: AppTypography.titleMedium.copyWith(
            color: isDark ? Colors.white : darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? darkCard : lightGrey,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Count',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white70 : Colors.grey.shade600,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$currentCount',
                      style: AppTypography.titleMedium.copyWith(
                        color: _selectedColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Circular wheel picker for count
              GestureDetector(
                onTap: () => _showCountWheelPicker(isDark, currentCount),
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _selectedColor.withOpacity(0.1),
                    border: Border.all(
                      color: _selectedColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$currentCount',
                        style: AppTypography.headlineLarge.copyWith(
                          color: _selectedColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      Text(
                        'times',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Tap to change',
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? Colors.white54 : Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCountWheelPicker(bool isDark, int currentCount) {
    int tempCount = currentCount;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: isDark ? darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Goal Count',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? Colors.white : darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: _selectedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _goalCountController.text = tempCount.toString();
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Count picker
              Expanded(
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cupertinoOverrideTheme: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        pickerTextStyle: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                          fontSize: 22,
                        ),
                      ),
                    ),
                  ),
                  child: CupertinoPicker(
                    itemExtent: 40,
                    scrollController: FixedExtentScrollController(
                      initialItem: currentCount - 1,
                    ),
                    onSelectedItemChanged: (index) {
                      tempCount = index + 1;
                      HapticFeedback.selectionClick();
                    },
                    children: List.generate(
                      100,
                      (index) => Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 22,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDurationWheelPicker(bool isDark, Duration? currentDuration) {
    int tempHours = currentDuration?.inHours ?? 0;
    int tempMinutes = (currentDuration?.inMinutes ?? 0) % 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: isDark ? darkCard : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Duration Goal',
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? Colors.white : darkGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      child: Text(
                        'Done',
                        style: TextStyle(
                          color: _selectedColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _goalDuration = Duration(
                            hours: tempHours,
                            minutes: tempMinutes,
                          );
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),

              // Duration pickers (hours and minutes)
              Expanded(
                child: Row(
                  children: [
                    // Hours picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Hours',
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                cupertinoOverrideTheme: CupertinoThemeData(
                                  brightness: isDark
                                      ? Brightness.dark
                                      : Brightness.light,
                                  textTheme: CupertinoTextThemeData(
                                    pickerTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: tempHours,
                                ),
                                onSelectedItemChanged: (index) {
                                  tempHours = index;
                                  HapticFeedback.selectionClick();
                                },
                                children: List.generate(
                                  13,
                                  (index) => Center(
                                    child: Text(
                                      '$index',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Minutes picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Minutes',
                            style: AppTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? Colors.white70
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                cupertinoOverrideTheme: CupertinoThemeData(
                                  brightness: isDark
                                      ? Brightness.dark
                                      : Brightness.light,
                                  textTheme: CupertinoTextThemeData(
                                    pickerTextStyle: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                              ),
                              child: CupertinoPicker(
                                itemExtent: 40,
                                scrollController: FixedExtentScrollController(
                                  initialItem: tempMinutes,
                                ),
                                onSelectedItemChanged: (index) {
                                  tempMinutes = index;
                                  HapticFeedback.selectionClick();
                                },
                                children: List.generate(
                                  60,
                                  (index) => Center(
                                    child: Text(
                                      '$index',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
