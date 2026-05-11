import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('zh', 'CN'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Fooda'**
  String get appName;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get navHistory;

  /// No description provided for @navAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get navAnalysis;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @todayNutrition.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Nutrition'**
  String get todayNutrition;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoal;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbs;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @sodium.
  ///
  /// In en, this message translates to:
  /// **'Sodium'**
  String get sodium;

  /// No description provided for @sugar.
  ///
  /// In en, this message translates to:
  /// **'Sugar'**
  String get sugar;

  /// No description provided for @fiber.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber'**
  String get fiber;

  /// No description provided for @kcal.
  ///
  /// In en, this message translates to:
  /// **'kcal'**
  String get kcal;

  /// No description provided for @gram.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get gram;

  /// No description provided for @milligram.
  ///
  /// In en, this message translates to:
  /// **'mg'**
  String get milligram;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @snack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get snack;

  /// No description provided for @addRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Record'**
  String get addRecord;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo Recognition'**
  String get takePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload Photo Recognition'**
  String get uploadPhoto;

  /// No description provided for @manualInput.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get manualInput;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @currentLanguage.
  ///
  /// In en, this message translates to:
  /// **'Current Language'**
  String get currentLanguage;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About App'**
  String get aboutApp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @loginWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Login with Google'**
  String get loginWithGoogle;

  /// No description provided for @loginWithApple.
  ///
  /// In en, this message translates to:
  /// **'Login with Apple'**
  String get loginWithApple;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @traditionalChinese.
  ///
  /// In en, this message translates to:
  /// **'Traditional Chinese'**
  String get traditionalChinese;

  /// No description provided for @simplifiedChinese.
  ///
  /// In en, this message translates to:
  /// **'Simplified Chinese'**
  String get simplifiedChinese;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'female'**
  String get female;

  /// No description provided for @activityLevel.
  ///
  /// In en, this message translates to:
  /// **'Activity Level'**
  String get activityLevel;

  /// No description provided for @nutritionGoals.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Goals'**
  String get nutritionGoals;

  /// No description provided for @activitySedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get activitySedentary;

  /// No description provided for @activitySedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Office work, little exercise\nLess than 1 workout per week'**
  String get activitySedentaryDesc;

  /// No description provided for @activitySedentaryExamples.
  ///
  /// In en, this message translates to:
  /// **'Office work, watching TV, reading'**
  String get activitySedentaryExamples;

  /// No description provided for @activityLight.
  ///
  /// In en, this message translates to:
  /// **'Light Activity'**
  String get activityLight;

  /// No description provided for @activityLightDesc.
  ///
  /// In en, this message translates to:
  /// **'Occasional walking or light exercise\n1-3 workouts per week'**
  String get activityLightDesc;

  /// No description provided for @activityLightExamples.
  ///
  /// In en, this message translates to:
  /// **'Walking, light yoga, household activities'**
  String get activityLightExamples;

  /// No description provided for @activityModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Activity'**
  String get activityModerate;

  /// No description provided for @activityModerateDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular exercise habit\n3-5 workouts per week'**
  String get activityModerateDesc;

  /// No description provided for @activityModerateExamples.
  ///
  /// In en, this message translates to:
  /// **'Running, swimming, cycling, gym'**
  String get activityModerateExamples;

  /// No description provided for @activityHigh.
  ///
  /// In en, this message translates to:
  /// **'High Activity'**
  String get activityHigh;

  /// No description provided for @activityHighDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily exercise\nHigh intensity workouts'**
  String get activityHighDesc;

  /// No description provided for @activityHighExamples.
  ///
  /// In en, this message translates to:
  /// **'Daily running, weight training, competitive sports'**
  String get activityHighExamples;

  /// No description provided for @activityExtreme.
  ///
  /// In en, this message translates to:
  /// **'Extreme Activity'**
  String get activityExtreme;

  /// No description provided for @activityExtremeDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional athlete level\nHigh intensity training'**
  String get activityExtremeDesc;

  /// No description provided for @activityExtremeExamples.
  ///
  /// In en, this message translates to:
  /// **'Professional athletes, marathon runners'**
  String get activityExtremeExamples;

  /// No description provided for @activityLevelUpdated.
  ///
  /// In en, this message translates to:
  /// **'Activity level updated'**
  String get activityLevelUpdated;

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @jan.
  ///
  /// In en, this message translates to:
  /// **'Jan'**
  String get jan;

  /// No description provided for @feb.
  ///
  /// In en, this message translates to:
  /// **'Feb'**
  String get feb;

  /// No description provided for @mar.
  ///
  /// In en, this message translates to:
  /// **'Mar'**
  String get mar;

  /// No description provided for @apr.
  ///
  /// In en, this message translates to:
  /// **'Apr'**
  String get apr;

  /// No description provided for @may_short.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may_short;

  /// No description provided for @jun.
  ///
  /// In en, this message translates to:
  /// **'Jun'**
  String get jun;

  /// No description provided for @jul.
  ///
  /// In en, this message translates to:
  /// **'Jul'**
  String get jul;

  /// No description provided for @aug.
  ///
  /// In en, this message translates to:
  /// **'Aug'**
  String get aug;

  /// No description provided for @sep.
  ///
  /// In en, this message translates to:
  /// **'Sep'**
  String get sep;

  /// No description provided for @oct.
  ///
  /// In en, this message translates to:
  /// **'Oct'**
  String get oct;

  /// No description provided for @nov.
  ///
  /// In en, this message translates to:
  /// **'Nov'**
  String get nov;

  /// No description provided for @dec.
  ///
  /// In en, this message translates to:
  /// **'Dec'**
  String get dec;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @startRecordingMeals.
  ///
  /// In en, this message translates to:
  /// **'Start Recording Meals'**
  String get startRecordingMeals;

  /// No description provided for @startRecordingMessage.
  ///
  /// In en, this message translates to:
  /// **'No meal records for this {period} yet. Personalized analysis will be shown after you start recording.'**
  String startRecordingMessage(Object period);

  /// No description provided for @dataCollecting.
  ///
  /// In en, this message translates to:
  /// **'Data Collecting'**
  String get dataCollecting;

  /// No description provided for @dataCollectingMessage.
  ///
  /// In en, this message translates to:
  /// **'Currently have {days} days of record data. Continue recording more days for more accurate nutrition analysis.'**
  String dataCollectingMessage(Object days);

  /// No description provided for @insufficientCalories.
  ///
  /// In en, this message translates to:
  /// **'{period} Calorie Intake Insufficient'**
  String insufficientCalories(Object period);

  /// No description provided for @excessiveCalories.
  ///
  /// In en, this message translates to:
  /// **'{period} Calorie Intake Excessive'**
  String excessiveCalories(Object period);

  /// No description provided for @appropriateCalories.
  ///
  /// In en, this message translates to:
  /// **'{period} Calorie Intake Appropriate'**
  String appropriateCalories(Object period);

  /// No description provided for @appropriateCaloriesMessage.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}, within your personal recommended range. Keep up the balanced diet!'**
  String appropriateCaloriesMessage(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @proteinInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Protein Intake Insufficient'**
  String get proteinInsufficient;

  /// No description provided for @proteinSufficient.
  ///
  /// In en, this message translates to:
  /// **'Protein Intake Sufficient'**
  String get proteinSufficient;

  /// No description provided for @proteinSufficientMessage.
  ///
  /// In en, this message translates to:
  /// **'Your protein intake is sufficient, which helps muscle maintenance and repair.'**
  String get proteinSufficientMessage;

  /// No description provided for @carbsInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate Intake Insufficient'**
  String get carbsInsufficient;

  /// No description provided for @carbsExcessive.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrate Intake Excessive'**
  String get carbsExcessive;

  /// No description provided for @fatExcessive.
  ///
  /// In en, this message translates to:
  /// **'Fat Intake Excessive'**
  String get fatExcessive;

  /// No description provided for @sodiumExcessive.
  ///
  /// In en, this message translates to:
  /// **'Sodium Intake Excessive'**
  String get sodiumExcessive;

  /// No description provided for @fiberInsufficient.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber Intake Insufficient'**
  String get fiberInsufficient;

  /// No description provided for @weightUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight Attention Required'**
  String get weightUnderweight;

  /// No description provided for @weightControl.
  ///
  /// In en, this message translates to:
  /// **'Weight Control Recommendation'**
  String get weightControl;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'current'**
  String get current;

  /// No description provided for @analysisBasedOn.
  ///
  /// In en, this message translates to:
  /// **'Analysis will be based on your personal profile'**
  String get analysisBasedOn;

  /// No description provided for @basedOnData.
  ///
  /// In en, this message translates to:
  /// **'Based on existing'**
  String get basedOnData;

  /// No description provided for @daysData.
  ///
  /// In en, this message translates to:
  /// **'days data for preliminary analysis'**
  String get daysData;

  /// No description provided for @basedOnProfile.
  ///
  /// In en, this message translates to:
  /// **'Based on your'**
  String get basedOnProfile;

  /// No description provided for @daysActualRecord.
  ///
  /// In en, this message translates to:
  /// **'days actual record'**
  String get daysActualRecord;

  /// No description provided for @basedOnDays.
  ///
  /// In en, this message translates to:
  /// **'Based on'**
  String get basedOnDays;

  /// No description provided for @meetsRecommended.
  ///
  /// In en, this message translates to:
  /// **'meets your personal recommended value'**
  String get meetsRecommended;

  /// No description provided for @kcalPerDay.
  ///
  /// In en, this message translates to:
  /// **'kcal/day'**
  String get kcalPerDay;

  /// No description provided for @recommendedIntake.
  ///
  /// In en, this message translates to:
  /// **'Recommended intake'**
  String get recommendedIntake;

  /// No description provided for @day.
  ///
  /// In en, this message translates to:
  /// **'day'**
  String get day;

  /// No description provided for @basedOnWeight.
  ///
  /// In en, this message translates to:
  /// **'based on'**
  String get basedOnWeight;

  /// No description provided for @weightAnd.
  ///
  /// In en, this message translates to:
  /// **'kg weight and'**
  String get weightAnd;

  /// No description provided for @currentIntake.
  ///
  /// In en, this message translates to:
  /// **'Current intake'**
  String get currentIntake;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @basedOnHighActivity.
  ///
  /// In en, this message translates to:
  /// **'based on high activity level'**
  String get basedOnHighActivity;

  /// No description provided for @basedOn.
  ///
  /// In en, this message translates to:
  /// **'based on'**
  String get basedOn;

  /// No description provided for @basedOnAge.
  ///
  /// In en, this message translates to:
  /// **'based on'**
  String get basedOnAge;

  /// No description provided for @ageYears.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get ageYears;

  /// No description provided for @welcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CalHub'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your AI Nutrition Companion'**
  String get welcomeSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @languageSelectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get languageSelectionTitle;

  /// No description provided for @languageSelectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select your preferred language'**
  String get languageSelectionSubtitle;

  /// No description provided for @bodyDataTitle.
  ///
  /// In en, this message translates to:
  /// **'Body Information'**
  String get bodyDataTitle;

  /// No description provided for @bodyDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Help us personalize your nutrition goals'**
  String get bodyDataSubtitle;

  /// No description provided for @enterHeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your height'**
  String get enterHeight;

  /// No description provided for @enterWeight.
  ///
  /// In en, this message translates to:
  /// **'Enter your weight'**
  String get enterWeight;

  /// No description provided for @enterAge.
  ///
  /// In en, this message translates to:
  /// **'Enter your age'**
  String get enterAge;

  /// No description provided for @selectGender.
  ///
  /// In en, this message translates to:
  /// **'Select Gender'**
  String get selectGender;

  /// No description provided for @selectActivityLevel.
  ///
  /// In en, this message translates to:
  /// **'Select your activity level'**
  String get selectActivityLevel;

  /// No description provided for @calorieGoalTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoalTitle;

  /// No description provided for @calorieGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set your daily calorie target'**
  String get calorieGoalSubtitle;

  /// No description provided for @recommendedCalories.
  ///
  /// In en, this message translates to:
  /// **'Recommended Calories'**
  String recommendedCalories(int calories);

  /// No description provided for @useAIRecommendation.
  ///
  /// In en, this message translates to:
  /// **'Do you want to use AI to automatically analyze food content and nutrients?'**
  String get useAIRecommendation;

  /// No description provided for @customGoal.
  ///
  /// In en, this message translates to:
  /// **'Custom Goal'**
  String get customGoal;

  /// No description provided for @tutorialTitle.
  ///
  /// In en, this message translates to:
  /// **'App Tutorial'**
  String get tutorialTitle;

  /// No description provided for @tutorialSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip Tutorial'**
  String get tutorialSkip;

  /// No description provided for @tutorialComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete Tutorial'**
  String get tutorialComplete;

  /// No description provided for @homeButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Home Button'**
  String get homeButtonTitle;

  /// No description provided for @homeButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Click here to return to main page\nView today\'s nutrition intake\nThis is your nutrition recording center'**
  String get homeButtonDesc;

  /// No description provided for @historyButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'History Button'**
  String get historyButtonTitle;

  /// No description provided for @historyButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Click to view diet history\nAnalyze your nutrition trends\nTrack long-term health data changes'**
  String get historyButtonDesc;

  /// No description provided for @analysisButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Analysis Button'**
  String get analysisButtonTitle;

  /// No description provided for @analysisButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Click for detailed nutrition analysis\nGet professional dietary advice\nUnderstand your overall health status'**
  String get analysisButtonDesc;

  /// No description provided for @profileButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Button'**
  String get profileButtonTitle;

  /// No description provided for @profileButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Click to manage personal information\nSet health goals and preferences\nAdjust nutrition plan settings'**
  String get profileButtonDesc;

  /// No description provided for @addButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Record Button'**
  String get addButtonTitle;

  /// No description provided for @addButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Click to add new nutrition record\nThis is the core function entry\nStart tracking your meals'**
  String get addButtonDesc;

  /// No description provided for @cameraButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Camera Button'**
  String get cameraButtonTitle;

  /// No description provided for @cameraButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Take food photos\nAI automatically recognizes nutrition\nFastest recording method'**
  String get cameraButtonDesc;

  /// No description provided for @uploadButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Button'**
  String get uploadButtonTitle;

  /// No description provided for @uploadButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Upload existing food photos\nAI analysis of nutrition content\nPerfect for existing photos'**
  String get uploadButtonDesc;

  /// No description provided for @manualButtonTitle.
  ///
  /// In en, this message translates to:
  /// **'Manual Input Button'**
  String get manualButtonTitle;

  /// No description provided for @manualButtonDesc.
  ///
  /// In en, this message translates to:
  /// **'Manually enter food information\nMost accurate recording method\nComplete control over data'**
  String get manualButtonDesc;

  /// No description provided for @pleaseSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Please select a language'**
  String get pleaseSelectLanguage;

  /// No description provided for @languageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully'**
  String get languageChanged;

  /// No description provided for @restartRequired.
  ///
  /// In en, this message translates to:
  /// **'Please restart the app to apply language changes'**
  String get restartRequired;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @noRecordsYet.
  ///
  /// In en, this message translates to:
  /// **'No meal records yet'**
  String get noRecordsYet;

  /// No description provided for @noRecordsForDate.
  ///
  /// In en, this message translates to:
  /// **'No meal records for this date'**
  String get noRecordsForDate;

  /// No description provided for @clickAddToStart.
  ///
  /// In en, this message translates to:
  /// **'Click the + button below to start recording'**
  String get clickAddToStart;

  /// No description provided for @mealRecords.
  ///
  /// In en, this message translates to:
  /// **'Meal Records'**
  String get mealRecords;

  /// No description provided for @noAnalysisData.
  ///
  /// In en, this message translates to:
  /// **'No Analysis Data'**
  String get noAnalysisData;

  /// No description provided for @startRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Start recording meals to see personalized analysis suggestions'**
  String get startRecordingHint;

  /// No description provided for @mealName.
  ///
  /// In en, this message translates to:
  /// **'Meal Name'**
  String get mealName;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @morningSnack.
  ///
  /// In en, this message translates to:
  /// **'Morning Snack'**
  String get morningSnack;

  /// No description provided for @afternoonSnack.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Snack'**
  String get afternoonSnack;

  /// No description provided for @eveningSnack.
  ///
  /// In en, this message translates to:
  /// **'Evening Snack'**
  String get eveningSnack;

  /// No description provided for @homeCooked.
  ///
  /// In en, this message translates to:
  /// **'Home Cooked'**
  String get homeCooked;

  /// No description provided for @diningOut.
  ///
  /// In en, this message translates to:
  /// **'Dining Out'**
  String get diningOut;

  /// No description provided for @takeout.
  ///
  /// In en, this message translates to:
  /// **'Takeout'**
  String get takeout;

  /// No description provided for @dessert.
  ///
  /// In en, this message translates to:
  /// **'Dessert'**
  String get dessert;

  /// No description provided for @beverage.
  ///
  /// In en, this message translates to:
  /// **'Beverage'**
  String get beverage;

  /// No description provided for @aiRecognitionFailed.
  ///
  /// In en, this message translates to:
  /// **'AI recognition failed'**
  String get aiRecognitionFailed;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'Badges'**
  String get badges;

  /// No description provided for @badgesPage.
  ///
  /// In en, this message translates to:
  /// **'Badges Page'**
  String get badgesPage;

  /// No description provided for @membership.
  ///
  /// In en, this message translates to:
  /// **'Membership'**
  String get membership;

  /// No description provided for @membershipPage.
  ///
  /// In en, this message translates to:
  /// **'Membership Page'**
  String get membershipPage;

  /// No description provided for @loginPage.
  ///
  /// In en, this message translates to:
  /// **'Login Page'**
  String get loginPage;

  /// No description provided for @resetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App'**
  String get resetApp;

  /// No description provided for @resetAppConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset the app?'**
  String get resetAppConfirm;

  /// No description provided for @resetAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Clear all data and start fresh'**
  String get resetAppDesc;

  /// No description provided for @skipOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Skip Onboarding'**
  String get skipOnboarding;

  /// No description provided for @developmentMode.
  ///
  /// In en, this message translates to:
  /// **'Development Mode'**
  String get developmentMode;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @dietaryFiber.
  ///
  /// In en, this message translates to:
  /// **'Dietary Fiber'**
  String get dietaryFiber;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @nutritionOverview.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Overview'**
  String get nutritionOverview;

  /// No description provided for @editMeal.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal'**
  String get editMeal;

  /// No description provided for @deleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Delete Meal'**
  String get deleteMeal;

  /// No description provided for @mealEditedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal edited successfully'**
  String get mealEditedSuccessfully;

  /// No description provided for @mealDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal deleted successfully'**
  String get mealDeletedSuccessfully;

  /// No description provided for @areYouSureDeleteMeal.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal?'**
  String get areYouSureDeleteMeal;

  /// No description provided for @foodItems.
  ///
  /// In en, this message translates to:
  /// **'food items'**
  String get foodItems;

  /// No description provided for @addFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Add Food Item'**
  String get addFoodItem;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food Name'**
  String get foodName;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @grams.
  ///
  /// In en, this message translates to:
  /// **'grams'**
  String get grams;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'pieces'**
  String get pieces;

  /// No description provided for @cups.
  ///
  /// In en, this message translates to:
  /// **'cups'**
  String get cups;

  /// No description provided for @tablespoons.
  ///
  /// In en, this message translates to:
  /// **'tablespoons'**
  String get tablespoons;

  /// No description provided for @teaspoons.
  ///
  /// In en, this message translates to:
  /// **'teaspoons'**
  String get teaspoons;

  /// No description provided for @ounces.
  ///
  /// In en, this message translates to:
  /// **'ounces'**
  String get ounces;

  /// No description provided for @pounds.
  ///
  /// In en, this message translates to:
  /// **'pounds'**
  String get pounds;

  /// No description provided for @kilograms.
  ///
  /// In en, this message translates to:
  /// **'kilograms'**
  String get kilograms;

  /// No description provided for @milliliters.
  ///
  /// In en, this message translates to:
  /// **'milliliters'**
  String get milliliters;

  /// No description provided for @liters.
  ///
  /// In en, this message translates to:
  /// **'liters'**
  String get liters;

  /// No description provided for @servings.
  ///
  /// In en, this message translates to:
  /// **'servings'**
  String get servings;

  /// No description provided for @slices.
  ///
  /// In en, this message translates to:
  /// **'slices'**
  String get slices;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @per100g.
  ///
  /// In en, this message translates to:
  /// **'Per 100g'**
  String get per100g;

  /// No description provided for @nutritionFacts.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Facts'**
  String get nutritionFacts;

  /// No description provided for @enterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Enter food name'**
  String get enterFoodName;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// No description provided for @selectUnit.
  ///
  /// In en, this message translates to:
  /// **'Select unit'**
  String get selectUnit;

  /// No description provided for @addToMeal.
  ///
  /// In en, this message translates to:
  /// **'Add to Meal'**
  String get addToMeal;

  /// No description provided for @updateMeal.
  ///
  /// In en, this message translates to:
  /// **'Update Meal'**
  String get updateMeal;

  /// No description provided for @noFoodItemsAdded.
  ///
  /// In en, this message translates to:
  /// **'No food items added'**
  String get noFoodItemsAdded;

  /// No description provided for @tapToAddFood.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add food items'**
  String get tapToAddFood;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @pleaseEnterFoodName.
  ///
  /// In en, this message translates to:
  /// **'Please enter a food name'**
  String get pleaseEnterFoodName;

  /// No description provided for @searchFood.
  ///
  /// In en, this message translates to:
  /// **'Search food'**
  String get searchFood;

  /// No description provided for @recentFoods.
  ///
  /// In en, this message translates to:
  /// **'Recent Foods'**
  String get recentFoods;

  /// No description provided for @commonFoods.
  ///
  /// In en, this message translates to:
  /// **'Common Foods'**
  String get commonFoods;

  /// No description provided for @carbsHighTitle.
  ///
  /// In en, this message translates to:
  /// **'High Carbohydrate Ratio'**
  String get carbsHighTitle;

  /// No description provided for @carbsHighMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing refined starch intake and increasing protein and healthy fat proportions.'**
  String get carbsHighMessage;

  /// No description provided for @proteinLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Protein Intake Too Low'**
  String get proteinLowTitle;

  /// No description provided for @proteinLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider increasing quality protein intake such as fish, chicken, tofu, etc.'**
  String get proteinLowMessage;

  /// No description provided for @fatHighTitle.
  ///
  /// In en, this message translates to:
  /// **'High Fat Intake'**
  String get fatHighTitle;

  /// No description provided for @fatHighMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider reducing fried foods and choosing healthy fat sources like nuts and fish oil.'**
  String get fatHighMessage;

  /// No description provided for @sodiumHighTitle.
  ///
  /// In en, this message translates to:
  /// **'Excessive Sodium Intake'**
  String get sodiumHighTitle;

  /// No description provided for @sodiumHighTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sodium intake is too high. Consider reducing processed foods and seasonings.'**
  String get sodiumHighTodayMessage;

  /// No description provided for @fiberLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Dietary Fiber'**
  String get fiberLowTitle;

  /// No description provided for @fiberLowTodayMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s dietary fiber intake is insufficient. Consider eating more vegetables, fruits, and whole grains.'**
  String get fiberLowTodayMessage;

  /// No description provided for @noRecords.
  ///
  /// In en, this message translates to:
  /// **'No Records'**
  String get noRecords;

  /// No description provided for @smartSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Smart Suggestions'**
  String get smartSuggestion;

  /// No description provided for @setupComplete.
  ///
  /// In en, this message translates to:
  /// **'Setup Complete!'**
  String get setupComplete;

  /// No description provided for @welcomeToFooda.
  ///
  /// In en, this message translates to:
  /// **'Welcome to CalHub!'**
  String get welcomeToFooda;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred, please restart the app'**
  String get errorOccurred;

  /// No description provided for @aiRecognition.
  ///
  /// In en, this message translates to:
  /// **'AI Recognition'**
  String get aiRecognition;

  /// No description provided for @aiRecognitionDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically identify food and nutrition by taking photos'**
  String get aiRecognitionDesc;

  /// No description provided for @nutritionAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Analysis'**
  String get nutritionAnalysis;

  /// No description provided for @nutritionAnalysisDesc.
  ///
  /// In en, this message translates to:
  /// **'Detailed nutritional analysis and health recommendations'**
  String get nutritionAnalysisDesc;

  /// No description provided for @cloudSync.
  ///
  /// In en, this message translates to:
  /// **'Cloud Sync'**
  String get cloudSync;

  /// No description provided for @cloudSyncDesc.
  ///
  /// In en, this message translates to:
  /// **'Secure data backup and multi-device sync'**
  String get cloudSyncDesc;

  /// No description provided for @caloriesLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Intake Too Low'**
  String get caloriesLowTitle;

  /// No description provided for @caloriesLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s calorie intake is below recommended. Consider increasing nutrient-dense foods.'**
  String get caloriesLowMessage;

  /// No description provided for @caloriesHighTitle.
  ///
  /// In en, this message translates to:
  /// **'Calorie Intake Too High'**
  String get caloriesHighTitle;

  /// No description provided for @caloriesHighMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s calorie intake exceeds recommended. Consider controlling portion sizes and choosing lower calorie foods.'**
  String get caloriesHighMessage;

  /// No description provided for @caloriesGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Appropriate Calorie Intake'**
  String get caloriesGoodTitle;

  /// No description provided for @caloriesGoodMessage.
  ///
  /// In en, this message translates to:
  /// **'Today\'s calorie intake is within reasonable range. Keep up the balanced diet.'**
  String get caloriesGoodMessage;

  /// No description provided for @avgCaloriesLow.
  ///
  /// In en, this message translates to:
  /// **'Average Calories Too Low'**
  String get avgCaloriesLow;

  /// No description provided for @avgCaloriesHigh.
  ///
  /// In en, this message translates to:
  /// **'Average Calories Too High'**
  String get avgCaloriesHigh;

  /// No description provided for @caloriesControlGood.
  ///
  /// In en, this message translates to:
  /// **'Good Calorie Control'**
  String get caloriesControlGood;

  /// No description provided for @avgDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Average daily intake'**
  String get avgDailyIntake;

  /// No description provided for @belowRecommended.
  ///
  /// In en, this message translates to:
  /// **'below recommended'**
  String get belowRecommended;

  /// No description provided for @exceedsRecommended.
  ///
  /// In en, this message translates to:
  /// **'exceeds recommended'**
  String get exceedsRecommended;

  /// No description provided for @increaseNutrientDenseFoods.
  ///
  /// In en, this message translates to:
  /// **'Consider increasing nutrient-dense foods'**
  String get increaseNutrientDenseFoods;

  /// No description provided for @controlPortions.
  ///
  /// In en, this message translates to:
  /// **'Consider controlling portion sizes and choices'**
  String get controlPortions;

  /// No description provided for @withinRange.
  ///
  /// In en, this message translates to:
  /// **'within reasonable range'**
  String get withinRange;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up'**
  String get keepItUp;

  /// No description provided for @avgDailySodiumIntake.
  ///
  /// In en, this message translates to:
  /// **'Average daily sodium intake'**
  String get avgDailySodiumIntake;

  /// No description provided for @chooseLowSodiumFoods.
  ///
  /// In en, this message translates to:
  /// **'Consider choosing low-sodium foods'**
  String get chooseLowSodiumFoods;

  /// No description provided for @avgDailyFiberIntake.
  ///
  /// In en, this message translates to:
  /// **'Average daily fiber intake'**
  String get avgDailyFiberIntake;

  /// No description provided for @increaseVegetableFruit.
  ///
  /// In en, this message translates to:
  /// **'Consider increasing vegetable and fruit intake'**
  String get increaseVegetableFruit;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years old'**
  String get yearsOld;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @editAge.
  ///
  /// In en, this message translates to:
  /// **'Edit Age'**
  String get editAge;

  /// No description provided for @editHeight.
  ///
  /// In en, this message translates to:
  /// **'Edit Height'**
  String get editHeight;

  /// No description provided for @editWeight.
  ///
  /// In en, this message translates to:
  /// **'Edit Weight'**
  String get editWeight;

  /// No description provided for @ageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Age updated'**
  String get ageUpdated;

  /// No description provided for @heightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Height updated'**
  String get heightUpdated;

  /// No description provided for @weightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Weight updated'**
  String get weightUpdated;

  /// No description provided for @genderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Gender updated'**
  String get genderUpdated;

  /// No description provided for @mealReminders.
  ///
  /// In en, this message translates to:
  /// **'Meal Reminders'**
  String get mealReminders;

  /// No description provided for @breakfastReminder.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Reminder'**
  String get breakfastReminder;

  /// No description provided for @lunchReminder.
  ///
  /// In en, this message translates to:
  /// **'Lunch Reminder'**
  String get lunchReminder;

  /// No description provided for @dinnerReminder.
  ///
  /// In en, this message translates to:
  /// **'Dinner Reminder'**
  String get dinnerReminder;

  /// No description provided for @breakfastReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Breakfast Reminder Time'**
  String get breakfastReminderTime;

  /// No description provided for @lunchReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Lunch Reminder Time'**
  String get lunchReminderTime;

  /// No description provided for @dinnerReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Dinner Reminder Time'**
  String get dinnerReminderTime;

  /// No description provided for @breakfastTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Breakfast reminder time updated'**
  String get breakfastTimeUpdated;

  /// No description provided for @lunchTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Lunch reminder time updated'**
  String get lunchTimeUpdated;

  /// No description provided for @dinnerTimeUpdated.
  ///
  /// In en, this message translates to:
  /// **'Dinner reminder time updated'**
  String get dinnerTimeUpdated;

  /// No description provided for @breakfastReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Time for breakfast! Maintain balanced nutrition!'**
  String get breakfastReminderBody;

  /// No description provided for @lunchReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Lunch time! Remember to include protein and vegetables!'**
  String get lunchReminderBody;

  /// No description provided for @dinnerReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Dinner time! Control total calories for better health!'**
  String get dinnerReminderBody;

  /// No description provided for @lateNight.
  ///
  /// In en, this message translates to:
  /// **'Late Night'**
  String get lateNight;

  /// No description provided for @afternoonTea.
  ///
  /// In en, this message translates to:
  /// **'Afternoon Tea'**
  String get afternoonTea;

  /// No description provided for @manualInputMeal.
  ///
  /// In en, this message translates to:
  /// **'Manual Input Meal'**
  String get manualInputMeal;

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal Type'**
  String get mealType;

  /// No description provided for @mealTags.
  ///
  /// In en, this message translates to:
  /// **'Meal Tags'**
  String get mealTags;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @mealNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g.: Grilled Chicken Salad'**
  String get mealNameHint;

  /// No description provided for @loginToYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Login to Your Account'**
  String get loginToYourAccount;

  /// No description provided for @loginDataSecurityDescription.
  ///
  /// In en, this message translates to:
  /// **'Your data will be securely backed up to the cloud after login'**
  String get loginDataSecurityDescription;

  /// No description provided for @signInWithApple.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Apple'**
  String get signInWithApple;

  /// No description provided for @signInWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get signInWithGoogle;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @skipLoginLater.
  ///
  /// In en, this message translates to:
  /// **'Skip, Login Later'**
  String get skipLoginLater;

  /// No description provided for @loginAgreementText.
  ///
  /// In en, this message translates to:
  /// **'By logging in, you agree to our Terms of Service and Privacy Policy'**
  String get loginAgreementText;

  /// No description provided for @appleLoginSuccess.
  ///
  /// In en, this message translates to:
  /// **'Apple login successful!'**
  String get appleLoginSuccess;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed'**
  String get loginFailed;

  /// No description provided for @simulatorNotSupported.
  ///
  /// In en, this message translates to:
  /// **'Simulator doesn\'t support Apple Sign-In, please test on real device or click \"Skip\"'**
  String get simulatorNotSupported;

  /// No description provided for @appleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Apple login failed'**
  String get appleLoginFailed;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @loginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Login cancelled'**
  String get loginCancelled;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google login failed'**
  String get googleLoginFailed;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network connection error, please check network settings'**
  String get networkError;

  /// No description provided for @googleLoginRetry.
  ///
  /// In en, this message translates to:
  /// **'Google login failed, please try again later'**
  String get googleLoginRetry;

  /// No description provided for @validHeightError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid height'**
  String get validHeightError;

  /// No description provided for @validWeightError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight'**
  String get validWeightError;

  /// No description provided for @validAgeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid age'**
  String get validAgeError;

  /// No description provided for @sedentary.
  ///
  /// In en, this message translates to:
  /// **'Sedentary'**
  String get sedentary;

  /// No description provided for @sedentaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Office worker, little exercise\\nLess than 1 workout per week'**
  String get sedentaryDesc;

  /// No description provided for @sedentaryExamples.
  ///
  /// In en, this message translates to:
  /// **'Sitting at desk, watching TV, reading'**
  String get sedentaryExamples;

  /// No description provided for @lightActivity.
  ///
  /// In en, this message translates to:
  /// **'Light Activity'**
  String get lightActivity;

  /// No description provided for @lightActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Occasional walking or light exercise\\n1-3 workouts per week'**
  String get lightActivityDesc;

  /// No description provided for @lightActivityExamples.
  ///
  /// In en, this message translates to:
  /// **'Walking, light yoga, household activities'**
  String get lightActivityExamples;

  /// No description provided for @moderateActivity.
  ///
  /// In en, this message translates to:
  /// **'Moderate Activity'**
  String get moderateActivity;

  /// No description provided for @moderateActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Regular exercise habits\\n3-5 workouts per week'**
  String get moderateActivityDesc;

  /// No description provided for @moderateActivityExamples.
  ///
  /// In en, this message translates to:
  /// **'Running, swimming, cycling, gym'**
  String get moderateActivityExamples;

  /// No description provided for @highActivity.
  ///
  /// In en, this message translates to:
  /// **'High Activity'**
  String get highActivity;

  /// No description provided for @highActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily exercise\\nHigher intensity workouts'**
  String get highActivityDesc;

  /// No description provided for @highActivityExamples.
  ///
  /// In en, this message translates to:
  /// **'Daily running, weight training, competitive sports'**
  String get highActivityExamples;

  /// No description provided for @veryHighActivity.
  ///
  /// In en, this message translates to:
  /// **'Very High Activity'**
  String get veryHighActivity;

  /// No description provided for @veryHighActivityDesc.
  ///
  /// In en, this message translates to:
  /// **'Professional athlete level\\nHigh intensity training'**
  String get veryHighActivityDesc;

  /// No description provided for @veryHighActivityExamples.
  ///
  /// In en, this message translates to:
  /// **'Professional athletes, marathon runners'**
  String get veryHighActivityExamples;

  /// No description provided for @setCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Set Your Calorie Goal'**
  String get setCalorieGoal;

  /// No description provided for @calorieCalculationDescription.
  ///
  /// In en, this message translates to:
  /// **'We\'ve calculated personalized calorie needs based on your body data'**
  String get calorieCalculationDescription;

  /// No description provided for @aiSmartRecommendation.
  ///
  /// In en, this message translates to:
  /// **'AI Smart Recommendation'**
  String get aiSmartRecommendation;

  /// No description provided for @caloriesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Calories/Day'**
  String get caloriesPerDay;

  /// No description provided for @selectMonth.
  ///
  /// In en, this message translates to:
  /// **'Select Month'**
  String get selectMonth;

  /// No description provided for @editMealRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Meal Record'**
  String get editMealRecord;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this meal record? This action cannot be undone.'**
  String get confirmDeleteMessage;

  /// No description provided for @recordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Meal record updated'**
  String get recordUpdated;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Meal record deleted'**
  String get recordDeleted;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year}'**
  String dateFormat(Object day, Object month, Object year);

  /// No description provided for @monthYearFormat.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}'**
  String monthYearFormat(Object month, Object year);

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'App Version'**
  String get appVersion;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @lightMode.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get lightMode;

  /// No description provided for @followSystem.
  ///
  /// In en, this message translates to:
  /// **'Follow System'**
  String get followSystem;

  /// No description provided for @aiAutoRecognition.
  ///
  /// In en, this message translates to:
  /// **'AI automatically identifies food nutrition'**
  String get aiAutoRecognition;

  /// No description provided for @selectPhotoFromAlbum.
  ///
  /// In en, this message translates to:
  /// **'Select photos from album for recognition'**
  String get selectPhotoFromAlbum;

  /// No description provided for @manualInputWithAI.
  ///
  /// In en, this message translates to:
  /// **'Manual input nutrition info with AI assistance'**
  String get manualInputWithAI;

  /// No description provided for @resetAppWarning.
  ///
  /// In en, this message translates to:
  /// **'This will clear all local data including:\\n\\n• All meal records\\n• Personal profile settings\\n• Nutrition goals\\n• App preferences\\n\\nThis action cannot be undone. Are you sure you want to continue?'**
  String get resetAppWarning;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @appResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'App reset successfully'**
  String get appResetSuccess;

  /// No description provided for @appResetError.
  ///
  /// In en, this message translates to:
  /// **'Reset failed'**
  String get appResetError;

  /// No description provided for @basicSettings.
  ///
  /// In en, this message translates to:
  /// **'Basic Settings'**
  String get basicSettings;

  /// No description provided for @themeSettings.
  ///
  /// In en, this message translates to:
  /// **'Theme Settings'**
  String get themeSettings;

  /// No description provided for @developerOptions.
  ///
  /// In en, this message translates to:
  /// **'Developer Options'**
  String get developerOptions;

  /// No description provided for @aiProcessing.
  ///
  /// In en, this message translates to:
  /// **'AI is processing...'**
  String get aiProcessing;

  /// No description provided for @recognitionFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Recognition failed, please retry'**
  String get recognitionFailedRetry;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'Camera error'**
  String get cameraError;

  /// No description provided for @albumError.
  ///
  /// In en, this message translates to:
  /// **'Album selection failed'**
  String get albumError;

  /// No description provided for @example.
  ///
  /// In en, this message translates to:
  /// **'e.g.'**
  String get example;

  /// No description provided for @calculatedFromBodyData.
  ///
  /// In en, this message translates to:
  /// **'Calculated from your body data'**
  String get calculatedFromBodyData;

  /// No description provided for @setPersonalGoal.
  ///
  /// In en, this message translates to:
  /// **'Set your personalized goal'**
  String get setPersonalGoal;

  /// No description provided for @basalMetabolicRate.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate (BMR)'**
  String get basalMetabolicRate;

  /// No description provided for @recommendedDailyIntake.
  ///
  /// In en, this message translates to:
  /// **'Recommended Daily Intake'**
  String get recommendedDailyIntake;

  /// No description provided for @cal.
  ///
  /// In en, this message translates to:
  /// **'cal'**
  String get cal;

  /// No description provided for @intelligentCalcFromBodyData.
  ///
  /// In en, this message translates to:
  /// **'Intelligently calculated from your body data'**
  String get intelligentCalcFromBodyData;

  /// No description provided for @manualSetting.
  ///
  /// In en, this message translates to:
  /// **'Manual Setting'**
  String get manualSetting;

  /// No description provided for @inputDailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter your daily calorie goal'**
  String get inputDailyCalorieGoal;

  /// No description provided for @dailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Calorie Goal'**
  String get dailyCalorieGoal;

  /// No description provided for @enterDailyCalorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Enter daily calorie goal'**
  String get enterDailyCalorieGoal;

  /// No description provided for @kindTip.
  ///
  /// In en, this message translates to:
  /// **'Tip'**
  String get kindTip;

  /// No description provided for @calorieGoalTip.
  ///
  /// In en, this message translates to:
  /// **'You can adjust your calorie goal anytime in settings. We recommend adjusting based on your actual situation for optimal health results.'**
  String get calorieGoalTip;

  /// No description provided for @startExperience.
  ///
  /// In en, this message translates to:
  /// **'Start Experience'**
  String get startExperience;

  /// No description provided for @selectSettingMethod.
  ///
  /// In en, this message translates to:
  /// **'Select Setting Method'**
  String get selectSettingMethod;

  /// No description provided for @loginSyncedData.
  ///
  /// In en, this message translates to:
  /// **'Login synced data'**
  String get loginSyncedData;

  /// No description provided for @dataSyncedToCloud.
  ///
  /// In en, this message translates to:
  /// **'Data synced to cloud'**
  String get dataSyncedToCloud;

  /// No description provided for @loginToBackupData.
  ///
  /// In en, this message translates to:
  /// **'Login to backup data'**
  String get loginToBackupData;

  /// No description provided for @protectRecordsCrossDevice.
  ///
  /// In en, this message translates to:
  /// **'Protect your diet records and sync across devices'**
  String get protectRecordsCrossDevice;

  /// No description provided for @proteinGoodTitle.
  ///
  /// In en, this message translates to:
  /// **'Adequate Protein Intake'**
  String get proteinGoodTitle;

  /// No description provided for @proteinGoodMessage.
  ///
  /// In en, this message translates to:
  /// **'Good protein intake helps with muscle synthesis and repair.'**
  String get proteinGoodMessage;

  /// No description provided for @carbsLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates Too Low'**
  String get carbsLowTitle;

  /// No description provided for @carbsLowMessage.
  ///
  /// In en, this message translates to:
  /// **'Consider moderately increasing healthy carb sources like whole grains and fruits.'**
  String get carbsLowMessage;

  /// No description provided for @skipFailed.
  ///
  /// In en, this message translates to:
  /// **'Skip failed'**
  String get skipFailed;

  /// No description provided for @saveSettingsError.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get saveSettingsError;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'Smart food tracking, healthy living starts here'**
  String get appDescription;

  /// No description provided for @tellUsYourBodyData.
  ///
  /// In en, this message translates to:
  /// **'Tell us your body data'**
  String get tellUsYourBodyData;

  /// No description provided for @bodyDataDescription.
  ///
  /// In en, this message translates to:
  /// **'This information will help us calculate more accurate nutritional needs for you'**
  String get bodyDataDescription;

  /// No description provided for @enterMealName.
  ///
  /// In en, this message translates to:
  /// **'Enter meal name'**
  String get enterMealName;

  /// No description provided for @aiAnalysisComplete.
  ///
  /// In en, this message translates to:
  /// **'AI analysis complete'**
  String get aiAnalysisComplete;

  /// No description provided for @recognitionResults.
  ///
  /// In en, this message translates to:
  /// **'Recognition Results'**
  String get recognitionResults;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'You can fill in taste, source, etc.'**
  String get notesHint;

  /// No description provided for @aiRecognitionSuccess.
  ///
  /// In en, this message translates to:
  /// **'AI recognition successful'**
  String get aiRecognitionSuccess;

  /// No description provided for @recognizedItems.
  ///
  /// In en, this message translates to:
  /// **'Recognized'**
  String get recognizedItems;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @analysisFailed.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysisFailed;

  /// No description provided for @mealSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Meal saved successfully'**
  String get mealSavedSuccessfully;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @legalDocuments.
  ///
  /// In en, this message translates to:
  /// **'Legal Documents'**
  String get legalDocuments;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get termsOfUse;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'records'**
  String get records;

  /// No description provided for @aiAutoAnalyze.
  ///
  /// In en, this message translates to:
  /// **'AI automatically identifies food nutrition'**
  String get aiAutoAnalyze;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @chooseFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select photos from album for recognition'**
  String get chooseFromGallerySubtitle;

  /// No description provided for @manualInputSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manual input nutrition info with AI assistance'**
  String get manualInputSubtitle;

  /// No description provided for @photoAndRecognition.
  ///
  /// In en, this message translates to:
  /// **'Photo & Recognition'**
  String get photoAndRecognition;

  /// No description provided for @nutrientsOptional.
  ///
  /// In en, this message translates to:
  /// **'Nutrients (Optional)'**
  String get nutrientsOptional;

  /// No description provided for @aiAnalyzing.
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing food...'**
  String get aiAnalyzing;

  /// No description provided for @yesUseAI.
  ///
  /// In en, this message translates to:
  /// **'Yes, use AI'**
  String get yesUseAI;

  /// No description provided for @noManualInput.
  ///
  /// In en, this message translates to:
  /// **'No, fill in manually'**
  String get noManualInput;

  /// No description provided for @galleryError.
  ///
  /// In en, this message translates to:
  /// **'Gallery selection error'**
  String get galleryError;

  /// No description provided for @tutorialStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tutorialStep1Title;

  /// No description provided for @tutorialStep1Desc.
  ///
  /// In en, this message translates to:
  /// **'This is where you view today\'s intake.'**
  String get tutorialStep1Desc;

  /// No description provided for @tutorialStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Nutrition Stats'**
  String get tutorialStep2Title;

  /// No description provided for @tutorialStep2Desc.
  ///
  /// In en, this message translates to:
  /// **'View your daily nutrition breakdown here.'**
  String get tutorialStep2Desc;

  /// No description provided for @tutorialStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Meal Records'**
  String get tutorialStep3Title;

  /// No description provided for @tutorialStep3Desc.
  ///
  /// In en, this message translates to:
  /// **'See your recent meal records here.'**
  String get tutorialStep3Desc;

  /// No description provided for @tutorialStep4Title.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get tutorialStep4Title;

  /// No description provided for @tutorialStep4Desc.
  ///
  /// In en, this message translates to:
  /// **'View detailed records from past dates.'**
  String get tutorialStep4Desc;

  /// No description provided for @tutorialStep5Title.
  ///
  /// In en, this message translates to:
  /// **'Analysis'**
  String get tutorialStep5Title;

  /// No description provided for @tutorialStep5Desc.
  ///
  /// In en, this message translates to:
  /// **'View long-term nutrition trends.'**
  String get tutorialStep5Desc;

  /// No description provided for @tutorialStep6Title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tutorialStep6Title;

  /// No description provided for @tutorialStep6Desc.
  ///
  /// In en, this message translates to:
  /// **'Manage your profile and settings.'**
  String get tutorialStep6Desc;

  /// No description provided for @tutorialStep7Title.
  ///
  /// In en, this message translates to:
  /// **'Add Button'**
  String get tutorialStep7Title;

  /// No description provided for @tutorialStep7Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add a new meal record.'**
  String get tutorialStep7Desc;

  /// No description provided for @tutorialStep8Title.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get tutorialStep8Title;

  /// No description provided for @tutorialStep8Desc.
  ///
  /// In en, this message translates to:
  /// **'Take a photo to add a meal record.'**
  String get tutorialStep8Desc;

  /// No description provided for @tutorialStep9Title.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get tutorialStep9Title;

  /// No description provided for @tutorialStep9Desc.
  ///
  /// In en, this message translates to:
  /// **'Select from gallery to add a meal record.'**
  String get tutorialStep9Desc;

  /// No description provided for @tutorialStep10Title.
  ///
  /// In en, this message translates to:
  /// **'Manual Input'**
  String get tutorialStep10Title;

  /// No description provided for @tutorialStep10Desc.
  ///
  /// In en, this message translates to:
  /// **'Manually enter meal details.'**
  String get tutorialStep10Desc;

  /// No description provided for @tutorialStep11Title.
  ///
  /// In en, this message translates to:
  /// **'Start Recording'**
  String get tutorialStep11Title;

  /// No description provided for @tutorialStep11Desc.
  ///
  /// In en, this message translates to:
  /// **'Tap the gallery button to start your first record.'**
  String get tutorialStep11Desc;

  /// No description provided for @tutorialStep12Title.
  ///
  /// In en, this message translates to:
  /// **'Record Display'**
  String get tutorialStep12Title;

  /// No description provided for @tutorialStep12Desc.
  ///
  /// In en, this message translates to:
  /// **'Here is the meal you just recorded.'**
  String get tutorialStep12Desc;

  /// No description provided for @tutorialStep13Title.
  ///
  /// In en, this message translates to:
  /// **'Tutorial Complete'**
  String get tutorialStep13Title;

  /// No description provided for @tutorialStep13Desc.
  ///
  /// In en, this message translates to:
  /// **'Congratulations on completing the tutorial! You can now start using CalHub.'**
  String get tutorialStep13Desc;

  /// No description provided for @backupAndRestore.
  ///
  /// In en, this message translates to:
  /// **'Backup & Restore'**
  String get backupAndRestore;

  /// No description provided for @backupData.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get backupData;

  /// No description provided for @restoreData.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get restoreData;

  /// No description provided for @backupDesc.
  ///
  /// In en, this message translates to:
  /// **'Export your data to a file and save it to cloud or share it.'**
  String get backupDesc;

  /// No description provided for @restoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Import data from a backup file. This will overwrite current data.'**
  String get restoreDesc;

  /// No description provided for @backupSuccess.
  ///
  /// In en, this message translates to:
  /// **'Backup successful'**
  String get backupSuccess;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data restored successfully'**
  String get restoreSuccess;

  /// No description provided for @backupFailed.
  ///
  /// In en, this message translates to:
  /// **'Backup failed'**
  String get backupFailed;

  /// No description provided for @restoreFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to restore data'**
  String get restoreFailed;

  /// No description provided for @creatingBackup.
  ///
  /// In en, this message translates to:
  /// **'Creating backup...'**
  String get creatingBackup;

  /// No description provided for @restoringData.
  ///
  /// In en, this message translates to:
  /// **'Restoring data...'**
  String get restoringData;

  /// No description provided for @restoreConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Restore'**
  String get restoreConfirmTitle;

  /// No description provided for @restoreConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Restoring will overwrite all your current data and cannot be undone. Are you sure you want to continue?'**
  String get restoreConfirmMessage;

  /// No description provided for @dataManagement.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get dataManagement;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @loggedInAs.
  ///
  /// In en, this message translates to:
  /// **'Logged in as: {name}'**
  String loggedInAs(Object name);

  /// No description provided for @syncWithICloud.
  ///
  /// In en, this message translates to:
  /// **'Sync with iCloud'**
  String get syncWithICloud;

  /// No description provided for @uploadToCloud.
  ///
  /// In en, this message translates to:
  /// **'Upload to iCloud'**
  String get uploadToCloud;

  /// No description provided for @downloadFromCloud.
  ///
  /// In en, this message translates to:
  /// **'Download from iCloud'**
  String get downloadFromCloud;

  /// No description provided for @cloudSyncSuccess.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync successful'**
  String get cloudSyncSuccess;

  /// No description provided for @cloudSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Cloud sync failed'**
  String get cloudSyncFailed;

  /// No description provided for @startFresh.
  ///
  /// In en, this message translates to:
  /// **'Start Fresh'**
  String get startFresh;

  /// No description provided for @noBackupFound.
  ///
  /// In en, this message translates to:
  /// **'No backup found in iCloud'**
  String get noBackupFound;

  /// No description provided for @nickname.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @quotaExceeded.
  ///
  /// In en, this message translates to:
  /// **'Monthly Free Quota Exceeded'**
  String get quotaExceeded;

  /// No description provided for @quotaExceededDesc.
  ///
  /// In en, this message translates to:
  /// **'Free version allows up to 10 AI recognitions per month. Quota resets on the 1st of each month. Upgrade to Premium for unlimited access.'**
  String get quotaExceededDesc;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @paymentServiceUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Payment service unavailable, please check network connection'**
  String get paymentServiceUnavailable;

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String loadFailed(Object error);

  /// No description provided for @restorePremiumSuccess.
  ///
  /// In en, this message translates to:
  /// **'✅ Successfully restored Premium membership!'**
  String get restorePremiumSuccess;

  /// No description provided for @welcomePremium.
  ///
  /// In en, this message translates to:
  /// **'✅ Welcome to Fooda Premium!'**
  String get welcomePremium;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'❌ {message}'**
  String errorMessage(Object message);

  /// No description provided for @noSubscriptionFound.
  ///
  /// In en, this message translates to:
  /// **'⚠️ No restorable subscription found'**
  String get noSubscriptionFound;

  /// No description provided for @restoreFailedError.
  ///
  /// In en, this message translates to:
  /// **'Restore failed: {error}'**
  String restoreFailedError(Object error);

  /// No description provided for @cannotOpenSubscriptionManagement.
  ///
  /// In en, this message translates to:
  /// **'Cannot open subscription management page'**
  String get cannotOpenSubscriptionManagement;

  /// No description provided for @restorePurchase.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchase'**
  String get restorePurchase;

  /// No description provided for @youArePremium.
  ///
  /// In en, this message translates to:
  /// **'You are a valued Premium member'**
  String get youArePremium;

  /// No description provided for @unlockPremium.
  ///
  /// In en, this message translates to:
  /// **'Unlock Fooda Premium'**
  String get unlockPremium;

  /// No description provided for @enjoyPremiumFeatures.
  ///
  /// In en, this message translates to:
  /// **'Enjoy unlimited AI analysis and exclusive features'**
  String get enjoyPremiumFeatures;

  /// No description provided for @premiumFeaturesSummary.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Recognition • Remove Ads'**
  String get premiumFeaturesSummary;

  /// No description provided for @viewComparison.
  ///
  /// In en, this message translates to:
  /// **'View detailed feature comparison'**
  String get viewComparison;

  /// No description provided for @detailedComparison.
  ///
  /// In en, this message translates to:
  /// **'Detailed Feature Comparison'**
  String get detailedComparison;

  /// No description provided for @unlimitedAI.
  ///
  /// In en, this message translates to:
  /// **'Unlimited AI Recognition'**
  String get unlimitedAI;

  /// No description provided for @noAds.
  ///
  /// In en, this message translates to:
  /// **'No Ads'**
  String get noAds;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @cancelAnytime.
  ///
  /// In en, this message translates to:
  /// **'Cancel Anytime'**
  String get cancelAnytime;

  /// No description provided for @currentPlanActive.
  ///
  /// In en, this message translates to:
  /// **'Current Plan Active'**
  String get currentPlanActive;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Expires in {days} days'**
  String daysRemaining(Object days);

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get manageSubscription;

  /// No description provided for @manageSubscriptionHint.
  ///
  /// In en, this message translates to:
  /// **'To cancel or change plan, please go to Apple ID settings'**
  String get manageSubscriptionHint;

  /// No description provided for @feature.
  ///
  /// In en, this message translates to:
  /// **'Feature'**
  String get feature;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @tenTimesPerMonth.
  ///
  /// In en, this message translates to:
  /// **'10 times/month'**
  String get tenTimesPerMonth;

  /// No description provided for @unlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get unlimited;

  /// No description provided for @historyRecord.
  ///
  /// In en, this message translates to:
  /// **'History Record'**
  String get historyRecord;

  /// No description provided for @dataExport.
  ///
  /// In en, this message translates to:
  /// **'Data Export'**
  String get dataExport;

  /// No description provided for @advancedAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analysis'**
  String get advancedAnalysis;

  /// No description provided for @fourteenDays.
  ///
  /// In en, this message translates to:
  /// **'14 days'**
  String get fourteenDays;

  /// No description provided for @purchaseDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Payment will be charged to your Apple ID account at confirmation of purchase.'**
  String get purchaseDisclaimer;

  /// No description provided for @purchaseInitiationFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase initiation failed'**
  String get purchaseInitiationFailed;

  /// No description provided for @purchaseFailedError.
  ///
  /// In en, this message translates to:
  /// **'Purchase failed: {error}'**
  String purchaseFailedError(Object error);

  /// No description provided for @aiAnalysisResult.
  ///
  /// In en, this message translates to:
  /// **'AI Analysis Result'**
  String get aiAnalysisResult;

  /// No description provided for @updateFailedRetry.
  ///
  /// In en, this message translates to:
  /// **'Update failed, please retry'**
  String get updateFailedRetry;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/ Month'**
  String get perMonth;

  /// No description provided for @sponsorCode.
  ///
  /// In en, this message translates to:
  /// **'Sponsor Code'**
  String get sponsorCode;

  /// No description provided for @enterSponsorCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Sponsor Code'**
  String get enterSponsorCode;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid Code'**
  String get invalidCode;

  /// No description provided for @redemptionSuccess.
  ///
  /// In en, this message translates to:
  /// **'Redemption Successful'**
  String get redemptionSuccess;

  /// No description provided for @loginWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Login with Email'**
  String get loginWithEmail;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @invalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid email or password'**
  String get invalidCredentials;

  /// No description provided for @appleIdConnected.
  ///
  /// In en, this message translates to:
  /// **'Apple ID Connected'**
  String get appleIdConnected;

  /// No description provided for @signInSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Sign in successful'**
  String get signInSuccessful;

  /// No description provided for @signInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed: {error}'**
  String signInFailed(String error);

  /// No description provided for @signOutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get signOutConfirmation;

  /// No description provided for @signedOutSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully'**
  String get signedOutSuccessful;

  /// No description provided for @enterNickname.
  ///
  /// In en, this message translates to:
  /// **'Enter your nickname'**
  String get enterNickname;

  /// No description provided for @freeVersion.
  ///
  /// In en, this message translates to:
  /// **'Free Version'**
  String get freeVersion;

  /// No description provided for @unlockedAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Unlocked all premium features'**
  String get unlockedAllFeatures;

  /// No description provided for @upgradeForUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to unlock unlimited AI recognition'**
  String get upgradeForUnlimited;

  /// No description provided for @manage.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get manage;

  /// No description provided for @upgrade.
  ///
  /// In en, this message translates to:
  /// **'Upgrade'**
  String get upgrade;

  /// No description provided for @localUser.
  ///
  /// In en, this message translates to:
  /// **'Local User'**
  String get localUser;

  /// No description provided for @aiQuota.
  ///
  /// In en, this message translates to:
  /// **'AI: {count}/{total}'**
  String aiQuota(int count, int total);

  /// No description provided for @cameraNotReady.
  ///
  /// In en, this message translates to:
  /// **'Camera not ready'**
  String get cameraNotReady;

  /// No description provided for @cameraTip.
  ///
  /// In en, this message translates to:
  /// **'Place food in center, ensure good lighting'**
  String get cameraTip;

  /// No description provided for @analysisFailedNoFood.
  ///
  /// In en, this message translates to:
  /// **'Analysis failed, please upload a correct food photo'**
  String get analysisFailedNoFood;

  /// No description provided for @recordsRecorded.
  ///
  /// In en, this message translates to:
  /// **'{count} days recorded'**
  String recordsRecorded(int count);

  /// No description provided for @watchAdEarnCredits.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad (+1 Credit)'**
  String get watchAdEarnCredits;

  /// No description provided for @watchNow.
  ///
  /// In en, this message translates to:
  /// **'Watch Now'**
  String get watchNow;

  /// No description provided for @loadingAd.
  ///
  /// In en, this message translates to:
  /// **'Loading Ad...'**
  String get loadingAd;

  /// No description provided for @rewardEarned.
  ///
  /// In en, this message translates to:
  /// **'Earned {amount} credits!'**
  String rewardEarned(int amount);

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObeseMild.
  ///
  /// In en, this message translates to:
  /// **'Mild Obesity'**
  String get bmiObeseMild;

  /// No description provided for @bmiObeseModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Obesity'**
  String get bmiObeseModerate;

  /// No description provided for @bmiObeseSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe Obesity'**
  String get bmiObeseSevere;

  /// No description provided for @analysisCaloriesLowUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}. With a BMI indicating underweight status, it\'s recommended to increase intake of nutrient-dense foods like nuts, avocados, and whole grains.'**
  String analysisCaloriesLowUnderweight(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @analysisCaloriesLowNormal.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}, which is low and may affect basal metabolism. Consider adding nutrient-rich foods to maintain normal body function.'**
  String analysisCaloriesLowNormal(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @analysisCaloriesLowOverweight.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}. Although BMI is higher, insufficient intake may lead to muscle loss. Recommend increasing protein intake while controlling total calories.'**
  String analysisCaloriesLowOverweight(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @analysisCaloriesHighOverweight.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}. BMI indicates a need for weight control. Recommend reducing refined starches and fried foods while increasing vegetables and protein.'**
  String analysisCaloriesHighOverweight(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @analysisCaloriesHighNormal.
  ///
  /// In en, this message translates to:
  /// **'Your average daily calorie intake for {period} is {calories} kcal{daysSuffix}, exceeding recommendations. Long-term excess may lead to weight gain. Suggest controlling portion sizes and choosing low-calorie, nutrient-dense foods.'**
  String analysisCaloriesHighNormal(
    Object calories,
    Object daysSuffix,
    Object period,
  );

  /// No description provided for @analysisProteinLowHighActivity.
  ///
  /// In en, this message translates to:
  /// **'Your high activity level requires more protein for muscle repair and growth. Recommend including high-quality protein (chicken, fish, legumes) in every meal.'**
  String get analysisProteinLowHighActivity;

  /// No description provided for @analysisProteinLowElderly.
  ///
  /// In en, this message translates to:
  /// **'Age 50+ requires more protein to maintain muscle mass. Recommend increasing intake of lean meat, fish, eggs, and other quality proteins.'**
  String get analysisProteinLowElderly;

  /// No description provided for @analysisProteinLowGeneral.
  ///
  /// In en, this message translates to:
  /// **'Protein is essential for body function. Recommend increasing intake of lean meat, fish, legumes, and quality proteins.'**
  String get analysisProteinLowGeneral;

  /// No description provided for @analysisCarbsLowHighActivity.
  ///
  /// In en, this message translates to:
  /// **'High activity levels require sufficient carbohydrates for energy. Suggest increasing intake of whole grains, fruits, and healthy carbs.'**
  String get analysisCarbsLowHighActivity;

  /// No description provided for @analysisCarbsHighLowActivity.
  ///
  /// In en, this message translates to:
  /// **'With lower activity levels, recommend reducing refined starches and increasing the ratio of protein and healthy fats.'**
  String get analysisCarbsHighLowActivity;

  /// No description provided for @analysisFatHighElderlyFemale.
  ///
  /// In en, this message translates to:
  /// **'Females over 50 should be mindful of fat intake. Suggest choosing healthy fat sources like nuts, fish oil, and olive oil.'**
  String get analysisFatHighElderlyFemale;

  /// No description provided for @analysisFatHighGeneral.
  ///
  /// In en, this message translates to:
  /// **'Suggest reducing fried foods and choosing healthy fats like nuts, fish oil, and olive oil.'**
  String get analysisFatHighGeneral;

  /// No description provided for @analysisSodiumHighElderly.
  ///
  /// In en, this message translates to:
  /// **'Age 50+ should limit sodium intake to support healthy blood pressure. Suggest reducing processed foods and seasonings.'**
  String get analysisSodiumHighElderly;

  /// No description provided for @analysisSodiumHighGeneral.
  ///
  /// In en, this message translates to:
  /// **'Excessive sodium may affect blood pressure. Suggest reducing processed foods, pickled foods, and seasonings.'**
  String get analysisSodiumHighGeneral;

  /// No description provided for @analysisFiberLowElderlyFemale.
  ///
  /// In en, this message translates to:
  /// **'Females over 50 need more fiber for gut health. Suggest increasing intake of vegetables, fruits, and whole grains.'**
  String get analysisFiberLowElderlyFemale;

  /// No description provided for @analysisFiberLowGeneral.
  ///
  /// In en, this message translates to:
  /// **'Fiber supports gut health and blood sugar control. Suggest increasing vegetables, fruits, and whole grains.'**
  String get analysisFiberLowGeneral;

  /// No description provided for @analysisBmiUnderweightWarning.
  ///
  /// In en, this message translates to:
  /// **'Your BMI indicates you are underweight. It is recommended to increase your intake of nutrient-dense foods and consult a nutritionist.'**
  String get analysisBmiUnderweightWarning;

  /// No description provided for @analysisBmiOverweightWarning.
  ///
  /// In en, this message translates to:
  /// **'Weight management under professional guidance is recommended. Ensure balanced nutrition while controlling calorie intake.'**
  String get analysisBmiOverweightWarning;

  /// No description provided for @warningFried.
  ///
  /// In en, this message translates to:
  /// **'💛 Fried food, consume in moderation.'**
  String get warningFried;

  /// No description provided for @warningSugar.
  ///
  /// In en, this message translates to:
  /// **'🍯 High sugar/fat, enjoy in moderation.'**
  String get warningSugar;

  /// No description provided for @warningProtein.
  ///
  /// In en, this message translates to:
  /// **'🍖 Protein rich, pair with veggies.'**
  String get warningProtein;

  /// No description provided for @warningVeg.
  ///
  /// In en, this message translates to:
  /// **'🥗 Vitamin/Fiber rich, excellent choice.'**
  String get warningVeg;

  /// No description provided for @warningBalanced.
  ///
  /// In en, this message translates to:
  /// **'🌟 Balanced diet, healthy living.'**
  String get warningBalanced;

  /// No description provided for @advancedAnalysisFeature.
  ///
  /// In en, this message translates to:
  /// **'Advanced Analysis'**
  String get advancedAnalysisFeature;

  /// No description provided for @unlockPremiumAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium to unlock detailed Weekly and Monthly nutrition analysis.'**
  String get unlockPremiumAnalysis;

  /// No description provided for @applySuggestion.
  ///
  /// In en, this message translates to:
  /// **'Apply Suggestion'**
  String get applySuggestion;

  /// No description provided for @smartSuggestionTitle.
  ///
  /// In en, this message translates to:
  /// **'Smart Nutrition Suggestion'**
  String get smartSuggestionTitle;

  /// No description provided for @smartSuggestionDesc.
  ///
  /// In en, this message translates to:
  /// **'Based on your profile ({age} years, {gender}, {weight}kg, {activity})'**
  String smartSuggestionDesc(
    Object activity,
    Object age,
    Object gender,
    Object weight,
  );

  /// No description provided for @suggestionApplied.
  ///
  /// In en, this message translates to:
  /// **'Smart suggestions applied'**
  String get suggestionApplied;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a number between {min} and {max}'**
  String enterValidNumber(Object max, Object min);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'CN':
            return AppLocalizationsZhCn();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
