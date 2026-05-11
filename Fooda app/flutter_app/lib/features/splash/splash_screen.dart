import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main_navigation/main_navigation_screen.dart';
import '../onboarding/welcome_login_screen.dart';
import '../../l10n/app_localizations.dart';

/// 啟動畫面
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconScaleAnimation;
  late Animation<double> _iconFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _subtitleFadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _navigateToHome();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // 1. Icon Animation (0.0 - 0.5)
    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      ),
    );
    
    _iconFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // 2. Title Animation (0.3 - 0.7)
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 0.7, curve: Curves.easeOutCubic),
    ));

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 0.6, curve: Curves.easeIn),
      ),
    );

    // 3. Subtitle Animation (0.6 - 1.0)
    _subtitleFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _navigateToHome() async {
    // 顯示啟動動畫 3 秒
    await Future.delayed(const Duration(milliseconds: 3000));

    if (!mounted) return;

    try {
      // 檢查是否已完成用戶引導
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;
      
      print('✨ 引導狀態檢查: onboarding_completed = $onboardingCompleted');
      
      if (!mounted) return;

      // 登入功能已移除，所有數據存儲在本地
      Widget nextScreen;
      
      if (!onboardingCompleted) {
        // 首次使用，顯示歡迎頁面 (含登入/開始使用)
        nextScreen = const WelcomeLoginScreen();
      } else {
        // 已完成引導，直接進入主頁面
        nextScreen = const MainNavigationScreen(shouldShowTutorial: false);
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    } catch (e) {
      print('初始化錯誤: $e');
      if (!mounted) return;
      // 發生錯誤時顯示歡迎頁面
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeLoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 1. Icon
                  FadeTransition(
                    opacity: _iconFadeAnimation,
                    child: ScaleTransition(
                      scale: _iconScaleAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
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
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  // 2. Title
                  SlideTransition(
                    position: _textSlideAnimation,
                    child: FadeTransition(
                      opacity: _textFadeAnimation,
                      child: Text(
                        AppLocalizations.of(context)?.appName ?? 'Fooda',
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // 3. Subtitle
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: Text(
                      AppLocalizations.of(context)?.welcomeSubtitle ?? 'AI Smart Nutrition Tracker',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 80),
                  
                  // Loading Indicator (Optional, subtle)
                  FadeTransition(
                    opacity: _subtitleFadeAnimation,
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// 空白主頁面
class BlankHomePage extends StatelessWidget {
  const BlankHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: const Text(
          'Fooda',
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}