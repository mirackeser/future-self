import 'package:cloud_firestore/cloud_firestore.dart';

import 'category.dart';

/// Life Lessons akışındaki anonim bir paylaşım.
///
/// [authorUid] sadece iç kayıt (kural denetimi, ileride moderasyon)
/// içindir; UI'da hiçbir zaman gösterilmez.
class Lesson {
  const Lesson({
    required this.id,
    required this.authorUid,
    required this.text,
    required this.category,
    required this.createdAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.saveCount = 0,
    this.reportCount = 0,
  });

  final String id;
  final String authorUid;
  final String text;
  final Category category;
  final DateTime createdAt;
  final int likeCount;
  final int commentCount;
  final int saveCount;
  final int reportCount;

  Map<String, dynamic> toMap() {
    return {
      'authorUid': authorUid,
      'text': text,
      'category': category.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'saveCount': saveCount,
      'reportCount': reportCount,
    };
  }

  factory Lesson.fromMap(String id, Map<String, dynamic> map) {
    return Lesson(
      id: id,
      authorUid: map['authorUid'] as String,
      text: map['text'] as String,
      category: Category.values.byName(map['category'] as String),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likeCount: map['likeCount'] as int? ?? 0,
      commentCount: map['commentCount'] as int? ?? 0,
      saveCount: map['saveCount'] as int? ?? 0,
      reportCount: map['reportCount'] as int? ?? 0,
    );
  }
}
