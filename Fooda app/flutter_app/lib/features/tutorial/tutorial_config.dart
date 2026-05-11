import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'tutorial_controller.dart';

/// 教學步驟配置
class TutorialConfig {
  static String getTitle(BuildContext context, TutorialStep step) {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case TutorialStep.step1_home:
        return l10n.tutorialStep1Title ?? '首頁';
      case TutorialStep.step2_nutritionCard:
        return l10n.tutorialStep2Title ?? '營養統計卡片';
      case TutorialStep.step3_recordCard:
        return l10n.tutorialStep3Title ?? '營養記錄卡片';
      case TutorialStep.step4_history:
        return l10n.tutorialStep4Title ?? '歷史記錄';
      case TutorialStep.step5_analysis:
        return l10n.tutorialStep5Title ?? '分析';
      case TutorialStep.step6_profile:
        return l10n.tutorialStep6Title ?? '個人';
      case TutorialStep.step7_addButton:
        return l10n.tutorialStep7Title ?? '新增紀錄按鈕';
      case TutorialStep.step8_camera:
        return l10n.tutorialStep8Title ?? '拍照功能';
      case TutorialStep.step9_gallery:
        return l10n.tutorialStep9Title ?? '相簿功能';
      case TutorialStep.step10_manual:
        return l10n.tutorialStep10Title ?? '手動輸入功能';
      case TutorialStep.step11_galleryAction:
        return l10n.tutorialStep11Title ?? '開始紀錄';
      case TutorialStep.step12_showRecord:
        return l10n.tutorialStep12Title ?? '展示紀錄';
      case TutorialStep.step13_complete:
        return l10n.tutorialStep13Title ?? '完成教學';
    }
  }

  static String getDescription(BuildContext context, TutorialStep step) {
    final l10n = AppLocalizations.of(context)!;
    switch (step) {
      case TutorialStep.step1_home:
        return l10n.tutorialStep1Desc ?? '這是查看今日攝取量的地方';
      case TutorialStep.step2_nutritionCard:
        return l10n.tutorialStep2Desc ?? '這是查看今日攝取量的地方';
      case TutorialStep.step3_recordCard:
        return l10n.tutorialStep3Desc ?? '這是顯示最近飲食紀錄的地方';
      case TutorialStep.step4_history:
        return l10n.tutorialStep4Desc ?? '這裡可以查看過去日期的詳細飲食紀錄';
      case TutorialStep.step5_analysis:
        return l10n.tutorialStep5Desc ?? '這裡提供長期的營養攝取趨勢分析';
      case TutorialStep.step6_profile:
        return l10n.tutorialStep6Desc ?? '這裡可以查看個人資料和設定';
      case TutorialStep.step7_addButton:
        return l10n.tutorialStep7Desc ?? '這裡可以新增飲食紀錄，現在點擊新增按鈕';
      case TutorialStep.step8_camera:
        return l10n.tutorialStep8Desc ?? '這裡可以拍照新增飲食紀錄';
      case TutorialStep.step9_gallery:
        return l10n.tutorialStep9Desc ?? '這裡可以相簿新增飲食紀錄';
      case TutorialStep.step10_manual:
        return l10n.tutorialStep10Desc ?? '這裡可以手動輸入飲食紀錄';
      case TutorialStep.step11_galleryAction:
        return l10n.tutorialStep11Desc ?? '現在點擊相簿按鈕，開始我們的第一筆紀錄';
      case TutorialStep.step12_showRecord:
        return l10n.tutorialStep12Desc ?? '這裡是你剛剛紀錄的飲食紀錄';
      case TutorialStep.step13_complete:
        return l10n.tutorialStep13Desc ?? '恭喜你完成所有按鈕教學，現在你可以開始使用Calhub了';
    }
  }
  /// 判斷是否為動作步驟（需要用戶執行特定動作才能繼續）
  /// 動作步驟：點擊後需要觸發實際功能（如打開選單、打開相簿）
  /// 資訊步驟：點擊後直接進入下一步（只是介紹）
  static bool isActionStep(TutorialStep step) {
    switch (step) {
      case TutorialStep.step7_addButton:      // 需要點擊打開底部選單
      case TutorialStep.step11_galleryAction: // 需要點擊打開相簿
        return true;
      default:
        return false; // 其他都是資訊步驟
    }
  }
}
