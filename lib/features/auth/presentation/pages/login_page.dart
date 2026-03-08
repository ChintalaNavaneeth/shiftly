import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    bool isIOS = !kIsWeb && Platform.isIOS;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0), // Increased top/bottom padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      color: AppColors.textSecondary,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFCCCCCC), thickness: 1),
              const SizedBox(height: 24),
              
              // Google Login
              _buildLoginButton(
                icon: Icons.login, // Replace with custom icon if available
                label: 'Sign in with Google',
                onPressed: () {},
              ),
              
              if (isIOS) ...[
                const SizedBox(height: 16),
                _buildLoginButton(
                  icon: Icons.apple,
                  label: 'Sign in with Apple',
                  onPressed: () {},
                ),
              ],
              
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFCCCCCC), thickness: 1),
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
                    side: const BorderSide(color: Colors.black, width: 1.5),
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
    );
  }

  Widget _buildLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.black, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
