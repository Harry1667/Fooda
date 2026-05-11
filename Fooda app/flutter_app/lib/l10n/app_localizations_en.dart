// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Fooda';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get done => 'Done';

  @override
  String get skip => 'Skip';

  @override
  String get continueText => 'Continue';

  @override
  String get navHome => 'Home';

  @override
  String get navHistory => 'History';

  @override
  String get navAnalysis => 'Analysis';

  @override
  String get navProfile => 'Profile';

  @override
  String get todayNutrition => 'Today\'s Nutrition';

  @override
  String get calorieGoal => 'Calorie Goal';

  @override
  String get calories => 'Calories';

  @override
  String get carbs => 'Carbohydrates';

  @override
  String get protein => 'Protein';

  @override
  String get fat => 'Fat';

  @override
  String get sodium => 'Sodium';

  @override
  String get sugar => 'Sugar';

  @override
  String get fiber => 'Dietary Fiber';

  @override
  String get kcal => 'kcal';

  @override
  String get gram => 'g';

  @override
  String get milligram => 'mg';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get lunch => 'Lunch';

  @override
  String get dinner => 'Dinner';

  @override
  String get snack => 'Snack';

  @override
  String get addRecord => 'Add Record';

  @override
  String get takePhoto => 'Take Photo Recognition';

  @override
  String get uploadPhoto => 'Upload Photo Recognition';

  @override
  String get manualInput => 'Manual Input';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get currentLanguage => 'Current Language';

  @override
  String get theme => 'Theme';

  @override
  String get notifications => 'Notifications';

  @override
  String get aboutApp => 'About App';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get loginWithApple => 'Login with Apple';

  @override
  String get english => 'English';

  @override
  String get traditionalChinese => 'Traditional Chinese';

  @override
  String get simplifiedChinese => 'Simplified Chinese';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get age => 'Age';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'male';

  @override
  String get female => 'female';

  @override
  String get activityLevel => 'Activity Level';

  @override
  String get nutritionGoals => 'Nutrition Goals';

  @override
  String get activitySedentary => 'Sedentary';

  @override
  String get activitySedentaryDesc =>
      'Office work, little exercise\nLess than 1 workout per week';

  @override
  String get activitySedentaryExamples => 'Office work, watching TV, reading';

  @override
  String get activityLight => 'Light Activity';

  @override
  String get activityLightDesc =>
      'Occasional walking or light exercise\n1-3 workouts per week';

  @override
  String get activityLightExamples =>
      'Walking, light yoga, household activities';

  @override
  String get activityModerate => 'Moderate Activity';

  @override
  String get activityModerateDesc =>
      'Regular exercise habit\n3-5 workouts per week';

  @override
  String get activityModerateExamples => 'Running, swimming, cycling, gym';

  @override
  String get activityHigh => 'High Activity';

  @override
  String get activityHighDesc => 'Daily exercise\nHigh intensity workouts';

  @override
  String get activityHighExamples =>
      'Daily running, weight training, competitive sports';

  @override
  String get activityExtreme => 'Extreme Activity';

  @override
  String get activityExtremeDesc =>
      'Professional athlete level\nHigh intensity training';

  @override
  String get activityExtremeExamples =>
      'Professional athletes, marathon runners';

  @override
  String get activityLevelUpdated => 'Activity level updated';

  @override
  String get january => 'January';

  @override
  String get february => 'February';

  @override
  String get march => 'March';

  @override
  String get april => 'April';

  @override
  String get may => 'May';

  @override
  String get june => 'June';

  @override
  String get july => 'July';

  @override
  String get august => 'August';

  @override
  String get september => 'September';

  @override
  String get october => 'October';

  @override
  String get november => 'November';

  @override
  String get december => 'December';

  @override
  String get jan => 'Jan';

  @override
  String get feb => 'Feb';

  @override
  String get mar => 'Mar';

  @override
  String get apr => 'Apr';

  @override
  String get may_short => 'May';

  @override
  String get jun => 'Jun';

  @override
  String get jul => 'Jul';

  @override
  String get aug => 'Aug';

  @override
  String get sep => 'Sep';

  @override
  String get oct => 'Oct';

  @override
  String get nov => 'Nov';

  @override
  String get dec => 'Dec';

  @override
  String get year => 'Year';

  @override
  String get startRecordingMeals => 'Start Recording Meals';

  @override
  String startRecordingMessage(Object period) {
    return 'No meal records for this $period yet. Personalized analysis will be shown after you start recording.';
  }

  @override
  String get dataCollecting => 'Data Collecting';

  @override
  String dataCollectingMessage(Object days) {
    return 'Currently have $days days of record data. Continue recording more days for more accurate nutrition analysis.';
  }

  @override
  String insufficientCalories(Object period) {
    return '$period Calorie Intake Insufficient';
  }

  @override
  String excessiveCalories(Object period) {
    return '$period Calorie Intake Excessive';
  }

  @override
  String appropriateCalories(Object period) {
    return '$period Calorie Intake Appropriate';
  }

  @override
  String appropriateCaloriesMessage(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix, within your personal recommended range. Keep up the balanced diet!';
  }

  @override
  String get proteinInsufficient => 'Protein Intake Insufficient';

  @override
  String get proteinSufficient => 'Protein Intake Sufficient';

  @override
  String get proteinSufficientMessage =>
      'Your protein intake is sufficient, which helps muscle maintenance and repair.';

  @override
  String get carbsInsufficient => 'Carbohydrate Intake Insufficient';

  @override
  String get carbsExcessive => 'Carbohydrate Intake Excessive';

  @override
  String get fatExcessive => 'Fat Intake Excessive';

  @override
  String get sodiumExcessive => 'Sodium Intake Excessive';

  @override
  String get fiberInsufficient => 'Dietary Fiber Intake Insufficient';

  @override
  String get weightUnderweight => 'Underweight Attention Required';

  @override
  String get weightControl => 'Weight Control Recommendation';

  @override
  String get today => 'Today';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get current => 'current';

  @override
  String get analysisBasedOn =>
      'Analysis will be based on your personal profile';

  @override
  String get basedOnData => 'Based on existing';

  @override
  String get daysData => 'days data for preliminary analysis';

  @override
  String get basedOnProfile => 'Based on your';

  @override
  String get daysActualRecord => 'days actual record';

  @override
  String get basedOnDays => 'Based on';

  @override
  String get meetsRecommended => 'meets your personal recommended value';

  @override
  String get kcalPerDay => 'kcal/day';

  @override
  String get recommendedIntake => 'Recommended intake';

  @override
  String get day => 'day';

  @override
  String get basedOnWeight => 'based on';

  @override
  String get weightAnd => 'kg weight and';

  @override
  String get currentIntake => 'Current intake';

  @override
  String get recommended => 'Recommended';

  @override
  String get basedOnHighActivity => 'based on high activity level';

  @override
  String get basedOn => 'based on';

  @override
  String get basedOnAge => 'based on';

  @override
  String get ageYears => 'years old';

  @override
  String get welcomeTitle => 'Welcome to CalHub';

  @override
  String get welcomeSubtitle => 'Your AI Nutrition Companion';

  @override
  String get getStarted => 'Get Started';

  @override
  String get languageSelectionTitle => 'Choose Your Language';

  @override
  String get languageSelectionSubtitle => 'Select your preferred language';

  @override
  String get bodyDataTitle => 'Body Information';

  @override
  String get bodyDataSubtitle => 'Help us personalize your nutrition goals';

  @override
  String get enterHeight => 'Enter your height';

  @override
  String get enterWeight => 'Enter your weight';

  @override
  String get enterAge => 'Enter your age';

  @override
  String get selectGender => 'Select Gender';

  @override
  String get selectActivityLevel => 'Select your activity level';

  @override
  String get calorieGoalTitle => 'Calorie Goal';

  @override
  String get calorieGoalSubtitle => 'Set your daily calorie target';

  @override
  String recommendedCalories(int calories) {
    return 'Recommended Calories';
  }

  @override
  String get useAIRecommendation =>
      'Do you want to use AI to automatically analyze food content and nutrients?';

  @override
  String get customGoal => 'Custom Goal';

  @override
  String get tutorialTitle => 'App Tutorial';

  @override
  String get tutorialSkip => 'Skip Tutorial';

  @override
  String get tutorialComplete => 'Complete Tutorial';

  @override
  String get homeButtonTitle => 'Home Button';

  @override
  String get homeButtonDesc =>
      'Click here to return to main page\nView today\'s nutrition intake\nThis is your nutrition recording center';

  @override
  String get historyButtonTitle => 'History Button';

  @override
  String get historyButtonDesc =>
      'Click to view diet history\nAnalyze your nutrition trends\nTrack long-term health data changes';

  @override
  String get analysisButtonTitle => 'Analysis Button';

  @override
  String get analysisButtonDesc =>
      'Click for detailed nutrition analysis\nGet professional dietary advice\nUnderstand your overall health status';

  @override
  String get profileButtonTitle => 'Profile Button';

  @override
  String get profileButtonDesc =>
      'Click to manage personal information\nSet health goals and preferences\nAdjust nutrition plan settings';

  @override
  String get addButtonTitle => 'Add Record Button';

  @override
  String get addButtonDesc =>
      'Click to add new nutrition record\nThis is the core function entry\nStart tracking your meals';

  @override
  String get cameraButtonTitle => 'Camera Button';

  @override
  String get cameraButtonDesc =>
      'Take food photos\nAI automatically recognizes nutrition\nFastest recording method';

  @override
  String get uploadButtonTitle => 'Upload Button';

  @override
  String get uploadButtonDesc =>
      'Upload existing food photos\nAI analysis of nutrition content\nPerfect for existing photos';

  @override
  String get manualButtonTitle => 'Manual Input Button';

  @override
  String get manualButtonDesc =>
      'Manually enter food information\nMost accurate recording method\nComplete control over data';

  @override
  String get pleaseSelectLanguage => 'Please select a language';

  @override
  String get languageChanged => 'Language changed successfully';

  @override
  String get restartRequired =>
      'Please restart the app to apply language changes';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get noRecordsYet => 'No meal records yet';

  @override
  String get noRecordsForDate => 'No meal records for this date';

  @override
  String get clickAddToStart => 'Click the + button below to start recording';

  @override
  String get mealRecords => 'Meal Records';

  @override
  String get noAnalysisData => 'No Analysis Data';

  @override
  String get startRecordingHint =>
      'Start recording meals to see personalized analysis suggestions';

  @override
  String get mealName => 'Meal Name';

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get morningSnack => 'Morning Snack';

  @override
  String get afternoonSnack => 'Afternoon Snack';

  @override
  String get eveningSnack => 'Evening Snack';

  @override
  String get homeCooked => 'Home Cooked';

  @override
  String get diningOut => 'Dining Out';

  @override
  String get takeout => 'Takeout';

  @override
  String get dessert => 'Dessert';

  @override
  String get beverage => 'Beverage';

  @override
  String get aiRecognitionFailed => 'AI recognition failed';

  @override
  String get badges => 'Badges';

  @override
  String get badgesPage => 'Badges Page';

  @override
  String get membership => 'Membership';

  @override
  String get membershipPage => 'Membership Page';

  @override
  String get loginPage => 'Login Page';

  @override
  String get resetApp => 'Reset App';

  @override
  String get resetAppConfirm => 'Are you sure you want to reset the app?';

  @override
  String get resetAppDesc => 'Clear all data and start fresh';

  @override
  String get skipOnboarding => 'Skip Onboarding';

  @override
  String get developmentMode => 'Development Mode';

  @override
  String get carbohydrates => 'Carbohydrates';

  @override
  String get dietaryFiber => 'Dietary Fiber';

  @override
  String get days => 'days';

  @override
  String get nutritionOverview => 'Nutrition Overview';

  @override
  String get editMeal => 'Edit Meal';

  @override
  String get deleteMeal => 'Delete Meal';

  @override
  String get mealEditedSuccessfully => 'Meal edited successfully';

  @override
  String get mealDeletedSuccessfully => 'Meal deleted successfully';

  @override
  String get areYouSureDeleteMeal =>
      'Are you sure you want to delete this meal?';

  @override
  String get foodItems => 'food items';

  @override
  String get addFoodItem => 'Add Food Item';

  @override
  String get foodName => 'Food Name';

  @override
  String get quantity => 'Quantity';

  @override
  String get unit => 'Unit';

  @override
  String get grams => 'grams';

  @override
  String get pieces => 'pieces';

  @override
  String get cups => 'cups';

  @override
  String get tablespoons => 'tablespoons';

  @override
  String get teaspoons => 'teaspoons';

  @override
  String get ounces => 'ounces';

  @override
  String get pounds => 'pounds';

  @override
  String get kilograms => 'kilograms';

  @override
  String get milliliters => 'milliliters';

  @override
  String get liters => 'liters';

  @override
  String get servings => 'servings';

  @override
  String get slices => 'slices';

  @override
  String get total => 'Total';

  @override
  String get per100g => 'Per 100g';

  @override
  String get nutritionFacts => 'Nutrition Facts';

  @override
  String get enterFoodName => 'Enter food name';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get selectUnit => 'Select unit';

  @override
  String get addToMeal => 'Add to Meal';

  @override
  String get updateMeal => 'Update Meal';

  @override
  String get noFoodItemsAdded => 'No food items added';

  @override
  String get tapToAddFood => 'Tap + to add food items';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get pleaseEnterFoodName => 'Please enter a food name';

  @override
  String get searchFood => 'Search food';

  @override
  String get recentFoods => 'Recent Foods';

  @override
  String get commonFoods => 'Common Foods';

  @override
  String get carbsHighTitle => 'High Carbohydrate Ratio';

  @override
  String get carbsHighMessage =>
      'Consider reducing refined starch intake and increasing protein and healthy fat proportions.';

  @override
  String get proteinLowTitle => 'Protein Intake Too Low';

  @override
  String get proteinLowMessage =>
      'Consider increasing quality protein intake such as fish, chicken, tofu, etc.';

  @override
  String get fatHighTitle => 'High Fat Intake';

  @override
  String get fatHighMessage =>
      'Consider reducing fried foods and choosing healthy fat sources like nuts and fish oil.';

  @override
  String get sodiumHighTitle => 'Excessive Sodium Intake';

  @override
  String get sodiumHighTodayMessage =>
      'Today\'s sodium intake is too high. Consider reducing processed foods and seasonings.';

  @override
  String get fiberLowTitle => 'Insufficient Dietary Fiber';

  @override
  String get fiberLowTodayMessage =>
      'Today\'s dietary fiber intake is insufficient. Consider eating more vegetables, fruits, and whole grains.';

  @override
  String get noRecords => 'No Records';

  @override
  String get smartSuggestion => 'Smart Suggestions';

  @override
  String get setupComplete => 'Setup Complete!';

  @override
  String get welcomeToFooda => 'Welcome to CalHub!';

  @override
  String get errorOccurred => 'An error occurred, please restart the app';

  @override
  String get aiRecognition => 'AI Recognition';

  @override
  String get aiRecognitionDesc =>
      'Automatically identify food and nutrition by taking photos';

  @override
  String get nutritionAnalysis => 'Nutrition Analysis';

  @override
  String get nutritionAnalysisDesc =>
      'Detailed nutritional analysis and health recommendations';

  @override
  String get cloudSync => 'Cloud Sync';

  @override
  String get cloudSyncDesc => 'Secure data backup and multi-device sync';

  @override
  String get caloriesLowTitle => 'Calorie Intake Too Low';

  @override
  String get caloriesLowMessage =>
      'Today\'s calorie intake is below recommended. Consider increasing nutrient-dense foods.';

  @override
  String get caloriesHighTitle => 'Calorie Intake Too High';

  @override
  String get caloriesHighMessage =>
      'Today\'s calorie intake exceeds recommended. Consider controlling portion sizes and choosing lower calorie foods.';

  @override
  String get caloriesGoodTitle => 'Appropriate Calorie Intake';

  @override
  String get caloriesGoodMessage =>
      'Today\'s calorie intake is within reasonable range. Keep up the balanced diet.';

  @override
  String get avgCaloriesLow => 'Average Calories Too Low';

  @override
  String get avgCaloriesHigh => 'Average Calories Too High';

  @override
  String get caloriesControlGood => 'Good Calorie Control';

  @override
  String get avgDailyIntake => 'Average daily intake';

  @override
  String get belowRecommended => 'below recommended';

  @override
  String get exceedsRecommended => 'exceeds recommended';

  @override
  String get increaseNutrientDenseFoods =>
      'Consider increasing nutrient-dense foods';

  @override
  String get controlPortions =>
      'Consider controlling portion sizes and choices';

  @override
  String get withinRange => 'within reasonable range';

  @override
  String get keepItUp => 'Keep it up';

  @override
  String get avgDailySodiumIntake => 'Average daily sodium intake';

  @override
  String get chooseLowSodiumFoods => 'Consider choosing low-sodium foods';

  @override
  String get avgDailyFiberIntake => 'Average daily fiber intake';

  @override
  String get increaseVegetableFruit =>
      'Consider increasing vegetable and fruit intake';

  @override
  String get yearsOld => 'years old';

  @override
  String get currentWeight => 'Current Weight';

  @override
  String get editAge => 'Edit Age';

  @override
  String get editHeight => 'Edit Height';

  @override
  String get editWeight => 'Edit Weight';

  @override
  String get ageUpdated => 'Age updated';

  @override
  String get heightUpdated => 'Height updated';

  @override
  String get weightUpdated => 'Weight updated';

  @override
  String get genderUpdated => 'Gender updated';

  @override
  String get mealReminders => 'Meal Reminders';

  @override
  String get breakfastReminder => 'Breakfast Reminder';

  @override
  String get lunchReminder => 'Lunch Reminder';

  @override
  String get dinnerReminder => 'Dinner Reminder';

  @override
  String get breakfastReminderTime => 'Breakfast Reminder Time';

  @override
  String get lunchReminderTime => 'Lunch Reminder Time';

  @override
  String get dinnerReminderTime => 'Dinner Reminder Time';

  @override
  String get breakfastTimeUpdated => 'Breakfast reminder time updated';

  @override
  String get lunchTimeUpdated => 'Lunch reminder time updated';

  @override
  String get dinnerTimeUpdated => 'Dinner reminder time updated';

  @override
  String get breakfastReminderBody =>
      'Time for breakfast! Maintain balanced nutrition!';

  @override
  String get lunchReminderBody =>
      'Lunch time! Remember to include protein and vegetables!';

  @override
  String get dinnerReminderBody =>
      'Dinner time! Control total calories for better health!';

  @override
  String get lateNight => 'Late Night';

  @override
  String get afternoonTea => 'Afternoon Tea';

  @override
  String get manualInputMeal => 'Manual Input Meal';

  @override
  String get mealType => 'Meal Type';

  @override
  String get mealTags => 'Meal Tags';

  @override
  String get notes => 'Notes';

  @override
  String get mealNameHint => 'e.g.: Grilled Chicken Salad';

  @override
  String get loginToYourAccount => 'Login to Your Account';

  @override
  String get loginDataSecurityDescription =>
      'Your data will be securely backed up to the cloud after login';

  @override
  String get signInWithApple => 'Sign in with Apple';

  @override
  String get signInWithGoogle => 'Sign in with Google';

  @override
  String get or => 'or';

  @override
  String get skipLoginLater => 'Skip, Login Later';

  @override
  String get loginAgreementText =>
      'By logging in, you agree to our Terms of Service and Privacy Policy';

  @override
  String get appleLoginSuccess => 'Apple login successful!';

  @override
  String get loginFailed => 'Login failed';

  @override
  String get simulatorNotSupported =>
      'Simulator doesn\'t support Apple Sign-In, please test on real device or click \"Skip\"';

  @override
  String get appleLoginFailed => 'Apple login failed';

  @override
  String get welcome => 'Welcome';

  @override
  String get loginCancelled => 'Login cancelled';

  @override
  String get googleLoginFailed => 'Google login failed';

  @override
  String get networkError =>
      'Network connection error, please check network settings';

  @override
  String get googleLoginRetry => 'Google login failed, please try again later';

  @override
  String get validHeightError => 'Please enter a valid height';

  @override
  String get validWeightError => 'Please enter a valid weight';

  @override
  String get validAgeError => 'Please enter a valid age';

  @override
  String get sedentary => 'Sedentary';

  @override
  String get sedentaryDesc =>
      'Office worker, little exercise\\nLess than 1 workout per week';

  @override
  String get sedentaryExamples => 'Sitting at desk, watching TV, reading';

  @override
  String get lightActivity => 'Light Activity';

  @override
  String get lightActivityDesc =>
      'Occasional walking or light exercise\\n1-3 workouts per week';

  @override
  String get lightActivityExamples =>
      'Walking, light yoga, household activities';

  @override
  String get moderateActivity => 'Moderate Activity';

  @override
  String get moderateActivityDesc =>
      'Regular exercise habits\\n3-5 workouts per week';

  @override
  String get moderateActivityExamples => 'Running, swimming, cycling, gym';

  @override
  String get highActivity => 'High Activity';

  @override
  String get highActivityDesc => 'Daily exercise\\nHigher intensity workouts';

  @override
  String get highActivityExamples =>
      'Daily running, weight training, competitive sports';

  @override
  String get veryHighActivity => 'Very High Activity';

  @override
  String get veryHighActivityDesc =>
      'Professional athlete level\\nHigh intensity training';

  @override
  String get veryHighActivityExamples =>
      'Professional athletes, marathon runners';

  @override
  String get setCalorieGoal => 'Set Your Calorie Goal';

  @override
  String get calorieCalculationDescription =>
      'We\'ve calculated personalized calorie needs based on your body data';

  @override
  String get aiSmartRecommendation => 'AI Smart Recommendation';

  @override
  String get caloriesPerDay => 'Calories/Day';

  @override
  String get selectMonth => 'Select Month';

  @override
  String get editMealRecord => 'Edit Meal Record';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get confirmDeleteMessage =>
      'Are you sure you want to delete this meal record? This action cannot be undone.';

  @override
  String get recordUpdated => 'Meal record updated';

  @override
  String get recordDeleted => 'Meal record deleted';

  @override
  String dateFormat(Object day, Object month, Object year) {
    return '$month/$day/$year';
  }

  @override
  String monthYearFormat(Object month, Object year) {
    return '$month $year';
  }

  @override
  String get appSettings => 'App Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get about => 'About';

  @override
  String get appVersion => 'App Version';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get followSystem => 'Follow System';

  @override
  String get aiAutoRecognition => 'AI automatically identifies food nutrition';

  @override
  String get selectPhotoFromAlbum => 'Select photos from album for recognition';

  @override
  String get manualInputWithAI =>
      'Manual input nutrition info with AI assistance';

  @override
  String get resetAppWarning =>
      'This will clear all local data including:\\n\\n• All meal records\\n• Personal profile settings\\n• Nutrition goals\\n• App preferences\\n\\nThis action cannot be undone. Are you sure you want to continue?';

  @override
  String get reset => 'Reset';

  @override
  String get appResetSuccess => 'App reset successfully';

  @override
  String get appResetError => 'Reset failed';

  @override
  String get basicSettings => 'Basic Settings';

  @override
  String get themeSettings => 'Theme Settings';

  @override
  String get developerOptions => 'Developer Options';

  @override
  String get aiProcessing => 'AI is processing...';

  @override
  String get recognitionFailedRetry => 'Recognition failed, please retry';

  @override
  String get cameraError => 'Camera error';

  @override
  String get albumError => 'Album selection failed';

  @override
  String get example => 'e.g.';

  @override
  String get calculatedFromBodyData => 'Calculated from your body data';

  @override
  String get setPersonalGoal => 'Set your personalized goal';

  @override
  String get basalMetabolicRate => 'Basal Metabolic Rate (BMR)';

  @override
  String get recommendedDailyIntake => 'Recommended Daily Intake';

  @override
  String get cal => 'cal';

  @override
  String get intelligentCalcFromBodyData =>
      'Intelligently calculated from your body data';

  @override
  String get manualSetting => 'Manual Setting';

  @override
  String get inputDailyCalorieGoal => 'Enter your daily calorie goal';

  @override
  String get dailyCalorieGoal => 'Daily Calorie Goal';

  @override
  String get enterDailyCalorieGoal => 'Enter daily calorie goal';

  @override
  String get kindTip => 'Tip';

  @override
  String get calorieGoalTip =>
      'You can adjust your calorie goal anytime in settings. We recommend adjusting based on your actual situation for optimal health results.';

  @override
  String get startExperience => 'Start Experience';

  @override
  String get selectSettingMethod => 'Select Setting Method';

  @override
  String get loginSyncedData => 'Login synced data';

  @override
  String get dataSyncedToCloud => 'Data synced to cloud';

  @override
  String get loginToBackupData => 'Login to backup data';

  @override
  String get protectRecordsCrossDevice =>
      'Protect your diet records and sync across devices';

  @override
  String get proteinGoodTitle => 'Adequate Protein Intake';

  @override
  String get proteinGoodMessage =>
      'Good protein intake helps with muscle synthesis and repair.';

  @override
  String get carbsLowTitle => 'Carbohydrates Too Low';

  @override
  String get carbsLowMessage =>
      'Consider moderately increasing healthy carb sources like whole grains and fruits.';

  @override
  String get skipFailed => 'Skip failed';

  @override
  String get saveSettingsError => 'Error saving settings';

  @override
  String get appDescription =>
      'Smart food tracking, healthy living starts here';

  @override
  String get tellUsYourBodyData => 'Tell us your body data';

  @override
  String get bodyDataDescription =>
      'This information will help us calculate more accurate nutritional needs for you';

  @override
  String get enterMealName => 'Enter meal name';

  @override
  String get aiAnalysisComplete => 'AI analysis complete';

  @override
  String get recognitionResults => 'Recognition Results';

  @override
  String get notesHint => 'You can fill in taste, source, etc.';

  @override
  String get aiRecognitionSuccess => 'AI recognition successful';

  @override
  String get recognizedItems => 'Recognized';

  @override
  String get unknownError => 'Unknown error';

  @override
  String get analysisFailed => 'Analysis failed';

  @override
  String get mealSavedSuccessfully => 'Meal saved successfully';

  @override
  String get saveFailed => 'Save failed';

  @override
  String get legalDocuments => 'Legal Documents';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get records => 'records';

  @override
  String get aiAutoAnalyze => 'AI automatically identifies food nutrition';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get chooseFromGallerySubtitle =>
      'Select photos from album for recognition';

  @override
  String get manualInputSubtitle =>
      'Manual input nutrition info with AI assistance';

  @override
  String get photoAndRecognition => 'Photo & Recognition';

  @override
  String get nutrientsOptional => 'Nutrients (Optional)';

  @override
  String get aiAnalyzing => 'AI is analyzing food...';

  @override
  String get yesUseAI => 'Yes, use AI';

  @override
  String get noManualInput => 'No, fill in manually';

  @override
  String get galleryError => 'Gallery selection error';

  @override
  String get tutorialStep1Title => 'Home';

  @override
  String get tutorialStep1Desc => 'This is where you view today\'s intake.';

  @override
  String get tutorialStep2Title => 'Nutrition Stats';

  @override
  String get tutorialStep2Desc => 'View your daily nutrition breakdown here.';

  @override
  String get tutorialStep3Title => 'Meal Records';

  @override
  String get tutorialStep3Desc => 'See your recent meal records here.';

  @override
  String get tutorialStep4Title => 'History';

  @override
  String get tutorialStep4Desc => 'View detailed records from past dates.';

  @override
  String get tutorialStep5Title => 'Analysis';

  @override
  String get tutorialStep5Desc => 'View long-term nutrition trends.';

  @override
  String get tutorialStep6Title => 'Profile';

  @override
  String get tutorialStep6Desc => 'Manage your profile and settings.';

  @override
  String get tutorialStep7Title => 'Add Button';

  @override
  String get tutorialStep7Desc => 'Tap here to add a new meal record.';

  @override
  String get tutorialStep8Title => 'Camera';

  @override
  String get tutorialStep8Desc => 'Take a photo to add a meal record.';

  @override
  String get tutorialStep9Title => 'Gallery';

  @override
  String get tutorialStep9Desc => 'Select from gallery to add a meal record.';

  @override
  String get tutorialStep10Title => 'Manual Input';

  @override
  String get tutorialStep10Desc => 'Manually enter meal details.';

  @override
  String get tutorialStep11Title => 'Start Recording';

  @override
  String get tutorialStep11Desc =>
      'Tap the gallery button to start your first record.';

  @override
  String get tutorialStep12Title => 'Record Display';

  @override
  String get tutorialStep12Desc => 'Here is the meal you just recorded.';

  @override
  String get tutorialStep13Title => 'Tutorial Complete';

  @override
  String get tutorialStep13Desc =>
      'Congratulations on completing the tutorial! You can now start using CalHub.';

  @override
  String get backupAndRestore => 'Backup & Restore';

  @override
  String get backupData => 'Backup Data';

  @override
  String get restoreData => 'Restore Data';

  @override
  String get backupDesc =>
      'Export your data to a file and save it to cloud or share it.';

  @override
  String get restoreDesc =>
      'Import data from a backup file. This will overwrite current data.';

  @override
  String get backupSuccess => 'Backup successful';

  @override
  String get restoreSuccess => 'Data restored successfully';

  @override
  String get backupFailed => 'Backup failed';

  @override
  String get restoreFailed => 'Failed to restore data';

  @override
  String get creatingBackup => 'Creating backup...';

  @override
  String get restoringData => 'Restoring data...';

  @override
  String get restoreConfirmTitle => 'Confirm Restore';

  @override
  String get restoreConfirmMessage =>
      'Restoring will overwrite all your current data and cannot be undone. Are you sure you want to continue?';

  @override
  String get dataManagement => 'Data Management';

  @override
  String get signOut => 'Sign Out';

  @override
  String loggedInAs(Object name) {
    return 'Logged in as: $name';
  }

  @override
  String get syncWithICloud => 'Sync with iCloud';

  @override
  String get uploadToCloud => 'Upload to iCloud';

  @override
  String get downloadFromCloud => 'Download from iCloud';

  @override
  String get cloudSyncSuccess => 'Cloud sync successful';

  @override
  String get cloudSyncFailed => 'Cloud sync failed';

  @override
  String get startFresh => 'Start Fresh';

  @override
  String get noBackupFound => 'No backup found in iCloud';

  @override
  String get nickname => 'Nickname';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get quotaExceeded => 'Monthly Free Quota Exceeded';

  @override
  String get quotaExceededDesc =>
      'Free version allows up to 10 AI recognitions per month. Quota resets on the 1st of each month. Upgrade to Premium for unlimited access.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get paymentServiceUnavailable =>
      'Payment service unavailable, please check network connection';

  @override
  String loadFailed(Object error) {
    return 'Load failed: $error';
  }

  @override
  String get restorePremiumSuccess =>
      '✅ Successfully restored Premium membership!';

  @override
  String get welcomePremium => '✅ Welcome to Fooda Premium!';

  @override
  String errorMessage(Object message) {
    return '❌ $message';
  }

  @override
  String get noSubscriptionFound => '⚠️ No restorable subscription found';

  @override
  String restoreFailedError(Object error) {
    return 'Restore failed: $error';
  }

  @override
  String get cannotOpenSubscriptionManagement =>
      'Cannot open subscription management page';

  @override
  String get restorePurchase => 'Restore Purchase';

  @override
  String get youArePremium => 'You are a valued Premium member';

  @override
  String get unlockPremium => 'Unlock Fooda Premium';

  @override
  String get enjoyPremiumFeatures =>
      'Enjoy unlimited AI analysis and exclusive features';

  @override
  String get premiumFeaturesSummary => 'Unlimited AI Recognition • Remove Ads';

  @override
  String get viewComparison => 'View detailed feature comparison';

  @override
  String get detailedComparison => 'Detailed Feature Comparison';

  @override
  String get unlimitedAI => 'Unlimited AI Recognition';

  @override
  String get noAds => 'No Ads';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get cancelAnytime => 'Cancel Anytime';

  @override
  String get currentPlanActive => 'Current Plan Active';

  @override
  String daysRemaining(Object days) {
    return 'Expires in $days days';
  }

  @override
  String get manageSubscription => 'Manage Subscription';

  @override
  String get manageSubscriptionHint =>
      'To cancel or change plan, please go to Apple ID settings';

  @override
  String get feature => 'Feature';

  @override
  String get free => 'Free';

  @override
  String get premium => 'Premium';

  @override
  String get tenTimesPerMonth => '10 times/month';

  @override
  String get unlimited => 'Unlimited';

  @override
  String get historyRecord => 'History Record';

  @override
  String get dataExport => 'Data Export';

  @override
  String get advancedAnalysis => 'Advanced Analysis';

  @override
  String get fourteenDays => '14 days';

  @override
  String get purchaseDisclaimer =>
      'Payment will be charged to your Apple ID account at confirmation of purchase.';

  @override
  String get purchaseInitiationFailed => 'Purchase initiation failed';

  @override
  String purchaseFailedError(Object error) {
    return 'Purchase failed: $error';
  }

  @override
  String get aiAnalysisResult => 'AI Analysis Result';

  @override
  String get updateFailedRetry => 'Update failed, please retry';

  @override
  String get perMonth => '/ Month';

  @override
  String get sponsorCode => 'Sponsor Code';

  @override
  String get enterSponsorCode => 'Enter Sponsor Code';

  @override
  String get invalidCode => 'Invalid Code';

  @override
  String get redemptionSuccess => 'Redemption Successful';

  @override
  String get loginWithEmail => 'Login with Email';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get invalidCredentials => 'Invalid email or password';

  @override
  String get appleIdConnected => 'Apple ID Connected';

  @override
  String get signInSuccessful => 'Sign in successful';

  @override
  String signInFailed(String error) {
    return 'Sign in failed: $error';
  }

  @override
  String get signOutConfirmation => 'Are you sure you want to sign out?';

  @override
  String get signedOutSuccessful => 'Signed out successfully';

  @override
  String get enterNickname => 'Enter your nickname';

  @override
  String get freeVersion => 'Free Version';

  @override
  String get unlockedAllFeatures => 'Unlocked all premium features';

  @override
  String get upgradeForUnlimited =>
      'Upgrade to unlock unlimited AI recognition';

  @override
  String get manage => 'Manage';

  @override
  String get upgrade => 'Upgrade';

  @override
  String get localUser => 'Local User';

  @override
  String aiQuota(int count, int total) {
    return 'AI: $count/$total';
  }

  @override
  String get cameraNotReady => 'Camera not ready';

  @override
  String get cameraTip => 'Place food in center, ensure good lighting';

  @override
  String get analysisFailedNoFood =>
      'Analysis failed, please upload a correct food photo';

  @override
  String recordsRecorded(int count) {
    return '$count days recorded';
  }

  @override
  String get watchAdEarnCredits => 'Watch Ad (+1 Credit)';

  @override
  String get watchNow => 'Watch Now';

  @override
  String get loadingAd => 'Loading Ad...';

  @override
  String rewardEarned(int amount) {
    return 'Earned $amount credits!';
  }

  @override
  String get bmiUnderweight => 'Underweight';

  @override
  String get bmiNormal => 'Normal';

  @override
  String get bmiOverweight => 'Overweight';

  @override
  String get bmiObeseMild => 'Mild Obesity';

  @override
  String get bmiObeseModerate => 'Moderate Obesity';

  @override
  String get bmiObeseSevere => 'Severe Obesity';

  @override
  String analysisCaloriesLowUnderweight(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix. With a BMI indicating underweight status, it\'s recommended to increase intake of nutrient-dense foods like nuts, avocados, and whole grains.';
  }

  @override
  String analysisCaloriesLowNormal(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix, which is low and may affect basal metabolism. Consider adding nutrient-rich foods to maintain normal body function.';
  }

  @override
  String analysisCaloriesLowOverweight(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix. Although BMI is higher, insufficient intake may lead to muscle loss. Recommend increasing protein intake while controlling total calories.';
  }

  @override
  String analysisCaloriesHighOverweight(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix. BMI indicates a need for weight control. Recommend reducing refined starches and fried foods while increasing vegetables and protein.';
  }

  @override
  String analysisCaloriesHighNormal(
    Object calories,
    Object daysSuffix,
    Object period,
  ) {
    return 'Your average daily calorie intake for $period is $calories kcal$daysSuffix, exceeding recommendations. Long-term excess may lead to weight gain. Suggest controlling portion sizes and choosing low-calorie, nutrient-dense foods.';
  }

  @override
  String get analysisProteinLowHighActivity =>
      'Your high activity level requires more protein for muscle repair and growth. Recommend including high-quality protein (chicken, fish, legumes) in every meal.';

  @override
  String get analysisProteinLowElderly =>
      'Age 50+ requires more protein to maintain muscle mass. Recommend increasing intake of lean meat, fish, eggs, and other quality proteins.';

  @override
  String get analysisProteinLowGeneral =>
      'Protein is essential for body function. Recommend increasing intake of lean meat, fish, legumes, and quality proteins.';

  @override
  String get analysisCarbsLowHighActivity =>
      'High activity levels require sufficient carbohydrates for energy. Suggest increasing intake of whole grains, fruits, and healthy carbs.';

  @override
  String get analysisCarbsHighLowActivity =>
      'With lower activity levels, recommend reducing refined starches and increasing the ratio of protein and healthy fats.';

  @override
  String get analysisFatHighElderlyFemale =>
      'Females over 50 should be mindful of fat intake. Suggest choosing healthy fat sources like nuts, fish oil, and olive oil.';

  @override
  String get analysisFatHighGeneral =>
      'Suggest reducing fried foods and choosing healthy fats like nuts, fish oil, and olive oil.';

  @override
  String get analysisSodiumHighElderly =>
      'Age 50+ should limit sodium intake to support healthy blood pressure. Suggest reducing processed foods and seasonings.';

  @override
  String get analysisSodiumHighGeneral =>
      'Excessive sodium may affect blood pressure. Suggest reducing processed foods, pickled foods, and seasonings.';

  @override
  String get analysisFiberLowElderlyFemale =>
      'Females over 50 need more fiber for gut health. Suggest increasing intake of vegetables, fruits, and whole grains.';

  @override
  String get analysisFiberLowGeneral =>
      'Fiber supports gut health and blood sugar control. Suggest increasing vegetables, fruits, and whole grains.';

  @override
  String get analysisBmiUnderweightWarning =>
      'Your BMI indicates you are underweight. It is recommended to increase your intake of nutrient-dense foods and consult a nutritionist.';

  @override
  String get analysisBmiOverweightWarning =>
      'Weight management under professional guidance is recommended. Ensure balanced nutrition while controlling calorie intake.';

  @override
  String get warningFried => '💛 Fried food, consume in moderation.';

  @override
  String get warningSugar => '🍯 High sugar/fat, enjoy in moderation.';

  @override
  String get warningProtein => '🍖 Protein rich, pair with veggies.';

  @override
  String get warningVeg => '🥗 Vitamin/Fiber rich, excellent choice.';

  @override
  String get warningBalanced => '🌟 Balanced diet, healthy living.';

  @override
  String get advancedAnalysisFeature => 'Advanced Analysis';

  @override
  String get unlockPremiumAnalysis =>
      'Upgrade to Premium to unlock detailed Weekly and Monthly nutrition analysis.';

  @override
  String get applySuggestion => 'Apply Suggestion';

  @override
  String get smartSuggestionTitle => 'Smart Nutrition Suggestion';

  @override
  String smartSuggestionDesc(
    Object activity,
    Object age,
    Object gender,
    Object weight,
  ) {
    return 'Based on your profile ($age years, $gender, ${weight}kg, $activity)';
  }

  @override
  String get suggestionApplied => 'Smart suggestions applied';

  @override
  String enterValidNumber(Object max, Object min) {
    return 'Please enter a number between $min and $max';
  }
}
