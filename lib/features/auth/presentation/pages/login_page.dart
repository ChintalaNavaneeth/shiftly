import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  bool _isEmailLogin = false;
  bool _isPhoneLogin = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  late AnimationController _cursorController;
  bool _showCursor = true;

  @override
  void initState() {
    super.initState();
    _cursorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          setState(() {
            _showCursor = !_showCursor;
          });
          _cursorController.reverse();
        } else if (status == AnimationStatus.dismissed) {
          setState(() {
            _showCursor = !_showCursor;
          });
          _cursorController.forward();
        }
      });
    _cursorController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _cursorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Apple login available on iOS, Web, and Desktop platforms
    bool showAppleLogin =
        kIsWeb ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isWindows ||
        Platform.isLinux;

    bool showMainOptions = !_isEmailLogin && !_isPhoneLogin;

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 60.0,
            ), // Increased top/bottom space
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Stack(
                children: [
                  Card(
                    elevation: 2,
                    color: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side:
                          const BorderSide(color: AppColors.black, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Logo
                          Center(
                            child: Image.asset(
                              'assets/images/s-orange.png',
                              height: 80,
                            ),
                          ),
                          const SizedBox(height: 32),

                          if (showMainOptions) ...[
                            // Selection View
                            _buildLoginButton(
                              icon: Icons.email_outlined,
                              label: 'Login with Email',
                              onPressed: () {
                                setState(() {
                                  _isEmailLogin = true;
                                  _isPhoneLogin = false;
                                });
                              },
                            ),
                            const SizedBox(height: 12),

                            // Phone Login
                            _buildLoginButton(
                              icon: Icons.phone_android_outlined,
                              label: 'Login with Phone',
                              onPressed: () {
                                setState(() {
                                  _isPhoneLogin = true;
                                  _isEmailLogin = false;
                                });
                              },
                            ),
                            const SizedBox(height: 24),
                          ] else if (_isEmailLogin) ...[
                            // Email Login View
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'Email address',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.linkBlue,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In Button
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandColor,
                                foregroundColor: AppColors.textOnColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Sign in',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else if (_isPhoneLogin) ...[
                            // Phone Login View
                            const Text(
                              'Enter your phone number',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GestureDetector(
                              onTap: () => _phoneFocusNode.requestFocus(),
                              behavior: HitTestBehavior.opaque,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Styled +91 Prefix
                                  const Text(
                                    '+',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  ...['9', '1'].map((char) => Container(
                                        width: 24,
                                        height: 40,
                                        margin: const EdgeInsets.only(right: 4),
                                        decoration: const BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: AppColors.black,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text(
                                          char,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.black,
                                          ),
                                        ),
                                      )),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Stack(
                                      alignment: Alignment.centerLeft,
                                      children: [
                                        // Hidden TextField for input
                                        SizedBox(
                                          height: 40,
                                          child: Opacity(
                                            opacity: 0,
                                            child: TextField(
                                              controller: _phoneController,
                                              focusNode: _phoneFocusNode,
                                              keyboardType:
                                                  TextInputType.number,
                                              maxLength: 10,
                                              autofocus: true,
                                              onChanged: (_) => setState(() {}),
                                              decoration:
                                                  const InputDecoration(
                                                counterText: "",
                                                border: InputBorder.none,
                                                isDense: true,
                                                contentPadding: EdgeInsets.zero,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Custom underscore UI
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: List.generate(10, (index) {
                                            String char = "";
                                            bool isCurrent = index ==
                                                _phoneController.text.length;
                                            if (_phoneController.text.length >
                                                index) {
                                              char = _phoneController
                                                  .text[index];
                                            }
                                            return Container(
                                              width: 24,
                                              height: 40,
                                              decoration: const BoxDecoration(
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: AppColors.black,
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Text(
                                                    char,
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.black,
                                                    ),
                                                  ),
                                                  if (isCurrent &&
                                                      _phoneFocusNode.hasFocus &&
                                                      _showCursor)
                                                    Container(
                                                      width: 2,
                                                      height: 24,
                                                      color: AppColors.black,
                                                    ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Send OTP Button
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandColor,
                                foregroundColor: AppColors.textOnColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Send OTP',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],

                          if (showMainOptions) ...[
                            const Divider(color: AppColors.black, thickness: 1),
                            const SizedBox(height: 16),

                            // Google Login
                            _buildLoginButton(
                              faIcon: FontAwesomeIcons.google,
                              iconColor: const Color(0xFFDB4437),
                              label: 'Sign in with Google',
                              onPressed: () {},
                            ),

                            if (showAppleLogin) ...[
                              const SizedBox(height: 12),
                              _buildLoginButton(
                                faIcon: FontAwesomeIcons.apple,
                                label: 'Sign in with Apple',
                                onPressed: () {},
                              ),
                            ],

                            const SizedBox(height: 16),
                            const Divider(color: AppColors.black, thickness: 1),
                            const SizedBox(height: 24),

                            // "New to Shiftly?" button
                            ElevatedButton(
                              onPressed: () => context.push('/dashboard'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brandColor,
                                foregroundColor: AppColors.textOnColor,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: AppColors.black,
                                    width: 1.5,
                                  ),
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
                        ],
                      ),
                    ),
                  ),
                  if (!showMainOptions)
                    Positioned(
                      top: 12,
                      left: 12,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back,
                            color: AppColors.black),
                        onPressed: () {
                          setState(() {
                            _isEmailLogin = false;
                            _isPhoneLogin = false;
                          });
                        },
                      ),
                    ),
                ],
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
              child: FaIcon(
                faIcon,
                color: iconColor ?? AppColors.black,
                size: 20,
              ),
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
