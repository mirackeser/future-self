import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Firebase erişim noktası.
///
/// Repository'ler Auth ve Firestore'a doğrudan `FirebaseAuth.instance`
/// üzerinden değil, her zaman bu servis (provider'ı) üzerinden erişir —
/// böylece testlerde sahte instance'larla değiştirilebilir.
class FirebaseService {
  FirebaseService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : auth = auth ?? FirebaseAuth.instance,
        firestore = firestore ?? FirebaseFirestore.instance,
        messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseMessaging messaging;

  /// Sistem bildirim izni penceresini açar (iOS ve Android 13+).
  ///
  /// Sonuç ne olursa olsun fırlatmaz — onboarding akışı izin
  /// reddedilse ya da istek başarısız olsa bile devam etmeli.
  Future<void> requestNotificationPermission() async {
    try {
      final settings = await messaging.requestPermission();
      log(
        'Bildirim izni: ${settings.authorizationStatus.name}',
        name: 'FirebaseService',
      );
    } catch (e, stackTrace) {
      log(
        'Bildirim izni istenemedi',
        name: 'FirebaseService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Oturum açmış kullanıcı (yoksa null).
  User? get currentUser => auth.currentUser;

  /// Auth durumu değişimlerini dinlemek için (router guard bunu kullanacak).
  Stream<User?> get authStateChanges => auth.authStateChanges();
}

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});
