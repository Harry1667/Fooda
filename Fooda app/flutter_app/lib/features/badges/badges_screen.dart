import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.badges ?? '成就徽章'),
      ),
      body: Center(
        child: Text(AppLocalizations.of(context)!.badgesPage ?? '徽章頁面'),
      ),
    );
  }
}