/// lessons özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../data/lessons_repository.dart';

/// Herkese açık akış, en yeni önce.
final lessonsFeedProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(lessonsRepositoryProvider).watchFeed();
});

/// Kullanıcının kaydettikleri, en son kaydedilen önce.
final savedLessonsProvider = StreamProvider<List<Lesson>>((ref) {
  return ref.watch(lessonsRepositoryProvider).watchSavedLessons();
});

/// Tek bir lesson (yorum ekranı); silinmişse null.
final lessonProvider = StreamProvider.family<Lesson?, String>((ref, id) {
  return ref.watch(lessonsRepositoryProvider).watchLesson(id);
});

/// Bir lesson'ın yorumları, en yeni üstte.
final lessonCommentsProvider =
    StreamProvider.family<List<LessonComment>, String>((ref, id) {
  return ref.watch(lessonsRepositoryProvider).watchComments(id);
});

/// Mevcut kullanıcı beğenmiş mi.
final isLikedProvider = StreamProvider.family<bool, String>((ref, id) {
  return ref.watch(lessonsRepositoryProvider).watchIsLiked(id);
});

/// Mevcut kullanıcı kaydetmiş mi.
final isSavedProvider = StreamProvider.family<bool, String>((ref, id) {
  return ref.watch(lessonsRepositoryProvider).watchIsSaved(id);
});
