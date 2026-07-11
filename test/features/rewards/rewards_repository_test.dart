import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/features/rewards/data/rewards_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late RewardsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = RewardsRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
    );
  });

  Future<void> seedUser(UserProgress progress) =>
      firestore.collection('users').doc(uid).set(progress.toMap());

  Future<UserProgress> readUser() async {
    final doc = await firestore.collection('users').doc(uid).get();
    return UserProgress.fromMap(doc.data()!);
  }

  group('claimDailyBonusXp', () {
    final now = DateTime(2026, 7, 6, 15, 0);

    test('ilk izleme: +30 XP eklenir, gün kilidi yazılır, true döner',
        () async {
      await seedUser(const UserProgress(totalXp: 100));

      expect(await repository.claimDailyBonusXp(now: now), isTrue);

      final progress = await readUser();
      expect(progress.totalXp, 100 + RewardsRepository.bonusXpAmount);
      expect(progress.lastBonusXpAdDate, '2026-07-06');
    });

    test('aynı gün ikinci istek reddedilir, XP değişmez', () async {
      await seedUser(const UserProgress(totalXp: 100));

      await repository.claimDailyBonusXp(now: now);
      expect(
        await repository.claimDailyBonusXp(
          now: now.add(const Duration(hours: 5)),
        ),
        isFalse,
      );

      expect(
        (await readUser()).totalXp,
        100 + RewardsRepository.bonusXpAmount,
      );
    });

    test('ertesi gün yeniden kullanılabilir', () async {
      await seedUser(const UserProgress());

      await repository.claimDailyBonusXp(now: now);
      final nextDay = now.add(const Duration(days: 1));
      expect(await repository.claimDailyBonusXp(now: nextDay), isTrue);

      final progress = await readUser();
      expect(progress.totalXp, RewardsRepository.bonusXpAmount * 2);
      expect(progress.lastBonusXpAdDate, '2026-07-07');
    });

    test('kullanıcı dokümanı henüz yokken de çalışır (yeni kullanıcı)',
        () async {
      expect(await repository.claimDailyBonusXp(now: now), isTrue);

      final progress = await readUser();
      expect(progress.totalXp, RewardsRepository.bonusXpAmount);
      expect(progress.lastBonusXpAdDate, '2026-07-06');
    });
  });

  group('restoreStreak', () {
    final now = DateTime(2026, 7, 6, 15, 0);

    UserProgress brokenProgress({
      int restoresUsed = 0,
      DateTime? brokenAt,
      String refillMonth = '2026-07',
    }) {
      return UserProgress(
        totalXp: 200,
        currentStreak: 1,
        longestStreakEver: 14,
        lastActiveDate: now,
        freezesAvailable: 1,
        lastFreezeRefillMonth: refillMonth,
        streakBrokenAt: brokenAt ?? now.subtract(const Duration(hours: 5)),
        previousStreakBeforeBreak: 14,
        streakRestoresUsedThisMonth: restoresUsed,
      );
    }

    test('mutlu yol: seri eski değerine döner, sayaç artar, kayıt temizlenir',
        () async {
      await seedUser(brokenProgress());

      expect(await repository.restoreStreak(now: now), isTrue);

      final progress = await readUser();
      expect(progress.currentStreak, 14);
      expect(progress.streakRestoresUsedThisMonth, 1);
      expect(progress.streakBrokenAt, isNull);
      expect(progress.previousStreakBeforeBreak, 0);
      expect(progress.totalXp, 200); // XP'ye dokunulmaz
      expect(progress.freezesAvailable, 1); // freeze'e dokunulmaz
    });

    test('48 saat geçtiyse false döner, hiçbir şey değişmez', () async {
      await seedUser(
        brokenProgress(brokenAt: now.subtract(const Duration(hours: 49))),
      );

      expect(await repository.restoreStreak(now: now), isFalse);

      final progress = await readUser();
      expect(progress.currentStreak, 1);
      expect(progress.streakRestoresUsedThisMonth, 0);
      expect(progress.streakBrokenAt, isNotNull);
    });

    test('aylık hak (2) dolduysa false döner', () async {
      await seedUser(brokenProgress(restoresUsed: 2));

      expect(await repository.restoreStreak(now: now), isFalse);
      expect((await readUser()).currentStreak, 1);
    });

    test('ay devrinde sayaç sıfırlanır; kurtarma yeni aydan düşer ve '
        'freeze hakları da yenilenir', () async {
      // Geçen ay 2 hak da kullanılmış; ay değişti.
      await seedUser(
        brokenProgress(restoresUsed: 2, refillMonth: '2026-06'),
      );

      expect(await repository.restoreStreak(now: now), isTrue);

      final progress = await readUser();
      expect(progress.currentStreak, 14);
      expect(progress.streakRestoresUsedThisMonth, 1);
      expect(progress.freezesAvailable, UserProgress.monthlyFreezeAllowance);
      expect(progress.lastFreezeRefillMonth, '2026-07');
    });

    test('kırılma kaydı yokken false döner', () async {
      await seedUser(const UserProgress(currentStreak: 3));

      expect(await repository.restoreStreak(now: now), isFalse);
    });

    test('kullanıcı dokümanı yokken false döner', () async {
      expect(await repository.restoreStreak(now: now), isFalse);
    });
  });
}
