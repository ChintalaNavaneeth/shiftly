import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

import '../../../../core/theme/app_colors.dart';

enum SignUpStep {
  userTypeSelection,
  methodSelection,
  emailEntry,
  phoneEntry,
  otpVerification,
  detailsEntry,
}

// Tracks which sign-up method the user selected
enum SignUpMethod { email, phone, google, apple }

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  bool _isEmployee = false;
  SignUpStep _currentStep = SignUpStep.userTypeSelection;
  SignUpMethod _signUpMethod = SignUpMethod.email;

  // Controllers & FocusNodes
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _otpController = TextEditingController();
  final _otpFocusNode = FocusNode();

  // Timer for OTP
  Timer? _otpTimer;
  int _timerSeconds = 60;

  // Employer Controllers
  final _employerNameController = TextEditingController();
  final _employerAadharController = TextEditingController();
  final _employerBusinessNameController = TextEditingController();
  final _employerBusinessTypeController = TextEditingController();
  final _employerGstController = TextEditingController();
  final _employerLocationController = TextEditingController();
  final _employerPhoneController = TextEditingController();

  // Employee Controllers
  final _employeeNameController = TextEditingController();
  final _employeeAadharController = TextEditingController();
  final _employeePhoneController = TextEditingController();

  late AnimationController _cursorController;
  bool _showCursor = true;

  // Particle Animation

  late AnimationController _particleController;
  final List<_Particle> _particles = List.generate(50, (_) => _Particle());

  @override
  void initState() {
    super.initState();
    _cursorController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (mounted) setState(() => _showCursor = !_showCursor);
            _cursorController.reverse();
          } else if (status == AnimationStatus.dismissed) {
            if (mounted) setState(() => _showCursor = !_showCursor);
            _cursorController.forward();
          }
        });
    _cursorController.forward();

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _otpController.dispose();
    _otpFocusNode.dispose();
    _employerNameController.dispose();
    _employerAadharController.dispose();
    _employerBusinessNameController.dispose();
    _employerBusinessTypeController.dispose();
    _employerGstController.dispose();
    _employerLocationController.dispose();
    _employerPhoneController.dispose();
    _employeeNameController.dispose();
    _employeeAadharController.dispose();
    _employeePhoneController.dispose();
    _cursorController.dispose();
    _otpTimer?.cancel();
    _particleController.dispose();
    super.dispose();
  }

  void _resetModalState() {
    _currentStep = SignUpStep.userTypeSelection;
    _isEmployee = false;
    _signUpMethod = SignUpMethod.email;
    _emailController.clear();
    _passwordController.clear();
    _phoneController.clear();
    _otpController.clear();
    _employerNameController.clear();
    _employerAadharController.clear();
    _employerBusinessNameController.clear();
    _employerBusinessTypeController.clear();
    _employerGstController.clear();
    _employerLocationController.clear();
    _employerPhoneController.clear();
    _employeeNameController.clear();
    _employeeAadharController.clear();
    _employeePhoneController.clear();
    _otpTimer?.cancel();
    _timerSeconds = 60;
  }

  void _startOtpTimer(StateSetter setModalState) {
    _otpTimer?.cancel();
    _timerSeconds = 60;
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setModalState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        } else {
          _otpTimer?.cancel();
        }
      });
    });
  }

  void _showSignUpModal(BuildContext context) {
    _resetModalState();

    if (kIsWeb) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: _buildModalContent(context),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _buildModalContent(context),
      );
    }
  }

  Widget _buildModalContent(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: kIsWeb
                ? BorderRadius.circular(24)
                : const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppColors.black, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildModalHeader(context, setModalState),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 12.0,
                  ),
                  child: _buildStepContent(context, setModalState),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context, StateSetter setModalState) {
    bool showBack = _currentStep != SignUpStep.userTypeSelection;

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: AppColors.black,
                size: 28,
              ),
              onPressed: () {
                setModalState(() {
                  if (_currentStep == SignUpStep.methodSelection) {
                    _currentStep = SignUpStep.userTypeSelection;
                  } else if (_currentStep == SignUpStep.emailEntry ||
                      _currentStep == SignUpStep.phoneEntry) {
                    _currentStep = SignUpStep.methodSelection;
                  } else if (_currentStep == SignUpStep.otpVerification) {
                    _currentStep = SignUpStep.phoneEntry;
                    _phoneFocusNode.requestFocus();
                  } else if (_currentStep == SignUpStep.detailsEntry) {
                    _currentStep = SignUpStep.otpVerification;
                    _otpFocusNode.requestFocus();
                  }
                });
              },
            )
          else
            const SizedBox(width: 48),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.black, size: 28),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, StateSetter setModalState) {
    switch (_currentStep) {
      case SignUpStep.userTypeSelection:
        return _buildUserTypeSelection(setModalState);
      case SignUpStep.methodSelection:
        return _buildMethodSelection(setModalState);
      case SignUpStep.emailEntry:
        return _buildEmailEntry(setModalState);
      case SignUpStep.phoneEntry:
        return _buildPhoneEntry(setModalState);
      case SignUpStep.otpVerification:
        return _buildOtpVerification(setModalState);
      case SignUpStep.detailsEntry:
        return _buildDetailsEntry(setModalState);
    }
  }

  Widget _buildUserTypeSelection(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Join Shiftly as...',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Figtree',
          ),
        ),
        const SizedBox(height: 40),
        GestureDetector(
          onTap: () => setModalState(() => _isEmployee = !_isEmployee),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.black, width: 1.5),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  alignment: _isEmployee
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.brandColor,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: AppColors.black, width: 1.5),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          'Gig Employer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: !_isEmployee ? Colors.white : Colors.black,
                            fontFamily: 'Figtree',
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'Gig Employee',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isEmployee ? Colors.white : Colors.black,
                            fontFamily: 'Figtree',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () =>
              setModalState(() => _currentStep = SignUpStep.methodSelection),
          style: _primaryButtonStyle(),
          child: const Text(
            'Continue',
            style: TextStyle(fontFamily: 'Figtree'),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelection(StateSetter setModalState) {
    bool showApple = kIsWeb || Platform.isIOS || Platform.isMacOS;

    return Column(
      children: [
        const Text(
          'Create your account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'Figtree',
          ),
        ),
        const SizedBox(height: 32),
        _buildSocialButton(
          icon: Icons.email_outlined,
          label: 'Continue with Email',
          onPressed: () => setModalState(() {
            _signUpMethod = SignUpMethod.email;
            _currentStep = SignUpStep.emailEntry;
          }),
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          icon: Icons.phone_android_outlined,
          label: 'Continue with Phone',
          onPressed: () => setModalState(() {
            _signUpMethod = SignUpMethod.phone;
            _currentStep = SignUpStep.phoneEntry;
            _phoneFocusNode.requestFocus();
          }),
        ),
        const SizedBox(height: 12),
        _buildSocialButton(
          faIcon: FontAwesomeIcons.google,
          iconColor: const Color(0xFFDB4437),
          label: 'Sign up with Google',
          onPressed: () {},
        ),
        if (showApple) ...[
          const SizedBox(height: 12),
          _buildSocialButton(
            faIcon: FontAwesomeIcons.apple,
            label: 'Sign up with Apple',
            onPressed: () {},
          ),
        ],
      ],
    );
  }

  Widget _buildEmailEntry(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sign up with Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Figtree',
          ),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration('Email address'),
          style: const TextStyle(fontFamily: 'Figtree'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: _inputDecoration('Password'),
          style: const TextStyle(fontFamily: 'Figtree'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: _primaryButtonStyle(),
          child: const Text(
            'Create Account',
            style: TextStyle(fontFamily: 'Figtree'),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneEntry(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Sign up with Phone',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Figtree',
          ),
        ),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => _phoneFocusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 36,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.transparent, width: 1.5),
                  ),
                ),
                child: const Text(
                  '+',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Figtree',
                  ),
                ),
              ),
              const SizedBox(width: 4),
              ...['9', '1'].map((char) => _buildDigitBox(char)),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0,
                        child: TextField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          maxLength: 10,
                          onChanged: (_) => setModalState(() {}),
                          decoration: const InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: const TextStyle(fontFamily: 'Figtree'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(10, (index) {
                          String char = _phoneController.text.length > index
                              ? _phoneController.text[index]
                              : "";
                          bool isCurrent =
                              index == _phoneController.text.length;
                          return _buildUnderlineBox(
                            char,
                            isCurrent && _phoneFocusNode.hasFocus,
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => setModalState(() {
            _currentStep = SignUpStep.otpVerification;
            _otpFocusNode.requestFocus();
            _startOtpTimer(setModalState);
          }),
          style: _primaryButtonStyle(),
          child: const Text(
            'Send OTP',
            style: TextStyle(fontFamily: 'Figtree'),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpVerification(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Verify OTP',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Figtree',
              ),
            ),
            if (_timerSeconds > 0)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '(${_timerSeconds.toString().padLeft(2, '0')}s)',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Figtree',
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 32),
        GestureDetector(
          onTap: () => _otpFocusNode.requestFocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Opacity(
                opacity: 0,
                child: TextField(
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: (_) => setModalState(() {}),
                  decoration: const InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontFamily: 'Figtree'),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  String char = _otpController.text.length > index
                      ? _otpController.text[index]
                      : "";
                  bool isCurrent = index == _otpController.text.length;
                  return _buildOtpBox(
                    char,
                    isCurrent && _otpFocusNode.hasFocus,
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () => setModalState(() {
            _currentStep = SignUpStep.detailsEntry;
          }),
          style: _primaryButtonStyle(),
          child: const Text(
            'Continue',
            style: TextStyle(fontFamily: 'Figtree'),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsEntry(StateSetter setModalState) {
    return _isEmployee
        ? _buildEmployeeDetails(setModalState)
        : _buildEmployerDetails(setModalState);
  }

  Widget _buildEmployerDetails(StateSetter setModalState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Employer Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All fields are mandatory',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Business Owner Name'),
          TextFormField(
            controller: _employerNameController,
            decoration: _inputDecoration('Enter name'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Owner Aadhar Number'),
          TextFormField(
            controller: _employerAadharController,
            decoration: _inputDecoration('12 digit number'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          _buildUploadButton(
            'Upload Unmasked Aadhar PDF',
            Icons.picture_as_pdf,
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Business Name'),
          TextFormField(
            controller: _employerBusinessNameController,
            decoration: _inputDecoration('Enter business name'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Business Type'),
          TextFormField(
            controller: _employerBusinessTypeController,
            decoration: _inputDecoration('e.g. Retail, Service'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('GST Number'),
          TextFormField(
            controller: _employerGstController,
            decoration: _inputDecoration('15 digit code'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Current Location'),
          TextFormField(
            controller: _employerLocationController,
            decoration: _inputDecoration('Add address'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          // Phone sign-up: collect email; Email sign-up: collect phone
          if (_signUpMethod == SignUpMethod.phone) ...[
            _buildFormLabel('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Enter email address'),
              style: const TextStyle(fontFamily: 'Figtree'),
            ),
          ] else ...[
            _buildFormLabel('Phone Number'),
            TextFormField(
              controller: _employerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('10 digit mobile'),
              style: const TextStyle(fontFamily: 'Figtree'),
            ),
          ],
          const SizedBox(height: 24),
          _buildFormLabel('Business Location Pictures (3)'),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildImagePlaceholder(),
              _buildImagePlaceholder(),
              _buildImagePlaceholder(),
            ],
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: _primaryButtonStyle(),
            child: const Text(
              'Submit & Finish',
              style: TextStyle(fontFamily: 'Figtree'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeDetails(StateSetter setModalState) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Employee Details',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'All fields are mandatory',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Full Name'),
          TextFormField(
            controller: _employeeNameController,
            decoration: _inputDecoration('Enter your name'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 16),
          // Phone sign-up: collect email; Email sign-up: collect phone
          if (_signUpMethod == SignUpMethod.phone) ...[
            _buildFormLabel('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Enter email address'),
              style: const TextStyle(fontFamily: 'Figtree'),
            ),
          ] else ...[
            _buildFormLabel('Phone Number'),
            TextFormField(
              controller: _employeePhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('10 digit mobile'),
              style: const TextStyle(fontFamily: 'Figtree'),
            ),
          ],
          const SizedBox(height: 16),
          _buildFormLabel('Aadhar Card Details'),
          TextFormField(
            controller: _employeeAadharController,
            decoration: _inputDecoration('12 digit number'),
            style: const TextStyle(fontFamily: 'Figtree'),
          ),
          const SizedBox(height: 12),
          _buildUploadButton(
            'Upload Unmasked Aadhar PDF',
            Icons.picture_as_pdf,
          ),
          const SizedBox(height: 24),
          _buildFormLabel('Profile Picture'),
          _buildImagePlaceholder(isSquare: true, label: "Upload Photo"),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: _primaryButtonStyle(),
            child: const Text(
              'Complete Profile',
              style: TextStyle(fontFamily: 'Figtree'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          fontFamily: 'Figtree',
        ),
      ),
    );
  }

  Widget _buildUploadButton(String label, IconData icon) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.black, width: 1),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: AppColors.brandColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                fontFamily: 'Figtree',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder({bool isSquare = false, String? label}) {
    return InkWell(
      onTap: () {},
      child: Container(
        width: isSquare ? 120 : 100,
        height: isSquare ? 120 : 80,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.black,
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[100],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
            if (label != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'Figtree',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitBox(String char) {
    return Container(
      width: 18,
      height: 36,
      margin: const EdgeInsets.only(right: 4),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.black, width: 2)),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Figtree',
        ),
      ),
    );
  }

  Widget _buildUnderlineBox(String char, bool isCurrent) {
    return Container(
      width: 18,
      height: 36,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.black, width: 2)),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          if (isCurrent && _showCursor)
            Container(width: 1.5, height: 20, color: AppColors.black),
        ],
      ),
    );
  }

  Widget _buildOtpBox(String char, bool isCurrent) {
    return Container(
      width: 40,
      height: kIsWeb ? 50 : 40,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.black, width: 2)),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          if (isCurrent && _showCursor)
            Container(width: 1.5, height: 24, color: AppColors.black),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'Figtree'),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brandColor, width: 2),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: const BorderSide(color: AppColors.black, width: 2),
      ),
      elevation: 0,
    );
  }

  Widget _buildSocialButton({
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
        side: const BorderSide(color: AppColors.black, width: 2),
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
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
              fontFamily: 'Figtree',
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      shape: const Border(bottom: BorderSide(color: AppColors.black, width: 2)),
      automaticallyImplyLeading: false,
      title: Image.asset('assets/images/s-orange.png', height: 32),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: ElevatedButton(
            onPressed: () => _showSignUpModal(context),
            style: _primaryButtonStyle().copyWith(
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
            ),
            child: const Text(
              'Sign In',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Figtree',
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // Global Particle Overlay
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _ParticlePainter(
                    _particles,
                    _particleController.value,
                  ),
                );
              },
            ),
          ),
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroSection(context),
                _buildFeaturesSection(context),
                _buildInteractiveFlowSection(context),
                _buildPaymentSection(context),
                _buildAboutAndFooter(context),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.brandColor,
        elevation: 0,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.black, width: 1.5),
        ),
        child: const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.textOnColor,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 140, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [AppColors.brandColor.withOpacity(0.05), AppColors.white],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Experience the future of',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Figtree',
              height: 1.1,
            ),
          ),
          const Text(
            'Shift Work',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 84,
              fontWeight: FontWeight.w900,
              fontFamily: 'Figtree',
              color: AppColors.brandColor,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Connect with top gig employers and employees in real-time. Trust, efficiency, and seamless payments all in one place.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontFamily: 'Figtree',
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 56),
          _buildModernCTA(context),
        ],
      ),
    );
  }

  Widget _buildModernCTA(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showSignUpModal(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: AppColors.black, width: 2),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            'Get Started Now',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFamily: 'Figtree',
            ),
          ),
          SizedBox(width: 12),
          Icon(Icons.arrow_forward, size: 26),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      color: AppColors.white,
      child: Column(
        children: [
          const Text(
            'Why Choose Shiftly?',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 100),
          MediaQuery.of(context).size.width < 1200
              ? SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: Row(
                    children: [
                      _buildBorderCard(
                        icon: Icons.location_on_outlined,
                        title: 'Local Matching',
                        description:
                            'Our application connects you with the right opportunities based on your proximity.',
                        width: MediaQuery.of(context).size.width * 0.75,
                      ),
                      const SizedBox(width: 20),
                      _buildBorderCard(
                        icon: Icons.track_changes_outlined,
                        title: 'Real-time Tracking',
                        description:
                            'Monitor shifts, check-ins, and performance metrics as they happen.',
                        width: MediaQuery.of(context).size.width * 0.75,
                      ),
                      const SizedBox(width: 20),
                      _buildBorderCard(
                        icon: Icons.support_agent_outlined,
                        title: '24/7 Support',
                        description:
                            'Our dedicated team is always here to ensure smooth support and operation.',
                        width: MediaQuery.of(context).size.width * 0.75,
                      ),
                    ],
                  ),
                )
              : Wrap(
                  spacing: 32,
                  runSpacing: 32,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildBorderCard(
                      icon: Icons.location_on_outlined,
                      title: 'Local Matching',
                      description:
                          'Our application connects you with the right opportunities based on your proximity.',
                    ),
                    _buildBorderCard(
                      icon: Icons.track_changes_outlined,
                      title: 'Real-time Tracking',
                      description:
                          'Monitor shifts, check-ins, and performance metrics as they happen.',
                    ),
                    _buildBorderCard(
                      icon: Icons.support_agent_outlined,
                      title: '24/7 Support',
                      description:
                          'Our dedicated team is always here to ensure smooth support and operation.',
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildBorderCard({
    required IconData icon,
    required String title,
    required String description,
    double? width,
  }) {
    final isSmall = width != null && width < 350;
    return Container(
      width: width ?? 380,
      padding: EdgeInsets.all(isSmall ? 24 : 48),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.black, width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.brandColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 48, color: AppColors.brandColor),
          ),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 20),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              color: AppColors.textSecondary,
              fontFamily: 'Figtree',
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveFlowSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 100, horizontal: 24),
      color: AppColors.backgroundPrimary,
      child: Column(
        children: [
          const Text(
            'How Shiftly Works',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontFamily: 'Figtree',
            ),
          ),
          const SizedBox(height: 64),
          _buildFlowToggle(),
          const SizedBox(height: 80),
          _buildFlowSteps(),
        ],
      ),
    );
  }

  Widget _buildFlowToggle() {
    return Center(
      child: GestureDetector(
        onTap: () => setState(() => _isEmployee = !_isEmployee),
        child: Container(
          width: 400,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.black, width: 2),
          ),
          child: Stack(
            children: [
              AnimatedAlign(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                alignment: _isEmployee
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.brandColor,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.black, width: 2),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Gig Employer',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: !_isEmployee
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontFamily: 'Figtree',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Gig Employee',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isEmployee
                              ? Colors.white
                              : AppColors.textSecondary,
                          fontFamily: 'Figtree',
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlowSteps() {
    final List<Map<String, dynamic>> steps = _isEmployee
        ? [
            {'icon': Icons.person_add_outlined, 'label': 'Register'},
            {'icon': Icons.search_outlined, 'label': 'Find Gig'},
            {'icon': Icons.location_on_outlined, 'label': 'Check-in/Out'},
            {'icon': Icons.task_alt_outlined, 'label': 'Complete Task'},
            {
              'icon': Icons.account_balance_wallet_outlined,
              'label': 'Get Paid',
            },
          ]
        : [
            {'icon': Icons.business_outlined, 'label': 'Register'},
            {'icon': Icons.post_add_outlined, 'label': 'Post Gig'},
            {'icon': Icons.lock_clock_outlined, 'label': 'Reserve Funds'},
            {'icon': Icons.person_search_outlined, 'label': 'Select Employees'},
            {'icon': Icons.handshake_outlined, 'label': 'Settle Payment'},
          ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: MediaQuery.of(context).size.width < 1200
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Row(
                children: List.generate(steps.length, (index) {
                  return _buildFlowStepItem(steps, index);
                }),
              ),
            )
          : Wrap(
              key: ValueKey<bool>(_isEmployee),
              alignment: WrapAlignment.center,
              spacing: 0,
              runSpacing: 48,
              children: List.generate(steps.length, (index) {
                return _buildFlowStepItem(steps, index);
              }),
            ),
    );
  }

  Widget _buildFlowStepItem(List<Map<String, dynamic>> steps, int index) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 150,
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: 0.8 + (0.2 * scale),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.black, width: 2),
                      ),
                      child: Icon(
                        steps[index]['icon'],
                        color: AppColors.brandColor,
                        size: 36,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                steps[index]['label'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: 'Figtree',
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (index < steps.length - 1)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ),
      ],
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 120, horizontal: 24),
      color: AppColors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Powered by ',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Figtree',
                ),
              ),
              Image.asset(
                'assets/images/razorpay.png',
                height: 48,
                errorBuilder: (c, e, s) => const Text(
                  'Razorpay',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 64),
          Container(
            constraints: const BoxConstraints(maxWidth: 900),
            padding: EdgeInsets.all(
              MediaQuery.of(context).size.width < 600 ? 24 : 64,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: AppColors.black, width: 2),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.security_outlined,
                  size: 80,
                  color: AppColors.brandColor,
                ),
                const SizedBox(height: 32),
                Text(
                  'Your Funds Are Safe',
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width < 600 ? 28 : 36,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Figtree',
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: const Text(
                    'With Razorpay UPI Reserve Pay, your funds are only reserved when you book a worker. Payment is only settled after the job is completed and both parties are satisfied.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      height: 1.8,
                      color: AppColors.textSecondary,
                      fontFamily: 'Figtree',
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                MediaQuery.of(context).size.width < 768
                    ? Column(
                        children: [
                          _buildPaymentStep(
                            Icons.lock_outlined,
                            'Reserve',
                            'Funds locked',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.grey,
                            ),
                          ),
                          _buildPaymentStep(
                            Icons.verified_user_outlined,
                            'Work Done',
                            'Task completed',
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Icon(
                              Icons.arrow_downward,
                              color: Colors.grey,
                            ),
                          ),
                          _buildPaymentStep(
                            Icons.currency_rupee,
                            'Settle',
                            'Payment released',
                          ),
                        ],
                      )
                    : _buildPaymentLogicVisual(),
                const SizedBox(height: 64),
                _buildModernMoreInfoButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMoreInfoButton() {
    return ElevatedButton.icon(
      onPressed: () => launchUrl(
        Uri.parse(
          'https://razorpay.com/docs/payments/recurring-payments/upi-reserve-pay/',
        ),
      ),
      icon: const Icon(Icons.info_outline, color: Colors.white, size: 24),
      label: const Text(
        'More Info',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
          fontFamily: 'Figtree',
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
          side: const BorderSide(color: AppColors.black, width: 2),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildPaymentLogicVisual() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildPaymentStep(Icons.lock_outlined, 'Reserve', 'Funds locked'),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildPaymentStep(
          Icons.verified_user_outlined,
          'Work Done',
          'Task completed',
        ),
        const Icon(Icons.arrow_forward, color: Colors.grey),
        _buildPaymentStep(Icons.currency_rupee, 'Settle', 'Payment released'),
      ],
    );
  }

  Widget _buildPaymentStep(IconData icon, String title, String sub) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppColors.brandColor),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAboutAndFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      color: AppColors.black,
      child: Column(
        children: [
          const Text(
            'About Shiftly',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: const Text(
              'Shiftly is born from a desire to redefine how shift-based work happens. We bridge the gap between talented individuals looking for flexible work and employers needing reliable, short-term labor. By combining real-time matching with secure, milestone-based payments, we create a marketplace where everyone wins.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
                height: 1.8,
              ),
            ),
          ),
          const SizedBox(height: 80),
          const Divider(color: Colors.white24, indent: 40, endIndent: 40),
          const SizedBox(height: 80),
          Image.asset('assets/images/s-orange.png', height: 48),
          const SizedBox(height: 24),
          const Text(
            '© 2026 Shiftly. All rights reserved.',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('Privacy Policy'),
              const SizedBox(width: 24),
              _buildFooterLink('Terms of Service'),
              const SizedBox(width: 24),
              _buildFooterLink('Contact Us'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String label) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: Colors.white70,
          fontFamily: 'Figtree',
        ),
      ),
    );
  }
}

class _Particle {
  double x = 0;
  double y = 0;
  double angle = 0;
  double speed = 0;
  double length = 0;
  Color color = Colors.white;

  _Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    angle = math.Random().nextDouble() * math.pi * 2;
    speed = 0.001 + math.Random().nextDouble() * 0.003;
    length = 20 + math.Random().nextDouble() * 40;
    color = math.Random().nextBool()
        ? Colors.white.withOpacity(0.4)
        : AppColors.brandColor.withOpacity(0.15);
  }

  void move() {
    x += math.cos(angle) * speed;
    y += math.sin(angle) * speed;
    if (x < -0.1 || x > 1.1 || y < -0.1 || y > 1.1) reset();
  }
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double animationValue;

  _ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.move();
      final tailX =
          particle.x * size.width - math.cos(particle.angle) * particle.length;
      final tailY =
          particle.y * size.height - math.sin(particle.angle) * particle.length;

      final paint = Paint()
        ..shader = ui.Gradient.linear(
          Offset(particle.x * size.width, particle.y * size.height),
          Offset(tailX, tailY),
          [particle.color, Colors.transparent],
        )
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(particle.x * size.width, particle.y * size.height),
        Offset(tailX, tailY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
