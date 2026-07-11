import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';

void main() {
  group('level hesabı — xpToNextLevel(n) = 100 + (n-1)*25', () {
    // Kümülatif eşikler: L2=100, L3=225, L4=375, L5=550
    test('0 XP → Level 1, sıfır birikim, 100 XP hedef', () {
      const progress = UserProgress();
      expect(progress.level, 1);
      expect(progress.xpIntoCurrentLevel, 0);
      expect(progress.xpForNextLevel, 100);
    });

    test('eşiğin hemen altı levele geçirmez', () {
      const progress = UserProgress(totalXp: 99);
      expect(progress.level, 1);
      expect(progress.xpIntoCurrentLevel, 99);
    });

    test('100 XP → Level 2, sonraki eşik 125', () {
      const progress = UserProgress(totalXp: 100);
      expect(progress.level, 2);
      expect(progress.xpIntoCurrentLevel, 0);
      expect(progress.xpForNextLevel, 125);
    });

    test('224 XP → hâlâ Level 2, 124 XP birikmiş', () {
      const progress = UserProgress(totalXp: 224);
      expect(progress.level, 2);
      expect(progress.xpIntoCurrentLevel, 124);
    });

    test('225 XP → Level 3, 550 XP → Level 5', () {
      expect(const UserProgress(totalXp: 225).level, 3);
      expect(const UserProgress(totalXp: 550).level, 5);
      expect(const UserProgress(totalXp: 549).level, 4);
    });

    test('negatif XP çökmez, Level 1 kalır', () {
      expect(const UserProgress(totalXp: -50).level, 1);
    });
  });

  group('nextStreak', () {
    final now = DateTime(2026, 7, 6, 14, 30);

    test('hiç aktiflik yoksa 1 başlar, freeze tüketilmez', () {
      final result = UserProgress.nextStreak(
        currentStreak: 0,
        lastActiveDate: null,
        now: now,
        freezesAvailable: 2,
      );
      expect(result.newStreak, 1);
      expect(result.freezeConsumed, isFalse);
      expect(result.newFreezesAvailable, 2);
    });

    test('son aktiflik bugünse streak değişmez', () {
      expect(
        UserProgress.nextStreak(
          currentStreak: 5,
          lastActiveDate: DateTime(2026, 7, 6, 8, 0),
          now: now,
        ).newStreak,
        5,
      );
    });

    test('aynı gün ama streak 0 ise (eski kayıt) 1\'e çekilir', () {
      expect(
        UserProgress.nextStreak(
          currentStreak: 0,
          lastActiveDate: DateTime(2026, 7, 6, 8, 0),
          now: now,
        ).newStreak,
        1,
      );
    });

    test('son aktiflik dünse +1, freeze tüketilmez', () {
      final result = UserProgress.nextStreak(
        currentStreak: 5,
        lastActiveDate: DateTime(2026, 7, 5, 23, 59),
        now: now,
        freezesAvailable: 2,
      );
      expect(result.newStreak, 6);
      expect(result.freezeConsumed, isFalse);
      expect(result.newFreezesAvailable, 2);
    });

    test('dün gece geç saat → bugün erken saat de +1 sayılır (gün bazlı)',
        () {
      expect(
        UserProgress.nextStreak(
          currentStreak: 2,
          lastActiveDate: DateTime(2026, 7, 5, 23, 50),
          now: DateTime(2026, 7, 6, 0, 10),
        ).newStreak,
        3,
      );
    });

    test('2 gün önce + freeze varsa: seri korunur, hak 1 azalır', () {
      final result = UserProgress.nextStreak(
        currentStreak: 12,
        lastActiveDate: DateTime(2026, 7, 4),
        now: now,
        freezesAvailable: 2,
      );
      expect(result.newStreak, 13); // atlanan gün hiç olmamış gibi
      expect(result.freezeConsumed, isTrue);
      expect(result.newFreezesAvailable, 1);
    });

    test('2 gün önce ama freeze yoksa: 1\'e sıfırlanır', () {
      final result = UserProgress.nextStreak(
        currentStreak: 12,
        lastActiveDate: DateTime(2026, 7, 4),
        now: now,
        freezesAvailable: 0,
      );
      expect(result.newStreak, 1);
      expect(result.freezeConsumed, isFalse);
      expect(result.newFreezesAvailable, 0);
    });

    test('3+ gün önce: freeze olsa bile sıfırlanır, hak tüketilmez', () {
      final result = UserProgress.nextStreak(
        currentStreak: 12,
        lastActiveDate: DateTime(2026, 7, 3),
        now: now,
        freezesAvailable: 2,
      );
      expect(result.newStreak, 1);
      expect(result.freezeConsumed, isFalse);
      expect(result.newFreezesAvailable, 2);

      expect(
        UserProgress.nextStreak(
          currentStreak: 12,
          lastActiveDate: DateTime(2026, 6, 1),
          now: now,
          freezesAvailable: 2,
        ).newStreak,
        1,
      );
    });

    test('ay sınırında dün doğru hesaplanır', () {
      expect(
        UserProgress.nextStreak(
          currentStreak: 3,
          lastActiveDate: DateTime(2026, 6, 30),
          now: DateTime(2026, 7, 1, 9, 0),
        ).newStreak,
        4,
      );
    });
  });

  group('refillFreezesIfNeeded', () {
    test('ay değişince haklar 2\'ye yenilenir, ay güncellenir', () {
      const progress = UserProgress(
        totalXp: 500,
        currentStreak: 4,
        freezesAvailable: 0,
        lastFreezeRefillMonth: '2026-06',
      );

      final refilled =
          UserProgress.refillFreezesIfNeeded(progress, DateTime(2026, 7, 6));

      expect(refilled.freezesAvailable, 2);
      expect(refilled.lastFreezeRefillMonth, '2026-07');
      // Diğer alanlar korunur.
      expect(refilled.totalXp, 500);
      expect(refilled.currentStreak, 4);
    });

    test('aynı ay içinde tekrar yenilenmez (harcanmış hak geri gelmez)', () {
      const progress = UserProgress(
        freezesAvailable: 1,
        lastFreezeRefillMonth: '2026-07',
      );

      final result =
          UserProgress.refillFreezesIfNeeded(progress, DateTime(2026, 7, 20));

      expect(result.freezesAvailable, 1);
      expect(result.lastFreezeRefillMonth, '2026-07');
    });

    test('hiç yenilenmemiş (yeni kullanıcı) ilk çağrıda yenilenir', () {
      const progress = UserProgress(freezesAvailable: 0);

      final result =
          UserProgress.refillFreezesIfNeeded(progress, DateTime(2026, 7, 6));

      expect(result.freezesAvailable, 2);
      expect(result.lastFreezeRefillMonth, '2026-07');
    });

    test('ay değişince seri kurtarma sayacı da sıfırlanır', () {
      const progress = UserProgress(
        streakRestoresUsedThisMonth: 2,
        lastFreezeRefillMonth: '2026-06',
      );

      final refilled =
          UserProgress.refillFreezesIfNeeded(progress, DateTime(2026, 7, 6));

      expect(refilled.streakRestoresUsedThisMonth, 0);
    });

    test('aynı ay içinde kurtarma sayacına dokunulmaz', () {
      const progress = UserProgress(
        streakRestoresUsedThisMonth: 1,
        lastFreezeRefillMonth: '2026-07',
      );

      final result =
          UserProgress.refillFreezesIfNeeded(progress, DateTime(2026, 7, 20));

      expect(result.streakRestoresUsedThisMonth, 1);
    });
  });

  group('dayKey', () {
    test('yyyy-MM-dd, tek haneler sıfırla doldurulur', () {
      expect(UserProgress.dayKey(DateTime(2026, 7, 6)), '2026-07-06');
      expect(UserProgress.dayKey(DateTime(2026, 11, 23)), '2026-11-23');
    });
  });

  group('canRestoreStreak', () {
    final now = DateTime(2026, 7, 6, 14, 0);

    UserProgress broken({
      DateTime? brokenAt,
      int previousStreak = 14,
      int restoresUsed = 0,
    }) {
      return UserProgress(
        currentStreak: 1,
        streakBrokenAt: brokenAt ?? now.subtract(const Duration(hours: 3)),
        previousStreakBeforeBreak: previousStreak,
        streakRestoresUsedThisMonth: restoresUsed,
        lastFreezeRefillMonth: '2026-07',
      );
    }

    test('48 saat içinde ve hak varken true', () {
      expect(broken().canRestoreStreak(now), isTrue);
    });

    test('kırılma kaydı yoksa false', () {
      expect(const UserProgress().canRestoreStreak(DateTime(2026, 7, 6)),
          isFalse);
    });

    test('48 saat geçtiyse false, sınırın hemen içindeyse true', () {
      expect(
        broken(brokenAt: now.subtract(const Duration(hours: 49)))
            .canRestoreStreak(now),
        isFalse,
      );
      expect(
        broken(brokenAt: now.subtract(const Duration(hours: 47)))
            .canRestoreStreak(now),
        isTrue,
      );
    });

    test('aylık hak (2) dolduysa false', () {
      expect(broken(restoresUsed: 2).canRestoreStreak(now), isFalse);
      expect(broken(restoresUsed: 1).canRestoreStreak(now), isTrue);
    });
  });

  group('yeni alanların map dönüşümü ve copyWith', () {
    test('toMap/fromMap gidiş-dönüşü yeni alanları korur', () {
      final brokenAt = DateTime(2026, 7, 5, 10, 0);
      final progress = UserProgress(
        totalXp: 90,
        currentStreak: 1,
        lastBonusXpAdDate: '2026-07-06',
        streakBrokenAt: brokenAt,
        previousStreakBeforeBreak: 9,
        streakRestoresUsedThisMonth: 1,
      );

      final roundTrip = UserProgress.fromMap(progress.toMap());

      expect(roundTrip.lastBonusXpAdDate, '2026-07-06');
      expect(roundTrip.streakBrokenAt, brokenAt);
      expect(roundTrip.previousStreakBeforeBreak, 9);
      expect(roundTrip.streakRestoresUsedThisMonth, 1);
    });

    test('eski dokümanlarda (alanlar yok) güvenli varsayılanlar', () {
      final progress = UserProgress.fromMap({'totalXp': 10});

      expect(progress.lastBonusXpAdDate, '');
      expect(progress.streakBrokenAt, isNull);
      expect(progress.previousStreakBeforeBreak, 0);
      expect(progress.streakRestoresUsedThisMonth, 0);
    });

    test('copyWith clearStreakBreak kırılma kaydını temizler', () {
      final progress = UserProgress(
        streakBrokenAt: DateTime(2026, 7, 5),
        previousStreakBeforeBreak: 9,
      );

      final cleared = progress.copyWith(clearStreakBreak: true);

      expect(cleared.streakBrokenAt, isNull);
      expect(cleared.previousStreakBeforeBreak, 0);

      // Bayrak olmadan mevcut kayıt korunur (?? deseni null'a çekemez).
      final kept = progress.copyWith(currentStreak: 3);
      expect(kept.streakBrokenAt, isNotNull);
      expect(kept.previousStreakBeforeBreak, 9);
    });
  });
}
