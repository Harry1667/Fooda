// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MembershipInfo _$MembershipInfoFromJson(Map<String, dynamic> json) =>
    MembershipInfo(
      level: json['level'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      nameCn: json['nameCn'] as String,
      nameJa: json['nameJa'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toInt(),
      features: MembershipFeatures.fromJson(
        json['features'] as Map<String, dynamic>,
      ),
      aiQuota: AiQuota.fromJson(json['aiQuota'] as Map<String, dynamic>),
      restrictions: MembershipRestrictions.fromJson(
        json['restrictions'] as Map<String, dynamic>,
      ),
      expireDate: json['expireDate'] == null
          ? null
          : DateTime.parse(json['expireDate'] as String),
      extraCredits: (json['extraCredits'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$MembershipInfoToJson(MembershipInfo instance) =>
    <String, dynamic>{
      'level': instance.level,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'nameCn': instance.nameCn,
      'nameJa': instance.nameJa,
      'monthlyPrice': instance.monthlyPrice,
      'features': instance.features,
      'aiQuota': instance.aiQuota,
      'restrictions': instance.restrictions,
      'expireDate': instance.expireDate?.toIso8601String(),
      'extraCredits': instance.extraCredits,
    };

MembershipFeatures _$MembershipFeaturesFromJson(Map<String, dynamic> json) =>
    MembershipFeatures(
      manualInput: json['manualInput'] as bool,
      photoUpload: json['photoUpload'] as bool,
      basicNutrition: json['basicNutrition'] as bool,
      historyTracking: json['historyTracking'] as bool,
      aiRecognition: json['aiRecognition'] as bool,
      advancedAnalysis: json['advancedAnalysis'] as bool,
      healthSuggestions: json['healthSuggestions'] as bool,
      adsFree: json['adsFree'] as bool,
      smartRecognition: json['smartRecognition'] as bool,
    );

Map<String, dynamic> _$MembershipFeaturesToJson(MembershipFeatures instance) =>
    <String, dynamic>{
      'manualInput': instance.manualInput,
      'photoUpload': instance.photoUpload,
      'basicNutrition': instance.basicNutrition,
      'historyTracking': instance.historyTracking,
      'aiRecognition': instance.aiRecognition,
      'advancedAnalysis': instance.advancedAnalysis,
      'healthSuggestions': instance.healthSuggestions,
      'adsFree': instance.adsFree,
      'smartRecognition': instance.smartRecognition,
    };

AiQuota _$AiQuotaFromJson(Map<String, dynamic> json) => AiQuota(
  monthlyLimit: (json['monthlyLimit'] as num).toInt(),
  currentUsed: (json['currentUsed'] as num).toInt(),
  remaining: (json['remaining'] as num).toInt(),
  resetDate: json['resetDate'] == null
      ? null
      : DateTime.parse(json['resetDate'] as String),
);

Map<String, dynamic> _$AiQuotaToJson(AiQuota instance) => <String, dynamic>{
  'monthlyLimit': instance.monthlyLimit,
  'currentUsed': instance.currentUsed,
  'remaining': instance.remaining,
  'resetDate': instance.resetDate?.toIso8601String(),
};

MembershipRestrictions _$MembershipRestrictionsFromJson(
  Map<String, dynamic> json,
) => MembershipRestrictions(
  analysisBlocked: json['analysisBlocked'] as bool,
  showAds: json['showAds'] as bool,
  limitedFeatures: json['limitedFeatures'] as bool,
);

Map<String, dynamic> _$MembershipRestrictionsToJson(
  MembershipRestrictions instance,
) => <String, dynamic>{
  'analysisBlocked': instance.analysisBlocked,
  'showAds': instance.showAds,
  'limitedFeatures': instance.limitedFeatures,
};

UpgradeOption _$UpgradeOptionFromJson(Map<String, dynamic> json) =>
    UpgradeOption(
      level: json['level'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      monthlyPrice: (json['monthlyPrice'] as num).toInt(),
      yearlyPrice: (json['yearlyPrice'] as num).toInt(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isPopular: json['isPopular'] as bool? ?? false,
      badge: json['badge'] as String?,
    );

Map<String, dynamic> _$UpgradeOptionToJson(UpgradeOption instance) =>
    <String, dynamic>{
      'level': instance.level,
      'name': instance.name,
      'description': instance.description,
      'monthlyPrice': instance.monthlyPrice,
      'yearlyPrice': instance.yearlyPrice,
      'features': instance.features,
      'isPopular': instance.isPopular,
      'badge': instance.badge,
    };

CreditPackage _$CreditPackageFromJson(Map<String, dynamic> json) =>
    CreditPackage(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      nameCn: json['nameCn'] as String,
      nameJa: json['nameJa'] as String,
      credits: (json['credits'] as num).toInt(),
      price: (json['price'] as num).toInt(),
      description: json['description'] as String,
      isPopular: json['isPopular'] as bool? ?? false,
    );

Map<String, dynamic> _$CreditPackageToJson(CreditPackage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'nameEn': instance.nameEn,
      'nameCn': instance.nameCn,
      'nameJa': instance.nameJa,
      'credits': instance.credits,
      'price': instance.price,
      'description': instance.description,
      'isPopular': instance.isPopular,
    };

PurchaseResult _$PurchaseResultFromJson(Map<String, dynamic> json) =>
    PurchaseResult(
      success: json['success'] as bool,
      transactionId: json['transactionId'] as String?,
      error: json['error'] as String?,
      updatedMembership: json['updatedMembership'] == null
          ? null
          : MembershipInfo.fromJson(
              json['updatedMembership'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PurchaseResultToJson(PurchaseResult instance) =>
    <String, dynamic>{
      'success': instance.success,
      'transactionId': instance.transactionId,
      'error': instance.error,
      'updatedMembership': instance.updatedMembership,
    };
