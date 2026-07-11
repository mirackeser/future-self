import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';

/// Günlük yansıma yanıtları: users/{uid}/reflections/{yyyy-MM-dd}.
class ReflectionsRepository {
  ReflectionsRepository(this._firebase);

  final FirebaseService _firebase;

  CollectionReference<Map<String, dynamic>> _reflectionsRef(String uid) =>
      _firebase.firestore
          .collection('users')
          .doc(uid)
          .collection('reflections');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Yansıma işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  /// yyyy-MM-dd biçiminde doküman anahtarı.
  static String dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  Future<void> saveReflectionAnswer(
    String dateKey,
    String question,
    String answer,
  ) {
    final reflection = Reflection(
      dateKey: dateKey,
      question: question,
      answer: answer.trim(),
      answeredAt: DateTime.now(),
    );
    return _reflectionsRef(_uid).doc(dateKey).set(reflection.toMap());
  }

  /// Bugünün yanıtı; henüz yanıtlanmamışsa null.
  Stream<Reflection?> watchTodayReflection() {
    final key = dateKey(DateTime.now());
    return _reflectionsRef(_uid).doc(key).snapshots().map(
          (doc) => doc.exists ? Reflection.fromMap(key, doc.data()!) : null,
        );
  }
}

final reflectionsRepositoryProvider = Provider<ReflectionsRepository>((ref) {
  return ReflectionsRepository(ref.watch(firebaseServiceProvider));
});
