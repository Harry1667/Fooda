import 'package:flutter/material.dart';
import '../../main.dart';
import '../tutorial/tutorial_controller.dart';

/// 教學測試輔助類
/// 用於測試步驟 12-13，跳過 AI 識別
class TutorialTestHelper {
  /// 模擬 AI 識別完成後直接觸發步驟 12
  static void triggerStep12(BuildContext context) {
    final tutorialController = FoodaApp.tutorialController;
    
    if (tutorialController.isTutorialActive && 
        tutorialController.currentSession == TutorialSession.galleryAction) {
      
      tutorialController.log('🧪 測試模式：直接觸發步驟 12');
      
      // 延遲觸發，模擬保存記錄後返回首頁的場景
      Future.delayed(const Duration(milliseconds: 800), () {
        if (context.mounted) {
          tutorialController.startFinalTutorial(context);
        }
      });
    }
  }
  
  /// 顯示測試按鈕，用於觸發步驟 12
  static Widget buildTestButton(BuildContext context) {
    final tutorialController = FoodaApp.tutorialController;
    
    // 只在教學模式的步驟 11 之後顯示
    if (!tutorialController.isTutorialActive || 
        tutorialController.currentSession != TutorialSession.galleryAction) {
      return const SizedBox.shrink();
    }
    
    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
          triggerStep12(context);
        },
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.bug_report),
        label: const Text('測試步驟12'),
      ),
    );
  }
}
