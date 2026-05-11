import 'package:flutter/material.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/analysis/analysis_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/badges/badges_screen.dart';
import '../../features/main_navigation/main_navigation_screen.dart';
import '../../features/add_meal/add_meal_screen.dart';
import '../../features/camera/camera_screen.dart';
import '../../features/manual_input/manual_input_screen.dart';
import '../../features/ai_upload/ai_upload_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/membership/membership_screen.dart';
// import '../../features/login/login_screen.dart'; // 已移除登入功能
// import '../../features/test/test_apple_signin_page.dart'; // 已移除登入功能

/// 應用路由管理
/// 對應 PHP 版本的頁面導航系統
class AppRoutes {
  // 路由名稱常數
  static const String splash = '/';
  static const String mainNavigation = '/main';
  static const String home = '/home';
  static const String history = '/history';
  static const String analysis = '/analysis';
  static const String profile = '/profile';
  static const String badges = '/badges';
  static const String addMeal = '/add-meal';
  static const String camera = '/camera';
  static const String manualInput = '/manual-input';
  static const String aiUpload = '/ai-upload';
  static const String settings = '/settings';
  static const String membership = '/membership';
  static const String login = '/login';
  static const String testAppleSignIn = '/test-apple-signin';
  
  /// 生成路由
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
        
      case mainNavigation:
        return _buildRoute(const MainNavigationScreen(), settings);
        
      case home:
        return _buildRoute(const HomeScreen(), settings);
        
      case history:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          const HistoryScreen(),
          settings,
        );
        
      case analysis:
        return _buildRoute(const AnalysisScreen(), settings);
        
      case profile:
        return _buildRoute(const ProfileScreen(), settings);
        
      case badges:
        return _buildRoute(const BadgesScreen(), settings);
        
      case addMeal:
        return _buildRoute(const AddMealScreen(), settings);
        
      case camera:
        // 暫時禁用相機功能
        return _buildRoute(const HomeScreen(), settings);
        
      case manualInput:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildRoute(
          ManualInputScreen(
            editingMeal: args?['editingMeal'],
            selectedDate: args?['selectedDate'],
          ),
          settings,
        );
        
      case aiUpload:
        return _buildRoute(const AiUploadScreen(), settings);
        
      case AppRoutes.settings:
        return _buildRoute(const SettingsScreen(), settings);
        
      case membership:
        return _buildRoute(const MembershipScreen(), settings);
        
      case login:
        // 登入頁面已移除 - 所有數據存儲在本地
        return _buildRoute(const MainNavigationScreen(), settings);
        
      case testAppleSignIn:
        // Apple Sign In 測試頁面已移除
        return _buildRoute(const MainNavigationScreen(), settings);
        
      default:
        return _buildRoute(
          const NotFoundScreen(),
          settings,
        );
    }
  }
  
  /// 建立路由
  static PageRoute _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // 使用滑動動畫，類似原生 iOS 體驗
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}

/// 404 頁面
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('頁面不存在'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              '抱歉，找不到此頁面',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '請檢查網址是否正確',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 路由輔助類
class RouteHelper {
  /// 導航到指定路由
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
  }
  
  /// 替換當前路由
  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
      result: result,
    );
  }
  
  /// 清除所有路由並導航到指定路由
  static Future<T?> pushNamedAndRemoveUntil<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
  
  /// 返回上一頁
  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    Navigator.pop<T>(context, result);
  }
  
  /// 檢查是否可以返回
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }
  
  /// 導航到首頁（對應 PHP 版本的 firstpage.php）
  static void goToHome(BuildContext context) {
    pushNamedAndRemoveUntil(context, AppRoutes.mainNavigation);
  }
  
  /// 導航到歷史記錄頁面（對應 PHP 版本的 historypage.php）
  static void goToHistory(BuildContext context, {DateTime? selectedDate}) {
    pushNamed(
      context,
      AppRoutes.history,
      arguments: {'selectedDate': selectedDate},
    );
  }
  
  /// 導航到分析頁面（對應 PHP 版本的 analyzepage.php）
  static void goToAnalysis(BuildContext context) {
    pushNamed(context, AppRoutes.analysis);
  }
  
  /// 導航到個人頁面（對應 PHP 版本的 personpage.php）
  static void goToProfile(BuildContext context) {
    pushNamed(context, AppRoutes.profile);
  }
  
  /// 導航到徽章頁面（對應 PHP 版本的 badgespage.php）
  static void goToBadges(BuildContext context) {
    pushNamed(context, AppRoutes.badges);
  }
  
  /// 導航到添加餐點頁面
  static void goToAddMeal(BuildContext context) {
    pushNamed(context, AppRoutes.addMeal);
  }
  
  /// 導航到相機頁面
  static void goToCamera(BuildContext context) {
    pushNamed(context, AppRoutes.camera);
  }
  
  /// 導航到手動輸入頁面
  static void goToManualInput(BuildContext context, {
    Map<String, dynamic>? editingMeal,
    DateTime? selectedDate,
  }) {
    pushNamed(
      context,
      AppRoutes.manualInput,
      arguments: {
        'editingMeal': editingMeal,
        'selectedDate': selectedDate,
      },
    );
  }
  
  /// 導航到 AI 上傳頁面
  static void goToAiUpload(BuildContext context) {
    pushNamed(context, AppRoutes.aiUpload);
  }
  
  /// 導航到設定頁面
  static void goToSettings(BuildContext context) {
    pushNamed(context, AppRoutes.settings);
  }
  
  /// 導航到會員頁面
  static void goToMembership(BuildContext context) {
    pushNamed(context, AppRoutes.membership);
  }
  
  /// 導航到登入頁面（已移除 - 所有數據存儲在本地）
  static void goToLogin(BuildContext context) {
    // 登入功能已移除，導航到主頁面
    goToHome(context);
  }
}