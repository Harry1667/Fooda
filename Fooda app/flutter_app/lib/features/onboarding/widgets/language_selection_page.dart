import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'responsive_container.dart';

class LanguageSelectionPage extends StatefulWidget {
  final Function(String) onLanguageSelected;
  
  const LanguageSelectionPage({
    super.key,
    required this.onLanguageSelected,
  });

  @override
  State<LanguageSelectionPage> createState() => _LanguageSelectionPageState();
}

class _LanguageSelectionPageState extends State<LanguageSelectionPage>
    with TickerProviderStateMixin {
  String? selectedLanguage;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<LanguageOption> languageOptions = [
    LanguageOption(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸',
    ),
    LanguageOption(
      code: 'zh_TW',
      name: 'Traditional Chinese',
      nativeName: '繁體中文',
      flag: '🇹🇼',
    ),
    LanguageOption(
      code: 'zh_CN',
      name: 'Simplified Chinese',
      nativeName: '简体中文',
      flag: '🇨🇳',
    ),
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 引導畫面強制使用淺色模式
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ResponsiveContainer(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - 100,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 應用圖標
                    Container(
                      width: screenHeight * 0.12,
                      height: screenHeight * 0.12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.language,
                        size: screenHeight * 0.05,
                        color: Colors.white,
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.04),
                    
                    // 標題
                    Text(
                      _getTitle(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.07,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.01),
                    
                    // 副標題
                    Text(
                      _getSubtitle(),
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    SizedBox(height: screenHeight * 0.05),
                    
                    // 語言選項
                    ...languageOptions.asMap().entries.map((entry) {
                      int index = entry.key;
                      LanguageOption option = entry.value;
                      
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        margin: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.01,
                        ),
                        child: Material(
                          color: Colors.white,
                          elevation: selectedLanguage == option.code ? 8 : 2,
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _selectLanguage(option.code),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.06,
                                vertical: screenHeight * 0.02,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selectedLanguage == option.code
                                      ? const Color(0xFF2563EB)
                                      : Colors.grey[300]!,
                                  width: selectedLanguage == option.code ? 2 : 1,
                                ),
                                color: selectedLanguage == option.code
                                    ? const Color(0xFF2563EB).withOpacity(0.1)
                                    : Colors.white,
                              ),
                              child: Row(
                                children: [
                                  // 國旗表情符號
                                  Text(
                                    option.flag,
                                    style: TextStyle(fontSize: screenWidth * 0.08),
                                  ),
                                  
                                  SizedBox(width: screenWidth * 0.04),
                                  
                                  // 語言名稱
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option.nativeName,
                                          style: TextStyle(
                                            fontSize: screenWidth * 0.045,
                                            fontWeight: FontWeight.bold,
                                            color: selectedLanguage == option.code
                                                ? const Color(0xFF2563EB)
                                                : Colors.black87,
                                          ),
                                        ),
                                        if (option.name != option.nativeName)
                                          Text(
                                            option.name,
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.035,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  
                                  // 選中指示器
                                  if (selectedLanguage == option.code)
                                    Icon(
                                      Icons.check_circle,
                                      color: const Color(0xFF2563EB),
                                      size: screenWidth * 0.06,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    
                    SizedBox(height: screenHeight * 0.05),
                    
                    // 繼續按鈕
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedLanguage != null ? _continue : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          disabledForegroundColor: Colors.grey[500],
                          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: selectedLanguage != null ? 4 : 0,
                        ),
                        child: Text(
                          selectedLanguage == null 
                              ? _getSelectLanguageText() 
                              : _getContinueText(),
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      selectedLanguage = languageCode;
    });
    
    // 立即更新應用語言
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);
    localeProvider.setLocale(languageCode);
  }

  String _getTitle() {
    // 根據目前選擇的語言或系統語言顯示標題
    final locale = Localizations.localeOf(context);
    if (selectedLanguage == 'zh_TW' || (selectedLanguage == null && locale.languageCode == 'zh' && locale.countryCode == 'TW')) {
      return '選擇您的語言';
    } else if (selectedLanguage == 'zh_CN' || (selectedLanguage == null && locale.languageCode == 'zh' && locale.countryCode == 'CN')) {
      return '选择您的语言';
    } else {
      return 'Choose Your Language';
    }
  }
  
  String _getSubtitle() {
    return 'Select your preferred language\n選擇您的偏好語言\n选择您的首选语言';
  }
  
  String _getSelectLanguageText() {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'zh' && locale.countryCode == 'TW') {
      return '請選擇語言';
    } else if (locale.languageCode == 'zh' && locale.countryCode == 'CN') {
      return '请选择语言';
    } else {
      return 'Please select a language';
    }
  }

  String _getContinueText() {
    switch (selectedLanguage) {
      case 'en':
        return 'Continue';
      case 'zh_TW':
        return '繼續';
      case 'zh_CN':
        return '继续';
      default:
        return 'Continue';
    }
  }

  void _continue() {
    if (selectedLanguage != null) {
      widget.onLanguageSelected(selectedLanguage!);
    }
  }
}

class LanguageOption {
  final String code;
  final String name;
  final String nativeName;
  final String flag;

  LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
  });
}