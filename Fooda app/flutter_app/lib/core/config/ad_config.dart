import 'dart:io';

class AdConfig {
  // Production App ID: ca-app-pub-5936164848570883~3088010955
  
  // -- Production Ad Unit IDs --
  // Note: Usually distinct IDs are needed for Android vs iOS. 
  // Using the provided IDs for both platforms temporarily.
  
  // Banner (Removed per user request)
  // static const String bannerAdUnitIdAndroid = 'ca-app-pub-3940256099942544/6300978111'; // TEST ID
  // static const String bannerAdUnitIdIos = 'ca-app-pub-3940256099942544/2934735716';     // TEST ID
  
  // Interstitial: "AI Analysis"
  // Production Ad Unit IDs (Commented out for testing)
  // Interstitial: "AI Analysis"
  // Interstitial: "AI Analysis"
  // Production Ad Unit IDs (Provided by User)
  // Production Ad Unit IDs (Provided by User)
  // Note: These IDs are from the iOS AdMob account.
  // Android is kept on Test IDs until Android-specific keys are provided.
  
  static const String interstitialAdUnitIdAndroid = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String interstitialAdUnitIdIos = 'ca-app-pub-5936164848570883/5814246644';      // Production ID

  // Rewarded: "rewarded_ai_loading"
  static const String rewardedAdUnitIdAndroid = 'ca-app-pub-3940256099942544/5224354917';     // Test ID
  static const String rewardedAdUnitIdIos = 'ca-app-pub-5936164848570883/6183295190';         // Production ID

  // static String get bannerAdUnitId {
  //   if (Platform.isAndroid) return bannerAdUnitIdAndroid;
  //   if (Platform.isIOS) return bannerAdUnitIdIos;
  //   throw UnsupportedError('Unsupported platform');
  // }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) return interstitialAdUnitIdAndroid;
    if (Platform.isIOS) return interstitialAdUnitIdIos;
    throw UnsupportedError('Unsupported platform');
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) return rewardedAdUnitIdAndroid;
    if (Platform.isIOS) return rewardedAdUnitIdIos;
    throw UnsupportedError('Unsupported platform');
  }
}
