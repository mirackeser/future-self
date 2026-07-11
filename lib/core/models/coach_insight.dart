/// Coach ekranındaki kart tipleri.
enum CoachInsightType {
  /// Streak kutlaması (accent tonlu kart).
  streakHighlight,

  /// İhmal edilen hedef uyarısı (dikkat tonlu kart, suçlamayan dil).
  neglectedGoal,

  /// Hedef bazlı kısa öneri.
  goalTip,

  /// Henüz hedef yokken gösterilen tek kart.
  empty,
}

/// Kural tabanlı coach motorunun ürettiği tek bir içgörü.
class CoachInsight {
  const CoachInsight({
    required this.type,
    required this.message,
    this.goalId,
  });

  final CoachInsightType type;
  final String message;

  /// İçgörünün referans verdiği hedef (varsa).
  final String? goalId;
}
