import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'theme_provider.dart';
import 'locale_provider.dart';
import 'meal_data_provider.dart';
import '../../features/nutrition/providers/nutrition_provider.dart';
import '../../features/meals/providers/meal_provider.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../features/badges/providers/badges_provider.dart';
import '../../features/camera/providers/camera_provider.dart';

/// 應用提供者配置
/// 管理所有全域狀態和數據提供者
class AppProviders {
  static List<SingleChildWidget> get providers => [
    // 主題和語言提供者
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => LocaleProvider()..initialize()),
    
    // 統一餐點數據管理提供者
    ChangeNotifierProvider(create: (_) => MealDataProvider()..initialize()),
    
    // 營養數據提供者
    ChangeNotifierProvider(create: (_) => NutritionProvider()),
    
    // 餐點記錄提供者
    ChangeNotifierProvider(create: (_) => MealProvider()),
    
    // 會員系統提供者
    ChangeNotifierProvider(create: (_) => MembershipProvider()),
    
    // 用戶資料提供者
    ChangeNotifierProvider(create: (_) => ProfileProvider()),
    
    // 徽章系統提供者
    ChangeNotifierProvider(create: (_) => BadgesProvider()),
    
    // 相機功能提供者
    ChangeNotifierProvider(create: (_) => CameraProvider()),
  ];
}