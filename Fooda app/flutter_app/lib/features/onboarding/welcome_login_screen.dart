import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/backup_service.dart';
import '../../features/auth/auth_service.dart';
import '../../l10n/app_localizations.dart';
import '../main_navigation/main_navigation_screen.dart';
import 'enhanced_onboarding_screen.dart';
import 'package:provider/provider.dart';
import '../../features/membership/providers/membership_provider.dart';
import 'models/onboarding_step.dart';

class WelcomeLoginScreen extends StatefulWidget {
  const WelcomeLoginScreen({super.key});

  @override
  State<WelcomeLoginScreen> createState() => _WelcomeLoginScreenState();
}

class _WelcomeLoginScreenState extends State<WelcomeLoginScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Apple 登入
      final success = await AuthService.signInWithApple();
      if (!success) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;

      if (!mounted) return;

      // CloudKit restore removed
      // final restoreSuccess = await BackupService.restoreFromCloud(context);
      
      // Directly proceed to onboarding or main screen
      // Since we removed cloud restore, we treat it as a fresh start or local login
      // But for consistency with previous logic flow:
      
      final prefs = await SharedPreferences.getInstance();
      // Check if tutorial was previously completed (locally)
      final bool tutorialCompleted = prefs.getBool('tutorial_completed') ?? false;

      if (tutorialCompleted) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const MainNavigationScreen(shouldShowTutorial: false),
              ),
            );
          }
      } else {
          // New user or tutorial not completed
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => EnhancedOnboardingScreen(
                initialStep: OnboardingStep.bodyData,
              ),
            ),
          );
      }
    } catch (e) {
      print('Sign in error: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2563EB), // Blue 600
              Color(0xFF60A5FA), // Blue 400
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 64,
                    color: Color(0xFF2563EB),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Title
                Text(
                  l10n.welcomeTitle,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Subtitle
                Text(
                  l10n.welcomeSubtitle,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const Spacer(),
                
                  // Fixed height container to prevent layout jump
                  SizedBox(
                    height: 120, // Increased height for two buttons
                    child: Column(
                      children: [
                        _isLoading
                            ? const Center(
                                child: CircularProgressIndicator(color: Colors.white),
                              )
                            : SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                height: 50,
                                child: SignInWithAppleButton(
                                  onPressed: _handleSignIn,
                                  text: AppLocalizations.of(context)!.signInWithApple,
                                  style: SignInWithAppleButtonStyle.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => _showEmailLoginDialog(context),
                          child: Text(
                            AppLocalizations.of(context)!.loginWithEmail ?? 'Login with Email',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showEmailLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.loginWithEmail ?? 'Login with Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: l10n.email ?? 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: l10n.password ?? 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              
              if (email == 'review@fooda.app' && password == 'fooda888') {
                // Reviewer Login: Reset all state to force full onboarding & tutorial flow
                 final prefs = await SharedPreferences.getInstance();
                 await prefs.setBool('tutorial_completed', false);
                 await prefs.setBool('onboarding_completed', false);
                 // Reset other relevant keys if necessary to ensure a "fresh" experience
                 
                 if (context.mounted) {
                   Navigator.pop(context); // Close dialog
                   
                   // Navigate to Onboarding Flow
                   Navigator.of(context).pushAndRemoveUntil(
                     MaterialPageRoute(
                       builder: (_) => EnhancedOnboardingScreen(
                         initialStep: OnboardingStep.bodyData,
                       ),
                     ),
                     (route) => false,
                   );
                 }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.invalidCredentials ?? 'Invalid credentials'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.login ?? 'Login'),
          ),
        ],
      ),
    );
  }
}
