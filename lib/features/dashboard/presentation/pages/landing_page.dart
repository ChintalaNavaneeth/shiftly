import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isEmployee = false;

  void _showSignUpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {

            return Container(
              height: MediaQuery.of(context).size.height * 0.45,
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(
                  top: BorderSide(color: AppColors.black, width: 1.5),
                  left: BorderSide(color: AppColors.black, width: 1.5),
                  right: BorderSide(color: AppColors.black, width: 1.5),
                ),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48), // Space for back button
                        const Text(
                          'Join Shiftly as...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Custom Toggle Switch
                        Center(
                          child: GestureDetector(
                            onTap: () => setModalState(() => _isEmployee = !_isEmployee),
                            child: Container(
                              width: 300,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(color: AppColors.black, width: 1.5),
                              ),
                              child: Stack(
                                children: [
                                  // Sliding Background
                                  AnimatedAlign(
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                    alignment: _isEmployee ? Alignment.centerRight : Alignment.centerLeft,
                                    child: Container(
                                      width: 150,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: AppColors.brandColor,
                                        borderRadius: BorderRadius.circular(30),
                                        border: Border.all(color: AppColors.black, width: 1.5),
                                      ),
                                    ),
                                  ),
                                  // Text Labels
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Center(
                                          child: Text(
                                            'Gig Employer',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: !_isEmployee ? AppColors.white : AppColors.black,
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
                                              color: _isEmployee ? AppColors.white : AppColors.black,
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
                        ),
                        const Spacer(),
                        
                        // Continue Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            // Handle navigation based on selection
                          },
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
                            'Continue',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  
                  // Back Button (Top Left)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.black, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/s-orange.png',
          height: 32,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () => _showSignUpModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandColor,
                foregroundColor: AppColors.textOnColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: AppColors.black, width: 1.5),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          const Center(
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
          Positioned(
            top: 12,
            left: 12,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.black),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Chat logic
        },
        backgroundColor: AppColors.brandColor,
        elevation: 0, // Flat design consistent with app
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.black, width: 1.5),
        ),
        child:
            const Icon(Icons.chat_bubble_outline, color: AppColors.textOnColor),
      ),
    );
  }
}
