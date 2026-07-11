/// chapters özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/chapters_repository.dart';

/// Bölümler, en yeni hafta önce.
final chaptersStreamProvider = StreamProvider<List<Chapter>>((ref) {
  return ref.watch(chaptersRepositoryProvider).watchChapters();
});

/// Uygulama oturumu başına bir kez tetiklenen arka plan bölüm üretimi
/// (dashboard ilk build'inde watch edilir; FutureProvider cache'lediği
/// için tekrar çalışmaz).
final weeklyChapterTriggerProvider = FutureProvider<void>((ref) {
  return ref.read(chaptersRepositoryProvider)
      .generateAndSaveWeeklyChapterIfNeeded();
});
