import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';

/// Reklam ödüllerinin Firestore katmanı: günlük bonus XP ve seri
/// kurtarma — ikisi de users/{uid} dokümanında yaşar.
class RewardsRepository {
  RewardsRepository(this._firebase);

  final FirebaseService _firebase;

  /// Günlük bonus XP reklamının ödülü.
  static const int bonusXpAmount = 30;

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Ödül işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> get _userRef =>
      _firebase.firestore.collection('users').doc(_uid);

  /// Bonus XP'yi verir; bugün zaten alındıysa false döner.
  ///
  /// Transaction dokümanı taze okuduğundan yarış durumunda bile aynı
  /// gün ikinci kez ödül verilmez. [now] testler için enjekte edilir.
  Future<bool> claimDailyBonusXp({DateTime? now}) {
    final today = UserProgress.dayKey(now ?? DateTime.now());
    final userRef = _userRef;

    return _firebase.firestore.runTransaction((tx) async {
      final doc = await tx.get(userRef);
      final progress = doc.exists
          ? UserProgress.fromMap(doc.data()!)
          : const UserProgress();
      if (progress.lastBonusXpAdDate == today) return false;

      tx.set(
        userRef,
        progress
            .copyWith(
              totalXp: progress.totalXp + bonusXpAmount,
              lastBonusXpAdDate: today,
            )
            .toMap(),
        SetOptions(merge: true),
      );
      return true;
    });
  }

  /// Kırık seriyi reklam ödülüyle kırılma öncesi değerine döndürür.
  ///
  /// Koşullar dashboard banner'ıyla aynıdır ama transaction içinde taze
  /// veriyle tekrar doğrulanır: kırılma kaydı var, 48 saat geçmemiş,
  /// bu ayki kurtarma hakkı dolmamış. Başarıda kurtarma sayacı artar,
  /// kırılma kaydı temizlenir ve true döner.
  Future<bool> restoreStreak({DateTime? now}) {
    final moment = now ?? DateTime.now();
    final userRef = _userRef;

    return _firebase.firestore.runTransaction((tx) async {
      final doc = await tx.get(userRef);
      if (!doc.exists) return false;

      // Ay değiştiyse kurtarma sayacı da burada sıfırlanır; böylece ay
      // devrinden sonraki ilk kurtarma yeni aydan düşer.
      final refilled = UserProgress.refillFreezesIfNeeded(
        UserProgress.fromMap(doc.data()!),
        moment,
      );
      if (!refilled.canRestoreStreak(moment)) return false;

      final restored = refilled.copyWith(
        currentStreak: refilled.previousStreakBeforeBreak,
        streakRestoresUsedThisMonth:
            refilled.streakRestoresUsedThisMonth + 1,
        clearStreakBreak: true,
      );
      tx.set(userRef, restored.toMap(), SetOptions(merge: true));
      return true;
    });
  }
}

final rewardsRepositoryProvider = Provider<RewardsRepository>((ref) {
  return RewardsRepository(ref.watch(firebaseServiceProvider));
});
