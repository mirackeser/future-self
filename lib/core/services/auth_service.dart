import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'firebase_service.dart';

/// Kullanıcıya gösterilebilir Türkçe mesaj taşıyan auth hatası.
class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => 'AuthFailure: $message';
}

/// Google akışından Firebase'e verilecek idToken'ı üretir (iptalde null).
typedef GoogleIdTokenFlow = Future<String?> Function();

/// Apple akışı: SHA-256'lanmış nonce alır, Apple credential'ı döner.
typedef AppleCredentialFlow = Future<AuthorizationCredentialAppleID> Function(
  String hashedNonce,
);

/// Kimlik doğrulama akışları.
///
/// Google/Apple akışları ve nonce üreticisi testlerde sahteleriyle
/// değiştirilebilsin diye enjekte edilebilir; üretimde varsayılanlar
/// kullanılır. Sosyal girişler kullanıcı iptalinde sessizce `false`
/// döner, diğer tüm hatalar [AuthFailure] olarak fırlatılır.
class AuthService {
  AuthService({
    required this.auth,
    GoogleIdTokenFlow? googleIdTokenFlow,
    AppleCredentialFlow? appleCredentialFlow,
    String Function()? nonceGenerator,
  })  : _googleIdTokenFlow = googleIdTokenFlow ?? _defaultGoogleIdTokenFlow,
        _appleCredentialFlow =
            appleCredentialFlow ?? _defaultAppleCredentialFlow,
        _nonceGenerator = nonceGenerator ?? _randomNonce;

  final FirebaseAuth auth;
  final GoogleIdTokenFlow _googleIdTokenFlow;
  final AppleCredentialFlow _appleCredentialFlow;
  final String Function() _nonceGenerator;

  static bool _googleInitialized = false;

  /// Google ile giriş.
  ///
  /// Kullanıcı iptal ederse `null`, hesap bu girişle yeni oluştuysa
  /// `true`, mevcut hesapsa `false` döner.
  Future<bool?> signInWithGoogle() async {
    try {
      final idToken = await _googleIdTokenFlow();
      if (idToken == null) return null;

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCredential = await auth.signInWithCredential(credential);
      return userCredential.additionalUserInfo?.isNewUser ?? false;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Google ile giriş başarısız oldu, tekrar dene.');
    }
  }

  /// Apple ile giriş.
  ///
  /// Kullanıcı iptal ederse `null`, hesap bu girişle yeni oluştuysa
  /// `true`, mevcut hesapsa `false` döner.
  ///
  /// Güvenli nonce pattern'i: rastgele raw nonce üretilir, SHA-256'sı
  /// Apple'a gönderilir, Firebase'e identityToken + raw nonce verilir.
  Future<bool?> signInWithApple() async {
    try {
      final rawNonce = _nonceGenerator();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final appleCredential = await _appleCredentialFlow(hashedNonce);
      final credential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );
      final userCredential = await auth.signInWithCredential(credential);
      return userCredential.additionalUserInfo?.isNewUser ?? false;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      throw const AuthFailure('Apple ile giriş başarısız oldu, tekrar dene.');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } on AuthFailure {
      rethrow;
    } catch (_) {
      throw const AuthFailure('Apple ile giriş başarısız oldu, tekrar dene.');
    }
  }

  /// E-posta ile kayıt; hesap her zaman yeni olduğu için `true` döner.
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// E-posta ile giriş; hesap her zaman mevcut olduğu için `false` döner.
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return false;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Oturumu kapatır; router redirect'i kullanıcıyı onboarding'e döndürür.
  Future<void> signOut() => auth.signOut();

  /// Şifreyle yeniden kimlik doğrulama (hesap silme gibi hassas
  /// işlemlerdeki requires-recent-login için).
  Future<void> reauthenticateWithPassword(String password) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null) {
      throw const AuthFailure('Bir şeyler ters gitti, tekrar dene.');
    }
    try {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: email, password: password),
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    }
  }

  /// Google ile yeniden kimlik doğrulama; kullanıcı iptal ederse `false`.
  Future<bool> reauthenticateWithGoogle() async {
    final user = _requireUser();
    try {
      final idToken = await _googleIdTokenFlow();
      if (idToken == null) return false;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      );
      return true;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } catch (_) {
      throw const AuthFailure('Google ile giriş başarısız oldu, tekrar dene.');
    }
  }

  /// Apple ile yeniden kimlik doğrulama; kullanıcı iptal ederse `false`.
  Future<bool> reauthenticateWithApple() async {
    final user = _requireUser();
    try {
      final rawNonce = _nonceGenerator();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
      final appleCredential = await _appleCredentialFlow(hashedNonce);
      await user.reauthenticateWithCredential(
        OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          rawNonce: rawNonce,
        ),
      );
      return true;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return false;
      throw const AuthFailure('Apple ile giriş başarısız oldu, tekrar dene.');
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapAuthError(e));
    } catch (_) {
      throw const AuthFailure('Apple ile giriş başarısız oldu, tekrar dene.');
    }
  }

  User _requireUser() {
    final user = auth.currentUser;
    if (user == null) {
      throw StateError('Yeniden doğrulama için oturum açık olmalı.');
    }
    return user;
  }

  static String _mapAuthError(FirebaseAuthException e) {
    return switch (e.code) {
      'wrong-password' ||
      'user-not-found' ||
      'invalid-credential' ||
      'INVALID_LOGIN_CREDENTIALS' =>
        'E-posta veya şifre hatalı.',
      'email-already-in-use' => 'Bu e-posta zaten kayıtlı.',
      'invalid-email' => 'Geçersiz e-posta adresi.',
      'weak-password' => 'Şifre en az 6 karakter olmalı.',
      'user-disabled' => 'Bu hesap devre dışı bırakılmış.',
      'too-many-requests' =>
        'Çok fazla deneme yapıldı, biraz sonra tekrar dene.',
      'network-request-failed' => 'İnternet bağlantını kontrol et.',
      _ => 'Bir şeyler ters gitti, tekrar dene.',
    };
  }

  static Future<String?> _defaultGoogleIdTokenFlow() async {
    final signIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await signIn.initialize();
      _googleInitialized = true;
    }
    try {
      final account = await signIn.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  static Future<AuthorizationCredentialAppleID> _defaultAppleCredentialFlow(
    String hashedNonce,
  ) {
    return SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );
  }

  /// Kriptografik olarak güvenli rastgele nonce (Firebase Apple dokümanı).
  static String _randomNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(auth: ref.watch(firebaseServiceProvider).auth);
});
