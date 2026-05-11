import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';

class LanguageSettingsDialog extends StatefulWidget {
  const LanguageSettingsDialog({super.key});

  @override
  State<LanguageSettingsDialog> createState() => _LanguageSettingsDialogState();
}

class _LanguageSettingsDialogState extends State<LanguageSettingsDialog> {
  String? selectedLanguage;

  @override
  void initState() {
    super.initState();
    final localeProvider = context.read<LocaleProvider>();
    selectedLanguage = localeProvider.currentLanguageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
          maxWidth: screenWidth * 0.9,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.05),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // 標題
            Row(
              children: [
                Icon(
                  Icons.language,
                  color: theme.primaryColor,
                  size: screenWidth * 0.07,
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.languageSettings,
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // 當前語言提示
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(screenWidth * 0.04),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: theme.primaryColor,
                    size: screenWidth * 0.05,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    child: Text(
                      '${l10n.currentLanguage}: ${context.read<LocaleProvider>().currentLanguageOption.nativeName}',
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // 語言選項列表
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenHeight * 0.4,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 跟隨系統選項
                    Container(
                      margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                      child: Material(
                        elevation: selectedLanguage == 'system' ? 4 : 1,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              selectedLanguage = 'system';
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.04),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedLanguage == 'system'
                                    ? theme.primaryColor 
                                    : theme.dividerColor,
                                width: selectedLanguage == 'system' ? 2 : 1,
                              ),
                              color: selectedLanguage == 'system'
                                  ? theme.primaryColor.withOpacity(0.1) 
                                  : theme.cardColor,
                            ),
                            child: Row(
                              children: [
                                // 圖標
                                Icon(
                                  Icons.settings_system_daydream,
                                  size: screenWidth * 0.06,
                                  color: theme.colorScheme.onSurface,
                                ),
                                
                                SizedBox(width: screenWidth * 0.04),
                                
                                // 選項名稱
                                Expanded(
                                  child: Text(
                                    l10n.followSystem ?? 'Follow System',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.04,
                                      fontWeight: FontWeight.bold,
                                      color: selectedLanguage == 'system'
                                          ? theme.primaryColor 
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                
                                // 選中指示器
                                if (selectedLanguage == 'system')
                                  Icon(
                                    Icons.check_circle,
                                    color: theme.primaryColor,
                                    size: screenWidth * 0.05,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: LocaleProvider.languageOptions.length,
                      itemBuilder: (context, index) {
                        final entry = LocaleProvider.languageOptions.entries.elementAt(index);
                        final languageCode = entry.key;
                        final option = entry.value;
                        final isSelected = selectedLanguage == languageCode;
                        
                        return Container(
                          margin: EdgeInsets.only(bottom: screenHeight * 0.01),
                          child: Material(
                            elevation: isSelected ? 4 : 1,
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap: () {
                                setState(() {
                                  selectedLanguage = languageCode;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(screenWidth * 0.04),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected 
                                        ? theme.primaryColor 
                                        : theme.dividerColor,
                                    width: isSelected ? 2 : 1,
                                  ),
                                  color: isSelected 
                                      ? theme.primaryColor.withOpacity(0.1) 
                                      : theme.cardColor,
                                ),
                                child: Row(
                                  children: [
                                    // 國旗
                                    Text(
                                      option.flag,
                                      style: TextStyle(fontSize: screenWidth * 0.06),
                                    ),
                                    
                                    SizedBox(width: screenWidth * 0.04),
                                    
                                    // 語言名稱
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          FittedBox(
                                            fit: BoxFit.scaleDown,
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              option.nativeName,
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.04,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected 
                                                    ? theme.primaryColor 
                                                    : theme.colorScheme.onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (option.name != option.nativeName)
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                option.name,
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.032,
                                                  color: theme.colorScheme.onSurface
                                                      .withOpacity(0.6),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    
                                    // 選中指示器
                                    if (isSelected)
                                      Icon(
                                        Icons.check_circle,
                                        color: theme.primaryColor,
                                        size: screenWidth * 0.05,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.025),
            
            // 操作按鈕
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                
                SizedBox(width: screenWidth * 0.03),
                
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: selectedLanguage != null ? _applyLanguageChange : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: selectedLanguage != null ? 4 : 0,
                    ),
                    child: Text(
                      l10n.confirm,
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                ],
              ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _applyLanguageChange() async {
    if (selectedLanguage == null) return;
    
    final localeProvider = context.read<LocaleProvider>();
    final l10n = AppLocalizations.of(context)!;
    
    // 檢查是否真的需要更改
    if (selectedLanguage == localeProvider.currentLanguageCode) {
      Navigator.of(context).pop();
      return;
    }
    
    // 應用語言更改
    await localeProvider.setLocale(selectedLanguage == 'system' ? null : selectedLanguage);
    
    // 關閉對話框
    Navigator.of(context).pop();
    
    // 顯示成功消息
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.languageChanged),
          backgroundColor: Theme.of(context).primaryColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}