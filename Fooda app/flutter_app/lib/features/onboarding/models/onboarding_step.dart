enum OnboardingStep {
  languageSelection,   // 語言選擇頁面
  welcome,              // 歡迎頁面
  login,               // 登入/註冊
  bodyData,            // 身體資料設置
  calorieGoal,         // 卡路里目標設置
  complete             // 完成
}

class OnboardingData {
  String? selectedLanguage;  // 新增：選擇的語言
  double? height;
  double? weight;
  int? age;
  String? gender;
  String? activityLevel;
  int? calorieGoal;
  bool? useAIGoal;
  
  OnboardingData({
    this.selectedLanguage,
    this.height,
    this.weight,
    this.age,
    this.gender,
    this.activityLevel,
    this.calorieGoal,
    this.useAIGoal,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'selectedLanguage': selectedLanguage,
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'calorieGoal': calorieGoal,
      'useAIGoal': useAIGoal,
    };
  }
  
  factory OnboardingData.fromJson(Map<String, dynamic> json) {
    return OnboardingData(
      selectedLanguage: json['selectedLanguage'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      age: json['age'],
      gender: json['gender'],
      activityLevel: json['activityLevel'],
      calorieGoal: json['calorieGoal'],
      useAIGoal: json['useAIGoal'],
    );
  }
}