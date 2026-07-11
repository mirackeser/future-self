/// auth özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/services.dart';

/// FirebaseAuth oturum durumu; router redirect'i bunu dinler.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseServiceProvider).authStateChanges;
});
