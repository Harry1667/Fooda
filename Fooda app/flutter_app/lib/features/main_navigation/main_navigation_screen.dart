import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:io';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import '../home/home_screen.dart';
import '../history/history_screen.dart';
import '../analysis/analysis_screen.dart';
import '../profile/profile_screen.dart';
import '../manual_input/manual_input_screen.dart';
import '../camera/camera_result_screen.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/membership/membership_screen.dart';
import '../../core/services/ai_analysis_service.dart';
import '../../core/providers/locale_provider.dart';
import '../tutorial/tutorial_controller.dart';
import '../tutorial/showcase_widget_wrapper.dart';
import '../tutorial/tutorial_config.dart';
import '../../core/app_config.dart';
import '../../features/meals/providers/meal_provider.dart';
import '../../main.dart';
import 'package:fooda_app/l10n/app_localizations.dart';

import '../../core/theme/text_colors.dart';

import '../../core/services/ad_service.dart';

/// 主導航頁面
class MainNavigationScreen extends StatefulWidget {
  final bool shouldShowTutorial;
  
  const MainNavigationScreen({
    super.key,
    this.shouldShowTutorial = false,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  
  TutorialController get _tutorialController => FoodaApp.tutorialController;

  final List<Widget> _pages = const [
    _KeepAliveWrapper(child: HomeScreen()),
    _KeepAliveWrapper(child: HistoryScreen()),
    _KeepAliveWrapper(child: AnalysisScreen()),
    _KeepAliveWrapper(child: ProfileScreen()),
  ];

  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    // 檢查是否需要啟動教學
    WidgetsBinding.instance.addPostFrameCallback((_) {
       _checkAndStartTutorial();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkAndStartTutorial() async {
    // 檢查是否為現有用戶（有餐點記錄）
    final mealProvider = Provider.of<MealProvider>(context, listen: false);
    final bool isTutorialCompleted = AppConfig.getBool(AppConstants.keyTutorialCompleted);
    
    // 如果明確指定要顯示教學（來自 Onboarding），則忽略完成狀態
    if (widget.shouldShowTutorial) {
      print('🎓 來自引導頁面，強制啟動教學');
      if (mounted) {
        _tutorialController.startMainTutorial(context);
      }
      return;
    }

    // 如果已經完成教學，直接返回
    if (isTutorialCompleted) return;

    // 如果沒有明確指定顯示教學，且未完成教學
    // 檢查是否為舊用戶（這裡假設如果不是從 Onboarding 來的，且沒完成過教學，可能是舊用戶）
    // 為了保險起見，我們直接標記為完成，不顯示教學
    // 這樣只有從 Onboarding 剛過來的用戶才會看到教學
    print('✅ 非 Onboarding 來源，自動標記教學為完成');
    await AppConfig.setBool(AppConstants.keyTutorialCompleted, true);
  }

  void _onTabTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: AppLocalizations.of(context)!.navHome ?? '首頁',
                  showcaseKey: _tutorialController.homeNavKey,
                  step: TutorialStep.step1_home,
                ),
                _buildNavItem(
                  index: 1,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: AppLocalizations.of(context)!.navHistory ?? '歷史',
                  showcaseKey: _tutorialController.historyNavKey,
                  step: TutorialStep.step4_history,
                ),
                const SizedBox(width: 60), // FAB 佔位空間
                _buildNavItem(
                  index: 2,
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics,
                  label: AppLocalizations.of(context)!.navAnalysis ?? '分析',
                  showcaseKey: _tutorialController.analysisNavKey,
                  step: TutorialStep.step5_analysis,
                ),
                _buildNavItem(
                  index: 3,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: AppLocalizations.of(context)!.navProfile ?? '個人',
                  showcaseKey: _tutorialController.profileNavKey,
                  step: TutorialStep.step6_profile,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ShowcaseWidgetWrapper(
        showcaseKey: _tutorialController.addMealButtonKey,
        title: TutorialConfig.getTitle(context, TutorialStep.step7_addButton),
        description: TutorialConfig.getDescription(context, TutorialStep.step7_addButton),
        targetShapeBorder: const CircleBorder(),
        disposeOnTap: true,
        onTargetClick: () {
             _showAddMealOptions(context);
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showAddMealOptions(context),
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(
                  Icons.add,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 1500.ms, curve: Curves.easeInOut),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required GlobalKey showcaseKey,
    required TutorialStep step,
  }) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor;
    
    return ShowcaseWidgetWrapper(
      showcaseKey: showcaseKey,
      title: TutorialConfig.getTitle(context, step),
      description: TutorialConfig.getDescription(context, step),
      targetShapeBorder: const CircleBorder(),
      disposeOnTap: true,
      child: InkWell(
        onTap: () => _onTabTapped(index),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                color: color,
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddMealOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _AddMealOptionsSheet(
        onCameraTap: () {
          Navigator.pop(sheetContext);
          _openCamera(context);
        },
        onGalleryTap: () {
          Navigator.pop(sheetContext);
          _openGallery(context);
        },
        onManualTap: () {
          Navigator.pop(sheetContext);
          _openManualInput(context);
        },
      ),
    );
  }

  Future<void> _openCamera(BuildContext context) async {
    // Check membership first
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog(context);
      return;
    }

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _analyzeImage(context, File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.cameraError}: $e')),
        );
      }
    }
  }

  Future<void> _openGallery(BuildContext context) async {
    // Check membership first
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog(context);
      return;
    }

    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        _analyzeImage(context, File(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.galleryError}: $e')),
        );
      }
    }
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.quotaExceeded ?? '已用完本月免費額度'),
        content: Text(AppLocalizations.of(context)!.quotaExceededDesc ?? '免費版每月最多可使用 10 次 AI 識別。請下個月再試或升級 Premium 以解鎖無限次數。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel ?? '取消'),
          ),
          // Rewarded Ad Button
          TextButton.icon(
             icon: const Icon(Icons.ondemand_video),
             label: const Text('觀看廣告 +3'), // Localization needed later
             onPressed: () async {
               Navigator.pop(context); // Close upgrade dialog
               
               // Show loading
               showDialog(
                 context: context,
                 barrierDismissible: false,
                 builder: (context) => const Center(child: CircularProgressIndicator()),
               );
               
               final adService = AdService();
               await adService.loadRewarded();
               
               if (context.mounted) {
                 Navigator.pop(context); // Close loading
                 
                 adService.showRewarded(
                   onUserEarnedReward: (reward) {
                     final membership = Provider.of<MembershipProvider>(context, listen: false);
                     membership.addRewardPoints(3);
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('🎉 已獲得 3 次額外識別機會！')),
                     );
                   },
                   onAdClosed: () {
                     // Ad closed
                   },
                 );
               }
             },
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: Text(AppLocalizations.of(context)!.upgradeToPremium ?? '升級 Premium'),
          ),
        ],
      ),
    );
  }
  Future<void> _analyzeImage(BuildContext context, File imageFile) async {
    // 確保 context 有效
    if (!context.mounted) {
      print('⚠️ Context 無效，無法顯示 loading 對話框');
      return;
    }

    // 檢查配額
    final membership = Provider.of<MembershipProvider>(context, listen: false);
    if (!membership.canUseAi) {
      _showUpgradeDialog(context);
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(AppLocalizations.of(context)!.aiProcessing ?? 'AI 正在識別中...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {

      // 使用 Localizations.localeOf(context) 獲取當前實際顯示的語言
      // 這樣即使 localeProvider.locale 為 null (跟隨系統)，也能拿到正確的語言
      final currentLocale = Localizations.localeOf(context);
      final languageCode = currentLocale.languageCode;
      final countryCode = currentLocale.countryCode;
      
      print('🌐 [MainNavigationScreen] AI Analysis Locale: $currentLocale');
      
      // 根據語言代碼決定 AI 使用的語言
      String language = 'zh-TW';
      if (languageCode == 'en') {
        language = 'en-US';
      } else if (languageCode == 'ja') {
        language = 'ja';
      } else if (languageCode == 'ko') {
        language = 'ko';
      } else if (languageCode == 'zh') {
        if (countryCode == 'CN') {
          language = 'zh-CN';
        } else {
          language = 'zh-TW';
        }
      }

      // Check Interstitial Ad Logic
      final adService = AdService();
      final bool shouldShowAd = membership.showAds && adService.shouldShowInterstitial;
      
      // 平行執行：啟動 AI 分析 和 廣告載入
      
      // 1. 啟動分析 (Future)
      final analysisFuture = AiAnalysisService.analyzeImageDirect(
        imageFile: imageFile,
        language: language,
      );

      // 2. 啟動廣告加載 (Future)，如果需要顯示廣告
      Future<bool> adLoadFuture = Future.value(false);
      if (shouldShowAd) {
        adLoadFuture = adService.loadInterstitial();
      }

      // 3. 等待 0.5 秒 (為了 UX，讓用戶看到轉圈圈，然後再彈出廣告)
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. 檢查廣告是否準備好
      bool adLoaded = await adLoadFuture;

      // 如果需要顯示且已加載，則顯示廣告
      // 注意：這裡我們會等待廣告關閉後才繼續
      if (mounted && shouldShowAd && adLoaded) {
           final completer = Completer<void>();
           adService.showInterstitial(onAdClosed: () {
             if (!completer.isCompleted) completer.complete();
           });
           await completer.future;
      }
      
      // 5. 等待分析結果 (如果分析比廣告慢，這裡會繼續等；如果比廣告快，這裡已經完成了)
      final result = await analysisFuture;
      
      // --- 以下邏輯保持不變 ---
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result['success'] == true && result['items'] != null) {
          final List<dynamic> items = result['items'];
          
          // Check if items list is empty (AI found no food)
          if (items.isEmpty) {
            final String errorMessage = currentLocale.languageCode == 'zh' 
                ? '分析失敗，請上傳正確的食物照片' 
                : 'Analysis failed, please upload a correct food photo';
                
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: const Color(0xFFEF4444),
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Do NOT deduct quota, do NOT navigate
            return; 
          }

          // 導航到結果頁面
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CameraResultScreen(
                imageFile: imageFile,
                analysisResult: result,
              ),
            ),
          );
          
          // 扣除配額 (MainNavigationScreen) - Only on success
          if (mounted) {
            final membership = Provider.of<MembershipProvider>(context, listen: false);
            await membership.consumeAiQuota();
          }
          
          // 這裡可以觸發最後的教學步驟 (Step 12)
          if (FoodaApp.tutorialController.isTutorialActive) {
             FoodaApp.tutorialController.startFinalTutorial(context);
          }
          
        } else {
          final errorMessage = result['error'] ?? '無法識別食物';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // Can't easily check if dialog is open. 
        // Best effort: Popping inside try block is standard. 
        Navigator.of(context).maybePop(); 
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.analysisFailed}: $e')),
        );
      }
    }
  }

  void _openManualInput(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ManualInputScreen(),
      ),
    );
  }
}

class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}

class _AddMealOptionsSheet extends StatefulWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final VoidCallback onManualTap;

  const _AddMealOptionsSheet({
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.onManualTap,
  });

  @override
  State<_AddMealOptionsSheet> createState() => _AddMealOptionsSheetState();
}

class _AddMealOptionsSheetState extends State<_AddMealOptionsSheet> {
  TutorialController get _tutorialController => FoodaApp.tutorialController;

  @override
  void initState() {
    super.initState();
    // 只有在主教學剛完成（步驟 7）時，才啟動底部選單教學
    // 避免每次打開選單都重複執行步驟 8-10
    final bool isCompleted = AppConfig.getBool(AppConstants.keyTutorialCompleted);
    
    if (!isCompleted && 
        _tutorialController.isTutorialActive && 
        _tutorialController.currentSession == TutorialSession.main) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tutorialController.log('🎓 第一次打開底部選單，啟動步驟 8-10');
        _tutorialController.startBottomSheetTutorial(context);
      });
    } else if (_tutorialController.isTutorialActive) {
      _tutorialController.log('ℹ️ 底部選單已打開，但不在步驟 7，跳過教學');
    }
  }

  @override
  Widget build(BuildContext context) {
    // 必須使用 ShowCaseWidget 包裹，因為這是新的 Modal Route
    return ShowCaseWidget(
      onStart: (index, key) {
        _tutorialController.log('🚀 底部選單 Step started: index=$index, key=$key');
      },
      onComplete: (index, key) {
        _tutorialController.log('✅ 底部選單 Step completed: index=$index, key=$key');
      },
      onFinish: () {
        _tutorialController.log('🏁 底部選單 Showcase session finished');
        _tutorialController.onShowcaseFinish(context);
      },
      builder: (context) => AnimatedBuilder(
        animation: _tutorialController,
        builder: (context, child) {
          return ShowcaseWidgetWrapper(
            showcaseKey: _tutorialController.addMealBottomSheetKey,
            step: TutorialStep.step11_galleryAction,
            targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            // 當用戶點擊整個底部選單時，我們期望他們去點擊相簿，所以這裡不需要特別的 onTargetClick
            // 因為 ShowCaseWidgetWrapper 預設不會攔截點擊，用戶可以直接點擊內部的相簿按鈕
            description: '現在點擊相簿按鈕，開始我們的第一筆紀錄', // 特別指定描述，覆蓋預設
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Text(
                      AppLocalizations.of(context)!.addRecord ?? 'Add Record',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // 拍照選項（步驟 8）
                    ShowcaseWidgetWrapper(
                      showcaseKey: _tutorialController.cameraOptionKey,
                      step: TutorialStep.step8_camera,
                      targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: _buildAddOption(
                        context,
                        icon: Icons.camera_alt,
                        title: AppLocalizations.of(context)!.takePhoto ?? 'Take Photo',
                        subtitle: AppLocalizations.of(context)!.aiAutoAnalyze ?? 'AI automatically identifies food nutrition',
                        color: const Color(0xFF3B82F6),
                        onTap: widget.onCameraTap,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 相簿選項 - 步驟 9：介紹相簿功能
                    // 步驟 11 現在由外層的 Container 負責
                    ShowcaseWidgetWrapper(
                      showcaseKey: _tutorialController.galleryOptionKey,
                      step: TutorialStep.step9_gallery,
                      targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      onTargetClick: () {
                         _tutorialController.log('🎯 步驟 9：介紹相簿功能');
                      },
                      child: _buildAddOption(
                        context,
                        icon: Icons.photo_library,
                        title: AppLocalizations.of(context)!.chooseFromGallery ?? 'Choose from Gallery',
                        subtitle: AppLocalizations.of(context)!.chooseFromGallerySubtitle ?? 'Select photos from album for recognition',
                        color: const Color(0xFF10B981),
                        onTap: () {
                          // 如果在步驟 11，點擊這裡會觸發相簿邏輯
                          if (_tutorialController.currentStep == TutorialStep.step11_galleryAction) {
                            _tutorialController.log('🎯 步驟 11：用戶點擊相簿，執行打開相簿');
                          }
                          widget.onGalleryTap();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    ShowcaseWidgetWrapper(
                      showcaseKey: _tutorialController.manualOptionKey,
                      step: TutorialStep.step10_manual,
                      targetShapeBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: _buildAddOption(
                        context,
                        icon: Icons.edit,
                        title: AppLocalizations.of(context)!.manualInput ?? 'Manual Input',
                        subtitle: AppLocalizations.of(context)!.manualInputSubtitle ?? 'Manual input nutrition info with AI assistance',
                        color: const Color(0xFF8B5CF6),
                        onTap: widget.onManualTap,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: context.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).disabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
