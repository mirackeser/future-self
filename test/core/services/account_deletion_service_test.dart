import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:future_self/core/services/account_deletion_service.dart';
import 'package:future_self/core/services/firebase_service.dart';
import 'package:future_self/core/services/local_notifications_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserInfo extends Mock implements UserInfo {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockLocalNotificationsService extends Mock
    implements LocalNotificationsService {}

void main() {
  const uid = 'user-1';
  const otherUid = 'user-2';

  late FakeFirebaseFirestore firestore;
  late MockUser user;
  late MockLocalNotificationsService notifications;
  late AccountDeletionService service;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.providerData).thenReturn(const []);
    when(() => user.delete()).thenAnswer((_) async {});

    final auth = MockFirebaseAuth();
    when(() => auth.currentUser).thenReturn(user);

    notifications = MockLocalNotificationsService();
    when(() => notifications.cancelNotification(any()))
        .thenAnswer((_) async {});

    service = AccountDeletionService(
      FirebaseService(
        auth: auth,
        firestore: firestore,
        messaging: MockFirebaseMessaging(),
      ),
      notifications,
    );
  });

  /// users/{uid} dokümanını ve bilinen tüm alt koleksiyonları doldurur.
  Future<void> seedUserData() async {
    final userRef = firestore.collection('users').doc(uid);
    await userRef.set({'level': 3});
    await userRef.collection('goals').doc('g1').set({'title': 'Kilo'});
    await userRef
        .collection('goals')
        .doc('g1')
        .collection('history')
        .doc('h1')
        .set({'newValue': 80});
    await userRef
        .collection('goals')
        .doc('g1')
        .collection('history')
        .doc('h2')
        .set({'newValue': 78});
    await userRef.collection('missions').doc('m1').set({'title': 'Japonya'});
    await userRef.collection('reflections').doc('r1').set({'text': 'not'});
    await userRef.collection('chapters').doc('c1').set({'summary': 'hafta'});
    await userRef
        .collection('letters')
        .doc('l1')
        .set({'text': 'mektup', 'notificationId': 42});
    await userRef
        .collection('letters')
        .doc('l2')
        .set({'text': 'mektup 2', 'notificationId': 0});
    await userRef.collection('weeklyChallenges').doc('w1').set({'xp': 100});
  }

  /// Kendi lesson'ı (alt koleksiyonlu) + başkasının lesson'ında yorum,
  /// like ve save izleri.
  Future<void> seedLessonsData() async {
    final own = firestore.collection('lessons').doc('own-1');
    await own.set({'authorUid': uid, 'text': 'kendi dersim'});
    await own.collection('comments').doc('oc1').set({'authorUid': otherUid});
    await own.collection('likes').doc(otherUid).set({'uid': otherUid});
    await own.collection('reports').doc(otherUid).set({'uid': otherUid});

    final other = firestore.collection('lessons').doc('other-1');
    await other.set({
      'authorUid': otherUid,
      'text': 'başkasının dersi',
      'commentCount': 2,
      'likeCount': 2,
    });
    await other.collection('comments').doc('mine').set({'authorUid': uid});
    await other
        .collection('comments')
        .doc('theirs')
        .set({'authorUid': otherUid});
    await other.collection('likes').doc(uid).set({'uid': uid});
  }

  test('users/{uid} dokümanı ve tüm alt koleksiyonlar silinir', () async {
    await seedUserData();

    await service.deleteAccount();

    final userRef = firestore.collection('users').doc(uid);
    expect((await userRef.get()).exists, isFalse);
    for (final sub in AccountDeletionService.userSubcollections) {
      expect(
        (await userRef.collection(sub).get()).docs,
        isEmpty,
        reason: '$sub silinmeliydi',
      );
    }
    expect(
      (await userRef.collection('goals').doc('g1').collection('history').get())
          .docs,
      isEmpty,
      reason: 'goal history silinmeliydi',
    );
    verify(() => user.delete()).called(1);
  });

  test('mektup bildirimleri silinmeden önce iptal edilir (id != 0)',
      () async {
    await seedUserData();

    await service.deleteAccount();

    verify(() => notifications.cancelNotification(42)).called(1);
    verifyNever(() => notifications.cancelNotification(0));
  });

  test('kendi lesson\'ları alt koleksiyonlarıyla silinir', () async {
    await seedLessonsData();

    await service.deleteAccount();

    final own = firestore.collection('lessons').doc('own-1');
    expect((await own.get()).exists, isFalse);
    expect((await own.collection('comments').get()).docs, isEmpty);
    expect((await own.collection('likes').get()).docs, isEmpty);
    expect((await own.collection('reports').get()).docs, isEmpty);
  });

  test(
      'başkasının lesson\'ındaki yorum ve like izleri silinir, '
      'sayaçlar azalır, diğerlerinin verisi durur', () async {
    await seedLessonsData();

    await service.deleteAccount();

    final other = firestore.collection('lessons').doc('other-1');
    final otherData = (await other.get()).data()!;
    expect(otherData['commentCount'], 1);
    expect(otherData['likeCount'], 1);
    expect(
      (await other.collection('comments').doc('mine').get()).exists,
      isFalse,
    );
    expect(
      (await other.collection('comments').doc('theirs').get()).exists,
      isTrue,
    );
    expect((await other.collection('likes').doc(uid).get()).exists, isFalse);
  });

  group('requires-recent-login', () {
    setUp(() {
      when(() => user.delete()).thenThrow(
        FirebaseAuthException(code: 'requires-recent-login'),
      );
    });

    UserInfo providerInfo(String providerId) {
      final info = MockUserInfo();
      when(() => info.providerId).thenReturn(providerId);
      return info;
    }

    test('veri yine de silinir, yöntem providerData\'dan tespit edilir',
        () async {
      await seedUserData();
      // Not: iç mock (providerInfo) thenReturn argümanı içinde
      // stub'lanamaz (mocktail state'i); önce oluşturulur.
      final google = providerInfo('google.com');
      when(() => user.providerData).thenReturn([google]);

      await expectLater(
        service.deleteAccount(),
        throwsA(
          isA<RequiresRecentLoginException>()
              .having((e) => e.method, 'method', ReauthMethod.google),
        ),
      );

      // Auth silinemese de Firestore verisi temizlenmiş olmalı.
      expect(
        (await firestore.collection('users').doc(uid).get()).exists,
        isFalse,
      );
    });

    test('apple ve password sağlayıcıları doğru eşlenir', () async {
      final apple = providerInfo('apple.com');
      when(() => user.providerData).thenReturn([apple]);
      await expectLater(
        service.deleteAuthUser(),
        throwsA(
          isA<RequiresRecentLoginException>()
              .having((e) => e.method, 'method', ReauthMethod.apple),
        ),
      );

      final password = providerInfo('password');
      when(() => user.providerData).thenReturn([password]);
      await expectLater(
        service.deleteAuthUser(),
        throwsA(
          isA<RequiresRecentLoginException>()
              .having((e) => e.method, 'method', ReauthMethod.password),
        ),
      );
    });

    test('providerData boşsa varsayılan yöntem password', () async {
      await expectLater(
        service.deleteAuthUser(),
        throwsA(
          isA<RequiresRecentLoginException>()
              .having((e) => e.method, 'method', ReauthMethod.password),
        ),
      );
    });
  });

  test('deleteAuthUser diğer auth hatalarını olduğu gibi fırlatır', () async {
    when(() => user.delete()).thenThrow(
      FirebaseAuthException(code: 'network-request-failed'),
    );
    await expectLater(
      service.deleteAuthUser(),
      throwsA(
        isA<FirebaseAuthException>()
            .having((e) => e.code, 'code', 'network-request-failed'),
      ),
    );
  });
}
