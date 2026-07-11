import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:future_self/core/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

MockUserCredential credentialWith({required bool isNewUser}) {
  final credential = MockUserCredential();
  when(() => credential.additionalUserInfo)
      .thenReturn(AdditionalUserInfo(isNewUser: isNewUser));
  return credential;
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  late MockFirebaseAuth auth;

  setUp(() {
    auth = MockFirebaseAuth();
    when(() => auth.signInWithCredential(any()))
        .thenAnswer((_) async => credentialWith(isNewUser: true));
  });

  group('signInWithGoogle', () {
    test("Google idToken'ı doğru credential olarak FirebaseAuth'a iletiliyor",
        () async {
      final service = AuthService(
        auth: auth,
        googleIdTokenFlow: () async => 'test-google-id-token',
      );

      final isNewUser = await service.signInWithGoogle();

      expect(isNewUser, isTrue);
      final credential =
          verify(() => auth.signInWithCredential(captureAny())).captured.single
              as OAuthCredential;
      expect(credential.providerId, 'google.com');
      expect(credential.idToken, 'test-google-id-token');
    });

    test('mevcut kullanıcıda isNewUser false döner', () async {
      when(() => auth.signInWithCredential(any()))
          .thenAnswer((_) async => credentialWith(isNewUser: false));
      final service = AuthService(
        auth: auth,
        googleIdTokenFlow: () async => 'token',
      );

      expect(await service.signInWithGoogle(), isFalse);
    });

    test('kullanıcı iptal edince null döner, FirebaseAuth hiç çağrılmıyor',
        () async {
      final service = AuthService(
        auth: auth,
        googleIdTokenFlow: () async => null,
      );

      final isNewUser = await service.signInWithGoogle();

      expect(isNewUser, isNull);
      verifyNever(() => auth.signInWithCredential(any()));
    });

    test('FirebaseAuthException AuthFailure olarak yüzeye çıkıyor', () async {
      when(() => auth.signInWithCredential(any()))
          .thenThrow(FirebaseAuthException(code: 'network-request-failed'));
      final service = AuthService(
        auth: auth,
        googleIdTokenFlow: () async => 'token',
      );

      expect(
        service.signInWithGoogle,
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.message,
            'message',
            'İnternet bağlantını kontrol et.',
          ),
        ),
      );
    });
  });

  group('signInWithApple', () {
    test('nonce SHA-256 ile hash\'lenip Apple\'a gidiyor, raw nonce '
        "credential'a konuyor", () async {
      String? receivedHashedNonce;
      final service = AuthService(
        auth: auth,
        nonceGenerator: () => 'fixed-raw-nonce',
        appleCredentialFlow: (hashedNonce) async {
          receivedHashedNonce = hashedNonce;
          return const AuthorizationCredentialAppleID(
            userIdentifier: 'user-1',
            givenName: null,
            familyName: null,
            authorizationCode: 'auth-code',
            email: null,
            identityToken: 'apple-identity-token',
            state: null,
          );
        },
      );

      final isNewUser = await service.signInWithApple();

      expect(isNewUser, isTrue);
      expect(
        receivedHashedNonce,
        sha256.convert(utf8.encode('fixed-raw-nonce')).toString(),
      );
      final credential =
          verify(() => auth.signInWithCredential(captureAny())).captured.single
              as OAuthCredential;
      expect(credential.providerId, 'apple.com');
      expect(credential.idToken, 'apple-identity-token');
      expect(credential.rawNonce, 'fixed-raw-nonce');
    });

    test('kullanıcı iptal edince null dönüyor, FirebaseAuth çağrılmıyor',
        () async {
      final service = AuthService(
        auth: auth,
        appleCredentialFlow: (_) async {
          throw const SignInWithAppleAuthorizationException(
            code: AuthorizationErrorCode.canceled,
            message: 'canceled',
          );
        },
      );

      final isNewUser = await service.signInWithApple();

      expect(isNewUser, isNull);
      verifyNever(() => auth.signInWithCredential(any()));
    });
  });

  group('e-posta hata eşlemeleri', () {
    test('email-already-in-use kullanıcı dostu mesaja çevriliyor', () {
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'email-already-in-use'));
      final service = AuthService(auth: auth);

      expect(
        () => service.signUpWithEmail('a@b.com', '123456'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.message,
            'message',
            'Bu e-posta zaten kayıtlı.',
          ),
        ),
      );
    });

    test('wrong-password "E-posta veya şifre hatalı." oluyor', () {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'wrong-password'));
      final service = AuthService(auth: auth);

      expect(
        () => service.signInWithEmail('a@b.com', 'yanlış'),
        throwsA(
          isA<AuthFailure>().having(
            (f) => f.message,
            'message',
            'E-posta veya şifre hatalı.',
          ),
        ),
      );
    });
  });
}
