import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../../core/services/payment_service.dart';

/// 會員等級
enum MembershipTier {
  free,
  premium,
  premiumPlus,
}

/// 會員系統提供者
class MembershipProvider extends ChangeNotifier {
  MembershipProvider() {
    _load();
  }

  final PaymentService _paymentService = PaymentService();

  // 會員類型
  MembershipTier _tier = MembershipTier.free;
  DateTime? _subscriptionEndDate;
  String? _subscriptionProductId;
  
  // AI 配額
  int _aiQuotaUsedThisMonth = 0;
  int _purchasedCredits = 0;
  int _manualInputUsedToday = 0;
  DateTime? _lastResetDate;
  DateTime? _lastManualInputResetDate;

  /// 載入狀態
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 載入會員等級
    final tierIndex = prefs.getInt('membership_tier') ?? MembershipTier.free.index;
    _tier = MembershipTier.values[tierIndex];
    
    // 載入配額使用情況
    _aiQuotaUsedThisMonth = prefs.getInt('ai_quota_used_month') ?? 0;
    _purchasedCredits = prefs.getInt('purchased_credits') ?? 0;
    _manualInputUsedToday = prefs.getInt('manual_input_used') ?? 0;
    
    // 載入訂閱信息
    _subscriptionProductId = prefs.getString('subscription_product_id');
    
    final endDateStr = prefs.getString('subscription_end_date');
    if (endDateStr != null) {
      _subscriptionEndDate = DateTime.parse(endDateStr);
    }
    
    // 載入重置日期
    final resetDateStr = prefs.getString('last_reset_date');
    if (resetDateStr != null) {
      _lastResetDate = DateTime.parse(resetDateStr);
    }
    
    final manualResetDateStr = prefs.getString('last_manual_reset_date');
    if (manualResetDateStr != null) {
      _lastManualInputResetDate = DateTime.parse(manualResetDateStr);
    }
    
    // 檢查過期狀態
    if (isExpired) {
      await _downgradeTo(MembershipTier.free);
    }
    
    notifyListeners();
    
    // 初始化支付服務並監聽更新
    await _initializePaymentService();
  }
  
  /// 初始化支付服務
  Future<void> _initializePaymentService() async {
    await _paymentService.initialize();
    _paymentService.addSuccessListener(handlePurchase);
  }
  
  @override
  void dispose() {
    _paymentService.removeSuccessListener(handlePurchase);
    super.dispose();
  }
  
  // Getters
  MembershipTier get tier => _tier;
  bool get isFree => _tier == MembershipTier.free;
  bool get isPremium => _tier == MembershipTier.premium;
  bool get isPremiumPlus => _tier == MembershipTier.premiumPlus;
  DateTime? get subscriptionEndDate => _subscriptionEndDate;
  String? get subscriptionProductId => _subscriptionProductId;
  
  /// 獲取會員等級名稱
  String get tierName {
    switch (_tier) {
      case MembershipTier.free:
        return '免費版';
      case MembershipTier.premium:
        return 'Premium';
      case MembershipTier.premiumPlus:
        return 'Premium Plus';
    }
  }
  
  /// 獲取會員等級顏色
  int get tierColor {
    switch (_tier) {
      case MembershipTier.free:
        return 0xFF9CA3AF; // 灰色
      case MembershipTier.premium:
        return 0xFF3B82F6; // 藍色
      case MembershipTier.premiumPlus:
        return 0xFFEAB308; // 金色
    }
  }
  
  /// 每月 AI 配額限制
  int get monthlyAiQuota {
    switch (_tier) {
      case MembershipTier.free:
        return 10;
      case MembershipTier.premium:
      case MembershipTier.premiumPlus:
        return 999999; // 無限制
    }
  }
  
  /// 每日手動輸入限制
  int get dailyManualInputLimit {
    // 手動輸入（一般拍照/上傳/文字）每日無限制
    return 999999; 
  }
  
  /// 歷史記錄天數限制
  int get historyDaysLimit {
    switch (_tier) {
      case MembershipTier.free:
        return 14;
      case MembershipTier.premium:
      case MembershipTier.premiumPlus:
        return 999999; // 無限制
    }
  }
  
  /// 剩餘 AI 配額 (AI 拍照/上傳共用此額度)
  int get remainingAiQuota => 
      (monthlyAiQuota - _aiQuotaUsedThisMonth + _purchasedCredits).clamp(0, 999999);

  /// 本月已使用 AI 配額
  int get aiQuotaUsedThisMonth => _aiQuotaUsedThisMonth;
  
  /// 是否可以使用 AI (包含 AI 拍照和 AI 上傳)
  bool get canUseAi => remainingAiQuota > 0;
  
  /// 是否顯示廣告
  bool get showAds => _tier == MembershipTier.free && !_removeAds;
  
  /// 是否可以導出數據
  bool get canExportData => _tier != MembershipTier.free;
  
  /// 是否有高級分析 (週/月視圖)
  bool get hasAdvancedAnalysis => _tier != MembershipTier.free;

  // CloudKit integration removed
  // bool get canUseCloudBackup => _tier != MembershipTier.free;

  /// 處理購買完成
  Future<void> handlePurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    
    debugPrint('📦 處理購買: $productId');
    
    // 判斷產品類型
    // 修复：不区分大小写，或者检查是否在订阅ID列表中
    // productID received from Apple might be "com.gomiigo.FoodaApp.Premium.monthly"
    if (PaymentService.subscriptionIds.contains(productId) || productId.toLowerCase().contains('premium')) {
      // Handles both premium.monthly and legacy premium IDs
      await _handleSubscription(purchase, MembershipTier.premium);
    } else if (productId.toLowerCase().contains('credits')) {
      await _handleCreditsPackage(productId);
    }
  }
  
  /// 處理訂閱購買
  Future<void> _handleSubscription(PurchaseDetails purchase, MembershipTier tier) async {
    final productId = purchase.productID;
    _tier = tier;
    _subscriptionProductId = productId;
    
    // 設置訂閱結束日期
    final isYearly = productId.contains('yearly');
    final duration = isYearly ? const Duration(days: 365) : const Duration(days: 30);
    
    // 使用交易日期計算到期日
    DateTime transactionDate = DateTime.now();
    bool parsedSuccessfully = false;

    if (purchase.transactionDate != null) {
      // transactionDate is a timestamp in milliseconds string
      try {
        var timestamp = int.parse(purchase.transactionDate!);
        
        // Robustness: If timestamp is small (seconds, < 100 billion), convert to ms
        // 2000-01-01 is roughly 946,000,000 (seconds) or 946,000,000,000 (ms)
        // Check if less than 10^11 (100 billion), which represents year 5138 if treated as seconds,
        // but represents year 1973 if treated as milliseconds.
        // It is safe to assume reasonable timestamps for IAP are > 2020.
        // 2020 timestamp in seconds ~1.5 billion. In ms ~1.5 trillion.
        // Threshold: 100,000,000,000 (100 billion)
        if (timestamp < 100000000000) {
           debugPrint('⚠️ Timestamp appears to be in seconds ($timestamp), converting to ms');
           timestamp *= 1000;
        }

        transactionDate = DateTime.fromMillisecondsSinceEpoch(timestamp);
        parsedSuccessfully = true;
        debugPrint('📅 Parsed Transaction Date: $transactionDate (from ${purchase.transactionDate})');
      } catch (e) {
        debugPrint('⚠️ 無法解析交易日期: ${purchase.transactionDate}, 使用當前時間');
      }
    }
    
    _subscriptionEndDate = transactionDate.add(duration);
    
    // Safety check: If for some reason the calculated end date is in the past
    // (e.g. old transaction restored, OR bad parsing, OR Sandbox weirdness)
    // AND this is a FRESH purchase event (not a background restore), we should ensure access.
    // 
    // In Sandbox, 1 month expires in 5 minutes. If we use transactionDate (transaction start), 
    // it handles the 5 minutes correctly.
    // But if we have the "1970 bug" or "Old Restore Bug", we might downgrade immediately.
    
    // If it is a fresh PURCHASE event (status == purchased), force valid end date if currently expired.
    if (purchase.status == PurchaseStatus.purchased) {
        if (isExpired) {
             debugPrint('⚠️ Fresh purchase calculated as expired (EndDate: $_subscriptionEndDate). Forcing validity.');
             // Force to Now + Duration to ensure user gets what they just bought.
             _subscriptionEndDate = DateTime.now().add(duration);
        }
    }
    
    // 檢查是否已過期 (Only downgrade if we are SURE it is expired and not a fresh fix above)
    if (isExpired) {
      debugPrint('⚠️ 訂閱已過期 (到期日: $_subscriptionEndDate)');
      await _downgradeTo(MembershipTier.free);
      return;
    }
    
    // 重置配額
    _aiQuotaUsedThisMonth = 0;
    _manualInputUsedToday = 0;
    
    await _save();
    
    debugPrint('✅ 已升級到 $tierName，到期日: $_subscriptionEndDate');
    notifyListeners();
  }
  
  /// 處理點數包購買
  Future<void> _handleCreditsPackage(String productId) async {
    int credits = 0;
    
    if (productId.contains('small')) {
      credits = 50;
    } else if (productId.contains('medium')) {
      credits = 150;
    } else if (productId.contains('large')) {
      credits = 500;
    }
    
    _purchasedCredits += credits;
    await _save();
    
    debugPrint('✅ 已添加 $credits 個點數，總計: $_purchasedCredits');
    notifyListeners();
  }
  
  /// 升級會員（用於測試）
  Future<void> upgradeTo(MembershipTier tier, {bool isYearly = false}) async {
    _tier = tier;
    
    // 設置訂閱結束日期
    final duration = isYearly ? Duration(days: 365) : Duration(days: 30);
    _subscriptionEndDate = DateTime.now().add(duration);
    
    // 重置配額
    _aiQuotaUsedThisMonth = 0;
    _manualInputUsedToday = 0;
    
    await _save();
    
    debugPrint('✅ 已升級到 ${tierName}');
    notifyListeners();
  }
  
  /// 降級會員
  Future<void> _downgradeTo(MembershipTier tier) async {
    _tier = tier;
    _subscriptionEndDate = null;
    _subscriptionProductId = null;
    await _save();
    
    debugPrint('⬇️ 已降級到 ${tierName}');
    notifyListeners();
  }

  /// 手動降級到免費版 (用於測試或贊助者代碼)
  Future<void> downgradeToFree() async {
    await _downgradeTo(MembershipTier.free);
  }
  
  /// 消耗 AI 配額
  Future<bool> consumeAiQuota() async {
    // 檢查是否需要重置每月配額
    if (_lastResetDate != null && _shouldResetMonthlyQuota(_lastResetDate!)) {
      await resetMonthlyQuota();
    } else if (_lastResetDate == null) {
      // 首次使用，設置重置日期
      _lastResetDate = DateTime.now();
      await _save();
    }
    
    if (!canUseAi) {
      debugPrint('❌ AI 配額不足');
      return false;
    }
    
    // 優先使用每月配額 (因為每月會重置，購買的點數永久有效)
    if (_aiQuotaUsedThisMonth < monthlyAiQuota) {
      _aiQuotaUsedThisMonth++;
      debugPrint('📊 使用每月配額，已用: $_aiQuotaUsedThisMonth/$monthlyAiQuota');
    } else if (_purchasedCredits > 0) {
      _purchasedCredits--;
      debugPrint('💎 使用購買點數，剩餘: $_purchasedCredits');
    }
    
    await _save();
    notifyListeners();
    return true;
  }
  
  /// 消耗手動輸入次數
  Future<bool> consumeManualInput() async {
    // 檢查是否需要重置每日配額
    if (_lastManualInputResetDate != null && 
        _shouldResetDailyQuota(_lastManualInputResetDate!)) {
      await resetDailyQuota();
    }
    
    if (!canManualInput) {
      debugPrint('❌ 手動輸入次數不足');
      return false;
    }
    
    _manualInputUsedToday++;
    debugPrint('✏️ 手動輸入，已用: $_manualInputUsedToday/$dailyManualInputLimit');
    
    await _save();
    notifyListeners();
    return true;
  }
  
  /// 重置每月配額
  Future<void> resetMonthlyQuota() async {
    _aiQuotaUsedThisMonth = 0;
    
    // Free Tier 每月重置時，點數不可超過上限 10
    // 因此如果有點數殘留 (purchasedCredits)，需要清除或重置
    if (isFree) {
        _purchasedCredits = 0;
    }

    _lastResetDate = DateTime.now();
    await _save();
    
    debugPrint('🔄 每月 AI 配額已重置 (上限: $monthlyAiQuota)');
    notifyListeners();
  }
  
  /// 重置每日配額
  Future<void> resetDailyQuota() async {
    _manualInputUsedToday = 0;
    _lastManualInputResetDate = DateTime.now();
    await _save();
    
    debugPrint('🔄 每日手動輸入配額已重置');
    notifyListeners();
  }
  
  /// 保存狀態
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setInt('membership_tier', _tier.index);
    await prefs.setInt('ai_quota_used_month', _aiQuotaUsedThisMonth);
    await prefs.setInt('purchased_credits', _purchasedCredits);
    await prefs.setInt('manual_input_used', _manualInputUsedToday);
    
    if (_subscriptionProductId != null) {
      await prefs.setString('subscription_product_id', _subscriptionProductId!);
    }
    
    if (_subscriptionEndDate != null) {
      await prefs.setString(
        'subscription_end_date',
        _subscriptionEndDate!.toIso8601String(),
      );
    }
    
    if (_lastResetDate != null) {
      await prefs.setString(
        'last_reset_date',
        _lastResetDate!.toIso8601String(),
      );
    }
    
    if (_lastManualInputResetDate != null) {
      await prefs.setString(
        'last_manual_reset_date',
        _lastManualInputResetDate!.toIso8601String(),
      );
    }
  }
  
  /// 是否需要重置每月配額 (每個月1號重置)
  bool _shouldResetMonthlyQuota(DateTime lastReset) {
    final now = DateTime.now();
    
    // 如果是不同年份或不同月份，肯定重置
    return now.year > lastReset.year || now.month > lastReset.month;
  }

  /// 是否需要重置每日配額
  bool _shouldResetDailyQuota(DateTime lastReset) {
    final now = DateTime.now();
    return now.year > lastReset.year || 
           now.month > lastReset.month || 
           now.day > lastReset.day;
  }

  /// 是否可以進行手動輸入
  bool get canManualInput => remainingManualInputToday > 0;

  /// 今日剩餘手動輸入次數
  int get remainingManualInputToday => 
      (dailyManualInputLimit - _manualInputUsedToday).clamp(0, 999999);

  /// 獲取訂閱剩餘天數
  int? get subscriptionDaysRemaining {
    if (_subscriptionEndDate == null) return null;
    final diff = _subscriptionEndDate!.difference(DateTime.now());
    // 如果過期，返回 0 或負數
    return diff.inDays;
  }
  
  /// 是否接近到期（少於 7 天）
  bool get isNearExpiry {
    final days = subscriptionDaysRemaining;
    return days != null && days <= 7 && days > 0;
  }
  
  /// 是否已過期
  /// 是否已過期
  bool get isExpired {
    if (_subscriptionEndDate == null) return true;
    return DateTime.now().isAfter(_subscriptionEndDate!);
  }

  /// 檢查訂閱狀態 (與 Apple 同步)
  Future<void> checkSubscriptionStatus() async {
    debugPrint('🔄 正在檢查訂閱狀態...');
    // 恢復購買會觸發 purchaseStream，從而調用 handlePurchase
    await _paymentService.restorePurchases();
  }

  // --- AdMob Related Logic ---

  bool _removeAds = false; // Toggle for removing ads (e.g., debug or specific purchase)
  
  /// Override to force remove ads (for testing or special status)
  void debugSetRemoveAds(bool remove) {
    _removeAds = remove;
    notifyListeners();
    debugPrint('🔧 調試：已${remove ? '禁用' : '啟用'}廣告');
  }

  // showAds is defined above in getters section

  /// Add reward points (e.g. from watching Rewarded Video)
  Future<void> addRewardPoints(int points) async {
    // 檢查 Free Tier 上限 10
    if (isFree) {
      final currentRemaining = remainingAiQuota;
      final limit = monthlyAiQuota; // 10
      
      if (currentRemaining >= limit) {
        debugPrint('⚠️ 已達 Free Tier 配額上限 ($limit)，不增加點數');
        return;
      }
      
      // 計算實際可增加的點數 (不超過 limit)
      final space = limit - currentRemaining;
      final actualPoints = points > space ? space : points;
      
      if (actualPoints > 0) {
        _purchasedCredits += actualPoints;
        await _save();
        debugPrint('🎁 獲得獎勵點數: $actualPoints (原: $points), 總計: $_purchasedCredits');
        notifyListeners();
      }
    } else {
      // Premium 無限制，直接加 (雖然 Premium 無限配額，加了也沒差)
      _purchasedCredits += points;
      await _save();
      debugPrint('🎁 獲得獎勵點數: $points, 總計: $_purchasedCredits');
      notifyListeners();
    }
  }

  /// 🔧 調試用：設置 AI 配額已使用量
  Future<void> debugSetAiQuota(int value) async {
    _aiQuotaUsedThisMonth = value;
    await _save();
    notifyListeners();
    debugPrint('🔧 調試：已將 AI 配額設置為 $value');
  }
}
