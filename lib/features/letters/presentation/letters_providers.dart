/// letters özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/letters_repository.dart';

/// Kullanıcının mektupları, en yeni önce.
final lettersStreamProvider = StreamProvider<List<FutureLetter>>((ref) {
  return ref.watch(lettersRepositoryProvider).watchLetters();
});
