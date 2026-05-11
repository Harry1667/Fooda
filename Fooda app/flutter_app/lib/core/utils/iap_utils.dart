import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 顯示友善的 IAP 錯誤訊息
/// 真正的錯誤只寫到 log，使用者只會看到友善的提示
void showFriendlyIapError(BuildContext context, Object error) {
  // 真正錯誤只寫到 log
  debugPrint('IAP error: $error');

  const userMessage = '目前無法連線到 App Store，請稍後再試。';

  // 如果 context 已經無效就直接 return
  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(userMessage),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 3),
    ),
  );
}
