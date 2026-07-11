import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/features/missions/data/missions_repository.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

void main() {
  const uid = 'user-1';
  late FakeFirebaseFirestore firestore;
  late MissionsRepository repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    repository = MissionsRepository(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
    );
  });

  Future<Mission> readMission(String id) async {
    final doc = await firestore
        .collection('users')
        .doc(uid)
        .collection('missions')
        .doc(id)
        .get();
    return Mission.fromMap(doc.id, doc.data()!);
  }

  Future<String> seedMission() async {
    await repository.createMission(title: 'Japonya gezisi', iconName: 'flight');
    final snapshot = await firestore
        .collection('users')
        .doc(uid)
        .collection('missions')
        .get();
    return snapshot.docs.single.id;
  }

  test('markCompleted isCompleted + completedAt yazar', () async {
    final id = await seedMission();

    await repository.markCompleted(id);

    final mission = await readMission(id);
    expect(mission.isCompleted, isTrue);
    expect(mission.completedAt, isNotNull);
  });

  test('markIncomplete tamamlanmayı geri alır', () async {
    final id = await seedMission();
    await repository.markCompleted(id);

    await repository.markIncomplete(id);

    final mission = await readMission(id);
    expect(mission.isCompleted, isFalse);
    expect(mission.completedAt, isNull);
  });

  test('addNote notu ekler ve lastActivityAt günceller', () async {
    final id = await seedMission();
    expect((await readMission(id)).lastActivityAt, isNull);

    await repository.addNote(id, 'Uçak biletlerine baktım');

    final mission = await readMission(id);
    expect(mission.notes, hasLength(1));
    expect(mission.notes.single.text, 'Uçak biletlerine baktım');
    expect(mission.lastActivityAt, isNotNull);
  });

  test('sortMissions: açıklar aktivitesi eski önce, tamamlananlar altta', () {
    final now = DateTime(2026, 7, 7);
    Mission mission(
      String id, {
      bool isCompleted = false,
      DateTime? lastActivityAt,
      DateTime? completedAt,
    }) =>
        Mission(
          id: id,
          userId: uid,
          title: id,
          createdAt: now.subtract(const Duration(days: 30)),
          isCompleted: isCompleted,
          lastActivityAt: lastActivityAt,
          completedAt: completedAt,
        );

    final sorted = MissionsRepository.sortMissions([
      mission('done', isCompleted: true, completedAt: now),
      mission('fresh', lastActivityAt: now.subtract(const Duration(days: 1))),
      mission('stale', lastActivityAt: now.subtract(const Duration(days: 20))),
    ]);

    expect(sorted.map((m) => m.id).toList(), ['stale', 'fresh', 'done']);
  });
}
