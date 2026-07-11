import 'package:cloud_firestore/cloud_firestore.dart';

/// Günlük yansıma sorusuna verilen yanıt —
/// users/{uid}/reflections/{yyyy-MM-dd}.
class Reflection {
  const Reflection({
    required this.dateKey,
    required this.question,
    required this.answer,
    required this.answeredAt,
  });

  final String dateKey;
  final String question;
  final String answer;
  final DateTime answeredAt;

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }

  factory Reflection.fromMap(String dateKey, Map<String, dynamic> map) {
    return Reflection(
      dateKey: dateKey,
      question: map['question'] as String,
      answer: map['answer'] as String,
      answeredAt: (map['answeredAt'] as Timestamp).toDate(),
    );
  }
}
