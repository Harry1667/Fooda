import 'package:flutter/material.dart';
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../config/ad_config.dart';

/// Centralized service for managing Google AdMob ads.
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // Interstitial Ad State
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _interstitialCounter = 0;
  static const int _interstitialFrequency = 1; // Show ad every 1 valid actions

  // Rewarded Ad State
  RewardedAd? _rewardedAd;
  bool _isRewardedLoading = false;

  /// Initialize and pre-load ads if necessary
  Future<void> initialize() async {
    // Preload ads could be done here if strategy requires
    // For now, we load on demand or just before needed
  }

  // --- Banner Ads ---

  // --- Banner Ads (Removed) ---
  // BannerAd createBannerAd({required Function() onAdLoaded}) { ... }

  // --- Interstitial Ads ---

  /// Increment counter and check if we should show interstitial
  bool get shouldShowInterstitial {
    _interstitialCounter++;
    if (_interstitialCounter >= _interstitialFrequency) {
      _interstitialCounter = 0;
      return true;
    }
    return false;
  }

  /// Load an Interstitial Ad
  /// Returns true if loaded successfully, false otherwise
  Future<bool> loadInterstitial() async {
    if (_interstitialAd != null) return true;
    if (_isInterstitialLoading) {
      // If already loading, we could return a future that waits for the current load.
      // For simplicity/safety to avoid multiple completers, just return false or wait.
      // But better: wait loop or just fail fast. Failing fast (false) is safer for now.
      return false; 
    }

    _isInterstitialLoading = true;
    final completer = Completer<bool>();

    await InterstitialAd.load(
      adUnitId: AdConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('InterstitialAd loaded');
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          if (!completer.isCompleted) completer.complete(true);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('InterstitialAd failed to load: $error');
          _interstitialAd = null;
          _isInterstitialLoading = false;
          if (!completer.isCompleted) completer.complete(false);
        },
      ),
    );
    
    return completer.future;
  }

  /// Show Interstitial Ad if available
  /// [onAdClosed] is called when ad is dismissed or fails to show
  void showInterstitial({required VoidCallback onAdClosed}) {
    if (_interstitialAd == null) {
      debugPrint('Warning: Attempted to show Interstitial before it was loaded.');
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('InterstitialAd dismissed');
        ad.dispose();
        _interstitialAd = null;
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('InterstitialAd failed to show: $error');
        ad.dispose();
        _interstitialAd = null;
        onAdClosed();
      },
      onAdShowedFullScreenContent: (InterstitialAd ad) => 
        debugPrint('InterstitialAd showed fullscreen content.'),
    );

    _interstitialAd!.show();
    // Preload next ad
    // loadInterstitial(); // Optional: depend on flow
  }

  // --- Rewarded Ads ---

  Future<void> loadRewarded() async {
    if (_rewardedAd != null || _isRewardedLoading) return;

    _isRewardedLoading = true;
    await RewardedAd.load(
      adUnitId: AdConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          debugPrint('RewardedAd loaded');
          _rewardedAd = ad;
          _isRewardedLoading = false;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          _isRewardedLoading = false;
        },
      ),
    );
  }

  /// Show Rewarded Ad
  /// [onUserEarnedReward] is called when user completes the ad
  /// [onAdClosed] is called when ad closes (regardless of reward)
  void showRewarded({
    required Function(RewardItem) onUserEarnedReward,
    required VoidCallback onAdClosed,
  }) {
    if (_rewardedAd == null) {
      debugPrint('Warning: Attempted to show RewardedAd before it was loaded.');
      onAdClosed(); // Or treat as error
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        debugPrint('RewardedAd dismissed');
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _rewardedAd = null;
        onAdClosed();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward);
      },
    );
    // Preload next
    // loadRewarded();
  }
}
