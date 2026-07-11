import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Mission ikonları — Firestore'da IconData yerine bu anahtarlar durur
/// (IconData serileştirmek icon tree-shaking'i bozar).
abstract final class MissionIcons {
  static const IconData fallback = Icons.flag;

  static const Map<String, IconData> all = {
    'flight': Icons.flight,
    'book': Icons.menu_book,
    'building': Icons.apartment,
    'heart': Icons.favorite,
    'mountain': Icons.terrain,
    'camera': Icons.photo_camera,
    'music': Icons.music_note,
    'star': Icons.star,
  };

  static IconData resolve(String? name) => all[name] ?? fallback;
}

/// Bir mission'a düşülen kısa not.
class MissionNote {
  const MissionNote({required this.text, required this.timestamp});

  final String text;
  final DateTime timestamp;

  Map<String, dynamic> toMap() => {
        'text': text,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  factory MissionNote.fromMap(Map<String, dynamic> map) => MissionNote(
        text: map['text'] as String,
        timestamp: (map['timestamp'] as Timestamp).toDate(),
      );
}

/// Life Missions (bucket list) girdisi.
///
/// [lastActivityAt] son not eklenme anını tutar; aktivite hesabı not
/// listesini taramak yerine bu alanı kullanır (hiç aktivite yoksa
/// [createdAt] esas alınır).
class Mission {
  const Mission({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    this.iconName,
    this.isCompleted = false,
    this.completedAt,
    this.notes = const [],
    this.lastActivityAt,
  });

  final String id;
  final String userId;
  final String title;
  final String? iconName;
  final DateTime createdAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final List<MissionNote> notes;
  final DateTime? lastActivityAt;

  IconData get icon => MissionIcons.resolve(iconName);

  int get daysSinceCreation => DateTime.now().difference(createdAt).inDays;

  int get daysSinceLastActivity =>
      DateTime.now().difference(lastActivityAt ?? createdAt).inDays;

  /// 14+ gündür dokunulmamış açık mission'lar nazikçe hatırlatılır.
  bool get needsGentleReminder => !isCompleted && daysSinceLastActivity >= 14;

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'iconName': iconName,
      'createdAt': Timestamp.fromDate(createdAt),
      'isCompleted': isCompleted,
      'completedAt':
          completedAt == null ? null : Timestamp.fromDate(completedAt!),
      'notes': [for (final note in notes) note.toMap()],
      'lastActivityAt':
          lastActivityAt == null ? null : Timestamp.fromDate(lastActivityAt!),
    };
  }

  factory Mission.fromMap(String id, Map<String, dynamic> map) {
    return Mission(
      id: id,
      userId: map['userId'] as String,
      title: map['title'] as String,
      iconName: map['iconName'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isCompleted: map['isCompleted'] as bool? ?? false,
      completedAt: (map['completedAt'] as Timestamp?)?.toDate(),
      notes: [
        for (final note in (map['notes'] as List<dynamic>? ?? const []))
          MissionNote.fromMap(note as Map<String, dynamic>),
      ],
      lastActivityAt: (map['lastActivityAt'] as Timestamp?)?.toDate(),
    );
  }
}
