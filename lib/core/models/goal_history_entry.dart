import 'package:cloud_firestore/cloud_firestore.dart';

/// Bir hedefe kaydedilen tek bir ilerleme adımı.
///
/// Numeric hedeflerde [previousValue]/[newValue], level hedeflerde
/// [previousLevel]/[newLevel] dolu olur; freeText hedeflerde sadece
/// [note] yazılır.
class GoalHistoryEntry {
  const GoalHistoryEntry({
    this.id = '',
    this.previousValue,
    this.newValue,
    this.previousLevel,
    this.newLevel,
    this.note,
    required this.timestamp,
  });

  final String id;
  final double? previousValue;
  final double? newValue;
  final String? previousLevel;
  final String? newLevel;
  final String? note;
  final DateTime timestamp;

  Map<String, dynamic> toMap() {
    return {
      'previousValue': previousValue,
      'newValue': newValue,
      'previousLevel': previousLevel,
      'newLevel': newLevel,
      'note': note,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  factory GoalHistoryEntry.fromMap(String id, Map<String, dynamic> map) {
    return GoalHistoryEntry(
      id: id,
      previousValue: (map['previousValue'] as num?)?.toDouble(),
      newValue: (map['newValue'] as num?)?.toDouble(),
      previousLevel: map['previousLevel'] as String?,
      newLevel: map['newLevel'] as String?,
      note: map['note'] as String?,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
