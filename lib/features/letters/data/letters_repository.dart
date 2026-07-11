import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';

/// Future Self mektupları: users/{uid}/letters.
class LettersRepository {
  LettersRepository(this._firebase, this._notifications);

  final FirebaseService _firebase;
  final LocalNotificationsService _notifications;

  CollectionReference<Map<String, dynamic>> _lettersRef(String uid) =>
      _firebase.firestore.collection('users').doc(uid).collection('letters');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Mektup işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  /// Bildirim önizlemesi: mektubun ilk birkaç kelimesi.
  @visibleForTesting
  static String previewOf(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length <= 6) return words.join(' ');
    return '${words.take(6).join(' ')}…';
  }

  /// Mektubu mühürler. fixedDate ise bildirimi hemen zamanlar;
  /// goalCompletion ise zamanlamaz — hedef %100'e ulaştığında
  /// [checkGoalCompletionLetters] anlık bildirim tetikler.
  Future<void> createLetter({
    required String text,
    required LetterDeliveryMode deliveryMode,
    DateTime? deliveryDate,
    String? relatedGoalId,
  }) async {
    final docRef = _lettersRef(_uid).doc();

    var notificationId = 0;
    if (deliveryMode == LetterDeliveryMode.fixedDate) {
      notificationId = await _notifications.scheduleLetterNotification(
        letterId: docRef.id,
        deliveryDate: deliveryDate!,
        previewText: previewOf(text),
      );
    }

    final letter = FutureLetter(
      id: docRef.id,
      text: text.trim(),
      createdAt: DateTime.now(),
      deliveryMode: deliveryMode,
      deliveryDate:
          deliveryMode == LetterDeliveryMode.fixedDate ? deliveryDate : null,
      relatedGoalId:
          deliveryMode == LetterDeliveryMode.goalCompletion ? relatedGoalId : null,
      notificationId: notificationId,
    );
    await docRef.set(letter.toMap());
  }

  /// Hedef güncellendiğinde çağrılır: hedef %100'e ulaştıysa o hedefe
  /// bağlı, henüz teslim edilmemiş goalCompletion mektuplarını anlık
  /// bildirimle teslim eder (deliveryDate damgası tekrar bildirmeyi
  /// engeller).
  Future<void> checkGoalCompletionLetters(String goalId) async {
    final uid = _uid;

    final goalDoc = await _firebase.firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .doc(goalId)
        .get();
    if (!goalDoc.exists) return;
    final goal = Goal.fromMap(goalDoc.id, goalDoc.data()!);
    if (goal.progressPercent != 1.0) return;

    final pending = await _lettersRef(uid)
        .where('deliveryMode',
            isEqualTo: LetterDeliveryMode.goalCompletion.name)
        .where('relatedGoalId', isEqualTo: goalId)
        .where('isOpened', isEqualTo: false)
        .get();

    final now = DateTime.now();
    for (final doc in pending.docs) {
      final letter = FutureLetter.fromMap(doc.id, doc.data());
      // Zaten teslim edilmişse (deliveryDate damgalı) tekrar bildirme.
      if (letter.deliveryDate != null) continue;
      final notificationId = await _notifications.showLetterDeliveredNow(
        letterId: letter.id,
        previewText: previewOf(letter.text),
      );
      await doc.reference.update({
        'deliveryDate': Timestamp.fromDate(now),
        'notificationId': notificationId,
      });
    }
  }

  Future<void> markOpened(String letterId) =>
      _lettersRef(_uid).doc(letterId).update({'isOpened': true});

  /// Mektuplar, en yeni önce.
  Stream<List<FutureLetter>> watchLetters() {
    return _lettersRef(_uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              FutureLetter.fromMap(doc.id, doc.data()),
          ],
        );
  }
}

final lettersRepositoryProvider = Provider<LettersRepository>((ref) {
  return LettersRepository(
    ref.watch(firebaseServiceProvider),
    ref.watch(localNotificationsServiceProvider),
  );
});
