import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../meals/providers/meal_provider.dart';
import '../../core/widgets/meal_record_card.dart';
import '../../core/models/meal_model.dart';
import '../../l10n/app_localizations.dart';
import '../../features/membership/providers/membership_provider.dart';
import '../../features/membership/membership_screen.dart';
import '../../core/widgets/edit_meal_dialog.dart';

/// 歷史記錄頁面
/// 完全對應 PHP 版本的 historypage.php
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  late DateTime _windowStartDate;
  late List<String> _dayNames;

  @override
  void initState() {
    super.initState();
    _windowStartDate = _selectedDate.subtract(const Duration(days: 3));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 使用固定的英文簡稱，避免本地化問題
    _dayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 日期選擇器（對應 date-selector）
                    _buildDateSelector(context),
                    
                    const SizedBox(height: 24),
                    
                    // 餐飲記錄區域（對應 meal-records-section）
                    _buildMealRecordsSection(context),
                  ],
                ),
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
        children: [
          Text(
            AppLocalizations.of(context)!.navHistory,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 日期選擇器（對應 date-selector）
  Widget _buildDateSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      children: [
        // 月份顯示和導航
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 月份切換按鈕組
              Flexible(
                flex: 3,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  // 上一月
                  InkWell(
                    onTap: _goToPreviousMonth,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.chevron_left,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 月份顯示（可點擊）
                  InkWell(
                    onTap: _showMonthPicker,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _getMonthYearText(),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // 下一月
                  InkWell(
                    onTap: _goToNextMonth,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
              
              const SizedBox(width: 4),
              
              // 快捷按鈕組
              Flexible(
                flex: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                  // 週跳轉按鈕 (隱藏以節省空間)
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       _windowStartDate = _windowStartDate.subtract(const Duration(days: 7));
                  //     });
                  //   },
                  //   borderRadius: BorderRadius.circular(6),
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     child: const Icon(
                  //       Icons.keyboard_double_arrow_left,
                  //       size: 18,
                  //       color: Color(0xFF9CA3AF),
                  //     ),
                  //   ),
                  // ),
                  // const SizedBox(width: 4),
                  
                  // 今天按鈕
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDate = DateTime.now();
                        _windowStartDate = DateTime.now().subtract(const Duration(days: 3));
                      });
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AppLocalizations.of(context)!.today ?? '今天',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(width: 4),
                  
                  // 週跳轉按鈕 (隱藏以節省空間)
                  // InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       _windowStartDate = _windowStartDate.add(const Duration(days: 7));
                  //     });
                  //   },
                  //   borderRadius: BorderRadius.circular(6),
                  //   child: Container(
                  //     padding: const EdgeInsets.all(4),
                  //     child: const Icon(
                  //       Icons.keyboard_double_arrow_right,
                  //       size: 18,
                  //       color: Color(0xFF9CA3AF),
                  //     ),
                  //   ),
                  // ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 日期選擇器
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 左箭頭
              InkWell(
                onTap: () {
                  setState(() {
                    _windowStartDate = _windowStartDate.subtract(const Duration(days: 1));
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.chevron_left,
                    size: 24,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
              
              // 7天日期（使用 Expanded 防止溢出）
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(7, (index) {
                    final date = _windowStartDate.add(Duration(days: index));
                    final isToday = _isSameDay(date, DateTime.now());
                    final isSelected = _isSameDay(date, _selectedDate);
                    
                    return Expanded(
                      child: _buildDateItem(context, date, isToday, isSelected),
                    );
                  }),
                ),
              ),
              
              // 右箭頭
              InkWell(
                onTap: () {
                  setState(() {
                    _windowStartDate = _windowStartDate.add(const Duration(days: 1));
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.chevron_right,
                    size: 24,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 單個日期項目（對應 date-item）
  Widget _buildDateItem(BuildContext context, DateTime date, bool isToday, bool isSelected) {
    return Consumer<MealProvider>(
      builder: (context, mealProvider, child) {
        final theme = Theme.of(context);
        // 檢查該日期是否有記錄
        final hasRecords = mealProvider.getMealsByDate(date).isNotEmpty;
        
        return InkWell(
          onTap: () {
            setState(() {
              _selectedDate = date;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 2),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected 
                  ? theme.colorScheme.primary
                  : isToday
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 2,
                    )
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 星期名稱
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _dayNames[date.weekday % 7],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: isSelected
                          ? theme.colorScheme.onPrimary
                          : isToday
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 6),
                // 日期數字
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : isToday
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                // 記錄指示點
                if (hasRecords && !isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: isToday 
                          ? theme.colorScheme.primary
                          : theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (isToday && !isSelected)
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else
                  const SizedBox(height: 5),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 餐飲記錄區域（對應 meal-records-section）
  Widget _buildMealRecordsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 標題行（對應 section-header）
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.mealRecords ?? '餐飲記錄',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Text(
              _getSelectedDateInfo(),
              style: TextStyle(
                fontSize: 14,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // 餐飲記錄列表或空狀態
        _buildMealRecordsList(context),
      ],
    );
  }

  /// 餐飲記錄列表（對應 meal-records-list）
  Widget _buildMealRecordsList(BuildContext context) {
    return Consumer2<MealProvider, MembershipProvider>(
      builder: (context, mealProvider, membership, child) {
        // 檢查歷史記錄限制
        final daysDifference = DateTime.now().difference(_selectedDate).inDays;
        if (daysDifference > membership.historyDaysLimit) {
          return _buildUpgradePrompt(context);
        }

        // 獲取選中日期的餐點
        final meals = mealProvider.getMealsByDate(_selectedDate);
        
        if (meals.isEmpty) {
          return _buildNoRecordsMessage();
        }
        
        // 顯示餐點卡片
        return Column(
          children: meals.asMap().entries.map((entry) {
            return MealRecordCard(
              meal: entry.value,
              onTap: () => _showEditDialog(context, entry.value),
            );
          }).toList(),
        );
      },
    );
  }

  /// 升級提示
  Widget _buildUpgradePrompt(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            '免費版僅可查看最近 14 天記錄',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '升級 Premium 可查看完整歷史記錄',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MembershipScreen()),
              );
            },
            child: const Text('查看方案'),
          ),
        ],
      ),
    );
  }


  /// 顯示編輯對話框
  void _showEditDialog(BuildContext context, MealRecord meal) {
    showDialog(
      context: context,
      builder: (context) => EditMealDialog(meal: meal),
    );
  }

  /// 空記錄提示（對應 no-records）
  Widget _buildNoRecordsMessage() {
    return Builder(
      builder: (context) {
        final theme = Theme.of(context);
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Center(
            child: Column(
              children: [
                const Text(
                  '📝',
                  style: TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context)!.noRecordsForDate ?? '此日期尚無餐飲記錄',
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.clickAddToStart ?? '點擊右下角的 + 按鈕開始記錄',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 獲取選中日期信息
  String _getSelectedDateInfo() {
    final now = DateTime.now();
    if (_isSameDay(_selectedDate, now)) {
      return AppLocalizations.of(context)!.today ?? '今天';
    } else if (_isSameDay(_selectedDate, now.subtract(const Duration(days: 1)))) {
      return AppLocalizations.of(context)!.yesterday ?? '昨天';
    } else if (_isSameDay(_selectedDate, now.add(const Duration(days: 1)))) {
      return AppLocalizations.of(context)!.tomorrow ?? '明天';
    } else {
      final l10n = AppLocalizations.of(context)!;
      final format = l10n.dateFormat?.toString() ?? '{month}/{day}/{year}';
      return format.replaceAll('{year}', _selectedDate.year.toString())
        .replaceAll('{month}', _selectedDate.month.toString())
        .replaceAll('{day}', _selectedDate.day.toString());
    }
  }

  /// 判斷兩個日期是否為同一天
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// 獲取月份年份文字
  String _getMonthYearText() {
    // 獲取視窗中間的日期來顯示月份
    final middleDate = _windowStartDate.add(const Duration(days: 3));
    final monthName = _getMonthName(middleDate.month, short: true);
    final yearText = _getYearText(middleDate.year);
    return '$monthName $yearText';
  }

  /// 獲取月份名稱（支援多語言）
  String _getMonthName(int month, {bool short = false}) {
    final l10n = AppLocalizations.of(context)!;
    if (short) {
      switch (month) {
        case 1: return l10n.jan;
        case 2: return l10n.feb;
        case 3: return l10n.mar;
        case 4: return l10n.apr;
        case 5: return l10n.may_short;
        case 6: return l10n.jun;
        case 7: return l10n.jul;
        case 8: return l10n.aug;
        case 9: return l10n.sep;
        case 10: return l10n.oct;
        case 11: return l10n.nov;
        case 12: return l10n.dec;
        default: return month.toString();
      }
    } else {
      switch (month) {
        case 1: return l10n.january;
        case 2: return l10n.february;
        case 3: return l10n.march;
        case 4: return l10n.april;
        case 5: return l10n.may;
        case 6: return l10n.june;
        case 7: return l10n.july;
        case 8: return l10n.august;
        case 9: return l10n.september;
        case 10: return l10n.october;
        case 11: return l10n.november;
        case 12: return l10n.december;
        default: return month.toString();
      }
    }
  }

  /// 獲取年份文字（支援多語言）
  String _getYearText(int year) {
    // 在日曆頭部只顯示年份數字，不添加後綴
    return '$year';
  }

  /// 切換到上一月
  void _goToPreviousMonth() {
    setState(() {
      final middleDate = _windowStartDate.add(const Duration(days: 3));
      final previousMonth = DateTime(
        middleDate.year,
        middleDate.month - 1,
        1,
      );
      _windowStartDate = previousMonth.subtract(const Duration(days: 3));
      _selectedDate = previousMonth;
    });
  }

  /// 切換到下一月
  void _goToNextMonth() {
    setState(() {
      final middleDate = _windowStartDate.add(const Duration(days: 3));
      final nextMonth = DateTime(
        middleDate.year,
        middleDate.month + 1,
        1,
      );
      _windowStartDate = nextMonth.subtract(const Duration(days: 3));
      _selectedDate = nextMonth;
    });
  }

  /// 顯示月份選擇器
  Future<void> _showMonthPicker() async {
    final middleDate = _windowStartDate.add(const Duration(days: 3));
    
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 500),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 標題
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.selectMonth ?? '選擇月份',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // 年份選擇
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      setState(() {
                        final newDate = DateTime(
                          middleDate.year - 1,
                          middleDate.month,
                          1,
                        );
                        _windowStartDate = newDate.subtract(const Duration(days: 3));
                        _selectedDate = newDate;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  Text(
                    _getYearText(middleDate.year),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      setState(() {
                        final newDate = DateTime(
                          middleDate.year + 1,
                          middleDate.month,
                          1,
                        );
                        _windowStartDate = newDate.subtract(const Duration(days: 3));
                        _selectedDate = newDate;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // 月份網格
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 2.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    final month = index + 1;
                    final isCurrentMonth = month == middleDate.month;
                    
                    return InkWell(
                      onTap: () {
                        setState(() {
                          final newDate = DateTime(
                            middleDate.year,
                            month,
                            1,
                          );
                          _windowStartDate = newDate.subtract(const Duration(days: 3));
                          _selectedDate = newDate;
                        });
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isCurrentMonth
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            _getMonthName(month, short: true),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isCurrentMonth
                                  ? Theme.of(context).colorScheme.onPrimary
                                  : Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Local _EditMealDialog removed. Using imported EditMealDialog.
