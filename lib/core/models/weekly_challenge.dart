/// Haftalık meydan okuma tipleri.
enum ChallengeType {
  threeDayUpdateStreak,
  twoGoalsProgress,
  addMissionNote,
  answerReflection,
  commentOnLesson,
  tenPercentOnAnyGoal,
}

/// Haftalık meydan okuma — users/{uid}/weeklyChallenges/{yyyy-Www}.
///
/// Firestore'a hazır başlık YAZILMAZ; başlık [type]'tan görüntüleme
/// anında o anki dile göre üretilir (bkz. model_labels.dart'taki
/// ChallengeL10n.displayTitle). Eski dokümanlardaki title alanı
/// okumada yok sayılır.
class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.type,
    required this.targetValue,
    required this.xpReward,
    this.isClaimed = false,
  });

  /// ISO hafta kimliği, örn "2026-W28".
  final String id;
  final ChallengeType type;
  final int targetValue;
  final int xpReward;
  final bool isClaimed;

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'targetValue': targetValue,
      'xpReward': xpReward,
      'isClaimed': isClaimed,
    };
  }

  factory WeeklyChallenge.fromMap(String id, Map<String, dynamic> map) {
    return WeeklyChallenge(
      id: id,
      type: ChallengeType.values.byName(map['type'] as String),
      targetValue: map['targetValue'] as int,
      xpReward: map['xpReward'] as int,
      isClaimed: map['isClaimed'] as bool? ?? false,
    );
  }
}
