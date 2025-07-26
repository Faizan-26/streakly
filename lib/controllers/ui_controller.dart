// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/material.dart';
// import 'package:streakly/model/habit_model.dart';
// import 'package:streakly/types/habit_frequency_types.dart';
// import 'package:streakly/types/habit_type.dart';
// import 'package:streakly/types/time_of_day_type.dart';

// /// State for habit form (Add/Edit habit)
// @immutable
// class HabitFormState {
//   final String title;
//   final HabitType habitType;
//   final Frequency frequency;
//   final TimeOfDayPreference? timeOfDay;
//   final bool hasReminder;
//   final TimeOfDay? reminderTime;
//   final Color color;
//   final IconData icon;
//   final String? category;
//   final Duration? goalDuration;
//   final int? goalCount;
//   final DateTime? startDate;
//   final DateTime? endDate;
//   final bool isValid;
//   final String? error;

//   const HabitFormState({
//     this.title = '',
//     this.habitType = HabitType.regular,
//     required this.frequency,
//     this.timeOfDay,
//     this.hasReminder = false,
//     this.reminderTime,
//     this.color = Colors.blue,
//     this.icon = Icons.star,
//     this.category,
//     this.goalDuration,
//     this.goalCount,
//     this.startDate,
//     this.endDate,
//     this.isValid = false,
//     this.error,
//   });

//   HabitFormState copyWith({
//     String? title,
//     HabitType? habitType,
//     Frequency? frequency,
//     TimeOfDayPreference? timeOfDay,
//     bool? hasReminder,
//     TimeOfDay? reminderTime,
//     Color? color,
//     IconData? icon,
//     String? category,
//     Duration? goalDuration,
//     int? goalCount,
//     DateTime? startDate,
//     DateTime? endDate,
//     bool? isValid,
//     String? error,
//   }) {
//     return HabitFormState(
//       title: title ?? this.title,
//       habitType: habitType ?? this.habitType,
//       frequency: frequency ?? this.frequency,
//       timeOfDay: timeOfDay ?? this.timeOfDay,
//       hasReminder: hasReminder ?? this.hasReminder,
//       reminderTime: reminderTime ?? this.reminderTime,
//       color: color ?? this.color,
//       icon: icon ?? this.icon,
//       category: category ?? this.category,
//       goalDuration: goalDuration ?? this.goalDuration,
//       goalCount: goalCount ?? this.goalCount,
//       startDate: startDate ?? this.startDate,
//       endDate: endDate ?? this.endDate,
//       isValid: isValid ?? this.isValid,
//       error: error,
//     );
//   }

//   /// Convert form state to Habit model
//   Habit toHabit({String? id}) {
//     return Habit(
//       id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
//       title: title,
//       type: habitType,
//       frequency: frequency,
//       timeOfDay: timeOfDay,
//       hasReminder: hasReminder,
//       reminderTime: reminderTime,
//       color: color,
//       icon: icon,
//       category: category,
//       goalDuration: goalDuration,
//       goalCount: goalCount,
//       startDate: startDate,
//       endDate: endDate,
//     );
//   }

//   /// Validate form data
//   bool get _isFormValid {
//     if (title.trim().isEmpty) return false;
//     if (hasReminder && reminderTime == null) return false;
//     if (habitType == HabitType.oneTime && endDate == null) return false;
//     return true;
//   }
// }

// /// Controller for habit form
// class HabitFormController extends StateNotifier<HabitFormState> {
//   HabitFormController()
//     : super(HabitFormState(frequency: Frequency(type: FrequencyType.daily)));

//   /// Initialize form with existing habit (for editing)
//   void initializeWithHabit(Habit habit) {
//     state = HabitFormState(
//       title: habit.title,
//       habitType: habit.type,
//       frequency: habit.frequency,
//       timeOfDay: habit.timeOfDay,
//       hasReminder: habit.hasReminder,
//       reminderTime: habit.reminderTime,
//       color: habit.color,
//       icon: habit.icon,
//       category: habit.category,
//       goalDuration: habit.goalDuration,
//       goalCount: habit.goalCount,
//       startDate: habit.startDate,
//       endDate: habit.endDate,
//     );
//     _validateForm();
//   }

//   /// Update title
//   void updateTitle(String title) {
//     state = state.copyWith(title: title);
//     _validateForm();
//   }

//   /// Update habit type
//   void updateHabitType(HabitType type) {
//     state = state.copyWith(habitType: type);

//     // Reset frequency based on habit type
//     if (type == HabitType.oneTime) {
//       state = state.copyWith(
//         frequency: Frequency(type: FrequencyType.longTerm),
//         endDate: DateTime.now().add(const Duration(days: 30)),
//       );
//     } else {
//       state = state.copyWith(
//         frequency: Frequency(type: FrequencyType.daily),
//         endDate: null,
//       );
//     }
//     _validateForm();
//   }

//   /// Update frequency
//   void updateFrequency(Frequency frequency) {
//     state = state.copyWith(frequency: frequency);
//     _validateForm();
//   }

//   /// Update time of day preference
//   void updateTimeOfDay(TimeOfDayPreference? timeOfDay) {
//     state = state.copyWith(timeOfDay: timeOfDay);
//     _validateForm();
//   }

//   /// Toggle reminder
//   void toggleReminder(bool hasReminder) {
//     state = state.copyWith(
//       hasReminder: hasReminder,
//       reminderTime: hasReminder ? state.reminderTime : null,
//     );
//     _validateForm();
//   }

//   /// Update reminder time
//   void updateReminderTime(TimeOfDay? time) {
//     state = state.copyWith(reminderTime: time);
//     _validateForm();
//   }

//   /// Update color
//   void updateColor(Color color) {
//     state = state.copyWith(color: color);
//   }

//   /// Update icon
//   void updateIcon(IconData icon) {
//     state = state.copyWith(icon: icon);
//   }

//   /// Update category
//   void updateCategory(String? category) {
//     state = state.copyWith(category: category);
//   }

//   /// Update goal duration
//   void updateGoalDuration(Duration? duration) {
//     state = state.copyWith(goalDuration: duration);
//   }

//   /// Update goal count
//   void updateGoalCount(int? count) {
//     state = state.copyWith(goalCount: count);
//   }

//   /// Update end date (for one-time habits)
//   void updateEndDate(DateTime? date) {
//     state = state.copyWith(endDate: date);
//     _validateForm();
//   }

//   /// Reset form
//   void reset() {
//     state = HabitFormState(frequency: Frequency(type: FrequencyType.daily));
//   }

//   /// Validate form
//   void _validateForm() {
//     final isValid = state._isFormValid;
//     state = state.copyWith(isValid: isValid, error: null);
//   }
// }

// /// Provider for habit form controller
// final habitFormControllerProvider =
//     StateNotifierProvider<HabitFormController, HabitFormState>((ref) {
//       return HabitFormController();
//     });

// /// UI State Controller for managing app navigation and UI state
// @immutable
// class UIState {
//   final int currentTabIndex;
//   final bool isBottomSheetOpen;
//   final String? selectedHabitId;
//   final bool isLoadingAction;

//   const UIState({
//     this.currentTabIndex = 0,
//     this.isBottomSheetOpen = false,
//     this.selectedHabitId,
//     this.isLoadingAction = false,
//   });

//   UIState copyWith({
//     int? currentTabIndex,
//     bool? isBottomSheetOpen,
//     String? selectedHabitId,
//     bool? isLoadingAction,
//   }) {
//     return UIState(
//       currentTabIndex: currentTabIndex ?? this.currentTabIndex,
//       isBottomSheetOpen: isBottomSheetOpen ?? this.isBottomSheetOpen,
//       selectedHabitId: selectedHabitId ?? this.selectedHabitId,
//       isLoadingAction: isLoadingAction ?? this.isLoadingAction,
//     );
//   }
// }

// /// UI Controller
// class UIController extends StateNotifier<UIState> {
//   UIController() : super(const UIState());

//   /// Change tab
//   void changeTab(int index) {
//     state = state.copyWith(currentTabIndex: index);
//   }

//   /// Toggle bottom sheet
//   void toggleBottomSheet(bool isOpen) {
//     state = state.copyWith(isBottomSheetOpen: isOpen);
//   }

//   /// Select habit
//   void selectHabit(String? habitId) {
//     state = state.copyWith(selectedHabitId: habitId);
//   }

//   /// Set loading state
//   void setLoadingAction(bool isLoading) {
//     state = state.copyWith(isLoadingAction: isLoading);
//   }
// }

// /// Provider for UI controller
// final uiControllerProvider = StateNotifierProvider<UIController, UIState>((
//   ref,
// ) {
//   return UIController();
// });
