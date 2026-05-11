import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import 'responsive_container.dart';
import '../../membership/providers/membership_provider.dart';
import '../../main_navigation/main_navigation_screen.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class ResponsiveWelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback? onSignIn;
  
  const ResponsiveWelcomePage({
    super.key,
    required this.onNext,
    this.onSignIn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;
    
    // 根據屏幕大小調整間距和尺寸
    final isSmallScreen = screenHeight < 700;
    final iconSize = isSmallScreen ? 80.0 : 100.0;
    final spacing = isSmallScreen ? 16.0 : 24.0;
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: spacing,
          ),
          child: Column(
            children: [
              // 可滾動內容區域
              Expanded(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: screenHeight - 250, // Adjusted for extra button
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // 應用圖標
                        _buildAppIcon(iconSize),
                        
                        // 標題和副標題
                        _buildTitleSection(context, isSmallScreen),
                        
                        // 功能介紹
                        _buildFeatureSection(context, isSmallScreen),
                      ],
                    ),
                  ),
                ),
              ),
              
              // 固定在底部的按鈕
              _buildActionButtons(context, screenWidth),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildAppIcon(double iconSize) {
    return AnimatedScaleWidget(
      duration: const Duration(milliseconds: 800),
      curve: Curves.elasticOut,
      child: Container(
        width: iconSize,
        height: iconSize,
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
          Icons.restaurant_menu,
          size: iconSize * 0.5,
          color: Colors.white,
        ),
      ),
    );
  }
  
  Widget _buildTitleSection(BuildContext context, bool isSmallScreen) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SlideInWidget(
          begin: const Offset(0, 0.5),
          duration: const Duration(milliseconds: 600),
          child: Text(
            AppLocalizations.of(context)!.welcomeToFooda,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
              fontSize: isSmallScreen ? 24 : 32,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 8 : 16),
        
        SlideInWidget(
          begin: const Offset(0, 0.5),
          duration: const Duration(milliseconds: 700),
          child: Text(
            AppLocalizations.of(context)!.appDescription,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isSmallScreen ? 14 : 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureSection(BuildContext context, bool isSmallScreen) {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      {
        'icon': Icons.camera_alt,
        'title': l10n.aiRecognition ?? 'AI 智能識別',
        'description': l10n.aiRecognitionDesc ?? '拍照即可自動識別食物和營養信息',
        'color': const Color(0xFF2563EB),
      },
      {
        'icon': Icons.analytics,
        'title': l10n.nutritionAnalysis ?? '營養分析',
        'description': l10n.nutritionAnalysisDesc ?? '詳細的營養成分分析和健康建議',
        'color': Colors.green,
      },
      {
        'icon': Icons.cloud_sync,
        'title': l10n.cloudSync ?? '雲端同步',
        'description': l10n.cloudSyncDesc ?? '數據安全備份，多設備同步',
        'color': Colors.blue,
      },
    ];
    
    return SlideInWidget(
      begin: const Offset(0, 0.3),
      duration: const Duration(milliseconds: 800),
      child: Column(
        children: features.map((feature) {
          return Container(
            margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
            child: _buildFeatureItem(
              context, // Added context
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
              feature['color'] as Color,
              isSmallScreen,
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context, // Added context
    IconData icon,
    String title,
    String description,
    Color color,
    bool isSmallScreen,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: isSmallScreen ? 40 : 48,
            height: isSmallScreen ? 40 : 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmallScreen ? 14 : 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActionButtons(BuildContext context, double screenWidth) {
    return Column(
      children: [
        if (onSignIn != null)
          SlideInWidget(
            begin: const Offset(0, 1),
            duration: const Duration(milliseconds: 800),
            delay: const Duration(milliseconds: 800),
            child: Column(
              children: [
                SizedBox(
                  width: screenWidth * 0.8,
                  height: 50,
                  child: SignInWithAppleButton(
                    onPressed: onSignIn!,
                    text: 'Sign in with Apple', // Or localized string
                    style: SignInWithAppleButtonStyle.black,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => _showEmailLoginDialog(context),
                  child: Text(
                    AppLocalizations.of(context)!.loginWithEmail ?? 'Login with Email',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  void _showEmailLoginDialog(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.loginWithEmail ?? 'Login with Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.email ?? 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.password ?? 'Password',
              ),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final email = emailController.text.trim();
              final password = passwordController.text.trim();
              
              if (email == 'review@fooda.app' && password == 'FoOda888') {
                final membership = Provider.of<MembershipProvider>(context, listen: false);
                await membership.upgradeTo(MembershipTier.premium);
                
                if (context.mounted) {
                  Navigator.pop(context); // Close dialog
                  // Navigate to main screen
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
                    (route) => false,
                  );
                }
              } else {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.invalidCredentials ?? 'Invalid credentials'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(AppLocalizations.of(context)!.login ?? 'Login'),
          ),
        ],
      ),
    );
  }
}

// 動畫組件保持不變...
class AnimatedScaleWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;

  const AnimatedScaleWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeInOut,
  });

  @override
  State<AnimatedScaleWidget> createState() => _AnimatedScaleWidgetState();
}

class _AnimatedScaleWidgetState extends State<AnimatedScaleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

class SlideInWidget extends StatefulWidget {
  final Widget child;
  final Offset begin;
  final Duration duration;
  final Duration delay;

  const SlideInWidget({
    super.key,
    required this.child,
    this.begin = const Offset(0, 0.5),
    this.duration = const Duration(milliseconds: 500),
    this.delay = Duration.zero,
  });

  @override
  State<SlideInWidget> createState() => _SlideInWidgetState();
}

class _SlideInWidgetState extends State<SlideInWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    
    _slideAnimation = Tween<Offset>(begin: widget.begin, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}