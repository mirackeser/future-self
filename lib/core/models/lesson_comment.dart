import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir lesson'a yapılan anonim yorum.
///
/// [authorUid] sadece iç kayıt içindir; UI'da gösterilmez.
class LessonComment {
  const LessonComment({
    required this.id,
    required this.lessonId,
    required this.authorUid,
    required this.text,
    required this.createdAt,
    this.likeCount = 0,
    this.reportCount = 0,
  });

  final String id;
  final String lessonId;
  final String authorUid;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final int reportCount;

  Map<String, dynamic> toMap() {
    return {
      'lessonId': lessonId,
      'authorUid': authorUid,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'likeCount': likeCount,
      'reportCount': reportCount,
    };
  }

  factory LessonComment.fromMap(String id, Map<String, dynamic> map) {
    return LessonComment(
      id: id,
      lessonId: map['lessonId'] as String,
      authorUid: map['authorUid'] as String,
      text: map['text'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      likeCount: map['likeCount'] as int? ?? 0,
      reportCount: map['reportCount'] as int? ?? 0,
    );
  }
}
