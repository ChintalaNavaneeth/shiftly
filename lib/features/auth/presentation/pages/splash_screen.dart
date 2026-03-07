import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    // Bounce animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _animation = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();

    // Show text after logo bounce
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      context.go('/admin');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bouncing Logo
            ScaleTransition(
              scale: _animation,
              child: Image.asset(
                'assets/images/s-orange.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.business_center,
                    size: 150,
                    color: AppColors.brandColor,
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Text appears AFTER logo bounce
            if (_showText)
              AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Shiftly',
                    textStyle: TextStyle(
                      fontFamily: 'Licorice',
                      fontSize: 120,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    speed: const Duration(milliseconds: 100),
                  ),
                ],
                isRepeatingAnimation: false,
              ),
          ],
        ),
      ),
    );
  }
}
