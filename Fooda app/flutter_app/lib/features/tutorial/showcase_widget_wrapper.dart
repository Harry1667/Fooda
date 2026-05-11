import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';
import 'tutorial_controller.dart';
import 'tutorial_config.dart';

class ShowcaseWidgetWrapper extends StatelessWidget {
  final GlobalKey showcaseKey;
  final TutorialStep? step; // Make step optional
  final String? title;
  final String? description;
  final Widget child;
  final ShapeBorder? targetShapeBorder;
  final EdgeInsets? targetPadding;
  final VoidCallback? onTargetClick;
  final bool disposeOnTap;
  final bool disableDefaultTargetGestures;

  const ShowcaseWidgetWrapper({
    super.key,
    required this.showcaseKey,
    this.step,
    this.title,
    this.description,
    required this.child,
    this.targetShapeBorder,
    this.targetPadding,
    this.onTargetClick,
    this.disposeOnTap = true,
    this.disableDefaultTargetGestures = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActionStep = step != null ? TutorialConfig.isActionStep(step!) : false;

    return Showcase(
      key: showcaseKey,
      title: title ?? (step != null ? TutorialConfig.getTitle(context, step!) : ''),
      description: description ?? (step != null ? TutorialConfig.getDescription(context, step!) : ''),
      targetShapeBorder: targetShapeBorder ?? const CircleBorder(),
      targetPadding: targetPadding ?? const EdgeInsets.all(8),
      tooltipBackgroundColor: Theme.of(context).primaryColor,
      textColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      descTextStyle: const TextStyle(
        fontSize: 14,
        color: Colors.white,
        height: 1.5,
      ),
      overlayColor: Colors.black,
      overlayOpacity: 0.85, // Darker overlay for better contrast
      
      // 關鍵修復：所有步驟都設為 disposeOnTap = false
      // 我們手動控制何時進入下一步
      disposeOnTap: false, 
      
      disableDefaultTargetGestures: disableDefaultTargetGestures,
      
      onTargetClick: () {
        TutorialController().log('🎯 用戶點擊目標：${title ?? (step != null ? TutorialConfig.getTitle(context, step!) : 'Custom')}');
        
        // 如果是動作步驟，先執行自定義動作
        if (onTargetClick != null) {
          TutorialController().log('🔧 執行自定義動作');
          onTargetClick!();
        }
        
        // 所有步驟點擊後都手動進入下一步
        TutorialController().log('🔧 準備呼叫 next()');
        ShowCaseWidget.of(context).next();
        TutorialController().log('🔧 已呼叫 next()');
      },
      
      onToolTipClick: () {
        TutorialController().log('💬 用戶點擊提示框：${title ?? (step != null ? TutorialConfig.getTitle(context, step!) : 'Custom')}');
        // 允許點擊提示框進入下一步
        TutorialController().log('🔧 從提示框呼叫 next()');
        ShowCaseWidget.of(context).next();
      },
      
      onBarrierClick: () {
        TutorialController().log('🖤 用戶點擊遮罩：${title ?? (step != null ? TutorialConfig.getTitle(context, step!) : 'Custom')}');
        
        // 對於資訊步驟，允許點擊遮罩進入下一步
        // 對於動作步驟，點擊遮罩不應有反應（必須點擊目標執行動作）
        if (!isActionStep) {
          TutorialController().log('🔧 從遮罩呼叫 next()');
          ShowCaseWidget.of(context).next();
        } else {
          TutorialController().log('❌ 動作步驟：必須點擊目標');
        }
      },
      child: child,
    );
  }
}
