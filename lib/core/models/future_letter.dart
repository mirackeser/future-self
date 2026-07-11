import 'package:cloud_firestore/cloud_firestore.dart';

/// Mektubun ne zaman teslim edileceği.
enum LetterDeliveryMode {
  /// Belirli bir tarihte (deliveryDate dolu).
  fixedDate,

  /// Bağlı hedef %100'e ulaşınca (relatedGoalId dolu).
  goalCompletion,
}

/// Kullanıcının gelecekteki kendisine yazdığı mektup —
/// users/{uid}/letters/{letterId}.
///
/// goalCompletion mektuplarında [deliveryDate] başta null'dır; hedef
/// tamamlanıp bildirim gönderildiğinde teslim anı olarak doldurulur
/// (aynı zamanda "tekrar bildirme" koruması budur).
class FutureLetter {
  const FutureLetter({
    required this.id,
    required this.text,
    required this.createdAt,
    required this.deliveryMode,
    this.deliveryDate,
    this.relatedGoalId,
    this.isOpened = false,
    this.notificationId = 0,
  });

  final String id;
  final String text;
  final DateTime createdAt;
  final LetterDeliveryMode deliveryMode;
  final DateTime? deliveryDate;
  final String? relatedGoalId;
  final bool isOpened;

  /// Zamanlanmış yerel bildirimi iptal edebilmek için.
  final int notificationId;

  /// Mektup teslim edildi mi (artık açılabilir)?
  bool isDelivered(DateTime now) {
    final date = deliveryDate;
    if (date == null) return false;
    return !date.isAfter(now);
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'deliveryMode': deliveryMode.name,
      'deliveryDate':
          deliveryDate == null ? null : Timestamp.fromDate(deliveryDate!),
      'relatedGoalId': relatedGoalId,
      'isOpened': isOpened,
      'notificationId': notificationId,
    };
  }

  factory FutureLetter.fromMap(String id, Map<String, dynamic> map) {
    return FutureLetter(
      id: id,
      text: map['text'] as String,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      deliveryMode:
          LetterDeliveryMode.values.byName(map['deliveryMode'] as String),
      deliveryDate: (map['deliveryDate'] as Timestamp?)?.toDate(),
      relatedGoalId: map['relatedGoalId'] as String?,
      isOpened: map['isOpened'] as bool? ?? false,
      notificationId: map['notificationId'] as int? ?? 0,
    );
  }
}
