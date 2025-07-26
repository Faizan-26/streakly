// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:streakly/widgets/icon_library_bottomsheet.dart';
// import 'package:streakly/theme/app_colors.dart';
// import 'package:streakly/theme/app_typography.dart';

// /// Example usage of the IconLibraryBottomSheet widget
// /// This shows how to integrate the icon picker into your UI
// class IconLibraryDemo extends StatefulWidget {
//   const IconLibraryDemo({super.key});

//   @override
//   State<IconLibraryDemo> createState() => _IconLibraryDemoState();
// }

// class _IconLibraryDemoState extends State<IconLibraryDemo> {
//   IconData selectedIcon = FontAwesomeIcons.solidStar;

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Scaffold(
//       backgroundColor: isDark ? darkBackground : Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'Icon Library Demo',
//           style: AppTypography.headlineSmall.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//           ),
//         ),
//         backgroundColor: isDark ? darkSurface : Colors.white,
//         elevation: 0,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Icon display container
//             Container(
//               width: 120,
//               height: 120,
//               decoration: BoxDecoration(
//                 color: isDark ? darkCard : lightGrey,
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: isDark ? darkCard : Colors.grey.shade300,
//                   width: 1,
//                 ),
//               ),
//               child: Center(
//                 child: FaIcon(
//                   selectedIcon,
//                   size: 48,
//                   color: isDark ? Colors.white : darkGreen,
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Selected icon info
//             Text(
//               'Selected Icon',
//               style: AppTypography.bodyLarge.copyWith(
//                 color: isDark ? Colors.grey[400] : Colors.grey[600],
//               ),
//             ),
            
//             const SizedBox(height: 8),
            
//             Text(
//               selectedIcon.toString().split('.').last,
//               style: AppTypography.headlineSmall.copyWith(
//                 color: isDark ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
            
//             const SizedBox(height: 32),
            
//             // Change icon button
//             SizedBox(
//               width: 200,
//               height: 56,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: green,
//                   foregroundColor: darkGreen,
//                   elevation: 3,
//                   shadowColor: Colors.black.withOpacity(0.3),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                 ),
//                 onPressed: () {
//                   showIconLibraryBottomSheet(
//                     context,
//                     selectedIcon: selectedIcon,
//                     onIconSelected: (IconData newIcon) {
//                       setState(() {
//                         selectedIcon = newIcon;
//                       });
//                     },
//                   );
//                 },
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const FaIcon(
//                       FontAwesomeIcons.palette,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       'Choose Icon',
//                       style: AppTypography.bodyLarge.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
            
//             const SizedBox(height: 16),
            
//             // Info text
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 32),
//               child: Text(
//                 'Tap "Choose Icon" to open the icon library with categorized tabs. Icons are organized into Popular, Lifestyle, Health, Diet, and more!',
//                 textAlign: TextAlign.center,
//                 style: AppTypography.bodyMedium.copyWith(
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   height: 1.4,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Integration example for use in forms (like AddHabitPage)
// class IconSelectionField extends StatelessWidget {
//   final IconData selectedIcon;
//   final Function(IconData) onIconSelected;
//   final String label;

//   const IconSelectionField({
//     super.key,
//     required this.selectedIcon,
//     required this.onIconSelected,
//     this.label = 'Icon',
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: AppTypography.bodyLarge.copyWith(
//             color: isDark ? Colors.white : Colors.black87,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
        
//         const SizedBox(height: 8),
        
//         GestureDetector(
//           onTap: () {
//             showIconLibraryBottomSheet(
//               context,
//               selectedIcon: selectedIcon,
//               onIconSelected: onIconSelected,
//             );
//           },
//           child: Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//             decoration: BoxDecoration(
//               color: isDark ? darkCard : lightGrey,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: isDark ? darkCard : Colors.grey.shade300,
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 40,
//                   height: 40,
//                   decoration: BoxDecoration(
//                     color: green.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Center(
//                     child: FaIcon(
//                       selectedIcon,
//                       size: 20,
//                       color: darkGreen,
//                     ),
//                   ),
//                 ),
                
//                 const SizedBox(width: 12),
                
//                 Text(
//                   'Tap to change icon',
//                   style: AppTypography.bodyMedium.copyWith(
//                     color: isDark ? Colors.grey[400] : Colors.grey[600],
//                   ),
//                 ),
                
//                 const Spacer(),
                
//                 Icon(
//                   Icons.chevron_right_rounded,
//                   color: isDark ? Colors.grey[400] : Colors.grey[600],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
