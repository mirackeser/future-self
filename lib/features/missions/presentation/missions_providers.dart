/// missions özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/missions_repository.dart';

/// Kullanıcının mission'ları, sıralı ve gerçek zamanlı.
final missionsStreamProvider = StreamProvider<List<Mission>>((ref) {
  return ref.watch(missionsRepositoryProvider).watchMissions();
});
