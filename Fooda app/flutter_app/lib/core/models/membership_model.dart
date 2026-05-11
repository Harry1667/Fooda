import 'package:json_annotation/json_annotation.dart';

part 'membership_model.g.dart';

/// 會員資訊模型
/// 對應 PHP 版本的會員系統
@JsonSerializable()
class MembershipInfo {
  final String level;
  final String name;
  final String nameEn;
  final String nameCn;
  final String nameJa;
  final int monthlyPrice;
  final MembershipFeatures features;
  final AiQuota aiQuota;
  final MembershipRestrictions restrictions;
  final DateTime? expireDate;
  final int extraCredits;

  const MembershipInfo({
    required this.level,
    required this.name,
    required this.nameEn,
    required this.nameCn,
    required this.nameJa,
    required this.monthlyPrice,
    required this.features,
    required this.aiQuota,
    required this.restrictions,
    this.expireDate,
    this.extraCredits = 0,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) =>
      _$MembershipInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipInfoToJson(this);

  /// 是否為免費會員
  bool get isFree => level == 'free';

  /// 是否為付費會員
  bool get isPremium => level == 'premium' || level == 'premium_plus';

  /// 獲取本地化名稱
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return nameCn;
      case 'en':
        return nameEn;
      case 'ja':
        return nameJa;
      default:
        return name;
    }
  }

  MembershipInfo copyWith({
    String? level,
    String? name,
    String? nameEn,
    String? nameCn,
    String? nameJa,
    int? monthlyPrice,
    MembershipFeatures? features,
    AiQuota? aiQuota,
    MembershipRestrictions? restrictions,
    DateTime? expireDate,
    int? extraCredits,
  }) {
    return MembershipInfo(
      level: level ?? this.level,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      nameCn: nameCn ?? this.nameCn,
      nameJa: nameJa ?? this.nameJa,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      features: features ?? this.features,
      aiQuota: aiQuota ?? this.aiQuota,
      restrictions: restrictions ?? this.restrictions,
      expireDate: expireDate ?? this.expireDate,
      extraCredits: extraCredits ?? this.extraCredits,
    );
  }
}

/// 會員功能權限模型
@JsonSerializable()
class MembershipFeatures {
  final bool manualInput;
  final bool photoUpload;
  final bool basicNutrition;
  final bool historyTracking;
  final bool aiRecognition;
  final bool advancedAnalysis;
  final bool healthSuggestions;
  final bool adsFree;
  final bool smartRecognition;

  const MembershipFeatures({
    required this.manualInput,
    required this.photoUpload,
    required this.basicNutrition,
    required this.historyTracking,
    required this.aiRecognition,
    required this.advancedAnalysis,
    required this.healthSuggestions,
    required this.adsFree,
    required this.smartRecognition,
  });

  factory MembershipFeatures.fromJson(Map<String, dynamic> json) =>
      _$MembershipFeaturesFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipFeaturesToJson(this);
}

/// AI 額度模型
@JsonSerializable()
class AiQuota {
  final int monthlyLimit;
  final int currentUsed;
  final int remaining;
  final DateTime? resetDate;

  const AiQuota({
    required this.monthlyLimit,
    required this.currentUsed,
    required this.remaining,
    this.resetDate,
  });

  factory AiQuota.fromJson(Map<String, dynamic> json) =>
      _$AiQuotaFromJson(json);

  Map<String, dynamic> toJson() => _$AiQuotaToJson(this);

  /// 是否有剩餘額度
  bool get hasQuota => remaining > 0;

  /// 使用百分比
  double get usagePercentage {
    if (monthlyLimit == 0) return 0;
    return (currentUsed / monthlyLimit) * 100;
  }

  AiQuota copyWith({
    int? monthlyLimit,
    int? currentUsed,
    int? remaining,
    DateTime? resetDate,
  }) {
    return AiQuota(
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      currentUsed: currentUsed ?? this.currentUsed,
      remaining: remaining ?? this.remaining,
      resetDate: resetDate ?? this.resetDate,
    );
  }
}

/// 會員限制模型
@JsonSerializable()
class MembershipRestrictions {
  final bool analysisBlocked;
  final bool showAds;
  final bool limitedFeatures;

  const MembershipRestrictions({
    required this.analysisBlocked,
    required this.showAds,
    required this.limitedFeatures,
  });

  factory MembershipRestrictions.fromJson(Map<String, dynamic> json) =>
      _$MembershipRestrictionsFromJson(json);

  Map<String, dynamic> toJson() => _$MembershipRestrictionsToJson(this);
}

/// 升級方案模型
@JsonSerializable()
class UpgradeOption {
  final String level;
  final String name;
  final String description;
  final int monthlyPrice;
  final int yearlyPrice;
  final List<String> features;
  final bool isPopular;
  final String? badge;

  const UpgradeOption({
    required this.level,
    required this.name,
    required this.description,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.features,
    this.isPopular = false,
    this.badge,
  });

  factory UpgradeOption.fromJson(Map<String, dynamic> json) =>
      _$UpgradeOptionFromJson(json);

  Map<String, dynamic> toJson() => _$UpgradeOptionToJson(this);
}

/// 點數包模型
@JsonSerializable()
class CreditPackage {
  final String id;
  final String name;
  final String nameEn;
  final String nameCn;
  final String nameJa;
  final int credits;
  final int price;
  final String description;
  final bool isPopular;

  const CreditPackage({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.nameCn,
    required this.nameJa,
    required this.credits,
    required this.price,
    required this.description,
    this.isPopular = false,
  });

  factory CreditPackage.fromJson(Map<String, dynamic> json) =>
      _$CreditPackageFromJson(json);

  Map<String, dynamic> toJson() => _$CreditPackageToJson(this);

  /// 獲取本地化名稱
  String getLocalizedName(String languageCode) {
    switch (languageCode) {
      case 'zh_CN':
        return nameCn;
      case 'en':
        return nameEn;
      case 'ja':
        return nameJa;
      default:
        return name;
    }
  }

  /// 每點數的價格
  double get pricePerCredit => price / credits;
}

/// 會員等級枚舉
enum MembershipLevel {
  free('free', '免費會員'),
  premium('premium', '訂閱會員'),
  premiumPlus('premium_plus', '高級訂閱');

  const MembershipLevel(this.value, this.displayName);

  final String value;
  final String displayName;

  static MembershipLevel fromValue(String value) {
    return MembershipLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => MembershipLevel.free,
    );
  }
}

/// 購買結果模型
@JsonSerializable()
class PurchaseResult {
  final bool success;
  final String? transactionId;
  final String? error;
  final MembershipInfo? updatedMembership;

  const PurchaseResult({
    required this.success,
    this.transactionId,
    this.error,
    this.updatedMembership,
  });

  factory PurchaseResult.fromJson(Map<String, dynamic> json) =>
      _$PurchaseResultFromJson(json);

  Map<String, dynamic> toJson() => _$PurchaseResultToJson(this);
}