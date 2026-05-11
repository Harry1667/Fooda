import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
// import 'package:firebase_core/firebase_core.dart';

import 'core/app_config.dart';
import 'core/env_config.dart';
import 'core/providers/app_providers.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';
import 'core/services/notification_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'features/tutorial/tutorial_controller.dart';
import 'package:showcaseview/showcaseview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 暫時禁用 Firebase 初始化
  // await Firebase.initializeApp();
  
  // Initialize AdMob
  await MobileAds.instance.initialize();
  
  // 初始化應用配置
  await AppConfig.initialize();
  
  // 預初始化語言提供者
  final localeProvider = LocaleProvider();
  await localeProvider.initialize();
  
  // 打印環境配置信息（僅在開發環境）
  EnvConfig.printConfig();
  
  // 設定系統 UI 樣式
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  await NotificationService().init();
  
  runApp(const FoodaApp());
}

class FoodaApp extends StatelessWidget {
  const FoodaApp({super.key});
  
  static final tutorialController = TutorialController();
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppProviders.providers,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Consumer<LocaleProvider>(
            builder: (context, localeProvider, child) {
              print('🌐 [FoodaApp] Rebuilding MaterialApp. Provider locale: ${localeProvider.locale}');
              return MaterialApp(
                navigatorKey: navigatorKey, // Set global navigator key
                title: 'Fooda',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                locale: localeProvider.locale,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: LocaleProvider.supportedLocales,
                builder: (context, child) {
                  return ShowCaseWidget(
                    builder: (context) => child!,
                    onFinish: () {
                       FoodaApp.tutorialController.log('🏁 ShowCase session finished');
                       FoodaApp.tutorialController.onShowcaseFinish(context);
                    },
                    onComplete: (index, key) {
                       FoodaApp.tutorialController.log('✅ Step completed: index=$index, key=$key');
                    },
                    onStart: (index, key) {
                       FoodaApp.tutorialController.log('🚀 Step started: index=$index, key=$key');
                    },
                    autoPlay: false,
                    autoPlayDelay: const Duration(seconds: 3),
                    blurValue: 1,
                    // disableBarrierInteraction: true, // 移除此行，允許我們在 Wrapper 中處理 onBarrierClick
                  );
                },
                home: const SplashScreen(),
              );
            },
          );
        },
      ),
    );
  }
}

// LocaleProvider 已移動到 core/providers/locale_provider.dart