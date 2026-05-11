# Fooda App 🍎

智能營養追踪應用，使用 AI 技術幫助用戶管理飲食健康。支援多語言界面，提供完整的國際化體驗。

## ✨ 功能特色

### 🤖 AI 智能功能
- **AI 食物識別**：使用相機拍攝食物，自動識別營養成分
- **智能分析**：基於 Google Gemini API 提供個人化營養建議
- **自動計算**：智能計算每日卡路里和營養素需求

### 📱 用戶體驗
- **多語言支援**：完整支援 English、繁體中文、简体中文
- **響應式設計**：適配不同螢幕尺寸和裝置
- **直觀界面**：清晰的導航和用戶友好的操作流程
- **開發模式**：內建開發跳過功能，快速測試

### 📊 營養追蹤
- **即時追蹤**：每日營養攝取情況即時更新
- **歷史記錄**：查看過往飲食記錄和營養趨勢
- **多種記錄方式**：
  - 🔷 AI 智能拍照識別
  - 📁 上傳照片分析
  - ✏️ 手動輸入營養資訊

### 🎯 個人化功能
- **用戶引導**：完整的 Onboarding 流程
- **身體資料設定**：身高、體重、年齡、性別、活動量
- **目標設定**：個人化卡路里和營養目標
- **語言選擇**：應用內即時切換語言

## 🌐 多語言支援

### 支援語言
- 🇺🇸 **English** - 完整支援
- 🇹🇼 **繁體中文** - 完整支援
- 🇨🇳 **简体中文** - 完整支援

### 本地化功能
- **界面文字**：所有 UI 元素完全本地化
- **導航標籤**：底部導航欄支援多語言
- **餐點類型**：早餐、午餐、晚餐等選項本地化
- **食物標籤**：家煮、外食、外賣等標籤本地化
- **操作提示**：所有按鈕和提示文字本地化
- **即時切換**：語言切換立即生效，無需重啟

## 🛠 技術架構

### 前端技術
- **框架**: Flutter 3.35.7 (iOS/Android)
- **狀態管理**: Provider
- **本地化**: flutter_localizations
- **本地儲存**: SharedPreferences + SQLite

### 後端服務
- **API 服務**: PHP 8.0+
- **AI 服務**: Google Gemini API
- **圖像處理**: 自建圖像分析服務

### 數據管理
- **本地數據庫**: SQLite
- **數據同步**: RESTful API
- **圖像存儲**: 本地快取 + 雲端備份

### 開發工具
- **IDE**: VS Code / Android Studio / Xcode
- **版本控制**: Git
- **測試**: Flutter Test Framework
- **部署**: iOS App Store / Google Play Store

## 🚀 快速開始

### 環境要求
- Flutter SDK >= 3.35.0
- Dart SDK >= 3.9.2
- iOS: Xcode 15.0+ (iOS 13.0+)
- Android: Android Studio (API 21+)
- PHP >= 8.0 (後端 API)

### 安裝步驟

1. **克隆項目**
```bash
git clone [repository-url]
cd "Fooda app"
```

2. **配置 Flutter 環境**
```bash
cd flutter_app
flutter doctor  # 檢查環境
flutter pub get  # 安裝依賴
```

3. **配置 API 服務**
```bash
# 配置後端 API
cd ../
cp env.example.php env.php
# 編輯 env.php 添加 Google API 密鑰
```

4. **生成本地化文件**
```bash
cd flutter_app
flutter gen-l10n  # 生成多語言文件
```

5. **運行應用**
```bash
# iOS 模擬器
flutter run -d ios

# Android 模擬器  
flutter run -d android

# 實體設備
flutter run
```

### 🛡 開發模式功能

在開發階段，應用提供以下便利功能：

- **跳過引導按鈕**：語言選擇頁面左上角紅色按鈕
- **預設配置**：自動設置預設用戶資料和目標
- **快速測試**：直接進入主應用，無需完整引導流程

## 📂 項目結構

```
Fooda app/
├── flutter_app/                 # Flutter 主應用
│   ├── lib/
│   │   ├── core/                # 核心功能
│   │   │   ├── models/          # 數據模型
│   │   │   ├── services/        # 服務層
│   │   │   ├── providers/       # 狀態管理
│   │   │   └── widgets/         # 共用組件
│   │   ├── features/            # 功能模組
│   │   │   ├── home/           # 首頁
│   │   │   ├── history/        # 歷史記錄
│   │   │   ├── analysis/       # 分析頁面
│   │   │   ├── profile/        # 個人資料
│   │   │   ├── onboarding/     # 用戶引導
│   │   │   ├── manual_input/   # 手動輸入
│   │   │   └── ai_upload/      # AI 上傳
│   │   └── l10n/               # 本地化文件
│   │       ├── app_en.arb      # 英文
│   │       ├── app_zh.arb      # 繁體中文
│   │       └── app_zh_CN.arb   # 简體中文
├── api/                        # PHP API 服務
│   ├── analyze.php             # AI 分析接口
│   ├── nutrition.php           # 營養數據接口
│   └── membership.php          # 會員服務接口
├── *.php                       # PHP 頁面文件
└── *.css                       # 樣式文件
```

## 📊 項目狀態

### ✅ 已完成功能
- **多語言系統**：完整的國際化支援
- **用戶引導**：Onboarding 流程和個人化設定
- **AI 食物識別**：基於 Gemini API 的圖像識別
- **手動輸入**：完整的營養資料輸入功能
- **營養追蹤**：即時營養數據計算和顯示
- **歷史記錄**：飲食記錄查看和管理
- **數據分析**：營養趨勢分析和建議
- **響應式 UI**：適配不同裝置的界面設計
- **開發工具**：開發階段的便利功能

### 🔄 進行中功能
- **用戶認證**：Google/Apple 登入整合
- **雲端同步**：跨裝置數據同步
- **社群功能**：用戶互動和分享
- **進階分析**：更詳細的健康報告

### 🎯 計劃功能
- **智能提醒**：用餐和飲水提醒
- **食譜建議**：基於營養目標的食譜推薦
- **健康整合**：與 Apple Health/Google Fit 整合
- **專家諮詢**：營養師在線諮詢服務

## 🧪 測試指南

### 多語言功能測試
1. 啟動應用
2. 進入個人資料頁面
3. 點擊語言設定
4. 選擇不同語言（English/繁體中文/简体中文）
5. 確認整個應用界面語言切換

### AI 識別功能測試
1. 點擊首頁 + 按鈕
2. 選擇「AI 智能拍照」
3. 拍攝或選擇食物照片
4. 確認 AI 識別結果和營養分析

### 開發模式測試
1. 確保開發模式開啟
2. 清除應用數據
3. 重新啟動應用
4. 在語言選擇頁面點擊左上角紅色跳過按鈕
5. 確認直接進入主應用

## 🤝 貢獻指南

我們歡迎各種形式的貢獻：

### 報告問題
- 使用 GitHub Issues 報告 Bug
- 提供詳細的重現步驟和螢幕截圖
- 指明作業系統和設備型號

### 功能建議
- 在 Issues 中提出新功能建議
- 描述功能的使用場景和預期效果
- 考慮功能的技術可行性

### 代碼貢獻
1. Fork 此儲存庫
2. 創建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 開啟 Pull Request

### 本地化貢獻
- 幫助翻譯新語言
- 改善現有翻譯品質
- 添加地區特定的功能

## 📄 授權信息

MIT License - 詳見 LICENSE 文件

## 📞 聯絡方式

- **項目維護者**: [您的姓名]
- **Email**: [您的郵箱]
- **GitHub**: [GitHub 用戶名]

## 🙏 致謝

- Google Gemini API 提供 AI 識別服務
- Flutter 團隊提供優秀的開發框架
- 所有貢獻者和測試用戶的支持

---

**Fooda App** - 讓健康飲食變得簡單智能 🌟