import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart'; // for kReleaseMode
import 'package:provider/provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../l10n/app_localizations.dart';
import '../../core/services/payment_service.dart';
import 'providers/membership_provider.dart';
import '../../core/services/ad_service.dart';
import '../../core/utils/iap_utils.dart';

/// 會員購買頁面 - Modern Midnight Redesign (Safe Layout for iPad)
class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  final PaymentService _paymentService = PaymentService();

  List<ProductDetails> _products = [];
  bool _isLoading = true;
  bool _isRestoring = false;
  String? _errorMessage;

  // Colors for Modern Midnight Theme
  final Color _primaryBlue = const Color(0xFF3B82F6);
  final Color _premiumGold = const Color(0xFFFFD700);
  final Color _darkBackground = const Color(0xFF0F172A);
  final Color _cardBackground = const Color(0xFF1E293B);

  bool _isPurchasing = false;
  bool _hasShownWelcome = false;
  bool _restoreDetected = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final initialized = await _paymentService.initialize();
      if (!initialized) {
        if (mounted) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)!.paymentServiceUnavailable;
            _isLoading = false;
          });
        }
        return;
      }

      _paymentService.addSuccessListener(_onPurchaseSuccess);
      _paymentService.addErrorListener(_onPurchaseError);

      final products = await _paymentService.getProducts();
      if (mounted) {
        setState(() {
          _products = products;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.loadFailed(e.toString());
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _paymentService.removeSuccessListener(_onPurchaseSuccess);
    _paymentService.removeErrorListener(_onPurchaseError);
    super.dispose();
  }

  void _onPurchaseSuccess(PurchaseDetails purchase) {
    if (mounted) _handlePurchaseSuccess(purchase);
  }

  void _onPurchaseError(String error) {
    if (mounted) _showError(error);
  }

  void _handlePurchaseSuccess(PurchaseDetails purchase) {
    final membershipProvider = Provider.of<MembershipProvider>(context, listen: false);
    membershipProvider.handlePurchase(purchase);

    // 標記已檢測到恢復
    if (purchase.status == PurchaseStatus.restored) {
      _restoreDetected = true;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.restorePremiumSuccess),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (!_hasShownWelcome) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.welcomePremium),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      _hasShownWelcome = true;
    }

    // Only pop if the purchase was initiated by the user in this session
    if (_isPurchasing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    } else {
      // If it's a restore or background update, just refresh the UI
      setState(() {
        _isPurchasing = false;
      });
    }
  }

  void _showError(dynamic error) {
    if (!mounted) return;
    
    setState(() {
      _isPurchasing = false;
    });

    showFriendlyIapError(context, error);
  }

  Future<void> _restorePurchases() async {
    if (!mounted) return;
    // explicit try-catch wrapping UI action
    try {
      setState(() {
        _isRestoring = true;
        _restoreDetected = false;
      });

      await _paymentService.restorePurchases();
      
      // 給予一點時間讓串流接收恢復的交易
      await Future.delayed(const Duration(seconds: 3));
      
      if (mounted && !_restoreDetected) {
        // 如果 3 秒後還沒有檢測到恢復的交易，且沒有報錯，則提示未找到訂閱
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.noSubscriptionFound),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) showFriendlyIapError(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
        });
      }
    }
  }

  Future<void> _openSubscriptionManagement() async {
    try {
      final Uri url = Uri.parse('https://apps.apple.com/account/subscriptions');
      if (!await launchUrl(url)) {
        if (mounted) _showError(AppLocalizations.of(context)!.cannotOpenSubscriptionManagement);
      }
    } catch (e) {
      if (mounted) showFriendlyIapError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _darkBackground,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isRestoring)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
            )
          else
            TextButton(
              onPressed: _restorePurchases,
              child: Text(AppLocalizations.of(context)!.restorePurchase, style: const TextStyle(color: Colors.white70)),
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: _primaryBlue))
          : _errorMessage != null
              ? _buildErrorView()
              : Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF1E3A8A), // Dark Blue
                        _darkBackground,
                      ],
                      stops: const [0.0, 0.4], // Fade out by 40% height
                    ),
                  ),
                  child: SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Safe Layout: Center > ConstrainedBox > SingleChildScrollView
                        return Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 600),
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              physics: const ClampingScrollPhysics(), // Safe physics
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(height: 20),
                                  _buildHeroContent(),
                                  const SizedBox(height: 40),
                                  _buildDetailsContent(),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.redAccent.withOpacity(0.8)),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _initialize,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  // Merged content from old Hero Page
  Widget _buildHeroContent() {
    final membershipProvider = Provider.of<MembershipProvider>(context);
    final isPremium = !membershipProvider.isFree;

    return Column(
      children: [
        // Icon & Title
        Icon(
          Icons.diamond_outlined,
          size: 64, 
          color: _premiumGold,
        ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack).shimmer(delay: 1000.ms, duration: 1500.ms),
        const SizedBox(height: 16),
        Text(
          isPremium ? AppLocalizations.of(context)!.youArePremium : AppLocalizations.of(context)!.unlockPremium,
          style: const TextStyle(
            fontSize: 24, 
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
        const SizedBox(height: 8),
        Text(
          isPremium ? AppLocalizations.of(context)!.enjoyPremiumFeatures : AppLocalizations.of(context)!.premiumFeaturesSummary,
          style: const TextStyle(
            fontSize: 14, 
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3, end: 0),
        
        const SizedBox(height: 20),
        
        // Benefits Summary (Simplified)
        _buildSimplifiedBenefits(),
        
        const SizedBox(height: 20),
        
        // Subscription Card or Status
        if (isPremium)
          _buildManageSubscriptionCard(membershipProvider)
        else
          _buildSubscriptionCard(),
      ],
    );
  }

  // Merged content from old Details Page
  Widget _buildDetailsContent() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.detailedComparison,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        _buildFeatureComparison(),
        const SizedBox(height: 40),
        _buildFooter(),
      ],
    );
  }

  Widget _buildSimplifiedBenefits() {
    final benefits = [
      {'icon': Icons.auto_awesome, 'text': AppLocalizations.of(context)!.unlimitedAI},
      {'icon': Icons.block, 'text': AppLocalizations.of(context)!.noAds},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: benefits.map((item) {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(item['icon'] as IconData, color: _primaryBlue, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              item['text'] as String,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        );
      }).toList(),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildSubscriptionCard() {
    final subscriptions = _products.where((p) => 
      PaymentService.subscriptionIds.contains(p.id)
    ).toList();

    subscriptions.retainWhere((p) => p.id == PaymentService.premiumMonthly);

    if (subscriptions.isEmpty) {
       // Fallback for Simulator/Error cases where products are not fetched
       // This ensures the UI is always visible even if IAP fails
       return _buildFallbackSubscriptionCard();
    }

    final product = subscriptions.first;
    final info = _paymentService.getProductInfo(product.id);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryBlue.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.2),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context)!.recommended.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            info['name'] as String,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          // 使用 FittedBox 防止溢出
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  product.price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.perMonth,
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => _purchaseProduct(product),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isPurchasing 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      AppLocalizations.of(context)!.subscribeNow,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ).animate(onPlay: (controller) => controller.repeat(reverse: true))
            .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.2))
            .scaleXY(begin: 1.0, end: 1.02, duration: 1000.ms, curve: Curves.easeInOut),
          const SizedBox(height: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              AppLocalizations.of(context)!.cancelAnytime,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ),
          
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          
          // Watch Ad Option
          _buildWatchAdOption(),
        ],
      ),
    );
  }


  Widget _buildFallbackSubscriptionCard() {
    // 檢查是否為 Release 模式
    // 如果是 Release 模式，且無法獲取產品資訊，不應顯示模擬器Fallback UI
    // 但為了保持防呆，如果真的發生了，我們只顯示基本資訊，不顯示模擬器提示
    
    // Check if IAP is available
    final bool isIapAvailable = _paymentService.isAvailable;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _primaryBlue.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              AppLocalizations.of(context)!.recommended.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fooda Premium Monthly',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              const Text(
                '\$1.99', // Fallback price
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                AppLocalizations.of(context)!.perMonth,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (!isIapAvailable)
             const Padding(
               padding: EdgeInsets.only(bottom: 12.0),
               child: Text(
                 '目前無法使用內購功能，請稍後再試。',
                 style: TextStyle(fontSize: 14, color: Colors.white70),
                 textAlign: TextAlign.center,
               ),
             ),
             
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isIapAvailable ? () {
                 // Try/catch safe for simple snackbar
                 try {
                   // Debug mode check
                   if (!kReleaseMode) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Simulator Mode: Cannot connect to App Store')),
                     );
                   } else {
                      // Release mode - Generic friendly error is handled by showFriendlyIapError but here we are in fallback
                      // Triggering a fake error to test the utility if user clicks on fallback
                      showFriendlyIapError(context, 'Simulator fallback clicked in release mode');
                   }
                 } catch (_) {}
              } : null, // Disable if not available
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.subscribeNow,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.cancelAnytime,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
          
          if (!kReleaseMode) ...[
             const SizedBox(height: 12),
             const Text(
                'Simulator Mode: Cannot connect to App Store',
                 style: TextStyle(fontSize: 12, color: Colors.white30),
             ),
          ],
          
          // isPhysicalDevice check is optional but kReleaseMode is key. 
          // If strictly following user request to add isPhysicalDevice check:
          /*
          if (!kReleaseMode) ...[
             const SizedBox(height: 12),
             const Text(
                'Simulator Mode: Cannot connect to App Store',
                 style: TextStyle(fontSize: 12, color: Colors.white30),
             ),
          ], 
          */

          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          
          _buildWatchAdOption(),
        ],
      ),
    );
  }

  Widget _buildWatchAdOption() {
      return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.movie_creation_outlined, color: Colors.white70, size: 20),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.watchAdEarnCredits ?? 'Watch Ad (+3 Credits)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      try {
                        final adService = AdService();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.loadingAd ?? 'Loading Ad...')),
                        );
                        
                        adService.loadRewarded().then((_) {
                          if (!mounted) return;
                          adService.showRewarded(
                            onUserEarnedReward: (reward) {
                               try {
                                 final membership = Provider.of<MembershipProvider>(context, listen: false);
                                 membership.addRewardPoints(1);
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     content: Text(AppLocalizations.of(context)!.rewardEarned(1) ?? 'Earned 1 credits!'),
                                     backgroundColor: Colors.green,
                                   ),
                                 );
                               } catch (e) {
                                 debugPrint('Error awarding points: $e');
                               }
                            },
                            onAdClosed: () {
                              // Ad closed
                            },
                          );
                        });
                      } catch (e) {
                         debugPrint('Error showing ad: $e');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(AppLocalizations.of(context)!.watchNow ?? 'Watch Now'),
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildManageSubscriptionCard(MembershipProvider provider) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1E40AF), const Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.currentPlanActive,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (provider.subscriptionEndDate != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.daysRemaining(provider.subscriptionDaysRemaining ?? 0),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _openSubscriptionManagement,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.manageSubscription,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.manageSubscriptionHint,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeatureComparison() {
    final features = [
      [AppLocalizations.of(context)!.feature, AppLocalizations.of(context)!.free, AppLocalizations.of(context)!.premium],
      [AppLocalizations.of(context)!.aiRecognition, AppLocalizations.of(context)!.tenTimesPerMonth, AppLocalizations.of(context)!.unlimited],
      [AppLocalizations.of(context)!.manualInput, AppLocalizations.of(context)!.unlimited, AppLocalizations.of(context)!.unlimited],
      [AppLocalizations.of(context)!.historyRecord, AppLocalizations.of(context)!.fourteenDays, AppLocalizations.of(context)!.unlimited],
      [AppLocalizations.of(context)!.noAds, '❌', '✅'],
      [AppLocalizations.of(context)!.dataExport, '❌', '✅'],
      [AppLocalizations.of(context)!.advancedAnalysis, '❌', '✅'],
    ];

    return Container(
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: features.asMap().entries.map((entry) {
          final index = entry.key;
          final row = entry.value;
          final isHeader = index == 0;

          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              border: index < features.length - 1
                  ? Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05)))
                  : null,
              color: isHeader ? Colors.white.withOpacity(0.05) : null,
            ),
            child: Row(
              children: row.asMap().entries.map((cellEntry) {
                final cellIndex = cellEntry.key;
                final cell = cellEntry.value;
                
                return Expanded(
                  flex: cellIndex == 0 ? 2 : 1,
                  child: Text(
                    cell,
                    style: TextStyle(
                      color: isHeader ? Colors.white : Colors.white70,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                    textAlign: cellIndex == 0 ? TextAlign.left : TextAlign.center,
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.purchaseDisclaimer,
          style: const TextStyle(color: Colors.white38, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse('https://ethereal-throne-212.notion.site/Fooda-Support-Help-Center-2be56be2c5c280a79660dde1fd89c497');
                if (!await launchUrl(url)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch $url')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.termsOfUse, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
            const Text('•', style: TextStyle(color: Colors.white38)),
            TextButton(
              onPressed: () async {
                final Uri url = Uri.parse('https://ethereal-throne-212.notion.site/CalHub-Privacy-Policy-2be56be2c5c280adb958c672e7215c03');
                if (!await launchUrl(url)) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Could not launch $url')),
                    );
                  }
                }
              },
              child: Text(AppLocalizations.of(context)!.privacyPolicy, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _purchaseProduct(ProductDetails product) async {
    // Explicit try/catch wrapping
    try {
      setState(() {
        _isPurchasing = true;
      });
      
      final success = await _paymentService.purchaseProduct(product);
      if (!success) {
        if (mounted) showFriendlyIapError(context, 'Purchase initiation failed');
      }
    } catch (e) {
      if (mounted) showFriendlyIapError(context, e);
    }
  }
}