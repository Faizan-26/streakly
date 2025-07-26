# Custom Bottom Navigation Bar

A beautiful, modern bottom navigation bar with blur effects, custom borders, and a cut-out space for a central floating action button.

## Features

- **Blur Effect**: Uses `BlurryContainer` for a modern glassmorphism look
- **Custom Borders**: Elegant borders that adapt to dark/light themes
- **FAB Cut-out**: Central floating action button elevated above the nav bar
- **Smooth Animations**: Animated selection states and transitions
- **Theme Adaptive**: Automatically adapts colors for dark and light modes
- **Customizable**: Extended version with full customization options

## Usage

### Basic Implementation

```dart
import 'package:streakly/navigation/navbar.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        onFABPressed: () {
          // Handle central FAB press
          Navigator.pushNamed(context, '/add-habit');
        },
      ),
    );
  }
}
```

### Extended Implementation with Customization

```dart
CustomBottomNavBarExtended(
  currentIndex: _currentIndex,
  items: [
    BottomNavItem(icon: Icons.home_rounded, label: 'Home'),
    BottomNavItem(icon: Icons.analytics_rounded, label: 'Analytics'),
    BottomNavItem(icon: Icons.person_rounded, label: 'Profile'),
    BottomNavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ],
  onTap: (index) => setState(() => _currentIndex = index),
  onFABPressed: () => _showAddBottomSheet(),
  fabColor: Colors.blue,
  fabIcon: Icons.add_rounded,
  fabSize: 70,
  navBarHeight: 85,
  borderRadius: 30,
  blurIntensity: 20,
  margin: EdgeInsets.all(20),
)
```

## Customization Options

### CustomBottomNavBar (Basic)

- `currentIndex`: Current selected tab index
- `onTap`: Callback when tab is tapped
- `onFABPressed`: Callback when central FAB is pressed

### CustomBottomNavBarExtended (Advanced)

- `items`: List of `BottomNavItem` for custom navigation items
- `fabColor`: Color of the central FAB (default: app green)
- `fabIcon`: Icon for the central FAB (default: `Icons.add_rounded`)
- `fabSize`: Size of the central FAB (default: 65)
- `navBarHeight`: Height of the navigation bar (default: 80)
- `margin`: Margin around the nav bar (default: 16px horizontal, 16px vertical)
- `borderRadius`: Border radius of the nav bar (default: 28)
- `blurIntensity`: Intensity of the blur effect (default: 15)

## Visual Features

### Blur Container

- Glassmorphism effect with customizable intensity
- Semi-transparent background that adapts to theme
- Elevation shadow for depth

### Custom Cut-out

- Precise path clipping for FAB space
- Smooth curved edges
- Perfect circular cut-out

### Theming

- **Dark Mode**: Dark blue background with white accents
- **Light Mode**: White background with gray accents
- Automatic color adaptation
- Consistent with app color scheme

### Animations

- Selection state transitions (200ms)
- Icon size changes on selection
- Background color animations
- Smooth FAB interactions

## Technical Implementation

### Key Components

1. **BlurryContainer**: Provides the glassmorphism effect
2. **BottomNavClipper**: Custom clipper for FAB cut-out
3. **Stack**: Positions FAB above the nav bar
4. **Theme Detection**: Automatic dark/light mode adaptation

### Performance

- Efficient clipping with `shouldReclip: false`
- Minimal rebuilds with proper state management
- Smooth 60fps animations

## Integration

The navbar integrates seamlessly with:

- **Riverpod** state management
- **Flutter's** built-in theming
- **Custom** app color schemes
- **Navigation** systems

## Dependencies

- `blurrycontainer: ^2.1.0` - For blur effects
- `flutter/material.dart` - Core Flutter UI
- App theme colors and typography

## Best Practices

1. **State Management**: Use with proper state management (Riverpod recommended)
2. **Navigation**: Combine with `IndexedStack` for smooth page transitions
3. **Accessibility**: Ensure proper labels and touch targets
4. **Performance**: Use `IndexedStack` to maintain page state
5. **Theming**: Leverage automatic theme adaptation

## Example Integration

See `lib/pages/main_wrapper.dart` for complete implementation examples with both basic and extended versions.

The navbar is designed to be the centerpiece of your app's navigation, providing a modern, intuitive, and beautiful user experience.
