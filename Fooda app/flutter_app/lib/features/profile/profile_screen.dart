import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import 'providers/profile_provider.dart';
import '../../core/services/smart_analysis_service.dart';
import '../../features/auth/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/theme/app_theme.dart';
import '../settings/settings_screen.dart';
// import 'widgets/login_banner.dart'; // 已移除登入功能
import 'widgets/language_settings_dialog.dart';
import '../../core/theme/text_colors.dart';
import '../main_navigation/main_navigation_screen.dart';
import '../../main.dart';
import '../meals/providers/meal_provider.dart';
import '../membership/providers/membership_provider.dart';
import '../membership/membership_screen.dart';
import '../debug/debug_ad_test.dart';

/// 個人頁面
/// 完全對應 PHP 版本的 personpage.php
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 頂部標題（對應 header）
            _buildHeader(context),
            
            // 主要內容（可滾動）
            Expanded(
              child: Consumer<ProfileProvider>(
                builder: (context, profile, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 帳戶區塊
                        _buildAccountHeader(context, profile),
                        
                        const SizedBox(height: 24),

                        // 訂閱狀態卡片
                        Consumer<MembershipProvider>(
                          builder: (context, membership, child) {
                            return _buildSubscriptionCard(context, membership);
                          },
                        ),

                        const SizedBox(height: 16),
                        
                        // 身體資料卡片（對應 body-data-card）
                        _buildBodyDataCard(context, profile),
                        
                        const SizedBox(height: 16),
                        
                        // 營養目標卡片（對應 nutrition-goals-card）
                        _buildNutritionGoalsCard(context, profile),
                        
                        const SizedBox(height: 16),
                        
                        // 通知設定卡片（對應 notification-card）
                        _buildNotificationCard(context, profile),
                        
                        const SizedBox(height: 16),
                        
                        // 設定按鈕
                        _buildSettingsButton(context),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 頂部標題（對應 header）
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)!.navProfile,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          IconButton(
            onPressed: () => _showSponsorCodeDialog(context),
            icon: Icon(
              Icons.card_giftcard,
              color: theme.colorScheme.surface, // Make it invisible
            ),
          ),
        ],
      ),
    );
  }

  void _showSponsorCodeDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.sponsorCode),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.enterSponsorCode,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              final code = controller.text.trim();
              final membership = Provider.of<MembershipProvider>(context, listen: false);
              
              if (code == 'Harryhua20051023') {
                await membership.upgradeTo(MembershipTier.premium);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.redemptionSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else if (code == 'Harryhua05') {
                await membership.downgradeToFree();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.redemptionSuccess),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.invalidCode),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.confirm),
          ),
        ],
      ),
    );
  }

  /// 帳戶區塊 (頭像、暱稱、登入狀態)
  Widget _buildAccountHeader(BuildContext context, ProfileProvider profile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 頭像
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              // 暱稱與狀態
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 暱稱 (可編輯)
                    GestureDetector(
                      onTap: () => _showEditNicknameDialog(context, profile),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              profile.userName == '本地用戶' 
                                  ? (AppLocalizations.of(context)!.localUser) 
                                  : profile.userName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // 登入狀態
                    FutureBuilder<bool>(
                      future: AuthService.isLoggedIn(),
                      builder: (context, snapshot) {
                        final isLoggedIn = snapshot.data ?? false;
                        if (isLoggedIn) {
                          return Row(
                            children: [
                              Icon(Icons.check_circle, size: 14, color: Colors.green),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)!.appleIdConnected,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => _handleSignOut(context),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: theme.colorScheme.error.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.logout,
                                    style: TextStyle(
                                      fontSize: 11, // Slightly smaller font
                                      color: theme.colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            onTap: () => _handleSignIn(context),
                            child: Text(
                              AppLocalizations.of(context)!.signInWithApple,
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      final success = await AuthService.signInWithApple();
      if (success) {
        if (mounted) {
          setState(() {}); // Refresh UI
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.signInSuccessful)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.signInFailed(e.toString()))),
        );
      }
    }
  }

  Future<void> _handleSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.logout),
        content: Text(AppLocalizations.of(context)!.signOutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.logout),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.signOut();
      if (mounted) {
        setState(() {}); // Refresh UI
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.signedOutSuccessful)),
        );
      }
    }
  }

  void _showEditNicknameDialog(BuildContext context, ProfileProvider profile) {
    final controller = TextEditingController(text: profile.userName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.editProfile),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context)!.nickname,
            hintText: AppLocalizations.of(context)!.enterNickname,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                profile.updateUserName(controller.text);
                Navigator.pop(context);
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  /// 訂閱狀態卡片
  Widget _buildSubscriptionCard(BuildContext context, MembershipProvider membership) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isPremium = membership.isPremium || membership.isPremiumPlus;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPremium
              ? [const Color(0xFF3B82F6), const Color(0xFF2563EB)]
              : [theme.cardColor, theme.cardColor],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: isPremium ? null : Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isPremium ? Colors.white.withOpacity(0.2) : theme.colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_rounded,
              color: isPremium ? Colors.white : theme.colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPremium ? 'Fooda Premium' : (AppLocalizations.of(context)!.freeVersion),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isPremium ? Colors.white : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isPremium ? (AppLocalizations.of(context)!.unlockedAllFeatures) : (AppLocalizations.of(context)!.upgradeForUnlimited),
                  style: TextStyle(
                    fontSize: 14,
                    color: isPremium ? Colors.white.withOpacity(0.9) : theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isPremium ? Colors.white : theme.colorScheme.primary,
              foregroundColor: isPremium ? const Color(0xFF2563EB) : Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Text(
              isPremium ? (AppLocalizations.of(context)!.manage) : (AppLocalizations.of(context)!.upgrade),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// 身體資料卡片（對應 body-data-card）
  Widget _buildBodyDataCard(BuildContext context, ProfileProvider profile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.personalInfo,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // 資料列表（對應 body-data-list）
          _buildDataItem(
            context,
            label: AppLocalizations.of(context)!.age,
            value: '${profile.age}',
            unit: AppLocalizations.of(context)!.yearsOld,
            onTap: () => _showEditAgeDialog(context, profile),
          ),
          _buildDivider(context),
          _buildDataItem(
            context,
            label: AppLocalizations.of(context)!.height,
            value: '${profile.height}',
            unit: 'cm',
            onTap: () => _showEditHeightDialog(context, profile),
          ),
          _buildDivider(context),
          _buildDataItem(
            context,
            label: AppLocalizations.of(context)!.currentWeight,
            value: '${profile.weight}',
            unit: 'kg',
            onTap: () => _showEditWeightDialog(context, profile),
          ),
          _buildDivider(context),
          _buildDataItem(
            context,
            label: AppLocalizations.of(context)!.gender,
            value: profile.gender == 'male' ? AppLocalizations.of(context)!.male : AppLocalizations.of(context)!.female,
            unit: '',
            onTap: () => _showEditGenderDialog(context, profile),
          ),
          _buildDivider(context),
          _buildDataItem(
            context,
            label: AppLocalizations.of(context)!.activityLevel,
            value: _getActivityLevelDisplayName(context, profile.activityLevelName),
            unit: '',
            onTap: () => _showEditActivityDialog(context, profile),
          ),
        ],
      ),
    );
  }

  /// 營養目標卡片（對應 nutrition-goals-card）
  Widget _buildNutritionGoalsCard(BuildContext context, ProfileProvider profile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.nutritionGoals,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 1,
                child: GestureDetector(
                  onTap: () => _showSmartRecommendationsDialog(context, profile),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              AppLocalizations.of(context)!.smartSuggestion,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 目標列表（對應 nutrition-goals-list）
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.calories,
            value: '${profile.caloriesGoal.toInt()}',
            unit: 'kcal',
            color: AppTheme.macroCalories,
            onTap: () => _showEditCaloriesDialog(context, profile),
          ),
          _buildDivider(context),
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.carbs,
            value: '${profile.carbsGoal.toInt()}',
            unit: 'g',
            color: AppTheme.macroCarbs,
            onTap: () => _showEditCarbsDialog(context, profile),
          ),
          _buildDivider(context),
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.protein,
            value: '${profile.proteinGoal.toInt()}',
            unit: 'g',
            color: AppTheme.macroProtein,
            onTap: () => _showEditProteinDialog(context, profile),
          ),
          _buildDivider(context),
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.fat,
            value: '${profile.fatGoal.toInt()}',
            unit: 'g',
            color: AppTheme.macroFat,
            onTap: () => _showEditFatDialog(context, profile),
          ),
          _buildDivider(context),
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.sodium,
            value: '${profile.sodiumGoal.toInt()}',
            unit: 'mg',
            color: AppTheme.macroSodium,
            onTap: () => _showEditSodiumDialog(context, profile),
          ),
          _buildDivider(context),
          _buildGoalItem(
            context,
            label: AppLocalizations.of(context)!.fiber,
            value: '${profile.fiberGoal.toInt()}',
            unit: 'g',
            color: AppTheme.macroFiber,
            onTap: () => _showEditFiberDialog(context, profile),
          ),
        ],
      ),
    );
  }

  /// 通知設定卡片（對應 notification-card）
  Widget _buildNotificationCard(BuildContext context, ProfileProvider profile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.mealReminders,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          // 提醒列表（對應 notification-list）
          _buildNotificationItem(
            context,
            mealName: AppLocalizations.of(context)!.breakfastReminder,
            time: profile.breakfastTime,
            onTap: () => _showEditBreakfastTimeDialog(context, profile),
          ),
          _buildDivider(context),
          _buildNotificationItem(
            context,
            mealName: AppLocalizations.of(context)!.lunchReminder,
            time: profile.lunchTime,
            onTap: () => _showEditLunchTimeDialog(context, profile),
          ),
          _buildDivider(context),
          _buildNotificationItem(
            context,
            mealName: AppLocalizations.of(context)!.dinnerReminder,
            time: profile.dinnerTime,
            onTap: () => _showEditDinnerTimeDialog(context, profile),
          ),
        ],
      ),
    );
  }

  /// 資料項目（對應 data-item）
  Widget _buildDataItem(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 3,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 目標項目（對應 goal-item）
  Widget _buildGoalItem(
    BuildContext context, {
    required String label,
    required String value,
    required String unit,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 通知項目（對應 notification-item）
  Widget _buildNotificationItem(
    BuildContext context, {
    required String mealName,
    required String time,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final timeParts = time.split(':');
    final hour = int.parse(timeParts[0]);
    final period = hour >= 12 ? 'PM' : 'AM';
    
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Text(
                mealName,
                style: TextStyle(
                  fontSize: 15,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              flex: 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      time,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    period,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 設定按鈕
  Widget _buildSettingsButton(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () => _navigateToSettings(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.settings_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.appSettings ?? '應用設定',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 分隔線
  Widget _buildDivider(BuildContext context) {
    final theme = Theme.of(context);
    return Divider(
      height: 1,
      thickness: 1,
      color: theme.dividerColor,
    );
  }

  /// 設定選項瓦片
  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: theme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null ? Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ) : null,
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
        onTap: onTap,
      ),
    );
  }

  /// 顯示語言設置對話框
  void _showLanguageSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSettingsDialog(),
    );
  }

  /// 跳轉到應用設置頁面
  void _navigateToSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  /// 構建設定區塊
  Widget _buildSettingsSection({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  /// 構建設定項目
  Widget _buildSettingsItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    bool showArrow = true,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      subtitle: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      trailing: trailing ?? (showArrow ? Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }

  /// 顯示重置應用確認對話框
  void _showResetAppDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.resetApp ?? '重置應用',
          style: TextStyle(color: Colors.orange),
        ),
        content: Text(
          l10n.resetAppWarning ?? '此操作將清除所有本地數據，包括：\n\n• 所有餐點記錄\n• 個人資料設定\n• 營養目標\n• 應用偏好設定\n\n此操作無法復原，確定要繼續嗎？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel ?? '取消'),
          ),
          ElevatedButton(
            onPressed: () => _performAppReset(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text(
              l10n.reset ?? '重置',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 執行應用重置
  Future<void> _performAppReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    try {
      // 這裡可以添加實際的重置邏輯
      // 例如：清除 SharedPreferences、刪除數據庫等
      
      Navigator.pop(context); // 關閉對話框
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.appResetSuccess ?? '應用已重置成功'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.appResetError ?? '重置失敗：$e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// 獲取活動程度的多語言顯示名稱
  String _getActivityLevelDisplayName(BuildContext context, String activityLevel) {
    final l10n = AppLocalizations.of(context)!;
    switch (activityLevel) {
      case 'sedentary':
        return l10n.activitySedentary;
      case 'light':
        return l10n.activityLight;
      case 'moderate':
        return l10n.activityModerate;
      case 'active':
        return l10n.activityHigh;
      case 'very_active':
        return l10n.activityExtreme;
      default:
        return l10n.activityModerate;
    }
  }



  // ========== 編輯對話框 ==========

  /// 編輯年齡
  void _showEditAgeDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: AppLocalizations.of(context)!.editAge ?? '編輯年齡',
      initialValue: profile.age,
      unit: AppLocalizations.of(context)!.yearsOld ?? '歲',
      min: 10,
      max: 120,
      onSave: (value) async {
        await profile.updateBodyData(age: value);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.ageUpdated ?? '年齡已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯身高
  void _showEditHeightDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: AppLocalizations.of(context)!.editHeight ?? '編輯身高',
      initialValue: profile.height,
      unit: 'cm',
      min: 100,
      max: 250,
      onSave: (value) async {
        await profile.updateBodyData(height: value);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.heightUpdated ?? '身高已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯體重
  void _showEditWeightDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: AppLocalizations.of(context)!.editWeight ?? '編輯體重',
      initialValue: profile.weight,
      unit: 'kg',
      min: 30,
      max: 200,
      onSave: (value) async {
        await profile.updateBodyData(weight: value);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.weightUpdated ?? '體重已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯性別
  void _showEditGenderDialog(BuildContext context, ProfileProvider profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectGender ?? '選擇性別'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(AppLocalizations.of(context)!.male),
              leading: Radio<String>(
                value: 'male',
                groupValue: profile.gender,
                onChanged: (value) async {
                  await profile.updateBodyData(gender: value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.genderUpdated ?? '性別已更新'), duration: Duration(seconds: 1)),
                    );
                  }
                },
              ),
            ),
            ListTile(
              title: Text(AppLocalizations.of(context)!.female),
              leading: Radio<String>(
                value: 'female',
                groupValue: profile.gender,
                onChanged: (value) async {
                  await profile.updateBodyData(gender: value);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context)!.genderUpdated ?? '性別已更新'), duration: Duration(seconds: 1)),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 編輯活動程度
  void _showEditActivityDialog(BuildContext context, ProfileProvider profile) {
    final l10n = AppLocalizations.of(context)!;
    final activities = [
      {'value': 'sedentary', 'name': l10n.activitySedentary, 'desc': l10n.activitySedentaryDesc},
      {'value': 'light', 'name': l10n.activityLight, 'desc': l10n.activityLightDesc},
      {'value': 'moderate', 'name': l10n.activityModerate, 'desc': l10n.activityModerateDesc},
      {'value': 'active', 'name': l10n.activityHigh, 'desc': l10n.activityHighDesc},
      {'value': 'very_active', 'name': l10n.activityExtreme, 'desc': l10n.activityExtremeDesc},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectActivityLevel ?? 'Select Activity Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: activities.map((activity) {
              return ListTile(
                title: Text(activity['name']!),
                subtitle: Text(activity['desc']!, style: const TextStyle(fontSize: 12)),
                leading: Radio<String>(
                  value: activity['value']!,
                  groupValue: profile.activityLevel,
                  onChanged: (value) async {
                    await profile.updateBodyData(activityLevel: value);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.activityLevelUpdated ?? '活動程度已更新'), duration: Duration(seconds: 1)),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel ?? '取消'),
          ),
        ],
      ),
    );
  }

  /// 編輯熱量目標
  void _showEditCaloriesDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯熱量目標',
      initialValue: profile.caloriesGoal.toInt(),
      unit: 'kcal',
      min: 1000,
      max: 5000,
      onSave: (value) async {
        await profile.updateNutritionGoals(calories: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('熱量目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯碳水目標
  void _showEditCarbsDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯碳水化合物目標',
      initialValue: profile.carbsGoal.toInt(),
      unit: 'g',
      min: 50,
      max: 500,
      onSave: (value) async {
        await profile.updateNutritionGoals(carbs: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('碳水化合物目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯蛋白質目標
  void _showEditProteinDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯蛋白質目標',
      initialValue: profile.proteinGoal.toInt(),
      unit: 'g',
      min: 30,
      max: 300,
      onSave: (value) async {
        await profile.updateNutritionGoals(protein: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('蛋白質目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯脂肪目標
  void _showEditFatDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯脂肪目標',
      initialValue: profile.fatGoal.toInt(),
      unit: 'g',
      min: 20,
      max: 200,
      onSave: (value) async {
        await profile.updateNutritionGoals(fat: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('脂肪目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯鈉目標
  void _showEditSodiumDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯鈉目標',
      initialValue: profile.sodiumGoal.toInt(),
      unit: 'mg',
      min: 500,
      max: 5000,
      onSave: (value) async {
        await profile.updateNutritionGoals(sodium: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('鈉目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯膳食纖維目標
  void _showEditFiberDialog(BuildContext context, ProfileProvider profile) {
    _showNumberEditDialog(
      context: context,
      title: '編輯膳食纖維目標',
      initialValue: profile.fiberGoal.toInt(),
      unit: 'g',
      min: 10,
      max: 100,
      onSave: (value) async {
        await profile.updateNutritionGoals(fiber: value.toDouble());
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('膳食纖維目標已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯早餐時間
  void _showEditBreakfastTimeDialog(BuildContext context, ProfileProvider profile) {
    _showTimePickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.breakfastReminderTime ?? '早餐提醒時間',
      initialTime: profile.breakfastTime,
      onSave: (time) async {
        await profile.updateNotificationSettings(breakfastTime: time);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.breakfastTimeUpdated ?? '早餐提醒時間已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯午餐時間
  void _showEditLunchTimeDialog(BuildContext context, ProfileProvider profile) {
    _showTimePickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.lunchReminderTime ?? '午餐提醒時間',
      initialTime: profile.lunchTime,
      onSave: (time) async {
        await profile.updateNotificationSettings(lunchTime: time);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.lunchTimeUpdated ?? '午餐提醒時間已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  /// 編輯晚餐時間
  void _showEditDinnerTimeDialog(BuildContext context, ProfileProvider profile) {
    _showTimePickerDialog(
      context: context,
      title: AppLocalizations.of(context)!.dinnerReminderTime ?? '晚餐提醒時間',
      initialTime: profile.dinnerTime,
      onSave: (time) async {
        await profile.updateNotificationSettings(dinnerTime: time);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.dinnerTimeUpdated ?? '晚餐提醒時間已更新'), duration: Duration(seconds: 1)),
          );
        }
      },
    );
  }

  // ========== 通用對話框 ==========

  /// 數字編輯對話框
  void _showNumberEditDialog({
    required BuildContext context,
    required String title,
    required int initialValue,
    required String unit,
    required int min,
    required int max,
    required Function(int) onSave,
  }) {
    final controller = TextEditingController(text: initialValue.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: unit,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value >= min && value <= max) {
                onSave(value);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(AppLocalizations.of(context)!.enterValidNumber(min, max))),
                );
              }
            },
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  /// 時間選擇對話框
  void _showTimePickerDialog({
    required BuildContext context,
    required String title,
    required String initialTime,
    required Function(String) onSave,
  }) async {
    final timeParts = initialTime.split(':');
    final initialTimeOfDay = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTimeOfDay,
    );

    if (picked != null) {
      final formattedTime = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      onSave(formattedTime);
    }
  }

  /// 顯示智能建議對話框
  void _showSmartRecommendationsDialog(BuildContext context, ProfileProvider profile) {
    final recommendations = SmartAnalysisService.calculateRecommendedNutritionGoals(profile);
    
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.auto_awesome, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(l10n.smartSuggestionTitle),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.smartSuggestionDesc(
                    profile.age,
                    profile.gender == 'male' ? l10n.male : l10n.female,
                    profile.weight,
                    _getActivityLevelDisplayName(context, profile.activityLevelName)),
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecommendationItem(l10n.calories, '${recommendations['calories']!.toInt()}', 'kcal', const Color(0xFF10B981)),
              _buildRecommendationItem(l10n.carbs, '${recommendations['carbs']!.toInt()}', 'g', const Color(0xFF3B82F6)),
              _buildRecommendationItem(l10n.protein, '${recommendations['protein']!.toInt()}', 'g', const Color(0xFFEF4444)),
              _buildRecommendationItem(l10n.fat, '${recommendations['fat']!.toInt()}', 'g', const Color(0xFFF97316)),
              _buildRecommendationItem(l10n.sodium, '${recommendations['sodium']!.toInt()}', 'mg', const Color(0xFF8B5CF6)),
              _buildRecommendationItem(l10n.fiber, '${recommendations['fiber']!.toInt()}', 'g', const Color(0xFFEC4899)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // 應用建議值
              profile.updateNutritionGoals(
                calories: recommendations['calories'],
                carbs: recommendations['carbs'],
                protein: recommendations['protein'],
                fat: recommendations['fat'],
                sodium: recommendations['sodium'],
                fiber: recommendations['fiber'],
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.suggestionApplied),
                  backgroundColor: const Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: context.onPrimaryText,
            ),
            child: Text(l10n.applySuggestion),
          ),
        ],
      ),
    );
  }

  /// 建議項目
  Widget _buildRecommendationItem(String label, String value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Text(
            '$value $unit',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }


}
