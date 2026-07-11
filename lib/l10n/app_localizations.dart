import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

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
    Locale('tr'),
  ];

  /// Uygulama adı
  ///
  /// In tr, this message translates to:
  /// **'Future Self'**
  String get appTitle;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In tr, this message translates to:
  /// **'Ekle'**
  String get add;

  /// No description provided for @continueButton.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get continueButton;

  /// No description provided for @continueShort.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueShort;

  /// No description provided for @back.
  ///
  /// In tr, this message translates to:
  /// **'Geri'**
  String get back;

  /// No description provided for @loading.
  ///
  /// In tr, this message translates to:
  /// **'Yükleniyor…'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti'**
  String get error;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @yes.
  ///
  /// In tr, this message translates to:
  /// **'Evet'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In tr, this message translates to:
  /// **'Hayır'**
  String get no;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @done.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get done;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  /// No description provided for @deleteAccountAction.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı Sil'**
  String get deleteAccountAction;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabını silmek istediğine emin misin?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem GERİ ALINAMAZ. Tüm hedeflerin, geçmişin, mission\'ların, paylaşımların ve tüm verilerin kalıcı olarak silinecek.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountConfirmWord.
  ///
  /// In tr, this message translates to:
  /// **'SİL'**
  String get deleteAccountConfirmWord;

  /// No description provided for @deleteAccountConfirmHint.
  ///
  /// In tr, this message translates to:
  /// **'Onaylamak için \"{word}\" yaz'**
  String deleteAccountConfirmHint(String word);

  /// No description provided for @deleteAccountConfirmButton.
  ///
  /// In tr, this message translates to:
  /// **'Hesabımı Sil'**
  String get deleteAccountConfirmButton;

  /// No description provided for @deleteAccountFailed.
  ///
  /// In tr, this message translates to:
  /// **'Hesap silinemedi, tekrar dene.'**
  String get deleteAccountFailed;

  /// No description provided for @accountDeletedMessage.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silindi.'**
  String get accountDeletedMessage;

  /// No description provided for @reauthPasswordTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni doğrula'**
  String get reauthPasswordTitle;

  /// No description provided for @reauthPasswordBody.
  ///
  /// In tr, this message translates to:
  /// **'Güvenlik için hesabını silmeden önce şifreni tekrar girmen gerekiyor.'**
  String get reauthPasswordBody;

  /// No description provided for @reauthConfirmButton.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get reauthConfirmButton;

  /// No description provided for @comingSoon.
  ///
  /// In tr, this message translates to:
  /// **'Yakında'**
  String get comingSoon;

  /// No description provided for @today.
  ///
  /// In tr, this message translates to:
  /// **'Bugün'**
  String get today;

  /// No description provided for @welcomeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin!'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın hazır. Şimdi seni biraz tanıyalım — her gün attığın küçük adımlar, gelecekteki halini şekillendirecek.'**
  String get welcomeSubtitle;

  /// No description provided for @categoriesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hangi alanlarda ilerlemek istiyorsun?'**
  String get categoriesTitle;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İstediğin kadar seç, sonra değiştirebilirsin.'**
  String get categoriesSubtitle;

  /// No description provided for @currentStateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şu an neredesin?'**
  String get currentStateTitle;

  /// No description provided for @currentStateSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü durumunu ve hedefini gir. Hepsi opsiyonel, sonra da doldurabilirsin.'**
  String get currentStateSubtitle;

  /// No description provided for @addMetric.
  ///
  /// In tr, this message translates to:
  /// **'Metrik ekle'**
  String get addMetric;

  /// No description provided for @addMetricFor.
  ///
  /// In tr, this message translates to:
  /// **'{category} için metrik ekle'**
  String addMetricFor(String category);

  /// No description provided for @nowLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi'**
  String get nowLabel;

  /// No description provided for @targetLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef'**
  String get targetLabel;

  /// No description provided for @decreasingHint.
  ///
  /// In tr, this message translates to:
  /// **'Hedef, şimdikinden düşük olmalı'**
  String get decreasingHint;

  /// No description provided for @currentLevelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şimdiki seviye'**
  String get currentLevelLabel;

  /// No description provided for @targetLevelLabel.
  ///
  /// In tr, this message translates to:
  /// **'Hedef seviye'**
  String get targetLevelLabel;

  /// No description provided for @freeTextHint.
  ///
  /// In tr, this message translates to:
  /// **'Hedefin ne?'**
  String get freeTextHint;

  /// No description provided for @notificationsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Future You seninle konuşsun mu?'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Günde birkaç kez, ilerlemeni fark ettiren nazik hatırlatmalar gönderelim. İstediğin zaman kapatabilirsin.'**
  String get notificationsSubtitle;

  /// No description provided for @morningMotivation.
  ///
  /// In tr, this message translates to:
  /// **'Sabah motivasyonu'**
  String get morningMotivation;

  /// No description provided for @streakReminders.
  ///
  /// In tr, this message translates to:
  /// **'Seri hatırlatmaları'**
  String get streakReminders;

  /// No description provided for @eveningSummary.
  ///
  /// In tr, this message translates to:
  /// **'Akşam özeti'**
  String get eveningSummary;

  /// No description provided for @allowNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimlere izin ver'**
  String get allowNotifications;

  /// No description provided for @notNow.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi değil'**
  String get notNow;

  /// No description provided for @accountTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğunu kaydedelim'**
  String get accountTitle;

  /// No description provided for @accountSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemenin kaybolmaması için bir hesap oluştur.'**
  String get accountSubtitle;

  /// No description provided for @continueWithApple.
  ///
  /// In tr, this message translates to:
  /// **'Apple ile devam et'**
  String get continueWithApple;

  /// No description provided for @continueWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile devam et'**
  String get continueWithGoogle;

  /// No description provided for @continueWithEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile devam et'**
  String get continueWithEmail;

  /// No description provided for @orSeparator.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get orSeparator;

  /// No description provided for @termsNotice.
  ///
  /// In tr, this message translates to:
  /// **'Devam ederek Kullanım Şartları ve Gizlilik Politikasını kabul etmiş olursun.'**
  String get termsNotice;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signUp;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get signIn;

  /// No description provided for @emailLabel.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get passwordLabel;

  /// No description provided for @emailPasswordRequired.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ve şifreni gir.'**
  String get emailPasswordRequired;

  /// No description provided for @categoryHealth.
  ///
  /// In tr, this message translates to:
  /// **'Sağlık'**
  String get categoryHealth;

  /// No description provided for @categoryCareer.
  ///
  /// In tr, this message translates to:
  /// **'Kariyer'**
  String get categoryCareer;

  /// No description provided for @categoryFinance.
  ///
  /// In tr, this message translates to:
  /// **'Finans'**
  String get categoryFinance;

  /// No description provided for @categoryLearning.
  ///
  /// In tr, this message translates to:
  /// **'Öğrenme'**
  String get categoryLearning;

  /// No description provided for @categoryRelationships.
  ///
  /// In tr, this message translates to:
  /// **'İlişkiler'**
  String get categoryRelationships;

  /// No description provided for @categorySpirituality.
  ///
  /// In tr, this message translates to:
  /// **'Maneviyat'**
  String get categorySpirituality;

  /// No description provided for @categoryPersonalGrowth.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Gelişim'**
  String get categoryPersonalGrowth;

  /// No description provided for @templateWeight.
  ///
  /// In tr, this message translates to:
  /// **'Kilo'**
  String get templateWeight;

  /// No description provided for @templateExerciseFrequency.
  ///
  /// In tr, this message translates to:
  /// **'Egzersiz sıklığı'**
  String get templateExerciseFrequency;

  /// No description provided for @templateFreeGoal.
  ///
  /// In tr, this message translates to:
  /// **'Serbest hedef'**
  String get templateFreeGoal;

  /// No description provided for @templateCareerLevel.
  ///
  /// In tr, this message translates to:
  /// **'Seviye'**
  String get templateCareerLevel;

  /// No description provided for @templateTargetPosition.
  ///
  /// In tr, this message translates to:
  /// **'Hedef pozisyon'**
  String get templateTargetPosition;

  /// No description provided for @templateSalary.
  ///
  /// In tr, this message translates to:
  /// **'Maaş'**
  String get templateSalary;

  /// No description provided for @templateSavings.
  ///
  /// In tr, this message translates to:
  /// **'Birikim'**
  String get templateSavings;

  /// No description provided for @templateGold.
  ///
  /// In tr, this message translates to:
  /// **'Altın'**
  String get templateGold;

  /// No description provided for @templateCrypto.
  ///
  /// In tr, this message translates to:
  /// **'Kripto'**
  String get templateCrypto;

  /// No description provided for @templateCardDebt.
  ///
  /// In tr, this message translates to:
  /// **'Kart borcu'**
  String get templateCardDebt;

  /// No description provided for @templateLanguageLevel.
  ///
  /// In tr, this message translates to:
  /// **'Dil seviyesi'**
  String get templateLanguageLevel;

  /// No description provided for @templateTopicCourse.
  ///
  /// In tr, this message translates to:
  /// **'Konu / kurs'**
  String get templateTopicCourse;

  /// No description provided for @goalsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Hedefler yüklenemedi. Bağlantını kontrol et.\n{error}'**
  String goalsLoadError(String error);

  /// No description provided for @statusNoGoals.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hedef eklemedin. İlk hedefinle yolculuğu başlat.'**
  String get statusNoGoals;

  /// No description provided for @statusQuietWeek.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta biraz sessiz geçti. Küçük bir adım bile Future You\'yu yaklaştırır.'**
  String get statusQuietWeek;

  /// No description provided for @statusStreak.
  ///
  /// In tr, this message translates to:
  /// **'{count} günlük serin var — geçen haftadan daha istikrarlı ilerliyorsun.'**
  String statusStreak(int count);

  /// No description provided for @statusProgress.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{Güzel gidiyorsun. Bu hafta {count} hedefinde ilerleme kaydettin.}}'**
  String statusProgress(int count);

  /// No description provided for @defaultUserName.
  ///
  /// In tr, this message translates to:
  /// **'Gezgin'**
  String get defaultUserName;

  /// No description provided for @levelXp.
  ///
  /// In tr, this message translates to:
  /// **'Level {level} • {xp} XP'**
  String levelXp(int level, int xp);

  /// No description provided for @todayProgress.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü İlerleme'**
  String get todayProgress;

  /// No description provided for @goalsProgressedCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, other{{count} hedef ilerletildi}}'**
  String goalsProgressedCount(int count);

  /// No description provided for @dayStreak.
  ///
  /// In tr, this message translates to:
  /// **'{count} günlük seri'**
  String dayStreak(int count);

  /// No description provided for @freezeIndicator.
  ///
  /// In tr, this message translates to:
  /// **'🧊 x{count}'**
  String freezeIndicator(int count);

  /// No description provided for @freezeDialogTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seri Dondurma 🧊'**
  String get freezeDialogTitle;

  /// No description provided for @freezeDialogBody.
  ///
  /// In tr, this message translates to:
  /// **'Bir günü kaçırırsan serini korur — atlanan gün hiç olmamış gibi devam edersin. Her ay 2 dondurma hakkı yenilenir ve gerektiğinde kendiliğinden kullanılır.'**
  String get freezeDialogBody;

  /// No description provided for @gotIt.
  ///
  /// In tr, this message translates to:
  /// **'Anladım'**
  String get gotIt;

  /// No description provided for @noEmailInfo.
  ///
  /// In tr, this message translates to:
  /// **'E-posta bilgisi yok'**
  String get noEmailInfo;

  /// No description provided for @activeGoals.
  ///
  /// In tr, this message translates to:
  /// **'Aktif Hedefler'**
  String get activeGoals;

  /// No description provided for @weeklyChallengeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bu Haftanın Meydan Okuması'**
  String get weeklyChallengeTitle;

  /// No description provided for @plusXp.
  ///
  /// In tr, this message translates to:
  /// **'+{xp} XP'**
  String plusXp(int xp);

  /// No description provided for @challengeCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı! +{xp} XP kazandın 🎉'**
  String challengeCompleted(int xp);

  /// No description provided for @inProgress.
  ///
  /// In tr, this message translates to:
  /// **'Devam ediyor'**
  String get inProgress;

  /// No description provided for @percentOnly.
  ///
  /// In tr, this message translates to:
  /// **'%{percent}'**
  String percentOnly(int percent);

  /// No description provided for @percentWithEstimate.
  ///
  /// In tr, this message translates to:
  /// **'%{percent} • tahmini {date}'**
  String percentWithEstimate(int percent, String date);

  /// No description provided for @estimatedDate.
  ///
  /// In tr, this message translates to:
  /// **'tahmini {date}'**
  String estimatedDate(String date);

  /// No description provided for @goalCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get goalCompleted;

  /// No description provided for @completedGoalsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Hedefler'**
  String get completedGoalsTitle;

  /// No description provided for @completedGoalsEntry.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan Hedefler ({count})'**
  String completedGoalsEntry(int count);

  /// No description provided for @completedOnDate.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı · {date}'**
  String completedOnDate(String date);

  /// No description provided for @noCompletedGoalsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz tamamlanan hedef yok.'**
  String get noCompletedGoalsYet;

  /// No description provided for @quickUpdate.
  ///
  /// In tr, this message translates to:
  /// **'Hızlı güncelle'**
  String get quickUpdate;

  /// No description provided for @noGoalsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hedefin yok'**
  String get noGoalsYet;

  /// No description provided for @noGoalsYetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Future You seni bekliyor. İlk hedefini ekle.'**
  String get noGoalsYetSubtitle;

  /// No description provided for @addGoal.
  ///
  /// In tr, this message translates to:
  /// **'Hedef ekle'**
  String get addGoal;

  /// No description provided for @newValueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni değer'**
  String get newValueLabel;

  /// No description provided for @freeTextProgressQuestion.
  ///
  /// In tr, this message translates to:
  /// **'Bu hedefte bugün ilerleme kaydettin mi?'**
  String get freeTextProgressQuestion;

  /// No description provided for @recordProgressWithXp.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme kaydet (+{xp} XP)'**
  String recordProgressWithXp(int xp);

  /// No description provided for @saveWithXp.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet (+{xp} XP)'**
  String saveWithXp(int xp);

  /// No description provided for @saveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi, tekrar dene.'**
  String get saveFailed;

  /// No description provided for @deleteDialogStreakTitle.
  ///
  /// In tr, this message translates to:
  /// **'{streak} günlük serini bırakmak üzeresin'**
  String deleteDialogStreakTitle(int streak);

  /// No description provided for @deleteDialogGenericTitle.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemeni bırakmak üzeresin'**
  String get deleteDialogGenericTitle;

  /// No description provided for @deleteDialogMessageWithValues.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde {from}\'den {to}\'ye kadar geldin ve {xp} XP kazandın. Bu hedefi silersen bu ilerleme geçmişi de silinir.'**
  String deleteDialogMessageWithValues(
    String title,
    String from,
    String to,
    int xp,
  );

  /// No description provided for @deleteDialogMessageXpOnly.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde şimdiye kadar {xp} XP kazandın. Bu hedefi silersen bu ilerleme geçmişi de silinir.'**
  String deleteDialogMessageXpOnly(String title, int xp);

  /// No description provided for @goalLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Hedef yüklenemedi.\n{error}'**
  String goalLoadError(String error);

  /// No description provided for @goalNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Hedef bulunamadı.'**
  String get goalNotFound;

  /// No description provided for @deleteGoalTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi sil'**
  String get deleteGoalTooltip;

  /// No description provided for @keepGoing.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek istiyorum'**
  String get keepGoing;

  /// No description provided for @deleteAnyway.
  ///
  /// In tr, this message translates to:
  /// **'Yine de sil'**
  String get deleteAnyway;

  /// No description provided for @deleteFailed.
  ///
  /// In tr, this message translates to:
  /// **'Silinemedi, tekrar dene.'**
  String get deleteFailed;

  /// No description provided for @nowValue.
  ///
  /// In tr, this message translates to:
  /// **'Şimdi: {value}'**
  String nowValue(String value);

  /// No description provided for @targetValueText.
  ///
  /// In tr, this message translates to:
  /// **'Hedef: {value}'**
  String targetValueText(String value);

  /// No description provided for @daysCount.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün'**
  String daysCount(int count);

  /// No description provided for @xpValue.
  ///
  /// In tr, this message translates to:
  /// **'{xp} XP'**
  String xpValue(int xp);

  /// No description provided for @streakLabel.
  ///
  /// In tr, this message translates to:
  /// **'Seri'**
  String get streakLabel;

  /// No description provided for @earnedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Kazanılan'**
  String get earnedLabel;

  /// No description provided for @recordProgress.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme kaydet'**
  String get recordProgress;

  /// No description provided for @historyLabel.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş'**
  String get historyLabel;

  /// No description provided for @historyLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Geçmiş yüklenemedi.'**
  String get historyLoadError;

  /// No description provided for @noHistoryYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kayıt yok'**
  String get noHistoryYet;

  /// No description provided for @progressRecorded.
  ///
  /// In tr, this message translates to:
  /// **'İlerleme kaydedildi'**
  String get progressRecorded;

  /// No description provided for @addGoalTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Ekle'**
  String get addGoalTitle;

  /// No description provided for @whichArea.
  ///
  /// In tr, this message translates to:
  /// **'Hangi alanda?'**
  String get whichArea;

  /// No description provided for @pickMetricFor.
  ///
  /// In tr, this message translates to:
  /// **'{category} için bir metrik seç'**
  String pickMetricFor(String category);

  /// No description provided for @alreadyAdded.
  ///
  /// In tr, this message translates to:
  /// **'Zaten eklendi'**
  String get alreadyAdded;

  /// No description provided for @freeTextType.
  ///
  /// In tr, this message translates to:
  /// **'Serbest metin'**
  String get freeTextType;

  /// No description provided for @addGoalSubmit.
  ///
  /// In tr, this message translates to:
  /// **'Hedefi ekle'**
  String get addGoalSubmit;

  /// No description provided for @goalAdded.
  ///
  /// In tr, this message translates to:
  /// **'Hedef eklendi.'**
  String get goalAdded;

  /// No description provided for @addFailed.
  ///
  /// In tr, this message translates to:
  /// **'Eklenemedi, tekrar dene.'**
  String get addFailed;

  /// No description provided for @lifeMissions.
  ///
  /// In tr, this message translates to:
  /// **'Hayat Görevleri'**
  String get lifeMissions;

  /// No description provided for @addMission.
  ///
  /// In tr, this message translates to:
  /// **'Görev ekle'**
  String get addMission;

  /// No description provided for @missionsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Görevler yüklenemedi.\n{error}'**
  String missionsLoadError(String error);

  /// No description provided for @missionsSummary.
  ///
  /// In tr, this message translates to:
  /// **'{total} görev · {completed} tamamlandı'**
  String missionsSummary(int total, int completed);

  /// No description provided for @addedDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Bugün eklendi} other{{count} gün önce eklendi}}'**
  String addedDaysAgo(int count);

  /// No description provided for @completedLabel.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı'**
  String get completedLabel;

  /// No description provided for @completedDaysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Tamamlandı · bugün} other{Tamamlandı · {count} gün önce}}'**
  String completedDaysAgo(int count);

  /// No description provided for @gentleReminder.
  ///
  /// In tr, this message translates to:
  /// **'{count} gündür bu hedefe dokunmadın, hatırlaman için buradayız'**
  String gentleReminder(int count);

  /// No description provided for @noNotesYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz not yok'**
  String get noNotesYet;

  /// No description provided for @noMissionsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz görev yok'**
  String get noMissionsYet;

  /// No description provided for @noMissionsYetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hayatta yapmak istediklerini buraya ekle — küçük ya da büyük, hepsi sayılır.'**
  String get noMissionsYetSubtitle;

  /// No description provided for @missionTitleHint.
  ///
  /// In tr, this message translates to:
  /// **'Ne başarmak istiyorsun?'**
  String get missionTitleHint;

  /// No description provided for @missionLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Görev yüklenemedi.\n{error}'**
  String missionLoadError(String error);

  /// No description provided for @missionNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Görev bulunamadı.'**
  String get missionNotFound;

  /// No description provided for @addedOn.
  ///
  /// In tr, this message translates to:
  /// **'Eklendi: {date}'**
  String addedOn(String date);

  /// No description provided for @markCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlandı olarak işaretle'**
  String get markCompleted;

  /// No description provided for @markIncomplete.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanmadı olarak işaretle'**
  String get markIncomplete;

  /// No description provided for @notesLabel.
  ///
  /// In tr, this message translates to:
  /// **'Notlar'**
  String get notesLabel;

  /// No description provided for @missionNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir gelişme, bir düşünce…'**
  String get missionNoteHint;

  /// No description provided for @addNote.
  ///
  /// In tr, this message translates to:
  /// **'Not ekle'**
  String get addNote;

  /// No description provided for @noteAddFailed.
  ///
  /// In tr, this message translates to:
  /// **'Not eklenemedi, tekrar dene.'**
  String get noteAddFailed;

  /// No description provided for @deleteMissionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Görev silinsin mi?'**
  String get deleteMissionTitle;

  /// No description provided for @deleteMissionConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu hedefi silmek istediğine emin misin?'**
  String get deleteMissionConfirm;

  /// No description provided for @lifeLessons.
  ///
  /// In tr, this message translates to:
  /// **'Hayat Dersleri'**
  String get lifeLessons;

  /// No description provided for @share.
  ///
  /// In tr, this message translates to:
  /// **'Paylaş'**
  String get share;

  /// No description provided for @feedTab.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get feedTab;

  /// No description provided for @savedTab.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get savedTab;

  /// No description provided for @lessonsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşımlar yüklenemedi.\n{error}'**
  String lessonsLoadError(String error);

  /// No description provided for @noLessonsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz paylaşım yok'**
  String get noLessonsYet;

  /// No description provided for @noLessonsYetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'İlk dersi sen paylaş — biri buna ihtiyaç duyuyor olabilir.'**
  String get noLessonsYetSubtitle;

  /// No description provided for @noSavedLessonsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz kaydettiğin bir paylaşım yok'**
  String get noSavedLessonsYet;

  /// No description provided for @noSavedLessonsYetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Akıştan bookmark ikonuyla kaydettiklerin burada birikecek.'**
  String get noSavedLessonsYetSubtitle;

  /// No description provided for @report.
  ///
  /// In tr, this message translates to:
  /// **'Bildir'**
  String get report;

  /// No description provided for @reportLessonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiyi bildirmek istediğine emin misin?'**
  String get reportLessonConfirm;

  /// No description provided for @reportCommentConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu yorumu bildirmek istediğine emin misin?'**
  String get reportCommentConfirm;

  /// No description provided for @reportThanks.
  ///
  /// In tr, this message translates to:
  /// **'Bildirdiğin için teşekkürler.'**
  String get reportThanks;

  /// No description provided for @deleteLessonTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi silinsin mi?'**
  String get deleteLessonTitle;

  /// No description provided for @deleteLessonConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Bu gönderiyi silmek istediğine emin misin? Bu işlem geri alınamaz.'**
  String get deleteLessonConfirm;

  /// No description provided for @lessonTextHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir deneyimini veya pişmanlığını paylaş...'**
  String get lessonTextHint;

  /// No description provided for @anonymousNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu paylaşım anonim olarak görünecek.'**
  String get anonymousNotice;

  /// No description provided for @profanityWarning.
  ///
  /// In tr, this message translates to:
  /// **'Bu metin uygun olmayan bir ifade içeriyor gibi görünüyor, lütfen düzenle.'**
  String get profanityWarning;

  /// No description provided for @shareFailed.
  ///
  /// In tr, this message translates to:
  /// **'Paylaşılamadı, tekrar dene.'**
  String get shareFailed;

  /// No description provided for @commentsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar'**
  String get commentsTitle;

  /// No description provided for @lessonLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi yüklenemedi.\n{error}'**
  String lessonLoadError(String error);

  /// No description provided for @lessonNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Gönderi bulunamadı.'**
  String get lessonNotFound;

  /// No description provided for @commentsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Yorumlar yüklenemedi.'**
  String get commentsLoadError;

  /// No description provided for @noCommentsYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz yorum yok — ilk yorumu sen yaz.'**
  String get noCommentsYet;

  /// No description provided for @commentHint.
  ///
  /// In tr, this message translates to:
  /// **'Anonim bir yorum yaz…'**
  String get commentHint;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @commentSendFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yorum gönderilemedi, tekrar dene.'**
  String get commentSendFailed;

  /// No description provided for @justNow.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk önce'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} sa önce'**
  String hoursAgo(int count);

  /// No description provided for @daysAgo.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String daysAgo(int count);

  /// No description provided for @coachEmptyMessage.
  ///
  /// In tr, this message translates to:
  /// **'Henüz hedefin yok. İlk hedefini eklediğinde Future You için sana özel düşünceler burada olacak.'**
  String get coachEmptyMessage;

  /// No description provided for @coachStreakWithGoal.
  ///
  /// In tr, this message translates to:
  /// **'{count} günlük serin var — bu tempo seni \'{title}\' hedefinde daha erken sonuca taşıyabilir.'**
  String coachStreakWithGoal(int count, String title);

  /// No description provided for @coachStreakGeneric.
  ///
  /// In tr, this message translates to:
  /// **'{count} günlük serin var — bu istikrar Future You\'ya yapılmış en iyi yatırım.'**
  String coachStreakGeneric(int count);

  /// No description provided for @coachNeglected.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefin {days} gündür seni bekliyor. Küçük bir güncelleme bile ivmeyi geri getirir — hazır olduğunda oradayız.'**
  String coachNeglected(String title, int days);

  /// No description provided for @coachTipRegular1.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde bu ritmi koruyorsun, harika gidiyor.'**
  String coachTipRegular1(String title);

  /// No description provided for @coachTipRegular2.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' konusunda son günlerde gerçekten istikrarlısın.'**
  String coachTipRegular2(String title);

  /// No description provided for @coachTipRegular3.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefin tam yolunda — böyle devam.'**
  String coachTipRegular3(String title);

  /// No description provided for @coachTipRegular4.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' için attığın düzenli adımlar birikmeye başladı bile.'**
  String coachTipRegular4(String title);

  /// No description provided for @coachTipRegular5.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefindeki tempon Future You\'nun işini kolaylaştırıyor.'**
  String coachTipRegular5(String title);

  /// No description provided for @coachTipRegular6.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde ivmen yerinde; küçük adımlar büyük fark yaratıyor.'**
  String coachTipRegular6(String title);

  /// No description provided for @coachTipUntouched1.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefine bugün küçük bir adım atsan nasıl olur?'**
  String coachTipUntouched1(String title);

  /// No description provided for @coachTipUntouched2.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' seni bekliyor — ne dersin?'**
  String coachTipUntouched2(String title);

  /// No description provided for @coachTipUntouched3.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' için ilk kaydı bugün açmak ister misin?'**
  String coachTipUntouched3(String title);

  /// No description provided for @coachTipUntouched4.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde başlamak, en zor kısmın yarısıdır.'**
  String coachTipUntouched4(String title);

  /// No description provided for @coachTipUntouched5.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' için beş dakikalık bir başlangıç bile sayılır.'**
  String coachTipUntouched5(String title);

  /// No description provided for @coachTipUntouched6.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefine giden yol ilk adımla açılır; bugün iyi bir gün.'**
  String coachTipUntouched6(String title);

  /// No description provided for @reflectionQuestion1.
  ///
  /// In tr, this message translates to:
  /// **'Hedeflerine doğru attığın en küçük adım neydi bu hafta?'**
  String get reflectionQuestion1;

  /// No description provided for @reflectionQuestion2.
  ///
  /// In tr, this message translates to:
  /// **'Seni bu hafta en çok ne motive etti?'**
  String get reflectionQuestion2;

  /// No description provided for @reflectionQuestion3.
  ///
  /// In tr, this message translates to:
  /// **'Bugün gelecekteki halin için ne yaptın?'**
  String get reflectionQuestion3;

  /// No description provided for @reflectionQuestion4.
  ///
  /// In tr, this message translates to:
  /// **'Bir yıl önceki sen, bugünkü halini görse neye şaşırırdı?'**
  String get reflectionQuestion4;

  /// No description provided for @reflectionQuestion5.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta neyi ertelediğini fark ettin?'**
  String get reflectionQuestion5;

  /// No description provided for @reflectionQuestion6.
  ///
  /// In tr, this message translates to:
  /// **'Enerjini en çok ne tüketiyor, ne geri kazandırıyor?'**
  String get reflectionQuestion6;

  /// No description provided for @reflectionQuestion7.
  ///
  /// In tr, this message translates to:
  /// **'Hangi alışkanlığın seni hedefinden uzaklaştırıyor olabilir?'**
  String get reflectionQuestion7;

  /// No description provided for @reflectionQuestion8.
  ///
  /// In tr, this message translates to:
  /// **'Bugün kendine teşekkür etsen, ne için olurdu?'**
  String get reflectionQuestion8;

  /// No description provided for @reflectionQuestion9.
  ///
  /// In tr, this message translates to:
  /// **'Hedeflerinden hangisi seni gerçekten heyecanlandırıyor?'**
  String get reflectionQuestion9;

  /// No description provided for @reflectionQuestion10.
  ///
  /// In tr, this message translates to:
  /// **'Son bir ayda kendinle ilgili ne öğrendin?'**
  String get reflectionQuestion10;

  /// No description provided for @reflectionQuestion11.
  ///
  /// In tr, this message translates to:
  /// **'Yarın sabah tek bir şeyi farklı yapabilseydin, ne olurdu?'**
  String get reflectionQuestion11;

  /// No description provided for @reflectionQuestion12.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta kim ya da ne sana iyi geldi?'**
  String get reflectionQuestion12;

  /// No description provided for @reflectionQuestion13.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeçmeyi düşündüğün ama devam ettiğin bir şey var mı?'**
  String get reflectionQuestion13;

  /// No description provided for @reflectionQuestion14.
  ///
  /// In tr, this message translates to:
  /// **'Beş yıl sonraki sen bugünkü sana ne tavsiye ederdi?'**
  String get reflectionQuestion14;

  /// No description provided for @reflectionQuestion15.
  ///
  /// In tr, this message translates to:
  /// **'Bugün seni gülümseten küçük bir an var mıydı?'**
  String get reflectionQuestion15;

  /// No description provided for @reflectionQuestion16.
  ///
  /// In tr, this message translates to:
  /// **'Hangi hedefin artık sana ait hissettirmiyor olabilir?'**
  String get reflectionQuestion16;

  /// No description provided for @reflectionQuestion17.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta hayır demen gereken ama evet dediğin bir şey oldu mu?'**
  String get reflectionQuestion17;

  /// No description provided for @reflectionQuestion18.
  ///
  /// In tr, this message translates to:
  /// **'Kendini en son ne zaman gerçekten dinlendin?'**
  String get reflectionQuestion18;

  /// No description provided for @reflectionQuestion19.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemeni kimseyle kıyaslamadan değerlendirsen ne görürsün?'**
  String get reflectionQuestion19;

  /// No description provided for @reflectionQuestion20.
  ///
  /// In tr, this message translates to:
  /// **'Bugün başladığın işi yarına bırakmamanı sağlayan şey ne olurdu?'**
  String get reflectionQuestion20;

  /// No description provided for @reflectionQuestion21.
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki halinin günlük rutininde neler var?'**
  String get reflectionQuestion21;

  /// No description provided for @reflectionQuestion22.
  ///
  /// In tr, this message translates to:
  /// **'Bu ay bırakmak istediğin bir alışkanlık var mı? Yerine ne koyardın?'**
  String get reflectionQuestion22;

  /// No description provided for @motivationalQuote1.
  ///
  /// In tr, this message translates to:
  /// **'Bugün attığın her adım, yarınki sana bir hediye.'**
  String get motivationalQuote1;

  /// No description provided for @motivationalQuote2.
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki sen, bugünkü kararlarının toplamı.'**
  String get motivationalQuote2;

  /// No description provided for @motivationalQuote3.
  ///
  /// In tr, this message translates to:
  /// **'Küçük adımlar sessizdir ama en uzağa onlar taşır.'**
  String get motivationalQuote3;

  /// No description provided for @motivationalQuote4.
  ///
  /// In tr, this message translates to:
  /// **'Mükemmel gün yok; sadece bugün var.'**
  String get motivationalQuote4;

  /// No description provided for @motivationalQuote5.
  ///
  /// In tr, this message translates to:
  /// **'İstikrar, motivasyonun bittiği yerde başlar.'**
  String get motivationalQuote5;

  /// No description provided for @motivationalQuote6.
  ///
  /// In tr, this message translates to:
  /// **'Bir yıl sonra, bugün başlamış olmayı dileyeceksin.'**
  String get motivationalQuote6;

  /// No description provided for @motivationalQuote7.
  ///
  /// In tr, this message translates to:
  /// **'Yavaş ilerlemek, durmaktan sonsuz kat hızlıdır.'**
  String get motivationalQuote7;

  /// No description provided for @motivationalQuote8.
  ///
  /// In tr, this message translates to:
  /// **'Kendine verdiğin sözler de tutulmayı hak eder.'**
  String get motivationalQuote8;

  /// No description provided for @motivationalQuote9.
  ///
  /// In tr, this message translates to:
  /// **'Değişim büyük anlarda değil, sıradan günlerde olur.'**
  String get motivationalQuote9;

  /// No description provided for @motivationalQuote10.
  ///
  /// In tr, this message translates to:
  /// **'Bugünün %1\'i, yarının bambaşka bir versiyonudur.'**
  String get motivationalQuote10;

  /// No description provided for @motivationalQuote11.
  ///
  /// In tr, this message translates to:
  /// **'Zor olan başlamak değil, yeniden başlamaktan korkmamak.'**
  String get motivationalQuote11;

  /// No description provided for @motivationalQuote12.
  ///
  /// In tr, this message translates to:
  /// **'Future You seni izlemiyor; seninle birlikte yürüyor.'**
  String get motivationalQuote12;

  /// No description provided for @motivationalQuote13.
  ///
  /// In tr, this message translates to:
  /// **'Hedef uzak görünebilir; adım hep bir adımlıktır.'**
  String get motivationalQuote13;

  /// No description provided for @motivationalQuote14.
  ///
  /// In tr, this message translates to:
  /// **'Dinlenmek de ilerlemenin bir parçasıdır.'**
  String get motivationalQuote14;

  /// No description provided for @motivationalQuote15.
  ///
  /// In tr, this message translates to:
  /// **'Dün ne olduysa olsun, bugün yeni bir kayıt günü.'**
  String get motivationalQuote15;

  /// No description provided for @motivationalQuote16.
  ///
  /// In tr, this message translates to:
  /// **'En iyi yatırım aracın: kendine ayırdığın yirmi dakika.'**
  String get motivationalQuote16;

  /// No description provided for @actionTip1.
  ///
  /// In tr, this message translates to:
  /// **'Büyük hedefleri küçük parçalara böl; bugün sadece ilk parçayı yap.'**
  String get actionTip1;

  /// No description provided for @actionTip2.
  ///
  /// In tr, this message translates to:
  /// **'Güne başlarken tek bir \"bugün bunu yapacağım\" cümlesi kur.'**
  String get actionTip2;

  /// No description provided for @actionTip3.
  ///
  /// In tr, this message translates to:
  /// **'İki dakikadan kısa süren işi erteleme, hemen yap.'**
  String get actionTip3;

  /// No description provided for @actionTip4.
  ///
  /// In tr, this message translates to:
  /// **'Yarının planını bu akşam iki cümleyle yaz.'**
  String get actionTip4;

  /// No description provided for @actionTip5.
  ///
  /// In tr, this message translates to:
  /// **'Bir hedefine takvimde 15 dakikalık sabit bir yer ayır.'**
  String get actionTip5;

  /// No description provided for @actionTip6.
  ///
  /// In tr, this message translates to:
  /// **'İlerlemeni haftada bir gözden geçir; rotayı küçükçe düzelt.'**
  String get actionTip6;

  /// No description provided for @actionTip7.
  ///
  /// In tr, this message translates to:
  /// **'Zor işi günün en enerjik saatine koy.'**
  String get actionTip7;

  /// No description provided for @actionTip8.
  ///
  /// In tr, this message translates to:
  /// **'Telefonu başka odaya bırakıp 25 dakikalık bir odak bloğu dene.'**
  String get actionTip8;

  /// No description provided for @actionTip9.
  ///
  /// In tr, this message translates to:
  /// **'Bir alışkanlığı mevcut bir rutine bağla: kahveden sonra beş sayfa.'**
  String get actionTip9;

  /// No description provided for @actionTip10.
  ///
  /// In tr, this message translates to:
  /// **'Bugün tek bir şeyi %80 yeterlilikte bitir; mükemmeli bekletme.'**
  String get actionTip10;

  /// No description provided for @actionTip11.
  ///
  /// In tr, this message translates to:
  /// **'Hedefini görünür bir yere yaz — göz önünde olan akılda kalır.'**
  String get actionTip11;

  /// No description provided for @actionTip12.
  ///
  /// In tr, this message translates to:
  /// **'Başlayamıyorsan kapsamı küçült: 10 dakikaya sığan versiyonu ne?'**
  String get actionTip12;

  /// No description provided for @actionTip13.
  ///
  /// In tr, this message translates to:
  /// **'Bittiğinde kendine küçük bir ödül tanımla ve sözünü tut.'**
  String get actionTip13;

  /// No description provided for @actionTip14.
  ///
  /// In tr, this message translates to:
  /// **'İvme kaybettiğinde en kolay adıma geri dön; zincir oradan kurulur.'**
  String get actionTip14;

  /// No description provided for @actionTip15.
  ///
  /// In tr, this message translates to:
  /// **'Bir engeli önceden tahmin et ve B planını şimdi yaz.'**
  String get actionTip15;

  /// No description provided for @actionTip16.
  ///
  /// In tr, this message translates to:
  /// **'Günün sonunda tek cümlelik bir \"bugün ne öğrendim\" notu düş.'**
  String get actionTip16;

  /// No description provided for @coachTitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki Ben Koçu'**
  String get coachTitle;

  /// No description provided for @coachSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugün için birkaç düşünce'**
  String get coachSubtitle;

  /// No description provided for @coachLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Coach yüklenemedi.\n{error}'**
  String coachLoadError(String error);

  /// No description provided for @dailyQuestionTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün sorusu'**
  String get dailyQuestionTitle;

  /// No description provided for @dailyQuoteTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün sözü'**
  String get dailyQuoteTitle;

  /// No description provided for @dailyTipTitle.
  ///
  /// In tr, this message translates to:
  /// **'Günün ipucu'**
  String get dailyTipTitle;

  /// No description provided for @todaysAnswer.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü yanıtın: {answer}'**
  String todaysAnswer(String answer);

  /// No description provided for @answerButton.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtla'**
  String get answerButton;

  /// No description provided for @reflectionAnswerHint.
  ///
  /// In tr, this message translates to:
  /// **'İçinden geldiği gibi yaz…'**
  String get reflectionAnswerHint;

  /// No description provided for @chapterTitleBeginning.
  ///
  /// In tr, this message translates to:
  /// **'Başlangıç'**
  String get chapterTitleBeginning;

  /// No description provided for @chapterTitleComeback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dönüş'**
  String get chapterTitleComeback;

  /// No description provided for @chapterTitleLeap.
  ///
  /// In tr, this message translates to:
  /// **'Sıçrama'**
  String get chapterTitleLeap;

  /// No description provided for @chapterTitleDream.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hayal Daha'**
  String get chapterTitleDream;

  /// No description provided for @chapterTitleQuiet.
  ///
  /// In tr, this message translates to:
  /// **'Sakin Hafta'**
  String get chapterTitleQuiet;

  /// No description provided for @chapterTitleSteady.
  ///
  /// In tr, this message translates to:
  /// **'İstikrar'**
  String get chapterTitleSteady;

  /// No description provided for @chapterTitleOnTheRoad.
  ///
  /// In tr, this message translates to:
  /// **'Yol Alış'**
  String get chapterTitleOnTheRoad;

  /// No description provided for @chapterFirstWeek.
  ///
  /// In tr, this message translates to:
  /// **'Yolculuğun daha yeni başlıyor. İlk adımlar her zaman en önemlileridir — hazır olduğunda buradayız.'**
  String get chapterFirstWeek;

  /// No description provided for @chapterQuietOpening1.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta sakin geçti — bazen soluklanmak da yolculuğun parçası.'**
  String get chapterQuietOpening1;

  /// No description provided for @chapterQuietOpening2.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta sakin bir hafta oldu; yeni hafta yeni bir sayfa.'**
  String get chapterQuietOpening2;

  /// No description provided for @chapterLowOpening1.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta küçük ama değerli adımlar attın.'**
  String get chapterLowOpening1;

  /// No description provided for @chapterLowOpening2.
  ///
  /// In tr, this message translates to:
  /// **'Yavaş ama emin ilerledin bu hafta.'**
  String get chapterLowOpening2;

  /// No description provided for @chapterMidOpening1.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta iyi bir tempo tutturdun.'**
  String get chapterMidOpening1;

  /// No description provided for @chapterMidOpening2.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta düzenli ve kararlıydın; adımlar üst üste eklendi.'**
  String get chapterMidOpening2;

  /// No description provided for @chapterHighOpening1.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta güçlüydün — Future You bu haftayı hatırlayacak.'**
  String get chapterHighOpening1;

  /// No description provided for @chapterHighOpening2.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta adeta sıçradın; emeğin görünür oldu.'**
  String get chapterHighOpening2;

  /// No description provided for @chapterComeback1.
  ///
  /// In tr, this message translates to:
  /// **'Ara verdikten sonra geri dönmen, hiç durmamaktan daha değerli.'**
  String get chapterComeback1;

  /// No description provided for @chapterComeback2.
  ///
  /// In tr, this message translates to:
  /// **'Kısa bir duraksamanın ardından yola devam ettin — asıl güç bu.'**
  String get chapterComeback2;

  /// No description provided for @chapterImproved.
  ///
  /// In tr, this message translates to:
  /// **'\'{title}\' hedefinde gözle görülür yol aldın (+%{percent}).'**
  String chapterImproved(String title, int percent);

  /// No description provided for @chapterMissions.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{Bu hafta bir görevi tamamladın — listenden bir hayal daha gerçek oldu.} other{Bu hafta {count} görev tamamladın — hayaller birer birer gerçek oluyor.}}'**
  String chapterMissions(int count);

  /// No description provided for @chaptersTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölümler'**
  String get chaptersTitle;

  /// No description provided for @chaptersLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Bölümler yüklenemedi.\n{error}'**
  String chaptersLoadError(String error);

  /// No description provided for @noChaptersYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz bölüm yok — ilk tamamlanan haftanın sonunda hikâyen burada yazılacak.'**
  String get noChaptersYet;

  /// No description provided for @chapterLabel.
  ///
  /// In tr, this message translates to:
  /// **'BÖLÜM {number}'**
  String chapterLabel(int number);

  /// No description provided for @longestStreakLabel.
  ///
  /// In tr, this message translates to:
  /// **'En uzun seri'**
  String get longestStreakLabel;

  /// No description provided for @missionsStatLabel.
  ///
  /// In tr, this message translates to:
  /// **'Görev'**
  String get missionsStatLabel;

  /// No description provided for @featuredGoal.
  ///
  /// In tr, this message translates to:
  /// **'Öne çıkan: {title}'**
  String featuredGoal(String title);

  /// No description provided for @chapterEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Bölüm {number}: {title}'**
  String chapterEntryTitle(int number, String title);

  /// No description provided for @chapterEntrySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçen haftanın hikâyesine göz at'**
  String get chapterEntrySubtitle;

  /// No description provided for @yourLetters.
  ///
  /// In tr, this message translates to:
  /// **'Mektupların'**
  String get yourLetters;

  /// No description provided for @writeFirstLetter.
  ///
  /// In tr, this message translates to:
  /// **'İlk mektubunu yaz'**
  String get writeFirstLetter;

  /// No description provided for @writeFirstLetterSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki sana bugünden bir not bırak'**
  String get writeFirstLetterSubtitle;

  /// No description provided for @lettersWaiting.
  ///
  /// In tr, this message translates to:
  /// **'{count} mektup açılmayı bekliyor'**
  String lettersWaiting(int count);

  /// No description provided for @lettersInJourney.
  ///
  /// In tr, this message translates to:
  /// **'{count} mektup yolculukta'**
  String lettersInJourney(int count);

  /// No description provided for @letterToFuture.
  ///
  /// In tr, this message translates to:
  /// **'Geleceğe Mektup'**
  String get letterToFuture;

  /// No description provided for @letterHint.
  ///
  /// In tr, this message translates to:
  /// **'Gelecekteki sana ne söylemek istersin?'**
  String get letterHint;

  /// No description provided for @whenToDeliver.
  ///
  /// In tr, this message translates to:
  /// **'Ne zaman ulaşsın?'**
  String get whenToDeliver;

  /// No description provided for @inOneMonth.
  ///
  /// In tr, this message translates to:
  /// **'1 ay sonra'**
  String get inOneMonth;

  /// No description provided for @inThreeMonths.
  ///
  /// In tr, this message translates to:
  /// **'3 ay sonra'**
  String get inThreeMonths;

  /// No description provided for @inSixMonths.
  ///
  /// In tr, this message translates to:
  /// **'6 ay sonra'**
  String get inSixMonths;

  /// No description provided for @onGoalCompletionChip.
  ///
  /// In tr, this message translates to:
  /// **'Hedef tamamlanınca'**
  String get onGoalCompletionChip;

  /// No description provided for @noActiveGoalForLetter.
  ///
  /// In tr, this message translates to:
  /// **'Bağlanabilecek aktif bir hedefin yok. Önce bir hedef ekle ya da sabit bir tarih seç.'**
  String get noActiveGoalForLetter;

  /// No description provided for @letterSealNote.
  ///
  /// In tr, this message translates to:
  /// **'Mektubun mühürlenir; zamanı gelene kadar kimse (sen dahil) okuyamaz.'**
  String get letterSealNote;

  /// No description provided for @sealLetter.
  ///
  /// In tr, this message translates to:
  /// **'Mektubu mühürle'**
  String get sealLetter;

  /// No description provided for @letterSealed.
  ///
  /// In tr, this message translates to:
  /// **'Mektubun mühürlendi.'**
  String get letterSealed;

  /// No description provided for @sealFailed.
  ///
  /// In tr, this message translates to:
  /// **'Mühürlenemedi, tekrar dene.'**
  String get sealFailed;

  /// No description provided for @writeLetterTooltip.
  ///
  /// In tr, this message translates to:
  /// **'Mektup yaz'**
  String get writeLetterTooltip;

  /// No description provided for @lettersLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Mektuplar yüklenemedi.\n{error}'**
  String lettersLoadError(String error);

  /// No description provided for @sealedLetter.
  ///
  /// In tr, this message translates to:
  /// **'Mühürlü mektup'**
  String get sealedLetter;

  /// No description provided for @opensToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugün açılacak'**
  String get opensToday;

  /// No description provided for @opensInDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün sonra açılacak'**
  String opensInDays(int count);

  /// No description provided for @opensOnGoalCompletion.
  ///
  /// In tr, this message translates to:
  /// **'Hedefin tamamlanınca açılacak'**
  String get opensOnGoalCompletion;

  /// No description provided for @notYetTime.
  ///
  /// In tr, this message translates to:
  /// **'Henüz zamanı gelmedi — sabır da yolculuğun parçası.'**
  String get notYetTime;

  /// No description provided for @letterArrivedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Geçmişten bir mektup geldi'**
  String get letterArrivedTitle;

  /// No description provided for @tapToOpen.
  ///
  /// In tr, this message translates to:
  /// **'Açmak için dokun'**
  String get tapToOpen;

  /// No description provided for @noLettersYet.
  ///
  /// In tr, this message translates to:
  /// **'Henüz mektubun yok'**
  String get noLettersYet;

  /// No description provided for @noLettersYetSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü duygularını geleceğe taşı — gelecekteki sen okuduğunda bambaşka biri olacak.'**
  String get noLettersYetSubtitle;

  /// No description provided for @letterTitle.
  ///
  /// In tr, this message translates to:
  /// **'Mektup'**
  String get letterTitle;

  /// No description provided for @letterLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Mektup yüklenemedi.\n{error}'**
  String letterLoadError(String error);

  /// No description provided for @letterNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Mektup bulunamadı.'**
  String get letterNotFound;

  /// No description provided for @letterStillSealed.
  ///
  /// In tr, this message translates to:
  /// **'Bu mektup hâlâ mühürlü — zamanı gelince burada açılacak.'**
  String get letterStillSealed;

  /// No description provided for @letterWrittenOn.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinde yazıldı'**
  String letterWrittenOn(String date);

  /// No description provided for @letterWrittenOnWithMonths.
  ///
  /// In tr, this message translates to:
  /// **'{date} tarihinde yazıldı — {count} ay önce'**
  String letterWrittenOnWithMonths(String date, int count);

  /// No description provided for @writeLetterToToday.
  ///
  /// In tr, this message translates to:
  /// **'Bugünkü sana bir mektup yaz'**
  String get writeLetterToToday;

  /// No description provided for @plusPercent.
  ///
  /// In tr, this message translates to:
  /// **'+%{percent}'**
  String plusPercent(int percent);

  /// No description provided for @languageLabel.
  ///
  /// In tr, this message translates to:
  /// **'Dil / Language'**
  String get languageLabel;

  /// No description provided for @languageTurkish.
  ///
  /// In tr, this message translates to:
  /// **'Türkçe'**
  String get languageTurkish;

  /// No description provided for @languageEnglish.
  ///
  /// In tr, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @levelUpCelebration.
  ///
  /// In tr, this message translates to:
  /// **'Level {level}! 🎉'**
  String levelUpCelebration(int level);

  /// No description provided for @goalCompletedCelebration.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Tamamlandı! 🏆'**
  String get goalCompletedCelebration;

  /// No description provided for @badgeStreak7.
  ///
  /// In tr, this message translates to:
  /// **'İlk Kıvılcım'**
  String get badgeStreak7;

  /// No description provided for @badgeStreak30.
  ///
  /// In tr, this message translates to:
  /// **'Alev Alev'**
  String get badgeStreak30;

  /// No description provided for @badgeStreak100.
  ///
  /// In tr, this message translates to:
  /// **'Durdurulamaz'**
  String get badgeStreak100;

  /// No description provided for @badgeFirstGoal.
  ///
  /// In tr, this message translates to:
  /// **'Yola Çıkış'**
  String get badgeFirstGoal;

  /// No description provided for @badgeFirstGoalCompleted.
  ///
  /// In tr, this message translates to:
  /// **'İlk Zafer'**
  String get badgeFirstGoalCompleted;

  /// No description provided for @badgeGoals5.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Avcısı'**
  String get badgeGoals5;

  /// No description provided for @badgeGoals10.
  ///
  /// In tr, this message translates to:
  /// **'Hedef Ustası'**
  String get badgeGoals10;

  /// No description provided for @badgeFirstMission.
  ///
  /// In tr, this message translates to:
  /// **'Hayalperest'**
  String get badgeFirstMission;

  /// No description provided for @badgeFirstMissionCompleted.
  ///
  /// In tr, this message translates to:
  /// **'Bir Hayal Gerçek'**
  String get badgeFirstMissionCompleted;

  /// No description provided for @badgeMissions5.
  ///
  /// In tr, this message translates to:
  /// **'Hayal Koleksiyoncusu'**
  String get badgeMissions5;

  /// No description provided for @badgeFirstLesson.
  ///
  /// In tr, this message translates to:
  /// **'Ses Ver'**
  String get badgeFirstLesson;

  /// No description provided for @badgeFirstComment.
  ///
  /// In tr, this message translates to:
  /// **'Destekçi'**
  String get badgeFirstComment;

  /// No description provided for @badgeLesson50Likes.
  ///
  /// In tr, this message translates to:
  /// **'İlham Kaynağı'**
  String get badgeLesson50Likes;

  /// No description provided for @badgeComeback.
  ///
  /// In tr, this message translates to:
  /// **'Geri Dönüş'**
  String get badgeComeback;

  /// No description provided for @badgeEarlyBird.
  ///
  /// In tr, this message translates to:
  /// **'Erken Kalkan'**
  String get badgeEarlyBird;

  /// No description provided for @badgeLevel10.
  ///
  /// In tr, this message translates to:
  /// **'Yükseliş'**
  String get badgeLevel10;

  /// No description provided for @badgeLevel25.
  ///
  /// In tr, this message translates to:
  /// **'Efsane'**
  String get badgeLevel25;

  /// No description provided for @achievementsTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar'**
  String get achievementsTitle;

  /// No description provided for @achievementsEntryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Başarılarını Gör'**
  String get achievementsEntryTitle;

  /// No description provided for @achievementsEntrySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler ve kişisel rekorlar'**
  String get achievementsEntrySubtitle;

  /// No description provided for @personalRecords.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel Rekorların'**
  String get personalRecords;

  /// No description provided for @recordLongestStreak.
  ///
  /// In tr, this message translates to:
  /// **'En uzun seri'**
  String get recordLongestStreak;

  /// No description provided for @recordTotalXp.
  ///
  /// In tr, this message translates to:
  /// **'Toplam XP'**
  String get recordTotalXp;

  /// No description provided for @recordCompletedGoals.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan hedef'**
  String get recordCompletedGoals;

  /// No description provided for @recordCompletedMissions.
  ///
  /// In tr, this message translates to:
  /// **'Tamamlanan görev'**
  String get recordCompletedMissions;

  /// No description provided for @recordFastestGoal.
  ///
  /// In tr, this message translates to:
  /// **'En hızlı ilerleyen: {title}'**
  String recordFastestGoal(String title);

  /// No description provided for @badgesCount.
  ///
  /// In tr, this message translates to:
  /// **'Rozetler ({unlocked}/{total})'**
  String badgesCount(int unlocked, int total);

  /// No description provided for @achievementsLoadError.
  ///
  /// In tr, this message translates to:
  /// **'Başarılar yüklenemedi.\n{error}'**
  String achievementsLoadError(String error);

  /// No description provided for @navDashboard.
  ///
  /// In tr, this message translates to:
  /// **'Panel'**
  String get navDashboard;

  /// No description provided for @navMissions.
  ///
  /// In tr, this message translates to:
  /// **'Görevler'**
  String get navMissions;

  /// No description provided for @navLessons.
  ///
  /// In tr, this message translates to:
  /// **'Dersler'**
  String get navLessons;

  /// No description provided for @navCoach.
  ///
  /// In tr, this message translates to:
  /// **'Koç'**
  String get navCoach;

  /// No description provided for @challengeThreeDayStreak.
  ///
  /// In tr, this message translates to:
  /// **'3 farklı günde ilerleme kaydet'**
  String get challengeThreeDayStreak;

  /// No description provided for @challengeTwoGoals.
  ///
  /// In tr, this message translates to:
  /// **'2 farklı hedefte ilerleme kaydet'**
  String get challengeTwoGoals;

  /// No description provided for @challengeMissionNote.
  ///
  /// In tr, this message translates to:
  /// **'Bir göreve not ekle'**
  String get challengeMissionNote;

  /// No description provided for @challengeReflection.
  ///
  /// In tr, this message translates to:
  /// **'Coach\'ın günün sorusunu yanıtla'**
  String get challengeReflection;

  /// No description provided for @challengeComment.
  ///
  /// In tr, this message translates to:
  /// **'Hayat Dersleri\'nde bir gönderiye yorum yap'**
  String get challengeComment;

  /// No description provided for @challengeTenPercent.
  ///
  /// In tr, this message translates to:
  /// **'Bir hedefte %10 ilerleme kaydet'**
  String get challengeTenPercent;
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
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
