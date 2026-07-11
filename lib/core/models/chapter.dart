import 'package:cloud_firestore/cloud_firestore.dart';

/// Kullanıcının bir haftasının HAM verisi —
/// users/{uid}/chapters/{yyyy-Www}.
///
/// Firestore'a asla hazır cümle/başlık yazılmaz; anlatı ve başlık,
/// ekran her açıldığında bu ham veriden o anki dile göre üretilir
/// (bkz. buildChapterNarrative). Böylece dil değişince eski bölümler
/// de yeni dilde okunur.
class Chapter {
  const Chapter({
    required this.id,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    required this.xpGainedThisWeek,
    required this.longestStreakThisWeek,
    required this.missionsCompletedThisWeek,
    required this.hadGap,
    required this.hadNoActivity,
    this.mostImprovedGoalId,
    this.mostImprovedGoalTitle,
    this.mostImprovedGoalProgressDelta,
  });

  /// ISO hafta kimliği, örn "2026-W28".
  final String id;

  /// Hesabın açıldığı haftadan itibaren kaçıncı bölüm (1, 2, 3...).
  final int weekNumber;

  final DateTime startDate;
  final DateTime endDate;
  final int xpGainedThisWeek;
  final int longestStreakThisWeek;
  final int missionsCompletedThisWeek;

  /// Hafta içinde en az bir tam gün boşluktan sonra aktiviteye dönüldü
  /// (geri dönüş anlatısı için).
  final bool hadGap;

  /// Hafta tamamen aktivitesiz geçti.
  final bool hadNoActivity;

  final String? mostImprovedGoalId;

  /// Hedef sonradan silinse bile anlatı kurulabilsin diye başlık da
  /// ham veride saklanır.
  final String? mostImprovedGoalTitle;

  /// O hafta içindeki ilerleme artışı (hedef aralığının oranı, 0..1).
  final double? mostImprovedGoalProgressDelta;

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'xpGainedThisWeek': xpGainedThisWeek,
      'longestStreakThisWeek': longestStreakThisWeek,
      'missionsCompletedThisWeek': missionsCompletedThisWeek,
      'hadGap': hadGap,
      'hadNoActivity': hadNoActivity,
      'mostImprovedGoalId': mostImprovedGoalId,
      'mostImprovedGoalTitle': mostImprovedGoalTitle,
      'mostImprovedGoalProgressDelta': mostImprovedGoalProgressDelta,
    };
  }

  factory Chapter.fromMap(String id, Map<String, dynamic> map) {
    final xp = map['xpGainedThisWeek'] as int? ?? 0;
    final missions = map['missionsCompletedThisWeek'] as int? ?? 0;
    return Chapter(
      id: id,
      weekNumber: map['weekNumber'] as int,
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      xpGainedThisWeek: xp,
      longestStreakThisWeek: map['longestStreakThisWeek'] as int? ?? 0,
      missionsCompletedThisWeek: missions,
      // Eski (anlatı yazılmış) dokümanlarda bu alanlar yok; makul
      // varsayılanlarla okunur, anlatı yeni sistemle yeniden üretilir.
      hadGap: map['hadGap'] as bool? ?? false,
      hadNoActivity:
          map['hadNoActivity'] as bool? ?? (xp == 0 && missions == 0),
      mostImprovedGoalId: map['mostImprovedGoalId'] as String?,
      mostImprovedGoalTitle: map['mostImprovedGoalTitle'] as String?,
      mostImprovedGoalProgressDelta:
          (map['mostImprovedGoalProgressDelta'] as num?)?.toDouble(),
    );
  }
}
