import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Apple login available on iOS, Web, and Desktop platforms
    bool showAppleLogin =
        kIsWeb ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Card(
                elevation: 2,
                color: AppColors.white, // Pure white background as requested
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.black, width: 1.5), // Black border
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Center(
                        child: Image.asset(
                          'assets/images/s-orange.png',
                          height: 120,
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Email Login
                      _buildLoginButton(
                        icon: Icons.email_outlined,
                        label: 'Login with Email',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 16),

                      // Phone Login
                      _buildLoginButton(
                        icon: Icons.phone_android_outlined,
                        label: 'Login with Phone',
                        onPressed: () {},
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              color: AppColors.linkBlue, // Blue color for links
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(color: AppColors.black, thickness: 1),
                      const SizedBox(height: 24),

                      // Google Login with FontAwesome Icon
                      _buildLoginButton(
                        faIcon: FontAwesomeIcons.google,
                        iconColor: const Color(0xFFDB4437), // Google Red
                        label: 'Sign in with Google',
                        onPressed: () {},
                      ),

                      if (showAppleLogin) ...[
                        const SizedBox(height: 16),
                        _buildLoginButton(
                          faIcon: FontAwesomeIcons.apple,
                          label: 'Sign in with Apple',
                          onPressed: () {},
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(color: AppColors.black, thickness: 1),
                      const SizedBox(height: 32),

                      // "New to Shiftly?" button
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandColor,
                          foregroundColor: AppColors.textOnColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.black, width: 1.5),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'New to Shiftly?',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton({
    IconData? icon,
    IconData? faIcon,
    Color? iconColor,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: AppColors.black, width: 1.5),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (faIcon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: FaIcon(faIcon, color: iconColor ?? AppColors.black, size: 20),
            )
          else if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Icon(icon, color: AppColors.black, size: 24),
            ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
