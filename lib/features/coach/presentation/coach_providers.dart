/// coach özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/reflections_repository.dart';

/// Bugünün yansıma yanıtı; yanıtlanmamışsa null.
final todayReflectionProvider = StreamProvider<Reflection?>((ref) {
  return ref.watch(reflectionsRepositoryProvider).watchTodayReflection();
});
