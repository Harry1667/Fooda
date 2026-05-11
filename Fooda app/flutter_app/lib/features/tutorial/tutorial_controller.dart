import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../core/app_config.dart';

enum TutorialSession {
  none,
  main,
  bottomSheet,
  galleryAction, // 新增：步驟 11 相簿動作
  finalStep,
}

enum TutorialStep {
  step1_home,
  step2_nutritionCard,
  step3_recordCard,
  step4_history,
  step5_analysis,
  step6_profile,
  step7_addButton,
  step8_camera,
  step9_gallery,
  step10_manual,
  step11_galleryAction,
  step12_showRecord,
  step13_complete,
}

class TutorialController extends ChangeNotifier {
  static final TutorialController _instance = TutorialController._internal();
  factory TutorialController() => _instance;
  TutorialController._internal();

  // Keys for Step 1-6 (Main Nav & Home)
  final GlobalKey homeNavKey = GlobalKey();
  final GlobalKey nutritionCardKey = GlobalKey();
  final GlobalKey recordCardKey = GlobalKey();
  final GlobalKey historyNavKey = GlobalKey();
  final GlobalKey analysisNavKey = GlobalKey();
  final GlobalKey profileNavKey = GlobalKey();

  // Key for Step 7 (Add Button)
  final GlobalKey addMealButtonKey = GlobalKey();

  // Keys for Step 8-11 (Bottom Sheet Options)
  final GlobalKey cameraOptionKey = GlobalKey();
  final GlobalKey galleryOptionKey = GlobalKey();
  final GlobalKey manualOptionKey = GlobalKey();
  // final GlobalKey galleryActionKey = GlobalKey(); // Deprecated or rename
  final GlobalKey addMealBottomSheetKey = GlobalKey(); // 步驟 11 使用：整個底部選單

  bool isTutorialActive = false;
  TutorialSession currentSession = TutorialSession.none;
  TutorialStep currentStep = TutorialStep.step1_home;
  
  // 回調函數
  VoidCallback? onAddButtonClicked;
  VoidCallback? onGalleryClicked;

  void log(String message) {
    print('📝 [Tutorial] $message');
  }
  
  void startMainTutorial(BuildContext context) {
    // 檢查是否已經完成過教學
    final bool isCompleted = AppConfig.getBool(AppConstants.keyTutorialCompleted);
    if (isCompleted) {
      log('✅ 用戶已完成過教學，跳過');
      return;
    }

    log('🎓 開始主要教學流程（步驟 1-7）');
    isTutorialActive = true;
    currentSession = TutorialSession.main;
    currentStep = TutorialStep.step1_home;
    notifyListeners();
    
    log('Keys: homeNavKey=$homeNavKey, nutritionCardKey=$nutritionCardKey, recordCardKey=$recordCardKey');
    
    ShowCaseWidget.of(context).startShowCase([
      homeNavKey,
      nutritionCardKey,
      recordCardKey,
      historyNavKey,
      analysisNavKey,
      profileNavKey,
      addMealButtonKey,
    ]);
  }

  void startBottomSheetTutorial(BuildContext context) {
    // 檢查是否已經完成過教學
    if (AppConfig.getBool(AppConstants.keyTutorialCompleted)) {
      log('✅ 用戶已完成過教學，跳過底部選單教學');
      return;
    }

    print('🎓 開始底部選單教學（步驟 8-10）');
    currentSession = TutorialSession.bottomSheet;
    currentStep = TutorialStep.step8_camera;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        ShowCaseWidget.of(context).startShowCase([
          cameraOptionKey,
          galleryOptionKey,
          manualOptionKey,
        ]);
      }
    });
  }

  void startGalleryActionTutorial(BuildContext context) {
    // 檢查是否已經完成過教學
    if (AppConfig.getBool(AppConstants.keyTutorialCompleted)) {
      log('✅ 用戶已完成過教學，跳過相簿動作教學');
      return;
    }

    print('🎓 開始相簿動作教學（步驟 11）');
    currentSession = TutorialSession.galleryAction;
    currentStep = TutorialStep.step11_galleryAction;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (context.mounted) {
        ShowCaseWidget.of(context).startShowCase([
          addMealBottomSheetKey, // 改用整個 BottomSheet 的 Key
        ]);
      }
    });
  }

  void startFinalTutorial(BuildContext context) {
    // 檢查是否已經完成過教學
    if (AppConfig.getBool(AppConstants.keyTutorialCompleted)) {
      log('✅ 用戶已完成過教學，跳過最終步驟');
      return;
    }

    print('🎓 開始最終教學（步驟 12）');
    currentSession = TutorialSession.finalStep;
    currentStep = TutorialStep.step12_showRecord;
    notifyListeners();
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (context.mounted) {
        ShowCaseWidget.of(context).startShowCase([
          recordCardKey,
        ]);
      }
    });
  }

  void onShowcaseFinish(BuildContext context) {
    print('🎓 Showcase 完成，當前會話：$currentSession');
    
    if (currentSession == TutorialSession.main) {
      // 步驟 1-7 完成，等待用戶點擊 FAB
      print('✅ 主要教學完成，等待用戶點擊新增按鈕');
      currentStep = TutorialStep.step7_addButton;
      notifyListeners();
      // 不做任何事，等待用戶點擊 FAB 觸發 onAddButtonClicked
      
    } else if (currentSession == TutorialSession.bottomSheet) {
      // 步驟 8-10 完成，開始步驟 11（相簿動作）
      // BottomSheet 教學結束，這裡通常是 Step 10 結束
      // 但我們在 Step 11 會手動啟動
      startGalleryActionTutorial(context);
    } else if (currentSession == TutorialSession.galleryAction) {
       // 相簿動作教學結束
       print('✅ 相簿動作教學完成，等待用戶點擊相簿');
    } else if (currentSession == TutorialSession.finalStep) {
      // Step 12 結束，顯示 Step 13 完成畫面
      _showCompletionPanel(context);
    }
  }

  void _showCompletionPanel(BuildContext context) {
    log('🎊 顯示步驟 13：完成教學面板');
    currentStep = TutorialStep.step13_complete;
    notifyListeners();
    
    showDialog(
      context: context,
      barrierDismissible: false, // 強制點擊 panel 關閉
      barrierColor: Colors.black.withOpacity(0.85), // 深色背景
      builder: (context) {
        return GestureDetector(
          onTap: () async {
            log('🎯 用戶點擊完成面板');
            Navigator.of(context).pop(); // 關閉 Dialog
            log('🎉 教學完全結束，標記為已完成');
            
            // 重置教學狀態
            isTutorialActive = false;
            currentSession = TutorialSession.none;
            currentStep = TutorialStep.step1_home;
            notifyListeners();
            
            // 保存教學完成狀態到 SharedPreferences
            await AppConfig.setBool(AppConstants.keyTutorialCompleted, true);
            log('💾 教學完成狀態已保存');
          },
          child: Container(
            color: Colors.transparent, // 接收點擊
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                    size: 80,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    '恭喜你完成所有按鈕教學',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '現在你可以開始使用 Fooda 了',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      decoration: TextDecoration.none,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    '點擊任意處關閉',
                    style: TextStyle(
                      color: Colors.white30,
                      fontSize: 14,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  // 重置教學狀態
  void reset() {
    isTutorialActive = false;
    currentSession = TutorialSession.none;
    currentStep = TutorialStep.step1_home;
    onAddButtonClicked = null;
    onGalleryClicked = null;
    notifyListeners();
  }
}
