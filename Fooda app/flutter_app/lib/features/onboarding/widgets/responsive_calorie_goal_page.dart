import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_step.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../l10n/app_localizations.dart';

class ResponsiveCalorieGoalPage extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const ResponsiveCalorieGoalPage({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ResponsiveCalorieGoalPage> createState() => _ResponsiveCalorieGoalPageState();
}

class _ResponsiveCalorieGoalPageState extends State<ResponsiveCalorieGoalPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _bmrController;
  late Animation<double> _progressAnimation;
  late Animation<int> _bmrAnimation;
  
  final _calorieController = TextEditingController();
  bool _useAIGoal = true;
  int _calculatedBMR = 0;
  int _recommendedCalories = 0;
  bool _showCalculation = false;

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _bmrController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.4,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward();
    _calculateCalories();
    
    if (widget.data.useAIGoal != null) {
      _useAIGoal = widget.data.useAIGoal!;
    }
    if (widget.data.calorieGoal != null) {
      _calorieController.text = widget.data.calorieGoal.toString();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _bmrController.dispose();
    _calorieController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    if (widget.data.height != null &&
        widget.data.weight != null &&
        widget.data.age != null &&
        widget.data.gender != null &&
        widget.data.activityLevel != null) {
      
      double bmr;
      if (widget.data.gender == 'male') {
        bmr = 88.362 + (13.397 * widget.data.weight!) + 
              (4.799 * widget.data.height!) - (5.677 * widget.data.age!);
      } else {
        bmr = 447.593 + (9.247 * widget.data.weight!) + 
              (3.098 * widget.data.height!) - (4.330 * widget.data.age!);
      }
      
      double activityMultiplier;
      switch (widget.data.activityLevel) {
        case 'sedentary':
          activityMultiplier = 1.2;
          break;
        case 'light':
          activityMultiplier = 1.375;
          break;
        case 'moderate':
          activityMultiplier = 1.55;
          break;
        case 'high':
          activityMultiplier = 1.725;
          break;
        case 'veryHigh':
          activityMultiplier = 1.9;
          break;
        default:
          activityMultiplier = 1.2;
      }
      
      _calculatedBMR = bmr.round();
      _recommendedCalories = (bmr * activityMultiplier).round();
      
      if (_useAIGoal) {
        _calorieController.text = _recommendedCalories.toString();
      }
      
      _bmrAnimation = IntTween(
        begin: 0,
        end: _recommendedCalories,
      ).animate(CurvedAnimation(
        parent: _bmrController,
        curve: Curves.easeOutCubic,
      ));
      
      _bmrController.forward();
      
      setState(() {
        _showCalculation = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Padding(
            padding: ResponsiveUtils.getSafePadding(context),
            child: Column(
              children: [
                // 進度條
                _buildProgressBar(theme),
                
                SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
                
                // 內容區域
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 標題 (Move into ScrollView)
                        _buildTitle(theme),
                        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),

                        // AI 建議卡片
                        if (_showCalculation) ...[
                          _buildAIRecommendationCard(theme),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                        ],
                        
                        // 選擇方式
                        _buildGoalSelection(theme),
                        
                        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                        
                        // 手動輸入區域
                        if (!_useAIGoal) ...[
                          _buildManualInput(theme),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                        ],
                        
                        // 說明信息
                        _buildInfoCard(theme),
                      ],
                    ),
                  ),
                ),
                
                // 按鈕區域
                _buildButtonRow(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProgressBar(ThemeData theme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '步驟 3/5',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
                color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.calorieGoalTitle,
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
                color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return LinearProgressIndicator(
              value: _progressAnimation.value,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
              minHeight: 6,
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.setCalorieGoal ?? '設定您的卡路里目標',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
        
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            AppLocalizations.of(context)!.calorieCalculationDescription ?? '我們根據您的身體資料為您計算了個人化的卡路里需求',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
              color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAIRecommendationCard(ThemeData theme) {
    return Container(
      padding: ResponsiveUtils.getSafePadding(context),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, SpacingType.small)),
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: ResponsiveUtils.getIconSize(context, IconSizeType.medium),
                ),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.aiSmartRecommendation ?? 'AI 智能建議',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
                    fontWeight: FontWeight.bold,
                    color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
          
          // 動畫數字顯示
          AnimatedBuilder(
            animation: _bmrAnimation,
            builder: (context, child) {
              return Column(
                children: [
                  Text(
                    '${_bmrAnimation.value}',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.headline),
                      fontWeight: FontWeight.bold,
                      color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.caloriesPerDay ?? '卡路里/天',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                      color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
          
          Container(
            padding: ResponsiveUtils.getSafePadding(context),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _buildCalorieDetail(AppLocalizations.of(context)!.basalMetabolicRate ?? '基礎代謝率 (BMR)', _calculatedBMR),
                SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
                _buildCalorieDetail(AppLocalizations.of(context)!.activityLevel ?? '活動水平', '${widget.data.activityLevel}'),
                SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
                _buildCalorieDetail(AppLocalizations.of(context)!.recommendedDailyIntake ?? '建議每日攝取', _recommendedCalories, isHighlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCalorieDetail(String label, dynamic value, {bool isHighlight = false}) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
            color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value is int ? '$value ${AppLocalizations.of(context)!.cal ?? '卡'}' : value.toString(),
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
            color: isHighlight ? (theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor) : (theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurface),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildGoalSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.selectSettingMethod ?? '選擇設定方式',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        
        _buildSelectionOption(
          title: AppLocalizations.of(context)!.useAIRecommendation ?? '使用 AI 建議',
          subtitle: AppLocalizations.of(context)!.intelligentCalcFromBodyData ?? '根據您的身體數據智能計算',
          icon: Icons.auto_awesome,
          isSelected: _useAIGoal,
          onTap: () {
            setState(() {
              _useAIGoal = true;
              _calorieController.text = _recommendedCalories.toString();
            });
            _updateData();
          },
          theme: theme,
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        
        _buildSelectionOption(
          title: AppLocalizations.of(context)!.manualSetting ?? '手動設定',
          subtitle: AppLocalizations.of(context)!.inputDailyCalorieGoal ?? '自己輸入每日卡路里目標',
          icon: Icons.edit,
          isSelected: !_useAIGoal,
          onTap: () {
            setState(() {
              _useAIGoal = false;
            });
            _updateData();
          },
          theme: theme,
        ),
      ],
    );
  }
  
  Widget _buildSelectionOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    final isDark = theme.brightness == Brightness.dark;
    final blueColor = const Color(0xFF3B82F6);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? blueColor.withOpacity(0.25) 
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
          border: Border.all(
            color: isSelected 
                ? blueColor 
                : (isDark ? Colors.white.withOpacity(0.6) : theme.dividerColor),
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected 
                    ? blueColor 
                    : (isDark ? Colors.white.withOpacity(0.1) : theme.colorScheme.secondary),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? Colors.white : theme.primaryColor),
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected 
                          ? blueColor 
                          : (isDark ? Colors.white : theme.colorScheme.onSurface),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: blueColor,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildManualInput(ThemeData theme) {
    // 引導畫面強制使用淺色模式
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.dailyCalorieGoal ?? '每日卡路里目標',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        TextFormField(
          controller: _calorieController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => _updateData(),
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.local_fire_department,
              size: ResponsiveUtils.getIconSize(context, IconSizeType.medium),
            ),
            suffixText: AppLocalizations.of(context)!.calories ?? '卡路里',
            hintText: AppLocalizations.of(context)!.enterDailyCalorieGoal ?? '輸入每日卡路里目標',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.primaryColor),
            ),
            filled: true,
            fillColor: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
            contentPadding: ResponsiveUtils.getSafePadding(context),
          ),
        ),
      ],
    );
  }
  
  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: ResponsiveUtils.getSafePadding(context),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.primary,
                size: ResponsiveUtils.getIconSize(context, IconSizeType.medium),
              ),
              SizedBox(width: ResponsiveUtils.getSpacing(context, SpacingType.small)),
              Text(
                AppLocalizations.of(context)!.kindTip ?? '溫馨提示',
                style: TextStyle(
                  fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
          Text(
            AppLocalizations.of(context)!.calorieGoalTip ?? '您可以隨時在設定中調整卡路里目標。建議根據實際情況適當調整，以達到理想的健康效果。',
            style: TextStyle(
              fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildButtonRow(ThemeData theme) {
    final buttonHeight = ResponsiveUtils.getButtonHeight(context);
    
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton(
              onPressed: widget.onBack,
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    AppLocalizations.of(context)!.previous ?? '上一步',
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _canProceed() ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  AppLocalizations.of(context)!.startExperience ?? '開始體驗',
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  bool _canProceed() {
    if (_useAIGoal) {
      return _recommendedCalories > 0;
    } else {
      final calories = int.tryParse(_calorieController.text);
      return calories != null && calories >= 800 && calories <= 5000;
    }
  }
  
  void _updateData() {
    final calories = int.tryParse(_calorieController.text);
    
    final updatedData = OnboardingData(
      height: widget.data.height,
      weight: widget.data.weight,
      age: widget.data.age,
      gender: widget.data.gender,
      activityLevel: widget.data.activityLevel,
      calorieGoal: calories,
      useAIGoal: _useAIGoal,
    );
    
    widget.onDataChanged(updatedData);
  }
  
  void _handleNext() {
    if (_canProceed()) {
      _updateData();
      widget.onNext();
    }
  }
}