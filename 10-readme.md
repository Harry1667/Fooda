# Fooda - AI 智能卡路里追蹤應用

## 📱 項目概述

Fooda 是一個現代化的智能卡路里追蹤應用，本文件提供詳細的**程式碼導航指南**，列出所有用戶介面 (UI) 和關鍵按鈕的檔案位置。

> **Flutter 專案路徑**: `Fooda app/flutter_app/lib/`

---

## 🏗️ 核心導航架構 (Navigation)

應用的主要骨架，包含底部導航列和頁面路由邏輯。

### 🧭 主導航頁面 (Main Shell)
*   **檔案位置**: [MainNavigationScreen](Fooda%20app/flutter_app/lib/features/main_navigation/main_navigation_screen.dart)
*   **功能**: 管理底部導航欄切換，承載 4 個主要分頁。
*   **關鍵按鈕**:
    *   **底部導航欄 (Bottom Navigation Bar)**:
        *   🏠 **首頁**: 切換至 [HomeScreen](Fooda%20app/flutter_app/lib/features/home/home_screen.dart)
        *   📅 **歷史**: 切換至 [HistoryScreen](Fooda%20app/flutter_app/lib/features/history/history_screen.dart)
        *   📊 **分析**: 切換至 [AnalysisScreen](Fooda%20app/flutter_app/lib/features/analysis/analysis_screen.dart)
        *   � **個人**: 切換至 [ProfileScreen](Fooda%20app/flutter_app/lib/features/profile/profile_screen.dart)
    *   **➕ 添加按鈕 (Floating Action Button)**:
        *   位置: `main_navigation_screen.dart` (Line 173)
        *   動作: 打開底部的 [記錄方式選單 (Modal Bottom Sheet)](Fooda%20app/flutter_app/lib/features/main_navigation/main_navigation_screen.dart#L271)。
    *   **記錄方式選單項目**:
        *   📷 **拍照 (Take Photo)**: 觸發 `_openCamera`，進入 [CameraScreen](Fooda%20app/flutter_app/lib/features/camera/camera_screen.dart)。
        *   🖼️ **相簿 (Gallery)**: 觸發 `_openGallery`，使用 ImagePicker 選圖後進入 AI 分析。
        *   ✏️ **手動輸入 (Manual)**: 進入 [ManualInputScreen](Fooda%20app/flutter_app/lib/features/manual_input/manual_input_screen.dart)。

---

## 🚀 引導流程 (Onboarding)

用戶首次安裝應用時的體驗流程。

### 1. 啟動畫面 (Splash)
*   **檔案位置**: [SplashScreen](Fooda%20app/flutter_app/lib/features/splash/splash_screen.dart)
*   **功能**: 應用初始化，檢查登入狀態。

### 2. 歡迎登入頁 (Welcome)
*   **檔案位置**: [WelcomeLoginScreen](Fooda%20app/flutter_app/lib/features/onboarding/welcome_login_screen.dart)
*   **功能**: 顯示 "Let's Go" 按鈕，開始引導流程。
*   **按鈕**:
    *   **Let's Go**: 導航至 `EnhancedOnboardingScreen`。

### 3. 多步驟引導 (Onboarding Steps)
*   **檔案位置**: [EnhancedOnboardingScreen](Fooda%20app/flutter_app/lib/features/onboarding/enhanced_onboarding_screen.dart)
*   **功能**: 收集用戶基礎資料（性別、體重、目標）。

---


按鈕引導：Fooda app/flutter_app/lib/features/tutorial/tutorial_config.dart
## 🏠 主要功能頁面 (Core Features)

### 1. 首頁 (Home)
*   **檔案位置**: [HomeScreen](Fooda%20app/flutter_app/lib/features/home/home_screen.dart)
*   **功能**: 儀表板，顯示今日營養攝取。
*   **介面元素與按鈕**:
    *   **頂部標題列 (Header)**:
        *   **🔥 連續打卡 (Streak)**: 左側顯示。
        *   **👑 會員狀態 (Premium Badge)**: 右側按鈕 ([Line 165](Fooda%20app/flutter_app/lib/features/home/home_screen.dart#L165))，點擊進入 [MembershipScreen](Fooda%20app/flutter_app/lib/features/membership/membership_screen.dart)。
    *   **今日營養卡片 (Nutrition Card)**:
        *   顯示圓環圖表和營養素列表 ([Line 248](Fooda%20app/flutter_app/lib/features/home/home_screen.dart#L248))。
    *   **餐點記錄卡片 (MealRecordCard)**:
        *   **檔案位置**: [MealRecordCard](Fooda%20app/flutter_app/lib/core/widgets/meal_record_card.dart)
        *   點擊卡片: 觸發 `edit`，彈出 [EditMealDialog](Fooda%20app/flutter_app/lib/core/widgets/edit_meal_dialog.dart)。

### 2. 歷史頁面 (History)
*   **檔案位置**: [HistoryScreen](Fooda%20app/flutter_app/lib/features/history/history_screen.dart)
*   **功能**: 查看過去的餐點記錄。
*   **互動**:
    *   **日期選擇器 (Date Picker)**: 切換不同日期。
    *   **列表項目**: 點擊編輯餐點。

### 3. 分析頁面 (Analysis)
*   **檔案位置**: [AnalysisScreen](Fooda%20app/flutter_app/lib/features/analysis/analysis_screen.dart)
*   **功能**: 圖表化顯示長期營養趨勢。
    *   **週/月切換按鈕**: 切換分析時間範圍。

### 4. 個人頁面 (Profile)
*   **檔案位置**: [ProfileScreen](Fooda%20app/flutter_app/lib/features/profile/profile_screen.dart)
*   **功能**: 用戶資料管理與設定入口。
*   **按鈕**:
    *   **⚙️ 設定 (Settings)**: 右上角，進入 [SettingsScreen](Fooda%20app/flutter_app/lib/features/settings/settings_screen.dart)。
    *   **💎 管理訂閱**: 進入 [MembershipScreen](Fooda%20app/flutter_app/lib/features/membership/membership_screen.dart)。
    *   **✏️ 編輯資料**: 進入編輯模式。

---

## � 記錄與相機 (Input & Camera)

### 1. 相機介面
*   **檔案位置**: [CameraScreen](Fooda%20app/flutter_app/lib/features/camera/camera_screen.dart)
*   **功能**: 拍照並上傳分析。
*   **按鈕**:
    *   **快門按鈕**: 拍照。
    *   **相簿按鈕**: 從這裡也可以選圖。

### 2. 識別結果頁
*   **檔案位置**: [CameraResultScreen](Fooda%20app/flutter_app/lib/features/camera/camera_result_screen.dart)
*   **功能**: 顯示 AI 分析結果，確認後保存。
*   **按鈕**:
    *   **✅ 保存 (Check)**: 確認並寫入資料庫。
    *   **🔄 重拍**: 重新拍照。

### 3. AI 分析載入頁
*   **檔案位置**: [AiAnalysisScreen](Fooda%20app/flutter_app/lib/features/ai_analysis/ai_analysis_screen.dart)
*   **功能**: 顯示分析進度。

### 4. 手動輸入頁
*   **檔案位置**: [ManualInputScreen](Fooda%20app/flutter_app/lib/features/manual_input/manual_input_screen.dart)
*   **功能**: 傳統表單輸入。
    *   **Web 風格輸入**: [WebStyleManualInputScreen](Fooda%20app/flutter_app/lib/features/manual_input/web_style_manual_input_screen.dart) (目前主要使用)。

---

## ⚙️ 設定與其他 (Settings & Misc)

### 1. 設定頁面
*   **檔案位置**: [SettingsScreen](Fooda%20app/flutter_app/lib/features/settings/settings_screen.dart)
*   **功能**: 主題切換、關於我們、贊助者代碼。
*   **列表項目**:
    *   **備份與還原**: 進入 [BackupRestoreScreen](Fooda%20app/flutter_app/lib/features/settings/backup_restore_screen.dart)。
    *   **隱私政策/使用條款**: 進入 [LegalDocumentScreen](Fooda%20app/flutter_app/lib/features/settings/legal_document_screen.dart)。

### 2. 會員訂閱頁
*   **檔案位置**: [MembershipScreen](Fooda%20app/flutter_app/lib/features/membership/membership_screen.dart)
*   **功能**: 顯示方案比較、購買 Premium。
*   **按鈕**:
    *   **升級按鈕**: 觸發 `in_app_purchase` 購買流程。
    *   **恢復購買**: 檢查 Apple ID 訂閱狀態。
    *   **觀看廣告 (Watch Ad)**: 觀看獎勵廣告以獲得 AI 額度 (+1 Credit)。

---

## 📂 檔案目錄速查

```
lib/
├── features/
│   ├── main_navigation/  # 主導航 (MainNavigationScreen)
│   ├── home/             # 首頁 (HomeScreen)
│   ├── history/          # 歷史 (HistoryScreen)
│   ├── analysis/         # 分析 (AnalysisScreen)
│   ├── profile/          # 個人 (ProfileScreen)
│   ├── onboarding/       # 引導 (Welcome/EnhancedOnboarding)
│   ├── camera/           # 相機 (CameraScreen/Result)
│   ├── manual_input/     # 手動輸入 (ManualInputScreen)
│   ├── membership/       # 會員 (MembershipScreen)
│   └── settings/         # 設定 (SettingsScreen)
└── core/
    ├── service/          # API 與邏輯服務
    └── widgets/          # 通用組件 (MealRecordCard, etc)
```
