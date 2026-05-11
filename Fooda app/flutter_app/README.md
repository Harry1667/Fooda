# 🍽️ Calhub App - 智能飲食記錄應用

Calhub 是一款智能的飲食記錄應用，結合 AI 技術為用戶提供個人化的營養分析和健康建議。

## 📱 應用特色

### 🎯 核心功能
- **AI 智能識別** - 拍照即可自動識別食物和營養信息
- **個人化建議** - 基於身體數據的 AI 卡路里計算
- **營養分析** - 詳細的營養成分分析和健康建議
- **雲端同步** - 安全的數據備份和多設備同步
- **完整引導** - 新手友好的互動式用戶教學

### 🎓 用戶引導系統

#### 引導流程（Onboarding）
完整的 6 步新手引導流程：
1. **歡迎頁面** - 應用介紹和功能展示
2. **帳戶登入** - Apple Sign-In 支持
3. **身體資料** - 性別、身高、體重、年齡、活動水平設置
4. **卡路里目標** - AI 智能計算個人化建議
5. **功能教學** - 相機拍照功能介紹

#### 教學系統（Tutorial）
**全新的 13 步聚光燈式互動教學系統** 🎊

- ✅ **聚光燈高亮引導**：半透明遮罩 + 高亮目標區域
- ✅ **強制互動流程**：用戶必須點擊高亮區域才能繼續
- ✅ **智能步驟控制**：自動檢測進度，避免重複執行
- ✅ **完整的 13 個步驟**：從導航介紹到完成第一筆飲食記錄

**教學步驟概覽：**
1. 步驟 1-6：主要導航介紹（首頁、歷史、分析、個人）
2. 步驟 7：新增記錄按鈕
3. 步驟 8-10：底部選單功能介紹（拍照、相簿、手動輸入）
4. 步驟 11：相簿功能實際操作
5. 步驟 12：展示新添加的記錄
6. 步驟 13：完成教學面板

📖 **詳細文檔**：[教學系統完整文檔](./README_TUTORIAL_SYSTEM.md)
6. **互動式營養記錄** - 真實操作體驗教學

## 📱 響應式設計

### 🏗️ 完美適配所有 iPhone 機型

#### 支持設備：
- ✅ **iPhone SE** (小屏幕) - 特殊優化縮放 (85% 縮放)
- ✅ **iPhone 12 mini, iPhone X** (中等屏幕) - 適度調整 (95% 縮放)
- ✅ **iPhone 12, iPhone 11** (標準屏幕) - 完美體驗 (100% 縮放)
- ✅ **iPhone 12 Pro Max** (大屏幕) - 充分利用空間 (110% 縮放)

#### 響應式系統：
```dart
// 智能間距系統
ResponsiveUtils.getSpacing(context, SpacingType.medium)
// 小屏: 16px, 中屏: 20px, 大屏: 24px, 超大屏: 28px

// 響應式字體
ResponsiveUtils.getFontSize(context, FontSizeType.title)
// 根據設備自動調整字體大小

// 動態按鈕高度
ResponsiveUtils.getButtonHeight(context)
// 小屏: 44px, 中屏: 48px, 大屏: 52px, 超大屏: 56px
```

## 🛠️ 技術架構

### 📂 項目結構
```
lib/
├── core/
│   ├── config/           # 配置文件
│   ├── models/           # 數據模型
│   ├── services/         # 核心服務
│   ├── utils/           # 工具類
│   └── widgets/         # 通用組件
├── features/
│   ├── onboarding/      # 用戶引導
│   ├── profile/         # 個人資料
│   ├── main_navigation/ # 主導航
│   └── ...
└── main.dart
```

### 🔧 核心技術

#### 後端集成：
- **Firebase Core** - 核心服務
- **Firebase Auth** - 用戶認證
- **Cloud Firestore** - 數據存儲
- **Firebase Storage** - 文件存儲

#### 響應式設計：
- **ResponsiveUtils** - 統一的響應式工具類
- **設備類型檢測** - 自動識別設備尺寸
- **動態縮放** - 智能調整UI元素大小

#### 狀態管理：
- **Provider** - 狀態管理
- **SharedPreferences** - 本地存儲
- **Animation Controllers** - 流暢動畫

## 🚀 快速開始

### 📋 環境要求
- Flutter SDK: >= 3.8.0
- Dart SDK: >= 3.8.0
- iOS: >= 13.0
- Xcode: >= 14.0

### 🔧 安裝步驟

1. **克隆項目**
```bash
git clone <repository-url>
cd flutter_app
```

2. **安裝依賴**
```bash
flutter pub get
cd ios && pod install && cd ..
```

3. **運行應用**
```bash
# iOS 模擬器
flutter run -d "iPhone 12"

# 真機 (需要開發者證書)
flutter run -d "Your iPhone"
```

### 🧪 測試不同設備
```bash
# 小屏幕測試
flutter run -d "iPhone SE (3rd generation)"

# 大屏幕測試
flutter run -d "iPhone 15 Pro Max"
```

## 🔐 配置設置

### 🔥 Firebase 配置
1. 在 Firebase Console 創建項目
2. 下載 `GoogleService-Info.plist` 到 `ios/Runner/`
3. 啟用 Authentication 和 Firestore

### 🍎 Apple Sign-In 配置
1. 在 Apple Developer 中配置 App ID
2. 啟用 Sign In with Apple 服務
3. 配置 Bundle Identifier

### 🛠️ 開發配置
```dart
// lib/core/config/development_config.dart
class DevelopmentConfig {
  static const bool isDevelopmentMode = true;
  static const bool alwaysShowOnboarding = true; // 開發時每次顯示引導
  static const bool showDebugInfo = true;
}
```

## 📊 AI 功能

### 🧠 智能卡路里計算
使用 Mifflin-St Jeor 公式計算基礎代謝率：

```dart
// 男性計算公式
BMR = 88.362 + (13.397 × 體重kg) + (4.799 × 身高cm) - (5.677 × 年齡)

// 女性計算公式  
BMR = 447.593 + (9.247 × 體重kg) + (3.098 × 身高cm) - (4.330 × 年齡)

// 根據活動水平調整
總消耗 = BMR × 活動係數
```

#### 活動係數：
- 久坐少動: 1.2
- 輕度活動: 1.375
- 中度活動: 1.55
- 高度活動: 1.725
- 極高活動: 1.9

### 🔮 營養成分識別
- 食物圖像識別 API
- 營養數據庫匹配
- 份量估算算法

## 📱 用戶體驗

### 🎨 設計原則
- **響應式優先** - 適配所有設備尺寸
- **直觀易用** - 簡潔明了的操作流程
- **視覺一致** - 統一的設計語言
- **性能優化** - 流暢的動畫和交互

### 🎭 動畫效果
- **頁面轉換** - 平滑的滑入動畫
- **元素出現** - 縮放和淡入效果
- **進度指示** - 動態進度條
- **數字計數** - 吸引人的計數動畫

### 🖐️ 交互設計
- **手勢支持** - 點擊空白區域收起鍵盤
- **視覺反饋** - 按鈕狀態變化
- **錯誤處理** - 友好的錯誤提示
- **表單驗證** - 實時輸入驗證

## 🧪 測試

### ✅ 功能測試
```bash
# 分析代碼
flutter analyze

# 運行測試
flutter test

# 構建測試
flutter build ios --debug --no-codesign
```

### 📱 設備測試檢查清單
- [ ] iPhone SE - 小屏幕適配
- [ ] iPhone 12 - 標準屏幕
- [ ] iPhone 12 Pro Max - 大屏幕
- [ ] 橫屏模式支持
- [ ] 鍵盤交互
- [ ] 引導流程完整性

## 🛠️ 開發工具

### 🔧 開發便利功能
應用內集成的開發工具：

1. **引導重置** - 個人頁面的開發選項
2. **數據查看** - 顯示所有存儲數據
3. **一鍵清除** - 重置所有應用數據
4. **調試信息** - 實時狀態監控

### 🎯 快速重置引導
```dart
// 重置引導狀態
await DevelopmentUtils.resetOnboardingState();
```

## 📈 性能優化

### 🚀 已實現的優化
- **延遲加載** - 按需加載頁面組件
- **圖像緩存** - 智能圖片緩存策略
- **動畫優化** - 高性能動畫實現
- **內存管理** - 及時釋放控制器資源

### 📊 響應式性能
- **設備檢測** - O(1) 時間複雜度
- **尺寸計算** - 緩存計算結果
- **佈局優化** - 避免不必要的重建

## 🔒 安全性

### 🛡️ 數據保護
- **本地加密** - 敏感數據本地加密存儲
- **網絡安全** - HTTPS 通信
- **認證安全** - Firebase Auth 集成
- **權限管理** - 最小權限原則

### 🔐 隱私保護
- **數據最小化** - 只收集必要數據
- **用戶控制** - 數據刪除和導出
- **透明度** - 清晰的隱私說明

## 🚢 部署

### 📦 構建發布版本
```bash
# iOS App Store 構建
flutter build ios --release

# 生成 IPA 文件 (需要 Xcode)
xcodebuild -workspace ios/Runner.xcworkspace \
          -scheme Runner \
        # Fooda - Smart Nutrition Tracker
        # Fooda is a smart nutrition tracking app that helps you manage your diet.
        # Fooda uses AI to identify food and calculate nutritional values.
          -configuration Release \
          -archivePath build/Runner.xcarchive \
          archive
```

### 🎯 發布檢查清單
- [ ] 關閉開發模式
- [ ] 更新版本號
- [ ] 測試發布構建
- [ ] App Store 元數據
- [ ] 隱私政策更新

## 🤝 貢獻

### 🔄 開發流程
1. Fork 項目
2. 創建功能分支
3. 提交更改
4. 創建 Pull Request

### 📝 代碼規範
- 使用 `flutter analyze` 檢查代碼
- 遵循 Dart 命名規範
- 添加適當的註釋
- 保持響應式設計一致性

## 📄 許可證

本項目採用 MIT 許可證 - 查看 [LICENSE](LICENSE) 文件了解詳情。

## 🆘 支持

### 🐛 問題報告
如果您遇到問題，請：
1. 檢查現有 Issues
2. 提供詳細的錯誤信息
3. 包含設備和版本信息
4. 提供重現步驟

### 💬 聯繫我們
- Email: support@foodaapp.com
- GitHub Issues: [項目Issues頁面]

---

## 🎉 更新日誌

### Version 1.0.0 (2024-01-XX)
#### ✨ 新功能
- 🎯 完整的用戶引導系統
- 📱 全設備響應式設計
- 🧠 AI 智能卡路里計算
- 🔐 Apple Sign-In 集成
- 🎮 互動式營養記錄教學

#### 🐛 修復
- 修復 Firebase 依賴衝突
- 解決模擬器 Apple Sign-In 問題
- 修復鍵盤交互問題
- 優化動畫性能

#### 🎨 設計改進
- 統一響應式設計系統
- 優化小屏幕設備體驗
- 改進按鈕和文字大小
- 增強視覺一致性

---

**🎊 感謝您使用 Fooda！健康飲食，從記錄開始！**