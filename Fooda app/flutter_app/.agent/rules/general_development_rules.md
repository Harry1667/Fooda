# 🚀 通用開發規則（General Development Rules）

## 📋 項目基本信息

- **項目語言**：中文（Chinese）
- **主要技術棧**：Flutter (Dart) + PHP
- **開發目標**：先用 PHP + CSS 快速開發，後遷移到 Flutter
- **測試文件命名**：`test_*.php` 或 `test_*.*`

---

## 🎯 核心開發原則

### 1. 語言規範
- ✅ 所有代碼註釋使用中文
- ✅ 所有變量命名使用英文（遵循 camelCase 或 snake_case）
- ✅ 所有文檔使用中文
- ✅ PowerShell 命令使用英文
- ✅ Git commit 訊息使用中文

### 2. 代碼質量
- ✅ 先理解問題，再動手寫代碼
- ✅ 寫通用的解決方案，不要硬編碼
- ✅ 遵循 DRY 原則（Don't Repeat Yourself）
- ✅ 保持函數簡短（<50 行）
- ✅ 使用清晰的命名

### 3. Flutter 兼容性
- ✅ PHP/CSS 開發時考慮 Flutter 遷移
- ✅ 避免使用 PHP 特有的語法
- ✅ UI 設計遵循 Material Design
- ✅ API 使用 RESTful 標準

---

## 📝 命名規範

### 文件命名（Dart/Flutter）
```dart
// ✅ 正確：使用 snake_case
user_profile_screen.dart
api_service.dart
meal_model.dart

// ❌ 錯誤
UserProfileScreen.dart  // 不要使用 PascalCase
user-profile-screen.dart  // 不要使用 kebab-case
```

### 類命名（Dart/Flutter）
```dart
// ✅ 正確：使用 PascalCase
class UserProfile { }
class ApiService { }
class MealModel { }
```

### 變量命名（Dart/Flutter）
```dart
// ✅ 正確：使用 camelCase
String userName;
int userAge;
bool isActive;
```

---

## 💡 最佳實踐

### 1. 錯誤處理
```dart
// ✅ 完整的錯誤處理
try {
  final result = await apiService.fetchData();
  return result;
} catch (e) {
  print('❌ 錯誤：$e');
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('操作失敗：$e')),
    );
  }
  return null;
}
```

### 2. Async 操作
```dart
// ✅ 檢查 context 有效性
Future<void> loadData() async {
  final data = await fetchData();
  if (mounted) {
    setState(() {
      _data = data;
    });
  }
}
```

### 3. 日誌輸出
```dart
// ✅ 使用表情符號前綴
print('🚀 應用啟動');
print('✅ 數據載入成功');
print('❌ 錯誤：$e');
print('🔧 調試信息：$data');
print('🎯 用戶動作：點擊按鈕');
```

---

## 🔄 Git 工作流程

### Commit 訊息規範
```
✅ feat: 添加用戶登入功能
✅ fix: 修復圖片上傳問題
✅ docs: 更新 README 文檔
✅ style: 格式化代碼
✅ refactor: 重構 API 服務
✅ test: 添加單元測試
```

---

## ✅ Code Review 檢查清單

提交代碼前檢查：
- [ ] 沒有 lint 錯誤和警告
- [ ] 所有變量都有明確的類型
- [ ] 沒有未使用的導入
- [ ] 功能正常工作
- [ ] 錯誤處理完善
- [ ] 代碼註釋清晰

---

**遵循這些規則，寫出高質量、可維護的代碼！** 🚀
