import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _showText = false;

  @override
  void initState() {
    super.initState();

    // Start typing shortly after the OS native splash screen transitions to Flutter
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _showText = true;
        });
      }
    });

    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    // Wait for typing to finish, then briefly pause before navigating
    // 200ms delay + (7 letters * 80ms) = 760ms. Total 1500ms means a ~740ms reading pause.
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      context.go('/admin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo for Web and Desktop only
            if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
              const SizedBox.shrink()
            else
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Image.asset(
                  'assets/images/s-orange.png',
                  height: 300, // Increased size
                ),
              ),
            // Letter by letter typing transition
            Opacity(
              opacity: _showText ? 1.0 : 0.0,
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Shiftly',
                    textStyle: const TextStyle(
                      fontFamily: 'Licorice',
                      fontSize: 120,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                    speed: const Duration(milliseconds: 80), // Smooth, quick typing
                  ),
                ],
                isRepeatingAnimation: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
