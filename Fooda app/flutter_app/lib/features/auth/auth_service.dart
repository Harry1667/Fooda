import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _userIdKey = 'apple_user_id';
  static const String _emailKey = 'apple_email';
  static const String _givenNameKey = 'apple_given_name';
  static const String _familyNameKey = 'apple_family_name';

  /// 檢查是否已登入
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey) != null;
  }

  /// 獲取當前用戶信息
  static Future<Map<String, String?>> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString(_userIdKey),
      'email': prefs.getString(_emailKey),
      'givenName': prefs.getString(_givenNameKey),
      'familyName': prefs.getString(_familyNameKey),
    };
  }

  /// 執行 Apple 登入
  static Future<bool> signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 保存用戶信息
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userIdKey, credential.userIdentifier!);
      
      if (credential.email != null) {
        await prefs.setString(_emailKey, credential.email!);
      }
      
      if (credential.givenName != null) {
        await prefs.setString(_givenNameKey, credential.givenName!);
      }
      
      if (credential.familyName != null) {
        await prefs.setString(_familyNameKey, credential.familyName!);
      }

      print('Apple Sign-In Success: ${credential.userIdentifier}');
      return true;
    } catch (e) {
      print('Apple Sign-In Failed: $e');
      return false;
    }
  }

  /// 登出
  static Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_givenNameKey);
    await prefs.remove(_familyNameKey);
  }
}
