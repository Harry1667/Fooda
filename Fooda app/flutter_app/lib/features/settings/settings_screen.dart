import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_provider.dart';
// import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import '../membership/providers/membership_provider.dart';


import 'package:url_launcher/url_launcher.dart';

// import '../../features/auth/apple_sign_in_banner.dart';

/// 設定頁面
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appSettings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Apple 登入橫幅已移至個人頁面
          // const AppleSignInBanner(),
          
          const SizedBox(height: 8),
          
          // 外觀設定區塊
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.appearance,
            children: [
              _buildThemeSettings(context),
            ],
          ),
          


          const SizedBox(height: 24),

          // 法律資訊區塊
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.legalDocuments,
            children: [
              _buildSettingItem(
                context,
                title: AppLocalizations.of(context)!.privacyPolicy,
                icon: Icons.privacy_tip_outlined,
                onTap: () => _launchUrl(context, 'https://ethereal-throne-212.notion.site/Fooda-Privacy-Policy-2be56be2c5c280adb958c672e7215c03?source=copy_link'),
              ),
              _buildSettingItem(
                context,
                title: AppLocalizations.of(context)!.termsOfUse,
                icon: Icons.description_outlined,
                onTap: () => _launchUrl(context, 'https://ethereal-throne-212.notion.site/Fooda-Terms-of-Use-EULA-2c456be2c5c280498f7cf74f3e0f895e?source=copy_link'),
              ),
            ],
          ),

          const SizedBox(height: 24),
          
          // 關於區塊
          _buildSection(
            context,
            title: AppLocalizations.of(context)!.about,
            children: [
              _buildAboutItem(
                context,
                title: AppLocalizations.of(context)!.appVersion,
                subtitle: '1.0.0',
                icon: Icons.info_outline,
              ),
              _buildSettingItem(
                context,
                title: 'Support / Help Center',
                icon: Icons.help_outline,
                onTap: () => _launchUrl(context, 'https://ethereal-throne-212.notion.site/Fooda-Support-Help-Center-2be56be2c5c280a79660dde1fd89c497?source=copy_link'),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Compliance Section
          _buildComplianceSection(context),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildComplianceSection(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nutrition Data Source',
            style: textStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'CalHub calculates nutritional estimations using public, authoritative nutrition databases:\n'
            '• USDA FoodData Central (https://fdc.nal.usda.gov/)\n'
            '• Japan Standard Tables of Food Composition 2020\n'
            '• Taiwan Food Nutrition Database (if applicable)\n'
            'Values are estimated and may vary depending on ingredients and preparation methods.',
            style: textStyle,
          ),
          const SizedBox(height: 16),
          Text(
            'Disclaimer',
            style: textStyle?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'CalHub provides AI-assisted meal estimation for general wellness purposes only and is not intended as medical advice, diagnosis, or treatment.',
            style: textStyle,
          ),
        ],
      ),
    );
  }




  /// 建立區塊容器
  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  /// 建立主題設定項
  Widget _buildThemeSettings(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Column(
          children: [
            _buildSettingItem(
              context,
              title: AppLocalizations.of(context)!.darkMode ?? '深色模式',
              subtitle: _getThemeModeText(context, themeProvider.themeMode),
              icon: themeProvider.isDarkMode
                  ? Icons.dark_mode
                  : Icons.light_mode,
              trailing: _buildThemeSelector(context, themeProvider),
            ),
          ],
        );
      },
    );
  }

  /// 建立設定項目
  Widget _buildSettingItem(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  /// 建立關於項目
  Widget _buildAboutItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return _buildSettingItem(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
    );
  }

  /// 建立主題選擇器
  Widget _buildThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    return PopupMenuButton<ThemeMode>(
      icon: const Icon(Icons.arrow_forward_ios, size: 16),
      onSelected: (mode) async {
        await themeProvider.setThemeMode(mode);
      },
      itemBuilder: (context) => [
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                size: 20,
                color: themeProvider.isLightMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.lightMode ?? '淺色'),
              if (themeProvider.isLightMode) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                size: 20,
                color: themeProvider.isDarkMode && !themeProvider.isSystemMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.darkMode ?? '深色'),
              if (themeProvider.isDarkMode && !themeProvider.isSystemMode) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem<ThemeMode>(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                size: 20,
                color: themeProvider.isSystemMode
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              const SizedBox(width: 12),
              Text(AppLocalizations.of(context)!.followSystem ?? '跟隨系統'),
              if (themeProvider.isSystemMode) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// 取得主題模式文字
  String _getThemeModeText(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.lightMode ?? '淺色';
      case ThemeMode.dark:
        return l10n.darkMode ?? '深色';
      case ThemeMode.system:
        return l10n.followSystem ?? '跟隨系統';
    }
  }

  Future<void> _launchUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    // ignore: deprecated_member_use
    if (!await canLaunch(url.toString())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } else {
      // ignore: deprecated_member_use
      await launch(url.toString());
    }
  }
}
