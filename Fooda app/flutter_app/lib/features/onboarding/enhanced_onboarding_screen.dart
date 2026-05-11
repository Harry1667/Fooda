import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main_navigation/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/onboarding_step.dart';
import 'widgets/language_selection_page.dart';
import 'widgets/responsive_welcome_page.dart';
// import 'widgets/login_page.dart'; // 已移除登入功能
import 'widgets/responsive_body_data_page.dart';
import 'widgets/responsive_calorie_goal_page.dart';
import '../../core/config/development_config.dart';
import '../../core/utils/development_utils.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/services/backup_service.dart';

class EnhancedOnboardingScreen extends StatefulWidget {
  final OnboardingStep initialStep;

  const EnhancedOnboardingScreen({
    super.key,
    this.initialStep = OnboardingStep.welcome,
  });

  @override
  State<EnhancedOnboardingScreen> createState() => _EnhancedOnboardingScreenState();
}

class _EnhancedOnboardingScreenState extends State<EnhancedOnboardingScreen>
    with TickerProviderStateMixin {
  late OnboardingStep _currentStep;
  OnboardingData _onboardingData = OnboardingData();
  late AnimationController _transitionController;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _transitionController,
      curve: Curves.easeInOut,
    ));
    
    _transitionController.forward();
  }

  @override
  void dispose() {
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('Apple Sign-In Success: ${credential.userIdentifier}');
      
      if (!mounted) return;

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // CloudKit restore removed
      // final success = await BackupService.restoreFromCloud(context);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // Skip onboarding directly as CloudKit restore is removed
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_completed', true);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } catch (e) {
      print('Apple Sign-In Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登入失敗: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 移除強制淺色模式，使用主題背景色
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          SlideTransition(
            position: _slideAnimation,
            child: _buildCurrentPage(),
          ),

        ],
      ),
    );
  }
  
  Widget _buildCurrentPage() {
    switch (_currentStep) {
      // 語言選擇頁面已移除，直接從歡迎頁面開始
      // case OnboardingStep.languageSelection:
      //   return LanguageSelectionPage(
      //     onLanguageSelected: _onLanguageSelected,
      //   );
        
      case OnboardingStep.welcome:
        return ResponsiveWelcomePage(
          onNext: _goToNextStep,
          onSignIn: _handleAppleSignIn,
        );
        
      case OnboardingStep.login:
        // 登入頁面已移除，直接跳到下一步
        _goToNextStep();
        return Container();
        
      case OnboardingStep.bodyData:
        return ResponsiveBodyDataPage(
          data: _onboardingData,
          onDataChanged: _updateOnboardingData,
          onNext: _goToNextStep,
          onBack: _goToPreviousStep,
        );
        
      case OnboardingStep.calorieGoal:
        return ResponsiveCalorieGoalPage(
          data: _onboardingData,
          onDataChanged: _updateOnboardingData,
          onNext: _goToNextStep,
          onBack: _goToPreviousStep,
        );
        
      case OnboardingStep.complete:
        return _buildCompletePage();
        
      default:
        return _buildErrorPage();
    }
  }
  
  Widget _buildCompletePage() {
    // 使用主題顏色
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: 100,
              color: Theme.of(context).colorScheme.primary, // Use primary color (vibrant blue/green)
            ),
            SizedBox(height: 24),
            Text(
              AppLocalizations.of(context)!.setupComplete,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.welcomeToFooda,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _completeOnboarding,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isDark ? 4 : 2,
                shadowColor: isDark ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : null,
              ),
              child: Text(
                AppLocalizations.of(context)!.getStarted,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorPage() {
    return Scaffold(
      body: Center(
        child: Text(AppLocalizations.of(context)!.errorOccurred),
      ),
    );
  }




  
  void _goToNextStep() {
    _animateToStep(_getNextStep());
  }
  
  void _goToPreviousStep() {
    _animateToStep(_getPreviousStep());
  }
  
  OnboardingStep _getNextStep() {
    switch (_currentStep) {
      // case OnboardingStep.languageSelection:
      //   return OnboardingStep.welcome;
      case OnboardingStep.welcome:
        return OnboardingStep.bodyData; // 跳過登入頁面
      case OnboardingStep.login:
        return OnboardingStep.bodyData; // 保留以防萬一
      case OnboardingStep.bodyData:
        return OnboardingStep.calorieGoal;
      case OnboardingStep.calorieGoal:
        return OnboardingStep.complete;
      case OnboardingStep.complete:
        return OnboardingStep.complete;
      default:
        return OnboardingStep.welcome;
    }
  }
  
  OnboardingStep _getPreviousStep() {
    switch (_currentStep) {
      // case OnboardingStep.languageSelection:
      //   return OnboardingStep.languageSelection;
      case OnboardingStep.welcome:
        return OnboardingStep.welcome; // 已經是第一步了
      case OnboardingStep.login:
        return OnboardingStep.welcome; // 保留以防萬一
      case OnboardingStep.bodyData:
        return OnboardingStep.welcome; // 跳過登入頁面
      case OnboardingStep.calorieGoal:
        return OnboardingStep.bodyData;
      case OnboardingStep.complete:
        return OnboardingStep.calorieGoal;
      default:
        return OnboardingStep.welcome;
    }
  }
  
  void _animateToStep(OnboardingStep step) {
    _transitionController.reverse().then((_) {
      setState(() {
        _currentStep = step;
      });
      _transitionController.forward();
    });
  }
  
  void _onLanguageSelected(String languageCode) async {
    setState(() {
      _onboardingData.selectedLanguage = languageCode;
    });
    
    // 立即更新應用語言
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    await localeProvider.setLocale(languageCode);
    
    _goToNextStep();
  }
  
  void _updateOnboardingData(OnboardingData data) {
    setState(() {
      _onboardingData = data;
    });
  }
  
  bool _isCompleting = false;

  Future<void> _completeOnboarding() async {
    if (_isCompleting) return;
    
    setState(() {
      _isCompleting = true;
    });

    try {
      // 保存用戶引導完成狀態
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', true);
      
      // 保存用戶數據
      await _saveUserData();
      
      // 先導航到主頁面，然後顯示聚光燈教程
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const MainNavigationScreen(shouldShowTutorial: true),
          ),
          (route) => false, // 移除所有舊路由，確保只剩下主頁面
        );
      }
    } catch (e) {
      print('完成引導時發生錯誤: $e');
      
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.saveSettingsError}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _saveUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存語言設置
      if (_onboardingData.selectedLanguage != null) {
        await prefs.setString('selected_language', _onboardingData.selectedLanguage!);
        await prefs.setString('app_language', _onboardingData.selectedLanguage!);
      }
      
      // 保存身體數據 - 使用個人頁面期望的 key
      if (_onboardingData.height != null) {
        await prefs.setDouble('height', _onboardingData.height!);
        await prefs.setDouble('user_height', _onboardingData.height!);
      }
      if (_onboardingData.weight != null) {
        await prefs.setDouble('weight', _onboardingData.weight!);
        await prefs.setDouble('user_weight', _onboardingData.weight!);
      }
      if (_onboardingData.age != null) {
        await prefs.setInt('age', _onboardingData.age!);
        await prefs.setInt('user_age', _onboardingData.age!);
      }
      if (_onboardingData.gender != null) {
        await prefs.setString('gender', _onboardingData.gender!);
        await prefs.setString('user_gender', _onboardingData.gender!);
      }
      if (_onboardingData.activityLevel != null) {
        await prefs.setString('activity_level', _onboardingData.activityLevel!);
        await prefs.setString('user_activity_level', _onboardingData.activityLevel!);
      }
      if (_onboardingData.calorieGoal != null) {
        await prefs.setInt('calorie_goal', _onboardingData.calorieGoal!);
        await prefs.setInt('user_calorie_goal', _onboardingData.calorieGoal!);
        await prefs.setInt('daily_calorie_goal', _onboardingData.calorieGoal!);
        
        // 同步到首頁營養卡片
        await prefs.setInt('home_calorie_goal', _onboardingData.calorieGoal!);
        await prefs.setInt('nutrition_card_calorie_target', _onboardingData.calorieGoal!);
        
        // 同步到個人頁面
        await prefs.setInt('profile_calorie_goal', _onboardingData.calorieGoal!);
        await prefs.setInt('profile_nutrition_target', _onboardingData.calorieGoal!);
        
        // 計算其他營養目標（基於卡路里的標準比例）
        final protein = (_onboardingData.calorieGoal! * 0.15 / 4).round(); // 15% 蛋白質
        final carbs = (_onboardingData.calorieGoal! * 0.55 / 4).round();   // 55% 碳水化合物  
        final fat = (_onboardingData.calorieGoal! * 0.30 / 9).round();     // 30% 脂肪
        
        await prefs.setInt('protein_goal', protein);
        await prefs.setInt('carbs_goal', carbs);
        await prefs.setInt('fat_goal', fat);
        await prefs.setInt('daily_protein_goal', protein);
        await prefs.setInt('daily_carbs_goal', carbs);
        await prefs.setInt('daily_fat_goal', fat);
      }
      if (_onboardingData.useAIGoal != null) {
        await prefs.setBool('use_ai_goal', _onboardingData.useAIGoal!);
        await prefs.setBool('user_use_ai_goal', _onboardingData.useAIGoal!);
      }
      
      // 計算並保存 BMI
      if (_onboardingData.height != null && _onboardingData.weight != null) {
        final heightInM = _onboardingData.height! / 100;
        final bmi = _onboardingData.weight! / (heightInM * heightInM);
        await prefs.setDouble('bmi', bmi);
      }
      
      // 保存完成時間
      await prefs.setString('onboarding_completed_date', DateTime.now().toIso8601String());
      
      // 設置引導完成標記
      await prefs.setBool('onboarding_completed', true);
      
      // 設置個人資料初始化標記
      await prefs.setBool('profile_initialized', true);
      
      print('✅ 用戶數據已保存並同步到個人資料');
      print('📊 身高: ${_onboardingData.height}cm, 體重: ${_onboardingData.weight}kg');
      print('🎯 卡路里目標: ${_onboardingData.calorieGoal} 卡/天');
    } catch (e) {
      print('❌ 保存用戶數據時發生錯誤: $e');
      rethrow;
    }
  }
}