import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:streakly/controllers/theme_controller.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';

class LoadingIndicatorPage extends ConsumerStatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onComplete;
  final Duration duration;

  const LoadingIndicatorPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = const Color(0xFF4CAF50),
    this.onComplete,
    this.duration = const Duration(seconds: 3),
  });

  @override
  ConsumerState<LoadingIndicatorPage> createState() =>
      _LoadingIndicatorPageState();
}

class _LoadingIndicatorPageState extends ConsumerState<LoadingIndicatorPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentPercentage = 0;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    _progressAnimation.addListener(() {
      setState(() {
        _currentPercentage = (_progressAnimation.value * 100).round();
      });
    });

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _progressController.forward();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeController = ref.watch(themeControllerProvider.notifier);
    final isDark = themeController.isDarkMode(context);

    // Dynamic theming based on mode
    final backgroundColor = isDark ? const Color(0xFF1A1B2E) : lightGrey;
    final textColor = isDark ? Colors.white : darkGreen;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade600;
    final progressBackgroundColor = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Title with improved styling
              Text(
                    widget.title,
                    style: AppTypography.headlineLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                  .animate()
                  .slideY(begin: 1, duration: 800.ms, delay: 200.ms)
                  .fadeIn(duration: 800.ms, delay: 200.ms),

              const SizedBox(height: 80),

              // Enhanced circular progress indicator
              Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background circle with enhanced styling
                      Container(
                        width: 220,
                        height: 220,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFF2A2D47).withOpacity(0.3)
                              : Colors.white.withOpacity(0.8),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.1)
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                      ),
                      // Progress circle with enhanced appearance
                      AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return SizedBox(
                            width: 200,
                            height: 200,
                            child: CircularProgressIndicator(
                              value: _progressAnimation.value,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              backgroundColor: progressBackgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(green),
                            ),
                          );
                        },
                      ),
                      // Enhanced percentage text
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$_currentPercentage%',
                            style: AppTypography.displayLarge.copyWith(
                              color: textColor,
                              fontSize: 42,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              'Loading...',
                              style: AppTypography.labelSmall.copyWith(
                                color: green,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), duration: 800.ms)
                  .fadeIn(duration: 800.ms),

              const SizedBox(height: 80),

              // Enhanced subtitle
              Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      widget.subtitle,
                      style: AppTypography.bodyLarge.copyWith(
                        color: subtitleColor,
                        fontSize: 16,
                        height: 1.5,
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                  .animate()
                  .slideY(begin: 1, duration: 800.ms, delay: 400.ms)
                  .fadeIn(duration: 800.ms, delay: 400.ms),

              const Spacer(),

              // Optional loading dots animation
              Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: green.withOpacity(0.6),
                            ),
                          )
                          .animate(onPlay: (controller) => controller.repeat())
                          .fadeIn(duration: 600.ms, delay: (index * 200).ms)
                          .then()
                          .fadeOut(duration: 600.ms, delay: (index * 200).ms);
                    }),
                  )
                  .animate()
                  .slideY(begin: 1, duration: 800.ms, delay: 600.ms)
                  .fadeIn(duration: 800.ms, delay: 600.ms),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
