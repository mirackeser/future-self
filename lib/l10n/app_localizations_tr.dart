// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Future Self';

  @override
  String get save => 'Kaydet';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get add => 'Ekle';

  @override
  String get continueButton => 'Devam et';

  @override
  String get continueShort => 'Devam';

  @override
  String get back => 'Geri';

  @override
  String get loading => 'Yükleniyor…';

  @override
  String get error => 'Bir şeyler ters gitti';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get close => 'Kapat';

  @override
  String get done => 'Tamam';

  @override
  String get settings => 'Ayarlar';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get deleteAccountAction => 'Hesabı Sil';

  @override
  String get deleteAccountDialogTitle =>
      'Hesabını silmek istediğine emin misin?';

  @override
  String get deleteAccountDialogBody =>
      'Bu işlem GERİ ALINAMAZ. Tüm hedeflerin, geçmişin, mission\'ların, paylaşımların ve tüm verilerin kalıcı olarak silinecek.';

  @override
  String get deleteAccountConfirmWord => 'SİL';

  @override
  String deleteAccountConfirmHint(String word) {
    return 'Onaylamak için \"$word\" yaz';
  }

  @override
  String get deleteAccountConfirmButton => 'Hesabımı Sil';

  @override
  String get deleteAccountFailed => 'Hesap silinemedi, tekrar dene.';

  @override
  String get accountDeletedMessage => 'Hesabın silindi.';

  @override
  String get reauthPasswordTitle => 'Şifreni doğrula';

  @override
  String get reauthPasswordBody =>
      'Güvenlik için hesabını silmeden önce şifreni tekrar girmen gerekiyor.';

  @override
  String get reauthConfirmButton => 'Doğrula';

  @override
  String get comingSoon => 'Yakında';

  @override
  String get today => 'Bugün';

  @override
  String get welcomeTitle => 'Hoş geldin!';

  @override
  String get welcomeSubtitle =>
      'Hesabın hazır. Şimdi seni biraz tanıyalım — her gün attığın küçük adımlar, gelecekteki halini şekillendirecek.';

  @override
  String get categoriesTitle => 'Hangi alanlarda ilerlemek istiyorsun?';

  @override
  String get categoriesSubtitle =>
      'İstediğin kadar seç, sonra değiştirebilirsin.';

  @override
  String get currentStateTitle => 'Şu an neredesin?';

  @override
  String get currentStateSubtitle =>
      'Bugünkü durumunu ve hedefini gir. Hepsi opsiyonel, sonra da doldurabilirsin.';

  @override
  String get addMetric => 'Metrik ekle';

  @override
  String addMetricFor(String category) {
    return '$category için metrik ekle';
  }

  @override
  String get nowLabel => 'Şimdi';

  @override
  String get targetLabel => 'Hedef';

  @override
  String get decreasingHint => 'Hedef, şimdikinden düşük olmalı';

  @override
  String get currentLevelLabel => 'Şimdiki seviye';

  @override
  String get targetLevelLabel => 'Hedef seviye';

  @override
  String get freeTextHint => 'Hedefin ne?';

  @override
  String get notificationsTitle => 'Future You seninle konuşsun mu?';

  @override
  String get notificationsSubtitle =>
      'Günde birkaç kez, ilerlemeni fark ettiren nazik hatırlatmalar gönderelim. İstediğin zaman kapatabilirsin.';

  @override
  String get morningMotivation => 'Sabah motivasyonu';

  @override
  String get streakReminders => 'Seri hatırlatmaları';

  @override
  String get eveningSummary => 'Akşam özeti';

  @override
  String get allowNotifications => 'Bildirimlere izin ver';

  @override
  String get notNow => 'Şimdi değil';

  @override
  String get accountTitle => 'Yolculuğunu kaydedelim';

  @override
  String get accountSubtitle =>
      'İlerlemenin kaybolmaması için bir hesap oluştur.';

  @override
  String get continueWithApple => 'Apple ile devam et';

  @override
  String get continueWithGoogle => 'Google ile devam et';

  @override
  String get continueWithEmail => 'E-posta ile devam et';

  @override
  String get orSeparator => 'veya';

  @override
  String get termsNotice =>
      'Devam ederek Kullanım Şartları ve Gizlilik Politikasını kabul etmiş olursun.';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get emailLabel => 'E-posta';

  @override
  String get passwordLabel => 'Şifre';

  @override
  String get emailPasswordRequired => 'E-posta ve şifreni gir.';

  @override
  String get categoryHealth => 'Sağlık';

  @override
  String get categoryCareer => 'Kariyer';

  @override
  String get categoryFinance => 'Finans';

  @override
  String get categoryLearning => 'Öğrenme';

  @override
  String get categoryRelationships => 'İlişkiler';

  @override
  String get categorySpirituality => 'Maneviyat';

  @override
  String get categoryPersonalGrowth => 'Kişisel Gelişim';

  @override
  String get templateWeight => 'Kilo';

  @override
  String get templateExerciseFrequency => 'Egzersiz sıklığı';

  @override
  String get templateFreeGoal => 'Serbest hedef';

  @override
  String get templateCareerLevel => 'Seviye';

  @override
  String get templateTargetPosition => 'Hedef pozisyon';

  @override
  String get templateSalary => 'Maaş';

  @override
  String get templateSavings => 'Birikim';

  @override
  String get templateGold => 'Altın';

  @override
  String get templateCrypto => 'Kripto';

  @override
  String get templateCardDebt => 'Kart borcu';

  @override
  String get templateLanguageLevel => 'Dil seviyesi';

  @override
  String get templateTopicCourse => 'Konu / kurs';

  @override
  String goalsLoadError(String error) {
    return 'Hedefler yüklenemedi. Bağlantını kontrol et.\n$error';
  }

  @override
  String get statusNoGoals =>
      'Henüz hedef eklemedin. İlk hedefinle yolculuğu başlat.';

  @override
  String get statusQuietWeek =>
      'Bu hafta biraz sessiz geçti. Küçük bir adım bile Future You\'yu yaklaştırır.';

  @override
  String statusStreak(int count) {
    return '$count günlük serin var — geçen haftadan daha istikrarlı ilerliyorsun.';
  }

  @override
  String statusProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Güzel gidiyorsun. Bu hafta $count hedefinde ilerleme kaydettin.',
    );
    return '$_temp0';
  }

  @override
  String get defaultUserName => 'Gezgin';

  @override
  String levelXp(int level, int xp) {
    return 'Level $level • $xp XP';
  }

  @override
  String get todayProgress => 'Bugünkü İlerleme';

  @override
  String goalsProgressedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hedef ilerletildi',
    );
    return '$_temp0';
  }

  @override
  String dayStreak(int count) {
    return '$count günlük seri';
  }

  @override
  String freezeIndicator(int count) {
    return '🧊 x$count';
  }

  @override
  String get freezeDialogTitle => 'Seri Dondurma 🧊';

  @override
  String get freezeDialogBody =>
      'Bir günü kaçırırsan serini korur — atlanan gün hiç olmamış gibi devam edersin. Her ay 2 dondurma hakkı yenilenir ve gerektiğinde kendiliğinden kullanılır.';

  @override
  String get gotIt => 'Anladım';

  @override
  String get noEmailInfo => 'E-posta bilgisi yok';

  @override
  String get activeGoals => 'Aktif Hedefler';

  @override
  String get weeklyChallengeTitle => 'Bu Haftanın Meydan Okuması';

  @override
  String plusXp(int xp) {
    return '+$xp XP';
  }

  @override
  String challengeCompleted(int xp) {
    return 'Tamamlandı! +$xp XP kazandın 🎉';
  }

  @override
  String get inProgress => 'Devam ediyor';

  @override
  String percentOnly(int percent) {
    return '%$percent';
  }

  @override
  String percentWithEstimate(int percent, String date) {
    return '%$percent • tahmini $date';
  }

  @override
  String estimatedDate(String date) {
    return 'tahmini $date';
  }

  @override
  String get goalCompleted => 'Tamamlandı';

  @override
  String get completedGoalsTitle => 'Tamamlanan Hedefler';

  @override
  String completedGoalsEntry(int count) {
    return 'Tamamlanan Hedefler ($count)';
  }

  @override
  String completedOnDate(String date) {
    return 'Tamamlandı · $date';
  }

  @override
  String get noCompletedGoalsYet => 'Henüz tamamlanan hedef yok.';

  @override
  String get quickUpdate => 'Hızlı güncelle';

  @override
  String get noGoalsYet => 'Henüz hedefin yok';

  @override
  String get noGoalsYetSubtitle =>
      'Future You seni bekliyor. İlk hedefini ekle.';

  @override
  String get addGoal => 'Hedef ekle';

  @override
  String get newValueLabel => 'Yeni değer';

  @override
  String get freeTextProgressQuestion =>
      'Bu hedefte bugün ilerleme kaydettin mi?';

  @override
  String recordProgressWithXp(int xp) {
    return 'İlerleme kaydet (+$xp XP)';
  }

  @override
  String saveWithXp(int xp) {
    return 'Kaydet (+$xp XP)';
  }

  @override
  String get saveFailed => 'Kaydedilemedi, tekrar dene.';

  @override
  String deleteDialogStreakTitle(int streak) {
    return '$streak günlük serini bırakmak üzeresin';
  }

  @override
  String get deleteDialogGenericTitle => 'İlerlemeni bırakmak üzeresin';

  @override
  String deleteDialogMessageWithValues(
    String title,
    String from,
    String to,
    int xp,
  ) {
    return '\'$title\' hedefinde $from\'den $to\'ye kadar geldin ve $xp XP kazandın. Bu hedefi silersen bu ilerleme geçmişi de silinir.';
  }

  @override
  String deleteDialogMessageXpOnly(String title, int xp) {
    return '\'$title\' hedefinde şimdiye kadar $xp XP kazandın. Bu hedefi silersen bu ilerleme geçmişi de silinir.';
  }

  @override
  String goalLoadError(String error) {
    return 'Hedef yüklenemedi.\n$error';
  }

  @override
  String get goalNotFound => 'Hedef bulunamadı.';

  @override
  String get deleteGoalTooltip => 'Hedefi sil';

  @override
  String get keepGoing => 'Devam etmek istiyorum';

  @override
  String get deleteAnyway => 'Yine de sil';

  @override
  String get deleteFailed => 'Silinemedi, tekrar dene.';

  @override
  String nowValue(String value) {
    return 'Şimdi: $value';
  }

  @override
  String targetValueText(String value) {
    return 'Hedef: $value';
  }

  @override
  String daysCount(int count) {
    return '$count gün';
  }

  @override
  String xpValue(int xp) {
    return '$xp XP';
  }

  @override
  String get streakLabel => 'Seri';

  @override
  String get earnedLabel => 'Kazanılan';

  @override
  String get recordProgress => 'İlerleme kaydet';

  @override
  String get historyLabel => 'Geçmiş';

  @override
  String get historyLoadError => 'Geçmiş yüklenemedi.';

  @override
  String get noHistoryYet => 'Henüz kayıt yok';

  @override
  String get progressRecorded => 'İlerleme kaydedildi';

  @override
  String get addGoalTitle => 'Hedef Ekle';

  @override
  String get whichArea => 'Hangi alanda?';

  @override
  String pickMetricFor(String category) {
    return '$category için bir metrik seç';
  }

  @override
  String get alreadyAdded => 'Zaten eklendi';

  @override
  String get freeTextType => 'Serbest metin';

  @override
  String get addGoalSubmit => 'Hedefi ekle';

  @override
  String get goalAdded => 'Hedef eklendi.';

  @override
  String get addFailed => 'Eklenemedi, tekrar dene.';

  @override
  String get lifeMissions => 'Hayat Görevleri';

  @override
  String get addMission => 'Görev ekle';

  @override
  String missionsLoadError(String error) {
    return 'Görevler yüklenemedi.\n$error';
  }

  @override
  String missionsSummary(int total, int completed) {
    return '$total görev · $completed tamamlandı';
  }

  @override
  String addedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün önce eklendi',
      zero: 'Bugün eklendi',
    );
    return '$_temp0';
  }

  @override
  String get completedLabel => 'Tamamlandı';

  @override
  String completedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Tamamlandı · $count gün önce',
      zero: 'Tamamlandı · bugün',
    );
    return '$_temp0';
  }

  @override
  String gentleReminder(int count) {
    return '$count gündür bu hedefe dokunmadın, hatırlaman için buradayız';
  }

  @override
  String get noNotesYet => 'Henüz not yok';

  @override
  String get noMissionsYet => 'Henüz görev yok';

  @override
  String get noMissionsYetSubtitle =>
      'Hayatta yapmak istediklerini buraya ekle — küçük ya da büyük, hepsi sayılır.';

  @override
  String get missionTitleHint => 'Ne başarmak istiyorsun?';

  @override
  String missionLoadError(String error) {
    return 'Görev yüklenemedi.\n$error';
  }

  @override
  String get missionNotFound => 'Görev bulunamadı.';

  @override
  String addedOn(String date) {
    return 'Eklendi: $date';
  }

  @override
  String get markCompleted => 'Tamamlandı olarak işaretle';

  @override
  String get markIncomplete => 'Tamamlanmadı olarak işaretle';

  @override
  String get notesLabel => 'Notlar';

  @override
  String get missionNoteHint => 'Bir gelişme, bir düşünce…';

  @override
  String get addNote => 'Not ekle';

  @override
  String get noteAddFailed => 'Not eklenemedi, tekrar dene.';

  @override
  String get deleteMissionTitle => 'Görev silinsin mi?';

  @override
  String get deleteMissionConfirm => 'Bu hedefi silmek istediğine emin misin?';

  @override
  String get lifeLessons => 'Hayat Dersleri';

  @override
  String get share => 'Paylaş';

  @override
  String get feedTab => 'Akış';

  @override
  String get savedTab => 'Kaydedilenler';

  @override
  String lessonsLoadError(String error) {
    return 'Paylaşımlar yüklenemedi.\n$error';
  }

  @override
  String get noLessonsYet => 'Henüz paylaşım yok';

  @override
  String get noLessonsYetSubtitle =>
      'İlk dersi sen paylaş — biri buna ihtiyaç duyuyor olabilir.';

  @override
  String get noSavedLessonsYet => 'Henüz kaydettiğin bir paylaşım yok';

  @override
  String get noSavedLessonsYetSubtitle =>
      'Akıştan bookmark ikonuyla kaydettiklerin burada birikecek.';

  @override
  String get report => 'Bildir';

  @override
  String get reportLessonConfirm =>
      'Bu gönderiyi bildirmek istediğine emin misin?';

  @override
  String get reportCommentConfirm =>
      'Bu yorumu bildirmek istediğine emin misin?';

  @override
  String get reportThanks => 'Bildirdiğin için teşekkürler.';

  @override
  String get deleteLessonTitle => 'Gönderi silinsin mi?';

  @override
  String get deleteLessonConfirm =>
      'Bu gönderiyi silmek istediğine emin misin? Bu işlem geri alınamaz.';

  @override
  String get lessonTextHint => 'Bir deneyimini veya pişmanlığını paylaş...';

  @override
  String get anonymousNotice => 'Bu paylaşım anonim olarak görünecek.';

  @override
  String get profanityWarning =>
      'Bu metin uygun olmayan bir ifade içeriyor gibi görünüyor, lütfen düzenle.';

  @override
  String get shareFailed => 'Paylaşılamadı, tekrar dene.';

  @override
  String get commentsTitle => 'Yorumlar';

  @override
  String lessonLoadError(String error) {
    return 'Gönderi yüklenemedi.\n$error';
  }

  @override
  String get lessonNotFound => 'Gönderi bulunamadı.';

  @override
  String get commentsLoadError => 'Yorumlar yüklenemedi.';

  @override
  String get noCommentsYet => 'Henüz yorum yok — ilk yorumu sen yaz.';

  @override
  String get commentHint => 'Anonim bir yorum yaz…';

  @override
  String get send => 'Gönder';

  @override
  String get commentSendFailed => 'Yorum gönderilemedi, tekrar dene.';

  @override
  String get justNow => 'az önce';

  @override
  String minutesAgo(int count) {
    return '$count dk önce';
  }

  @override
  String hoursAgo(int count) {
    return '$count sa önce';
  }

  @override
  String daysAgo(int count) {
    return '$count gün önce';
  }

  @override
  String get coachEmptyMessage =>
      'Henüz hedefin yok. İlk hedefini eklediğinde Future You için sana özel düşünceler burada olacak.';

  @override
  String coachStreakWithGoal(int count, String title) {
    return '$count günlük serin var — bu tempo seni \'$title\' hedefinde daha erken sonuca taşıyabilir.';
  }

  @override
  String coachStreakGeneric(int count) {
    return '$count günlük serin var — bu istikrar Future You\'ya yapılmış en iyi yatırım.';
  }

  @override
  String coachNeglected(String title, int days) {
    return '\'$title\' hedefin $days gündür seni bekliyor. Küçük bir güncelleme bile ivmeyi geri getirir — hazır olduğunda oradayız.';
  }

  @override
  String coachTipRegular1(String title) {
    return '\'$title\' hedefinde bu ritmi koruyorsun, harika gidiyor.';
  }

  @override
  String coachTipRegular2(String title) {
    return '\'$title\' konusunda son günlerde gerçekten istikrarlısın.';
  }

  @override
  String coachTipRegular3(String title) {
    return '\'$title\' hedefin tam yolunda — böyle devam.';
  }

  @override
  String coachTipRegular4(String title) {
    return '\'$title\' için attığın düzenli adımlar birikmeye başladı bile.';
  }

  @override
  String coachTipRegular5(String title) {
    return '\'$title\' hedefindeki tempon Future You\'nun işini kolaylaştırıyor.';
  }

  @override
  String coachTipRegular6(String title) {
    return '\'$title\' hedefinde ivmen yerinde; küçük adımlar büyük fark yaratıyor.';
  }

  @override
  String coachTipUntouched1(String title) {
    return '\'$title\' hedefine bugün küçük bir adım atsan nasıl olur?';
  }

  @override
  String coachTipUntouched2(String title) {
    return '\'$title\' seni bekliyor — ne dersin?';
  }

  @override
  String coachTipUntouched3(String title) {
    return '\'$title\' için ilk kaydı bugün açmak ister misin?';
  }

  @override
  String coachTipUntouched4(String title) {
    return '\'$title\' hedefinde başlamak, en zor kısmın yarısıdır.';
  }

  @override
  String coachTipUntouched5(String title) {
    return '\'$title\' için beş dakikalık bir başlangıç bile sayılır.';
  }

  @override
  String coachTipUntouched6(String title) {
    return '\'$title\' hedefine giden yol ilk adımla açılır; bugün iyi bir gün.';
  }

  @override
  String get reflectionQuestion1 =>
      'Hedeflerine doğru attığın en küçük adım neydi bu hafta?';

  @override
  String get reflectionQuestion2 => 'Seni bu hafta en çok ne motive etti?';

  @override
  String get reflectionQuestion3 => 'Bugün gelecekteki halin için ne yaptın?';

  @override
  String get reflectionQuestion4 =>
      'Bir yıl önceki sen, bugünkü halini görse neye şaşırırdı?';

  @override
  String get reflectionQuestion5 => 'Bu hafta neyi ertelediğini fark ettin?';

  @override
  String get reflectionQuestion6 =>
      'Enerjini en çok ne tüketiyor, ne geri kazandırıyor?';

  @override
  String get reflectionQuestion7 =>
      'Hangi alışkanlığın seni hedefinden uzaklaştırıyor olabilir?';

  @override
  String get reflectionQuestion8 =>
      'Bugün kendine teşekkür etsen, ne için olurdu?';

  @override
  String get reflectionQuestion9 =>
      'Hedeflerinden hangisi seni gerçekten heyecanlandırıyor?';

  @override
  String get reflectionQuestion10 =>
      'Son bir ayda kendinle ilgili ne öğrendin?';

  @override
  String get reflectionQuestion11 =>
      'Yarın sabah tek bir şeyi farklı yapabilseydin, ne olurdu?';

  @override
  String get reflectionQuestion12 => 'Bu hafta kim ya da ne sana iyi geldi?';

  @override
  String get reflectionQuestion13 =>
      'Vazgeçmeyi düşündüğün ama devam ettiğin bir şey var mı?';

  @override
  String get reflectionQuestion14 =>
      'Beş yıl sonraki sen bugünkü sana ne tavsiye ederdi?';

  @override
  String get reflectionQuestion15 =>
      'Bugün seni gülümseten küçük bir an var mıydı?';

  @override
  String get reflectionQuestion16 =>
      'Hangi hedefin artık sana ait hissettirmiyor olabilir?';

  @override
  String get reflectionQuestion17 =>
      'Bu hafta hayır demen gereken ama evet dediğin bir şey oldu mu?';

  @override
  String get reflectionQuestion18 =>
      'Kendini en son ne zaman gerçekten dinlendin?';

  @override
  String get reflectionQuestion19 =>
      'İlerlemeni kimseyle kıyaslamadan değerlendirsen ne görürsün?';

  @override
  String get reflectionQuestion20 =>
      'Bugün başladığın işi yarına bırakmamanı sağlayan şey ne olurdu?';

  @override
  String get reflectionQuestion21 =>
      'Gelecekteki halinin günlük rutininde neler var?';

  @override
  String get reflectionQuestion22 =>
      'Bu ay bırakmak istediğin bir alışkanlık var mı? Yerine ne koyardın?';

  @override
  String get motivationalQuote1 =>
      'Bugün attığın her adım, yarınki sana bir hediye.';

  @override
  String get motivationalQuote2 =>
      'Gelecekteki sen, bugünkü kararlarının toplamı.';

  @override
  String get motivationalQuote3 =>
      'Küçük adımlar sessizdir ama en uzağa onlar taşır.';

  @override
  String get motivationalQuote4 => 'Mükemmel gün yok; sadece bugün var.';

  @override
  String get motivationalQuote5 =>
      'İstikrar, motivasyonun bittiği yerde başlar.';

  @override
  String get motivationalQuote6 =>
      'Bir yıl sonra, bugün başlamış olmayı dileyeceksin.';

  @override
  String get motivationalQuote7 =>
      'Yavaş ilerlemek, durmaktan sonsuz kat hızlıdır.';

  @override
  String get motivationalQuote8 =>
      'Kendine verdiğin sözler de tutulmayı hak eder.';

  @override
  String get motivationalQuote9 =>
      'Değişim büyük anlarda değil, sıradan günlerde olur.';

  @override
  String get motivationalQuote10 =>
      'Bugünün %1\'i, yarının bambaşka bir versiyonudur.';

  @override
  String get motivationalQuote11 =>
      'Zor olan başlamak değil, yeniden başlamaktan korkmamak.';

  @override
  String get motivationalQuote12 =>
      'Future You seni izlemiyor; seninle birlikte yürüyor.';

  @override
  String get motivationalQuote13 =>
      'Hedef uzak görünebilir; adım hep bir adımlıktır.';

  @override
  String get motivationalQuote14 => 'Dinlenmek de ilerlemenin bir parçasıdır.';

  @override
  String get motivationalQuote15 =>
      'Dün ne olduysa olsun, bugün yeni bir kayıt günü.';

  @override
  String get motivationalQuote16 =>
      'En iyi yatırım aracın: kendine ayırdığın yirmi dakika.';

  @override
  String get actionTip1 =>
      'Büyük hedefleri küçük parçalara böl; bugün sadece ilk parçayı yap.';

  @override
  String get actionTip2 =>
      'Güne başlarken tek bir \"bugün bunu yapacağım\" cümlesi kur.';

  @override
  String get actionTip3 => 'İki dakikadan kısa süren işi erteleme, hemen yap.';

  @override
  String get actionTip4 => 'Yarının planını bu akşam iki cümleyle yaz.';

  @override
  String get actionTip5 =>
      'Bir hedefine takvimde 15 dakikalık sabit bir yer ayır.';

  @override
  String get actionTip6 =>
      'İlerlemeni haftada bir gözden geçir; rotayı küçükçe düzelt.';

  @override
  String get actionTip7 => 'Zor işi günün en enerjik saatine koy.';

  @override
  String get actionTip8 =>
      'Telefonu başka odaya bırakıp 25 dakikalık bir odak bloğu dene.';

  @override
  String get actionTip9 =>
      'Bir alışkanlığı mevcut bir rutine bağla: kahveden sonra beş sayfa.';

  @override
  String get actionTip10 =>
      'Bugün tek bir şeyi %80 yeterlilikte bitir; mükemmeli bekletme.';

  @override
  String get actionTip11 =>
      'Hedefini görünür bir yere yaz — göz önünde olan akılda kalır.';

  @override
  String get actionTip12 =>
      'Başlayamıyorsan kapsamı küçült: 10 dakikaya sığan versiyonu ne?';

  @override
  String get actionTip13 =>
      'Bittiğinde kendine küçük bir ödül tanımla ve sözünü tut.';

  @override
  String get actionTip14 =>
      'İvme kaybettiğinde en kolay adıma geri dön; zincir oradan kurulur.';

  @override
  String get actionTip15 =>
      'Bir engeli önceden tahmin et ve B planını şimdi yaz.';

  @override
  String get actionTip16 =>
      'Günün sonunda tek cümlelik bir \"bugün ne öğrendim\" notu düş.';

  @override
  String get coachTitle => 'Gelecekteki Ben Koçu';

  @override
  String get coachSubtitle => 'Bugün için birkaç düşünce';

  @override
  String coachLoadError(String error) {
    return 'Coach yüklenemedi.\n$error';
  }

  @override
  String get dailyQuestionTitle => 'Günün sorusu';

  @override
  String get dailyQuoteTitle => 'Günün sözü';

  @override
  String get dailyTipTitle => 'Günün ipucu';

  @override
  String todaysAnswer(String answer) {
    return 'Bugünkü yanıtın: $answer';
  }

  @override
  String get answerButton => 'Yanıtla';

  @override
  String get reflectionAnswerHint => 'İçinden geldiği gibi yaz…';

  @override
  String get chapterTitleBeginning => 'Başlangıç';

  @override
  String get chapterTitleComeback => 'Geri Dönüş';

  @override
  String get chapterTitleLeap => 'Sıçrama';

  @override
  String get chapterTitleDream => 'Bir Hayal Daha';

  @override
  String get chapterTitleQuiet => 'Sakin Hafta';

  @override
  String get chapterTitleSteady => 'İstikrar';

  @override
  String get chapterTitleOnTheRoad => 'Yol Alış';

  @override
  String get chapterFirstWeek =>
      'Yolculuğun daha yeni başlıyor. İlk adımlar her zaman en önemlileridir — hazır olduğunda buradayız.';

  @override
  String get chapterQuietOpening1 =>
      'Bu hafta sakin geçti — bazen soluklanmak da yolculuğun parçası.';

  @override
  String get chapterQuietOpening2 =>
      'Bu hafta sakin bir hafta oldu; yeni hafta yeni bir sayfa.';

  @override
  String get chapterLowOpening1 => 'Bu hafta küçük ama değerli adımlar attın.';

  @override
  String get chapterLowOpening2 => 'Yavaş ama emin ilerledin bu hafta.';

  @override
  String get chapterMidOpening1 => 'Bu hafta iyi bir tempo tutturdun.';

  @override
  String get chapterMidOpening2 =>
      'Bu hafta düzenli ve kararlıydın; adımlar üst üste eklendi.';

  @override
  String get chapterHighOpening1 =>
      'Bu hafta güçlüydün — Future You bu haftayı hatırlayacak.';

  @override
  String get chapterHighOpening2 =>
      'Bu hafta adeta sıçradın; emeğin görünür oldu.';

  @override
  String get chapterComeback1 =>
      'Ara verdikten sonra geri dönmen, hiç durmamaktan daha değerli.';

  @override
  String get chapterComeback2 =>
      'Kısa bir duraksamanın ardından yola devam ettin — asıl güç bu.';

  @override
  String chapterImproved(String title, int percent) {
    return '\'$title\' hedefinde gözle görülür yol aldın (+%$percent).';
  }

  @override
  String chapterMissions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'Bu hafta $count görev tamamladın — hayaller birer birer gerçek oluyor.',
      one:
          'Bu hafta bir görevi tamamladın — listenden bir hayal daha gerçek oldu.',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Bölümler';

  @override
  String chaptersLoadError(String error) {
    return 'Bölümler yüklenemedi.\n$error';
  }

  @override
  String get noChaptersYet =>
      'Henüz bölüm yok — ilk tamamlanan haftanın sonunda hikâyen burada yazılacak.';

  @override
  String chapterLabel(int number) {
    return 'BÖLÜM $number';
  }

  @override
  String get longestStreakLabel => 'En uzun seri';

  @override
  String get missionsStatLabel => 'Görev';

  @override
  String featuredGoal(String title) {
    return 'Öne çıkan: $title';
  }

  @override
  String chapterEntryTitle(int number, String title) {
    return 'Bölüm $number: $title';
  }

  @override
  String get chapterEntrySubtitle => 'Geçen haftanın hikâyesine göz at';

  @override
  String get yourLetters => 'Mektupların';

  @override
  String get writeFirstLetter => 'İlk mektubunu yaz';

  @override
  String get writeFirstLetterSubtitle =>
      'Gelecekteki sana bugünden bir not bırak';

  @override
  String lettersWaiting(int count) {
    return '$count mektup açılmayı bekliyor';
  }

  @override
  String lettersInJourney(int count) {
    return '$count mektup yolculukta';
  }

  @override
  String get letterToFuture => 'Geleceğe Mektup';

  @override
  String get letterHint => 'Gelecekteki sana ne söylemek istersin?';

  @override
  String get whenToDeliver => 'Ne zaman ulaşsın?';

  @override
  String get inOneMonth => '1 ay sonra';

  @override
  String get inThreeMonths => '3 ay sonra';

  @override
  String get inSixMonths => '6 ay sonra';

  @override
  String get onGoalCompletionChip => 'Hedef tamamlanınca';

  @override
  String get noActiveGoalForLetter =>
      'Bağlanabilecek aktif bir hedefin yok. Önce bir hedef ekle ya da sabit bir tarih seç.';

  @override
  String get letterSealNote =>
      'Mektubun mühürlenir; zamanı gelene kadar kimse (sen dahil) okuyamaz.';

  @override
  String get sealLetter => 'Mektubu mühürle';

  @override
  String get letterSealed => 'Mektubun mühürlendi.';

  @override
  String get sealFailed => 'Mühürlenemedi, tekrar dene.';

  @override
  String get writeLetterTooltip => 'Mektup yaz';

  @override
  String lettersLoadError(String error) {
    return 'Mektuplar yüklenemedi.\n$error';
  }

  @override
  String get sealedLetter => 'Mühürlü mektup';

  @override
  String get opensToday => 'Bugün açılacak';

  @override
  String opensInDays(int count) {
    return '$count gün sonra açılacak';
  }

  @override
  String get opensOnGoalCompletion => 'Hedefin tamamlanınca açılacak';

  @override
  String get notYetTime =>
      'Henüz zamanı gelmedi — sabır da yolculuğun parçası.';

  @override
  String get letterArrivedTitle => 'Geçmişten bir mektup geldi';

  @override
  String get tapToOpen => 'Açmak için dokun';

  @override
  String get noLettersYet => 'Henüz mektubun yok';

  @override
  String get noLettersYetSubtitle =>
      'Bugünkü duygularını geleceğe taşı — gelecekteki sen okuduğunda bambaşka biri olacak.';

  @override
  String get letterTitle => 'Mektup';

  @override
  String letterLoadError(String error) {
    return 'Mektup yüklenemedi.\n$error';
  }

  @override
  String get letterNotFound => 'Mektup bulunamadı.';

  @override
  String get letterStillSealed =>
      'Bu mektup hâlâ mühürlü — zamanı gelince burada açılacak.';

  @override
  String letterWrittenOn(String date) {
    return '$date tarihinde yazıldı';
  }

  @override
  String letterWrittenOnWithMonths(String date, int count) {
    return '$date tarihinde yazıldı — $count ay önce';
  }

  @override
  String get writeLetterToToday => 'Bugünkü sana bir mektup yaz';

  @override
  String plusPercent(int percent) {
    return '+%$percent';
  }

  @override
  String get languageLabel => 'Dil / Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String levelUpCelebration(int level) {
    return 'Level $level! 🎉';
  }

  @override
  String get goalCompletedCelebration => 'Hedef Tamamlandı! 🏆';

  @override
  String get badgeStreak7 => 'İlk Kıvılcım';

  @override
  String get badgeStreak30 => 'Alev Alev';

  @override
  String get badgeStreak100 => 'Durdurulamaz';

  @override
  String get badgeFirstGoal => 'Yola Çıkış';

  @override
  String get badgeFirstGoalCompleted => 'İlk Zafer';

  @override
  String get badgeGoals5 => 'Hedef Avcısı';

  @override
  String get badgeGoals10 => 'Hedef Ustası';

  @override
  String get badgeFirstMission => 'Hayalperest';

  @override
  String get badgeFirstMissionCompleted => 'Bir Hayal Gerçek';

  @override
  String get badgeMissions5 => 'Hayal Koleksiyoncusu';

  @override
  String get badgeFirstLesson => 'Ses Ver';

  @override
  String get badgeFirstComment => 'Destekçi';

  @override
  String get badgeLesson50Likes => 'İlham Kaynağı';

  @override
  String get badgeComeback => 'Geri Dönüş';

  @override
  String get badgeEarlyBird => 'Erken Kalkan';

  @override
  String get badgeLevel10 => 'Yükseliş';

  @override
  String get badgeLevel25 => 'Efsane';

  @override
  String get achievementsTitle => 'Başarılar';

  @override
  String get achievementsEntryTitle => 'Başarılarını Gör';

  @override
  String get achievementsEntrySubtitle => 'Rozetler ve kişisel rekorlar';

  @override
  String get personalRecords => 'Kişisel Rekorların';

  @override
  String get recordLongestStreak => 'En uzun seri';

  @override
  String get recordTotalXp => 'Toplam XP';

  @override
  String get recordCompletedGoals => 'Tamamlanan hedef';

  @override
  String get recordCompletedMissions => 'Tamamlanan görev';

  @override
  String recordFastestGoal(String title) {
    return 'En hızlı ilerleyen: $title';
  }

  @override
  String badgesCount(int unlocked, int total) {
    return 'Rozetler ($unlocked/$total)';
  }

  @override
  String achievementsLoadError(String error) {
    return 'Başarılar yüklenemedi.\n$error';
  }

  @override
  String get navDashboard => 'Panel';

  @override
  String get navMissions => 'Görevler';

  @override
  String get navLessons => 'Dersler';

  @override
  String get navCoach => 'Koç';

  @override
  String get challengeThreeDayStreak => '3 farklı günde ilerleme kaydet';

  @override
  String get challengeTwoGoals => '2 farklı hedefte ilerleme kaydet';

  @override
  String get challengeMissionNote => 'Bir göreve not ekle';

  @override
  String get challengeReflection => 'Coach\'ın günün sorusunu yanıtla';

  @override
  String get challengeComment => 'Hayat Dersleri\'nde bir gönderiye yorum yap';

  @override
  String get challengeTenPercent => 'Bir hedefte %10 ilerleme kaydet';

  @override
  String get bonusXpTitle => 'Bonus XP kazan';

  @override
  String bonusXpSubtitle(int xp) {
    return 'Kısa bir reklam izle, +$xp XP kazan';
  }

  @override
  String get watchAdAction => 'İzle';

  @override
  String get bonusXpComeBackTomorrow => 'Yarın tekrar gel';

  @override
  String bonusXpEarned(int xp) {
    return '+$xp XP kazandın!';
  }

  @override
  String get adRewardFailed =>
      'Ödül alınamadı — reklam yüklenemedi ya da tamamlanmadı. Sonra tekrar deneyebilirsin.';

  @override
  String streakRestoreTitle(int days) {
    return '$days günlük serin sıfırlandı';
  }

  @override
  String get streakRestoreAction => 'Reklam izle, serini geri kazan';

  @override
  String streakRestored(int days) {
    return 'Serin geri döndü: $days gün';
  }
}
