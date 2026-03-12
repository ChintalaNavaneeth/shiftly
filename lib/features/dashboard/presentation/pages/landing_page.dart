import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
    with SingleTickerProviderStateMixin {
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
            border: Border.all(color: AppColors.black, width: 1.5),
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
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
          child: const Text('Continue'),
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
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration('Email address'),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: true,
          decoration: _inputDecoration('Password'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: _primaryButtonStyle(),
          child: const Text('Create Account'),
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: List.generate(10, (index) {
                          String char = _phoneController.text.length > index
                              ? _phoneController.text[index]
                              : "";
                          bool isCurrent = index == _phoneController.text.length;
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
          child: const Text('Send OTP'),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          child: const Text('Continue'),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'All fields are mandatory',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Business Owner Name'),
          TextFormField(
            controller: _employerNameController,
            decoration: _inputDecoration('Enter name'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Owner Aadhar Number'),
          TextFormField(
            controller: _employerAadharController,
            decoration: _inputDecoration('12 digit number'),
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
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Business Type'),
          TextFormField(
            controller: _employerBusinessTypeController,
            decoration: _inputDecoration('e.g. Retail, Service'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('GST Number'),
          TextFormField(
            controller: _employerGstController,
            decoration: _inputDecoration('15 digit code'),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Current Location'),
          TextFormField(
            controller: _employerLocationController,
            decoration: _inputDecoration('Add address'),
          ),
          const SizedBox(height: 16),
          // Phone sign-up: collect email; Email sign-up: collect phone
          if (_signUpMethod == SignUpMethod.phone) ...[
            _buildFormLabel('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Enter email address'),
            ),
          ] else ...[
            _buildFormLabel('Phone Number'),
            TextFormField(
              controller: _employerPhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('10 digit mobile'),
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
            child: const Text('Submit & Finish'),
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'All fields are mandatory',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          _buildFormLabel('Full Name'),
          TextFormField(
            controller: _employeeNameController,
            decoration: _inputDecoration('Enter your name'),
          ),
          const SizedBox(height: 16),
          // Phone sign-up: collect email; Email sign-up: collect phone
          if (_signUpMethod == SignUpMethod.phone) ...[
            _buildFormLabel('Email Address'),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputDecoration('Enter email address'),
            ),
          ] else ...[
            _buildFormLabel('Phone Number'),
            TextFormField(
              controller: _employeePhoneController,
              keyboardType: TextInputType.phone,
              decoration: _inputDecoration('10 digit mobile'),
            ),
          ],
          const SizedBox(height: 16),
          _buildFormLabel('Aadhar Card Details'),
          TextFormField(
            controller: _employeeAadharController,
            decoration: _inputDecoration('12 digit number'),
          ),
          const SizedBox(height: 12),
          _buildUploadButton('Upload Unmasked Aadhar PDF', Icons.picture_as_pdf),
          const SizedBox(height: 24),
          _buildFormLabel('Profile Picture'),
          _buildImagePlaceholder(isSquare: true, label: "Upload Photo"),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: _primaryButtonStyle(),
            child: const Text('Complete Profile'),
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
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
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
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
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
        border: Border(bottom: BorderSide(color: AppColors.black, width: 1.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        char,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUnderlineBox(String char, bool isCurrent) {
    return Container(
      width: 18,
      height: 36,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.black, width: 1.5)),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
        border: Border(bottom: BorderSide(color: AppColors.black, width: 1.5)),
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            char,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.black, width: 1.5),
      ),
    );
  }

  ButtonStyle _primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppColors.brandColor,
      foregroundColor: AppColors.textOnColor,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.black, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        automaticallyImplyLeading: kIsWeb ? false : true,
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
                'Sign Up',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: const Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_outlined,
                  size: 80,
                  color: AppColors.brandColor,
                ),
                SizedBox(height: 24),
                Text(
                  'Landing Page',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Welcome to Shiftly',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
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
}
