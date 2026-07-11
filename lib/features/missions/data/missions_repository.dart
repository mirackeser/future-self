import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../../core/services/services.dart';

/// Life Missions'ın Firestore erişim katmanı: users/{uid}/missions.
class MissionsRepository {
  MissionsRepository(this._firebase);

  final FirebaseService _firebase;

  CollectionReference<Map<String, dynamic>> _missionsRef(String uid) =>
      _firebase.firestore.collection('users').doc(uid).collection('missions');

  String get _uid {
    final user = _firebase.currentUser;
    if (user == null) {
      throw StateError('Mission işlemleri için oturum açık olmalı.');
    }
    return user.uid;
  }

  Future<void> createMission({required String title, String? iconName}) {
    final docRef = _missionsRef(_uid).doc();
    final mission = Mission(
      id: docRef.id,
      userId: _uid,
      title: title.trim(),
      iconName: iconName,
      createdAt: DateTime.now(),
    );
    return docRef.set(mission.toMap());
  }

  /// Tamamlanmamışlar üstte (aktivitesi en eski önce, dikkat çeksin),
  /// tamamlananlar altta (en yeni tamamlanan önce).
  Stream<List<Mission>> watchMissions() {
    return _missionsRef(_uid).snapshots().map((snapshot) {
      final missions = [
        for (final doc in snapshot.docs) Mission.fromMap(doc.id, doc.data()),
      ];
      return sortMissions(missions);
    });
  }

  @visibleForTesting
  static List<Mission> sortMissions(List<Mission> missions) {
    DateTime activity(Mission m) => m.lastActivityAt ?? m.createdAt;
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);

    return [...missions]..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        if (a.isCompleted) {
          return (b.completedAt ?? epoch).compareTo(a.completedAt ?? epoch);
        }
        return activity(a).compareTo(activity(b));
      });
  }

  /// Not ekler ve lastActivityAt'i şimdiye çeker.
  Future<void> addNote(String missionId, String text) {
    final now = DateTime.now();
    final note = MissionNote(text: text.trim(), timestamp: now);
    return _missionsRef(_uid).doc(missionId).update({
      'notes': FieldValue.arrayUnion([note.toMap()]),
      'lastActivityAt': Timestamp.fromDate(now),
    });
  }

  Future<void> markCompleted(String missionId) {
    return _missionsRef(_uid).doc(missionId).update({
      'isCompleted': true,
      'completedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> markIncomplete(String missionId) {
    return _missionsRef(_uid).doc(missionId).update({
      'isCompleted': false,
      'completedAt': null,
    });
  }

  Future<void> deleteMission(String missionId) =>
      _missionsRef(_uid).doc(missionId).delete();
}

final missionsRepositoryProvider = Provider<MissionsRepository>((ref) {
  return MissionsRepository(ref.watch(firebaseServiceProvider));
});
