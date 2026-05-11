import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_step.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../l10n/app_localizations.dart';

class ActivityLevelInfo {
  final String title;
  final String description;
  final String examples;
  final IconData icon;

  ActivityLevelInfo({
    required this.title,
    required this.description,
    required this.examples,
    required this.icon,
  });
}

class ResponsiveBodyDataPage extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onDataChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;
  
  const ResponsiveBodyDataPage({
    super.key,
    required this.data,
    required this.onDataChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ResponsiveBodyDataPage> createState() => _ResponsiveBodyDataPageState();
}

class _ResponsiveBodyDataPageState extends State<ResponsiveBodyDataPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();
  
  String? _selectedGender;
  String? _selectedActivityLevel;
  
  Map<String, ActivityLevelInfo> _getActivityLevels(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'sedentary': ActivityLevelInfo(
        title: l10n.sedentary ?? 'Sedentary',
        description: (l10n.sedentaryDesc ?? 'Office workers, little exercise, Less than 1 workout per week').replaceAll('\\n', ', ').replaceAll('\n', ', '),
        examples: l10n.sedentaryExamples ?? 'Sitting at desk, watching TV, reading',
        icon: Icons.chair,
      ),
      'light': ActivityLevelInfo(
        title: l10n.lightActivity ?? 'Light Activity',
        description: (l10n.lightActivityDesc ?? 'Occasional walking or light exercise, 1-3 workouts per week').replaceAll('\\n', ', ').replaceAll('\n', ', '),
        examples: l10n.lightActivityExamples ?? 'Walking, light yoga, household activities',
        icon: Icons.directions_walk,
      ),
      'moderate': ActivityLevelInfo(
        title: l10n.moderateActivity ?? 'Moderate Activity',
        description: (l10n.moderateActivityDesc ?? 'Regular exercise habits, 3-5 workouts per week').replaceAll('\\n', ', ').replaceAll('\n', ', '),
        examples: l10n.moderateActivityExamples ?? 'Running, swimming, cycling, gym',
        icon: Icons.directions_run,
      ),
      'high': ActivityLevelInfo(
        title: l10n.highActivity ?? 'High Activity',
        description: (l10n.highActivityDesc ?? 'Daily exercise, Higher exercise intensity').replaceAll('\\n', ', ').replaceAll('\n', ', '),
        examples: l10n.highActivityExamples ?? 'Daily running, weight training, competitive sports',
        icon: Icons.fitness_center,
      ),
      'veryHigh': ActivityLevelInfo(
        title: l10n.veryHighActivity ?? 'Very High Activity',
        description: (l10n.veryHighActivityDesc ?? 'Professional athlete level, High-intensity training').replaceAll('\\n', ', ').replaceAll('\n', ', '),
        examples: l10n.veryHighActivityExamples ?? 'Professional athletes, marathon runners',
        icon: Icons.emoji_events,
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 0.4,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressController.forward();
    
    // 初始化數據
    if (widget.data.height != null) {
      _heightController.text = widget.data.height!.toStringAsFixed(1);
    }
    if (widget.data.weight != null) {
      _weightController.text = widget.data.weight!.toStringAsFixed(1);
    }
    if (widget.data.age != null) {
      _ageController.text = widget.data.age.toString();
    }
    _selectedGender = widget.data.gender;
    _selectedActivityLevel = widget.data.activityLevel;
  }

  @override
  void dispose() {
    _progressController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
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
                
                // 表單內容
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // 標題 (Move into ScrollView for better responsiveness)
                          _buildTitle(theme),
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),

                          // 性別選擇
                          _buildGenderSelection(theme),
                          
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                          
                          // 身高和體重
                          _buildHeightWeightRow(theme),
                          
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                          
                          // 年齡
                          _buildAgeInput(theme),
                          
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.large)),
                          
                          // 活動水平
                          _buildActivityLevelSelection(theme),
                          
                          SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.extraLarge)),
                        ],
                      ),
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
              '步驟 2/5',
              style: TextStyle(
                fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.small),
                color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              AppLocalizations.of(context)!.bodyDataTitle ?? '身體數據',
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
        Text(
          AppLocalizations.of(context)!.tellUsYourBodyData ?? '告訴我們關於您的信息',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.title),
            fontWeight: FontWeight.bold,
            color: theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
        Text(
          AppLocalizations.of(context)!.bodyDataDescription ?? '這些數據將幫助我們計算您的每日卡路里需求',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
            color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGenderSelection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.gender ?? '性別',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        Row(
          children: [
            Expanded(
              child: _buildSelectionOption(
                title: AppLocalizations.of(context)!.male ?? '男性',
                icon: Icons.male,
                isSelected: _selectedGender == 'male',
                onTap: () {
                  setState(() => _selectedGender = 'male');
                  _updateData();
                },
                theme: theme,
              ),
            ),
            SizedBox(width: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
            Expanded(
              child: _buildSelectionOption(
                title: AppLocalizations.of(context)!.female ?? '女性',
                icon: Icons.female,
                isSelected: _selectedGender == 'female',
                onTap: () {
                  setState(() => _selectedGender = 'female');
                  _updateData();
                },
                theme: theme,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionOption({
    required String title,
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected 
              ? blueColor.withOpacity(0.25) // Stronger blue tint
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.transparent),
          border: Border.all(
            color: isSelected 
                ? blueColor 
                : (isDark ? Colors.white.withOpacity(0.6) : theme.dividerColor), // More visible white border
            width: isSelected ? 2 : 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected 
                  ? blueColor 
                  : (isDark ? Colors.white : theme.colorScheme.onSurface),
              size: 32,
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected 
                    ? blueColor 
                    : (isDark ? Colors.white : theme.colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightWeightRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: _buildNumberInput(
            controller: _heightController,
            label: AppLocalizations.of(context)!.height ?? '身高',
            unit: 'cm',
            icon: Icons.height,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final n = double.tryParse(value);
              if (n == null || n < 50 || n > 300) return 'Invalid';
              return null;
            },
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        Expanded(
          child: _buildNumberInput(
            controller: _weightController,
            label: AppLocalizations.of(context)!.weight ?? '體重',
            unit: 'kg',
            icon: Icons.monitor_weight_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Required';
              final n = double.tryParse(value);
              if (n == null || n < 20 || n > 500) return 'Invalid';
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAgeInput(ThemeData theme) {
    return _buildNumberInput(
      controller: _ageController,
      label: AppLocalizations.of(context)!.age ?? '年齡',
      unit: AppLocalizations.of(context)!.yearsOld ?? '歲',
      icon: Icons.cake,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final n = int.tryParse(value);
        if (n == null || n < 10 || n > 120) return 'Invalid';
        return null;
      },
    );
  }
  Widget _buildNumberInput({
    required TextEditingController controller,
    required String label,
    required String unit,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    // 引導畫面強制使用淺色模式
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.small)),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1}')),
          ],
          validator: validator,
          onChanged: (_) => _updateData(),
          autofocus: false,
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: ResponsiveUtils.getIconSize(context, IconSizeType.medium),
            ),
            suffixText: unit,
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
  
  Widget _buildActivityLevelSelection(ThemeData theme) {
    final blueColor = const Color(0xFF3B82F6);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.activityLevel ?? '活動水平',
          style: TextStyle(
            fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.subtitle),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, SpacingType.medium)),
        ..._getActivityLevels(context).entries.map((entry) {
          final levelKey = entry.key;
          final levelInfo = entry.value;
          final isSelected = _selectedActivityLevel == levelKey;
          
          return Padding(
            padding: EdgeInsets.only(
              bottom: 16,
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedActivityLevel = levelKey;
                });
                _updateData();
              },
              borderRadius: BorderRadius.circular(16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: ResponsiveUtils.getSafePadding(context),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? blueColor.withOpacity(0.15) 
                      : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : theme.cardColor),
                  border: Border.all(
                    color: isSelected 
                        ? blueColor 
                        : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.6) : theme.dividerColor),
                    width: isSelected ? 2 : 1.5,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: blueColor.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : [],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 圖標
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? blueColor 
                            : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.1) : theme.colorScheme.secondary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        levelInfo.icon,
                        size: 24,
                        color: isSelected 
                            ? Colors.white 
                            : (theme.brightness == Brightness.dark ? Colors.white : theme.primaryColor),
                      ),
                    ),
                    
                    SizedBox(width: 16),
                    
                    // 內容
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 標題
                          Text(
                            levelInfo.title,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected 
                                  ? blueColor 
                                  : (theme.brightness == Brightness.dark ? Colors.white : theme.colorScheme.onSurface),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          
                          SizedBox(height: 4),
                          
                          // 描述
                          Text(
                            levelInfo.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: theme.brightness == Brightness.dark ? Colors.white70 : theme.colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          
                          SizedBox(height: 8),
                          
                          // 範例
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? blueColor.withOpacity(0.1) 
                                  : (theme.brightness == Brightness.dark ? Colors.white.withOpacity(0.05) : theme.colorScheme.surfaceContainerHighest),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${AppLocalizations.of(context)!.example ?? '例如'}：${levelInfo.examples}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isSelected 
                                    ? blueColor 
                                    : (theme.brightness == Brightness.dark ? Colors.white60 : theme.colorScheme.onSurfaceVariant),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // 選中指示器
                    if (isSelected) ...[
                      SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        color: blueColor,
                        size: 24,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),
      ],
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
                    AppLocalizations.of(context)!.previous,
                    style: TextStyle(
                      fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                  AppLocalizations.of(context)!.next,
                  style: TextStyle(
                    fontSize: ResponsiveUtils.getFontSize(context, FontSizeType.body),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  bool _canProceed() {
    return _selectedGender != null &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _ageController.text.isNotEmpty &&
        _selectedActivityLevel != null;
  }
  
  void _updateData() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    final age = int.tryParse(_ageController.text);
    
    final updatedData = OnboardingData(
      height: height,
      weight: weight,
      age: age,
      gender: _selectedGender,
      activityLevel: _selectedActivityLevel,
      calorieGoal: widget.data.calorieGoal,
      useAIGoal: widget.data.useAIGoal,
    );
    
    widget.onDataChanged(updatedData);
  }
  
  void _handleNext() {
    if (_formKey.currentState!.validate()) {
      _updateData();
      widget.onNext();
    }
  }
}