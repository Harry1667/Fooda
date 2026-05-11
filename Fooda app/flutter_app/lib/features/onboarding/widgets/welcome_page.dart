import 'package:flutter/material.dart';
import 'responsive_container.dart';

class WelcomePage extends StatelessWidget {
  final VoidCallback onNext;
  
  const WelcomePage({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return ResponsiveContainer(
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - 200, // 確保有足夠高度但不溢出
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
            // 應用圖標動畫
            AnimatedScaleWidget(
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              child: Container(
                width: screenHeight * 0.15,
                height: screenHeight * 0.15,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.primaryColor.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: (screenHeight * 0.06).clamp(40.0, 60.0),
                  color: Colors.white,
                ),
              ),
            ),
            
            SizedBox(height: (screenHeight * 0.02).clamp(12.0, 24.0)),
            
            // 標題動畫
            SlideInWidget(
              begin: const Offset(0, 0.5),
              duration: const Duration(milliseconds: 600),
              child: Text(
                '歡迎使用 Fooda',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.02),
            
            // 副標題動畫
            SlideInWidget(
              begin: const Offset(0, 0.5),
              duration: const Duration(milliseconds: 700),
              child: Text(
                '智能飲食記錄，健康生活從這裡開始',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            SizedBox(height: screenHeight * 0.06),
            
            // 功能介紹列表
            SlideInWidget(
              begin: const Offset(0, 0.3),
              duration: const Duration(milliseconds: 800),
              child: Column(
                children: [
                  _buildFeatureItem(
                    context,
                    Icons.camera_alt,
                    'AI 智能識別',
                    '拍照即可自動識別食物和營養信息',
                    theme.primaryColor,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFeatureItem(
                    context,
                    Icons.analytics,
                    '營養分析',
                    '詳細的營養成分分析和健康建議',
                    Colors.green,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  _buildFeatureItem(
                    context,
                    Icons.cloud_sync,
                    '雲端同步',
                    '數據安全備份，多設備同步',
                    Colors.blue,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: screenHeight * 0.06),
            
            // 開始按鈕
            SlideInWidget(
              begin: const Offset(0, 0.2),
              duration: const Duration(milliseconds: 900),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 8,
                    shadowColor: theme.primaryColor.withOpacity(0.3),
                  ),
                  child: const Text(
                    '開始使用',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
  
  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}