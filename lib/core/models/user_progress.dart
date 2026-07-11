import 'package:cloud_firestore/cloud_firestore.dart';

/// Streak güncellemesinin sonucu: yeni seri, dondurma kullanımı ve
/// kalan dondurma hakkı.
class StreakUpdateResult {
  const StreakUpdateResult({
    required this.newStreak,
    required this.freezeConsumed,
    required this.newFreezesAvailable,
  });

  final int newStreak;
  final bool freezeConsumed;
  final int newFreezesAvailable;
}

/// Kullanıcının XP/level/streak durumu — Firestore'da users/{uid} dokümanı.
///
/// Level formülü: bir sonraki level için gereken XP kademeli artar,
/// `xpToNextLevel(level) = 100 + (level - 1) * 25`.
/// Örn. L1→L2: 100, L2→L3: 125, L3→L4: 150 XP.
class UserProgress {
  const UserProgress({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.longestStreakEver = 0,
    this.lastActiveDate,
    this.freezesAvailable = monthlyFreezeAllowance,
    this.lastFreezeRefillMonth = '',
    this.lastBonusXpAdDate = '',
    this.streakBrokenAt,
    this.previousStreakBeforeBreak = 0,
    this.streakRestoresUsedThisMonth = 0,
  });

  /// Her ay yenilenen seri dondurma hakkı.
  static const int monthlyFreezeAllowance = 2;

  /// Her ay yenilenen, reklamla seri kurtarma hakkı.
  static const int monthlyStreakRestoreAllowance = 2;

  /// Kırılan seri, kırılma anından itibaren bu süre içinde kurtarılabilir.
  static const Duration streakRestoreWindow = Duration(hours: 48);

  final int totalXp;
  final int currentStreak;

  /// Tüm zamanların en uzun serisi (kişisel rekor panosu + Geri Dönüş
  /// rozeti için); her streak güncellemesinde max ile büyütülür.
  final int longestStreakEver;
  final DateTime? lastActiveDate;

  /// Kalan seri dondurma hakkı (bir gün kaçırılırsa seriyi korur).
  final int freezesAvailable;

  /// Hakların en son yenilendiği ay, "yyyy-MM".
  final String lastFreezeRefillMonth;

  /// Günlük bonus XP reklamının en son izlendiği gün, "yyyy-MM-dd"
  /// (boş: hiç izlenmedi).
  final String lastBonusXpAdDate;

  /// Serinin en son kırıldığı an; kurtarma penceresi buradan başlar.
  /// null: kurtarılabilecek kırık seri yok.
  final DateTime? streakBrokenAt;

  /// Kırılma anındaki seri değeri — kurtarmada geri yazılacak sayı.
  final int previousStreakBeforeBreak;

  /// Bu ay reklamla yapılan seri kurtarma sayısı; ay değişince
  /// [refillFreezesIfNeeded] sıfırlar.
  final int streakRestoresUsedThisMonth;

  /// [level] seviyesinden bir sonrakine geçmek için gereken XP.
  static int xpToNextLevel(int level) => 100 + (level - 1) * 25;

  /// (level, o levele girdikten sonra biriken XP, sonraki level için gereken XP)
  (int, int, int) get _breakdown {
    var level = 1;
    var remaining = totalXp < 0 ? 0 : totalXp;
    var needed = xpToNextLevel(level);
    while (remaining >= needed) {
      remaining -= needed;
      level++;
      needed = xpToNextLevel(level);
    }
    return (level, remaining, needed);
  }

  int get level => _breakdown.$1;

  /// Mevcut levele girdikten sonra biriken XP (progress bar payı).
  int get xpIntoCurrentLevel => _breakdown.$2;

  /// Bir sonraki level için gereken toplam XP (progress bar paydası).
  int get xpForNextLevel => _breakdown.$3;

  /// "yyyy-MM" ay anahtarı.
  static String monthKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}';

  /// "yyyy-MM-dd" gün anahtarı (günlük bonus XP kilidi için).
  static String dayKey(DateTime date) =>
      '${monthKey(date)}-${date.day.toString().padLeft(2, '0')}';

  /// Ay değiştiyse dondurma haklarını yeniler ve reklamla seri kurtarma
  /// sayacını sıfırlar; aynı ay içinde dokunmaz.
  static UserProgress refillFreezesIfNeeded(
    UserProgress current,
    DateTime now,
  ) {
    final key = monthKey(now);
    if (current.lastFreezeRefillMonth == key) return current;
    return current.copyWith(
      freezesAvailable: monthlyFreezeAllowance,
      streakRestoresUsedThisMonth: 0,
      lastFreezeRefillMonth: key,
    );
  }

  /// Kırık seri şu an reklamla kurtarılabilir mi?
  ///
  /// Aylık hak sayısının doğru okunması için önce
  /// [refillFreezesIfNeeded] uygulanmış olmalıdır.
  bool canRestoreStreak(DateTime now) {
    final brokenAt = streakBrokenAt;
    return brokenAt != null &&
        previousStreakBeforeBreak > 1 &&
        now.difference(brokenAt) <= streakRestoreWindow &&
        streakRestoresUsedThisMonth < monthlyStreakRestoreAllowance;
  }

  /// İlerleme kaydedildiğinde yeni streak durumu.
  ///
  /// Son aktiflik bugünse streak korunur, dünse +1. Tam bir gün
  /// atlanmışsa (son aktiflik 2 gün önce) ve dondurma hakkı varsa seri
  /// korunur (+1) ve bir hak tüketilir. Diğer tüm durumlarda seri 1'den
  /// başlar, hak tüketilmez. Saatler önemsiz, gün bazlı bakılır.
  /// Şu an ilerleme kaydedildiği için sonuç asla 1'in altına düşmez
  /// (örn. streak alanı olmadan yazılmış eski kayıtlarda 0 gelebilir).
  static StreakUpdateResult nextStreak({
    required int currentStreak,
    required DateTime? lastActiveDate,
    required DateTime now,
    int freezesAvailable = 0,
  }) {
    StreakUpdateResult result(int streak, {bool freezeConsumed = false}) {
      return StreakUpdateResult(
        newStreak: streak,
        freezeConsumed: freezeConsumed,
        newFreezesAvailable:
            freezeConsumed ? freezesAvailable - 1 : freezesAvailable,
      );
    }

    if (lastActiveDate == null) return result(1);

    final last = DateTime(
      lastActiveDate.year,
      lastActiveDate.month,
      lastActiveDate.day,
    );
    final today = DateTime(now.year, now.month, now.day);
    final dayDiff = today.difference(last).inDays;

    if (dayDiff <= 0) return result(currentStreak < 1 ? 1 : currentStreak);
    if (dayDiff == 1) return result(currentStreak + 1);
    if (dayDiff == 2 && freezesAvailable > 0) {
      // Bir gün atlandı ama dondurma seriyi korudu.
      return result(currentStreak + 1, freezeConsumed: true);
    }
    return result(1);
  }

  /// [clearStreakBreak] true olduğunda kırılma kaydı temizlenir
  /// (copyWith'in ?? deseni null'a çekmeye izin vermediği için).
  UserProgress copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreakEver,
    DateTime? lastActiveDate,
    int? freezesAvailable,
    String? lastFreezeRefillMonth,
    String? lastBonusXpAdDate,
    DateTime? streakBrokenAt,
    int? previousStreakBeforeBreak,
    int? streakRestoresUsedThisMonth,
    bool clearStreakBreak = false,
  }) {
    return UserProgress(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreakEver: longestStreakEver ?? this.longestStreakEver,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      freezesAvailable: freezesAvailable ?? this.freezesAvailable,
      lastFreezeRefillMonth:
          lastFreezeRefillMonth ?? this.lastFreezeRefillMonth,
      lastBonusXpAdDate: lastBonusXpAdDate ?? this.lastBonusXpAdDate,
      streakBrokenAt:
          clearStreakBreak ? null : (streakBrokenAt ?? this.streakBrokenAt),
      previousStreakBeforeBreak: clearStreakBreak
          ? 0
          : (previousStreakBeforeBreak ?? this.previousStreakBeforeBreak),
      streakRestoresUsedThisMonth:
          streakRestoresUsedThisMonth ?? this.streakRestoresUsedThisMonth,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalXp': totalXp,
      'currentStreak': currentStreak,
      'longestStreakEver': longestStreakEver,
      'lastActiveDate':
          lastActiveDate == null ? null : Timestamp.fromDate(lastActiveDate!),
      'freezesAvailable': freezesAvailable,
      'lastFreezeRefillMonth': lastFreezeRefillMonth,
      'lastBonusXpAdDate': lastBonusXpAdDate,
      'streakBrokenAt':
          streakBrokenAt == null ? null : Timestamp.fromDate(streakBrokenAt!),
      'previousStreakBeforeBreak': previousStreakBeforeBreak,
      'streakRestoresUsedThisMonth': streakRestoresUsedThisMonth,
    };
  }

  factory UserProgress.fromMap(Map<String, dynamic> map) {
    final currentStreak = map['currentStreak'] as int? ?? 0;
    return UserProgress(
      totalXp: map['totalXp'] as int? ?? 0,
      currentStreak: currentStreak,
      // Eski dokümanlarda alan yok: rekor en kötü mevcut seriden başlar.
      longestStreakEver: map['longestStreakEver'] as int? ?? currentStreak,
      lastActiveDate: (map['lastActiveDate'] as Timestamp?)?.toDate(),
      freezesAvailable:
          map['freezesAvailable'] as int? ?? monthlyFreezeAllowance,
      lastFreezeRefillMonth: map['lastFreezeRefillMonth'] as String? ?? '',
      lastBonusXpAdDate: map['lastBonusXpAdDate'] as String? ?? '',
      streakBrokenAt: (map['streakBrokenAt'] as Timestamp?)?.toDate(),
      previousStreakBeforeBreak:
          map['previousStreakBeforeBreak'] as int? ?? 0,
      streakRestoresUsedThisMonth:
          map['streakRestoresUsedThisMonth'] as int? ?? 0,
    );
  }
}
