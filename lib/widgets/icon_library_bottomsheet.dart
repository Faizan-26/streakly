import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:riverpod/riverpod.dart';
import 'package:streakly/constants/icon_data.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:flutter_riverpod/src/consumer.dart';

class IconLibraryBottomSheet extends StatefulWidget {
  final Function(IconData) onIconSelected;
  final IconData? selectedIcon;
  final bool isDark;
  const IconLibraryBottomSheet({
    super.key,
    required this.onIconSelected,
    required this.isDark,
    this.selectedIcon,
  });

  @override
  State<IconLibraryBottomSheet> createState() => _IconLibraryBottomSheetState();
}

class _IconLibraryBottomSheetState extends State<IconLibraryBottomSheet>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<String> _categories;
  Map<String, List<IconData>> _allIcons = {};

  @override
  void initState() {
    super.initState();
    _setupCategories();
    _tabController = TabController(length: _categories.length, vsync: this);
  }

  void _setupCategories() {
    // Add "All" category with all icons combined
    List<IconData> allIconsList = [];
    categorizedIcons.forEach((category, icons) {
      allIconsList.addAll(icons);
    });

    // Remove duplicates while preserving order
    final seenIcons = <String>{};
    allIconsList = allIconsList.where((icon) {
      final iconKey = icon.toString();
      return seenIcons.add(iconKey);
    }).toList();

    _allIcons = {'All': allIconsList, ...categorizedIcons};

    _categories = _allIcons.keys.toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isDark ? darkSurface : Colors.white;
    final surfaceColor = widget.isDark ? darkCard : lightGrey;
    final textColor = widget.isDark ? Colors.white : Colors.black87;
    print("DARK MODE: ${widget.isDark}");
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Text(
                  'Choose an Icon',
                  style: AppTypography.headlineSmall.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close_rounded,
                    color: widget.isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              labelColor: darkGreen,
              unselectedLabelColor: widget.isDark
                  ? Colors.grey[400]
                  : Colors.grey[600],
              labelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              dividerHeight: 0,
              tabs: _categories.map((category) {
                return Tab(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(category),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Icons grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _categories.map((category) {
                final icons = _allIcons[category] ?? [];
                return _buildIconGrid(icons, widget.isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconGrid(List<IconData> icons, bool isDark) {
    if (icons.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.faceSadTear,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No icons found',
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        padding: const EdgeInsets.only(bottom: 32),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final icon = icons[index];
          final isSelected = widget.selectedIcon == icon;

          return _buildIconItem(icon, isSelected, isDark);
        },
      ),
    );
  }

  Widget _buildIconItem(IconData icon, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        widget.onIconSelected(icon);
        Navigator.pop(context);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? green
              : isDark
              ? darkCard
              : lightGrey,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: darkGreen, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: green.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: FaIcon(
            icon,
            size: 20,
            color: isSelected
                ? darkGreen
                : isDark
                ? Colors.grey[300]
                : Colors.grey[700],
          ),
        ),
      ),
    );
  }
}

// Function to show the bottom sheet
void showIconLibraryBottomSheet(
  BuildContext context, {
  required Function(IconData) onIconSelected,
  required bool isDark,
  IconData? selectedIcon,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return IconLibraryBottomSheet(
        isDark: isDark,
        onIconSelected: onIconSelected,
        selectedIcon: selectedIcon,
      );
    },
  );
}
