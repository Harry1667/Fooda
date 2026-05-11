import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'auth_service.dart';
import 'package:fooda_app/l10n/app_localizations.dart';

class AppleSignInBanner extends StatefulWidget {
  const AppleSignInBanner({super.key});

  @override
  State<AppleSignInBanner> createState() => _AppleSignInBannerState();
}

class _AppleSignInBannerState extends State<AppleSignInBanner> {
  bool _isLoggedIn = false;
  String? _userName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (loggedIn) {
      final user = await AuthService.getCurrentUser();
      final givenName = user['givenName'];
      final familyName = user['familyName'];
      String? name;
      if (givenName != null && familyName != null) {
        name = '$givenName $familyName';
      } else if (givenName != null) {
        name = givenName;
      }
      
      if (mounted) {
        setState(() {
          _isLoggedIn = true;
          _userName = name;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoggedIn = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    setState(() => _isLoading = true);
    final success = await AuthService.signInWithApple();
    if (success) {
      await _checkLoginStatus();
    } else {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSignOut() async {
    await AuthService.signOut();
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator()));
    }

    if (_isLoggedIn) {
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Colors.black,
              child: Icon(Icons.apple, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.loggedInAs(_userName ?? 'User'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Apple ID',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: _handleSignOut,
              child: Text(AppLocalizations.of(context)!.signOut),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: SignInWithAppleButton(
        onPressed: _handleSignIn,
        text: AppLocalizations.of(context)!.signInWithApple,
        style: SignInWithAppleButtonStyle.black,
      ),
    );
  }
}
