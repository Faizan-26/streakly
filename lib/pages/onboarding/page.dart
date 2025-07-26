import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:streakly/pages/onboarding/on_boarding_pages.dart';
import 'package:streakly/theme/app_colors.dart';
import 'package:streakly/theme/app_typography.dart';
import 'package:streakly/widgets/primary_button.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: darkGreen,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        child: Stack(
          children: [
            // WORD MAP HERE
            Center(
              child:
                  Image.asset(
                        'assets/worldmap.png',
                        // width: 300,
                        // height: 300,
                        fit: BoxFit.cover,
                      )
                      .animate()
                      .fadeIn(duration: 1200.ms, delay: 150.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 1500.ms,
                        delay: 200.ms,
                      ),
            ),
            Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50), // Space at the top
                // ICON
                Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/logo.png', width: 60, height: 60),
                        SizedBox(width: 10),
                        Text(
                          'Streakly',
                          style: AppTypography.headlineMedium.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                    .animate()
                    .slideY(begin: -1, duration: 800.ms)
                    .fadeIn(duration: 800.ms),

                Spacer(),
                // SizedBox(height: 10), // Space between image and button
                Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 4 DOTS HERE
                            Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                )
                                .animate()
                                .slideX(
                                  begin: -1,
                                  duration: 600.ms,
                                  delay: 400.ms,
                                )
                                .fadeIn(duration: 600.ms, delay: 400.ms),
                            SizedBox(height: 10),
                            Text(
                                  'Welcome \nto Streakly',
                                  style: AppTypography.displayMedium.copyWith(
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                )
                                .animate()
                                .slideY(
                                  begin: 1,
                                  duration: 800.ms,
                                  delay: 600.ms,
                                )
                                .fadeIn(duration: 800.ms, delay: 600.ms),
                            SizedBox(height: 10),
                            Text(
                                  'Track your habits and achieve your with Streakly.',
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: Colors.white70,
                                  ),
                                )
                                .animate()
                                .slideY(
                                  begin: 1,
                                  duration: 800.ms,
                                  delay: 800.ms,
                                )
                                .fadeIn(duration: 800.ms, delay: 800.ms),
                            SizedBox(height: 24),
                          ],
                        ),
                      ),
                    )
                    .animate()
                    .slideY(begin: 1, duration: 1000.ms, delay: 200.ms)
                    .fadeIn(duration: 1000.ms, delay: 200.ms),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child:
                      primaryButton(
                            text: "Get Started",
                            onPressed: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => OnBoardingPages(),
                                ),
                              );
                            },
                          )
                          .animate()
                          .slideY(begin: 1, duration: 800.ms, delay: 1000.ms)
                          .fadeIn(duration: 800.ms, delay: 800.ms),
                ),
                // SizedBox(height: 8), // Space at the top
              ],
            ),
          ],
        ),
      ),
    );
  }
}
