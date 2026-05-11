import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

/// 支付服務
/// 處理應用內購買功能
class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;
  bool _isAvailable = false;
  
  // 產品 ID 定義
  static const String premiumMonthly = 'com.gomiigo.FoodaApp.Premium.monthly';
  // Legacy IDs (keeping for reference or backward compatibility if needed)
  // static const String premiumMonthlyLegacy = 'com.fooda.premium.monthly';
  // static const String premiumYearly = 'com.fooda.premium.yearly';
  // static const String premiumPlusMonthly = 'com.fooda.premium_plus.monthly';
  // static const String premiumPlusYearly = 'com.fooda.premium_plus.yearly';
  
  static const String creditsSmall = 'com.fooda.credits.small';
  static const String creditsMedium = 'com.fooda.credits.medium';
  static const String creditsLarge = 'com.fooda.credits.large';
  
  // 所有訂閱產品
  static const Set<String> subscriptionIds = {
    premiumMonthly,
  };
  
  // 所有消耗性產品
  static const Set<String> consumableIds = {
    creditsSmall,
    creditsMedium,
    creditsLarge,
  };
  
  // 所有產品
  static const Set<String> allProductIds = {
    ...subscriptionIds,
    ...consumableIds,
  };

  // ... (keeping existing code)

  // Callbacks
  // Callbacks
  final List<Function(PurchaseDetails)> _successListeners = [];
  final List<Function(String)> _errorListeners = [];

  void addSuccessListener(Function(PurchaseDetails) callback) {
    _successListeners.add(callback);
  }

  void removeSuccessListener(Function(PurchaseDetails) callback) {
    _successListeners.remove(callback);
  }

  void addErrorListener(Function(String) callback) {
    _errorListeners.add(callback);
  }

  void removeErrorListener(Function(String) callback) {
    _errorListeners.remove(callback);
  }
  
  // Deprecated setters
  set onPurchaseSuccess(Function(PurchaseDetails) callback) => addSuccessListener(callback);
  set onPurchaseError(Function(String) callback) => addErrorListener(callback);

  /// 初始化支付服務
  /// 初始化支付服務
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    // Check availability first
    bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      _isAvailable = false;
      return false;
    }

    _subscription = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onDone: () {
        _subscription?.cancel();
      },
      onError: (error) {
        for (var listener in _errorListeners) {
          listener(error.toString());
        }
      },
    );

    _isInitialized = true;
    _isAvailable = true;
    return true;
  }

  /// 獲取服務是否可用
  bool get isAvailable => _isAvailable;

  /// 獲取產品列表
  Future<List<ProductDetails>> getProducts() async {
    final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(allProductIds);
    
    if (response.error != null) {
      for (var listener in _errorListeners) {
        listener(response.error!.message);
      }
      return [];
    }

    return response.productDetails;
  }

  /// 購買產品
  Future<bool> purchaseProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    
    if (consumableIds.contains(product.id)) {
      return _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    } else {
      return _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  /// 恢復購買
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }

  /// 處理購買更新
  void _onPurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // 等待中
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          for (var listener in _errorListeners) {
            listener(purchaseDetails.error!.message);
          }
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                   purchaseDetails.status == PurchaseStatus.restored) {
          
          for (var listener in _successListeners) {
            listener(purchaseDetails);
          }
        }
        
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  /// 獲取產品信息映射
  Map<String, dynamic> getProductInfo(String productId) {
    switch (productId) {
      case premiumMonthly:
        return {
          'name': 'Fooda Premium Monthly',
          'duration': '1 個月',
          'aiQuota': 999999, // 無限制
          'features': ['無限次 AI 識別', 'iCloud 雲端備份', '完整營養分析', '移除所有廣告'],
        };
      case creditsSmall:
        return {
          'name': '小點數包',
          'credits': 50,
          'description': '50 次 AI 識別',
        };
      case creditsMedium:
        return {
          'name': '中點數包',
          'credits': 150,
          'description': '150 次 AI 識別',
          'discount': '省 NT\$ 10',
        };
      case creditsLarge:
        return {
          'name': '大點數包',
          'credits': 500,
          'description': '500 次 AI 識別',
          'discount': '省 NT\$ 50',
        };
      default:
        return {'name': '未知產品'};
    }
  }
  
  /// 銷毀服務
  void dispose() {
    _subscription?.cancel();
    _successListeners.clear();
    _errorListeners.clear();
    _isInitialized = false;
    debugPrint('🔚 支付服務已銷毀');
  }
}
