/// Haftalık bölüm (Chapter) üretici — pure fonksiyonlar.
///
/// İki katman: [generateChapter] sadece HAM veriyi toplayıp Chapter
/// üretir (Firestore'a yazılan budur); [buildChapterNarrative] bu ham
/// veriden, ekran her açıldığında o anki dile göre başlık + anlatı
/// üretir ve hiçbir yere kaydedilmez. Varyant seçimi bölüm id'sinin
/// hash'iyle yapılır: aynı bölüm aynı dilde hep aynı metni verir.
library;

import '../../../core/models/models.dart';
import '../../../l10n/app_localizations.dart';

/// "Sıçrama" başlığı ve güçlü açılış için haftalık XP eşiği.
const int leapXpThreshold = 250;

/// Hafta başlangıcının pazartesi 00:00'ı.
DateTime mondayOf(DateTime date) {
  final day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

/// ISO-8601 hafta kimliği, örn "2026-W28".
///
/// Standart kural: hafta, perşembesinin ait olduğu yıla ve o yıl
/// içindeki sırasına göre numaralanır.
String isoWeekIdFor(DateTime date) {
  final thursday = mondayOf(date).add(const Duration(days: 3));
  final firstDayOfYear = DateTime(thursday.year);
  final week = (thursday.difference(firstDayOfYear).inDays ~/ 7) + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}

/// Zaman damgalarından en uzun ardışık aktif gün serisi.
int longestConsecutiveActivityDays(Iterable<DateTime> timestamps) {
  final days =
      timestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet().toList()
        ..sort();
  if (days.isEmpty) return 0;

  var best = 1;
  var run = 1;
  for (var i = 1; i < days.length; i++) {
    if (days[i].difference(days[i - 1]).inDays == 1) {
      run++;
      if (run > best) best = run;
    } else {
      run = 1;
    }
  }
  return best;
}

/// Hafta içinde en az bir tam gün boşluktan sonra aktiviteye dönülmüş mü?
bool detectComeback(Iterable<DateTime> timestamps) {
  final days =
      timestamps.map((t) => DateTime(t.year, t.month, t.day)).toSet().toList()
        ..sort();
  for (var i = 1; i < days.length; i++) {
    if (days[i].difference(days[i - 1]).inDays >= 2) return true;
  }
  return false;
}

/// Haftalık HAM veriden bölüm üretir — cümle/başlık üretmez.
///
/// [weekHistoryByGoal]: goalId → o haftaya ait history kayıtları.
Chapter generateChapter({
  required int weekNumber,
  required DateTime startDate,
  required DateTime endDate,
  required Map<String, List<GoalHistoryEntry>> weekHistoryByGoal,
  required List<Goal> goals,
  required int xpGainedThisWeek,
  required int longestStreakThisWeek,
  required int missionsCompletedThisWeek,
}) {
  final allTimestamps = [
    for (final entries in weekHistoryByGoal.values)
      for (final entry in entries) entry.timestamp,
  ];
  final hasActivity =
      allTimestamps.isNotEmpty ||
      xpGainedThisWeek > 0 ||
      missionsCompletedThisWeek > 0;

  // En çok ilerleyen hedef: haftalık ilk previousValue → son newValue
  // farkının hedef aralığına oranı (level'da seviye indeksleri).
  Goal? mostImproved;
  double? bestDelta;
  for (final goal in goals) {
    final entries = weekHistoryByGoal[goal.id];
    if (entries == null || entries.isEmpty) continue;
    if (goal.type == MetricType.freeText) continue;
    final initial = goal.initialValue;
    final target = goal.targetValue;
    if (initial == null || target == null || target == initial) continue;

    final sorted = [...entries]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final firstValue = _entryValue(
      goal,
      sorted.first.previousValue,
      sorted.first.previousLevel,
    );
    final lastValue = _entryValue(
      goal,
      sorted.last.newValue,
      sorted.last.newLevel,
    );
    if (firstValue == null || lastValue == null) continue;

    final delta = (lastValue - firstValue) / (target - initial);
    if (delta > 0 && (bestDelta == null || delta > bestDelta)) {
      bestDelta = delta;
      mostImproved = goal;
    }
  }

  return Chapter(
    id: isoWeekIdFor(startDate),
    weekNumber: weekNumber,
    startDate: startDate,
    endDate: endDate,
    xpGainedThisWeek: xpGainedThisWeek,
    longestStreakThisWeek: longestStreakThisWeek,
    missionsCompletedThisWeek: missionsCompletedThisWeek,
    hadGap: detectComeback(allTimestamps),
    hadNoActivity: !hasActivity,
    mostImprovedGoalId: mostImproved?.id,
    mostImprovedGoalTitle: mostImproved?.title,
    mostImprovedGoalProgressDelta: bestDelta,
  );
}

/// Ham bölümden, o anki dile göre başlık + anlatı üretir.
///
/// UI katmanında ekran her build olduğunda çağrılır; sonuç HİÇBİR
/// yere kaydedilmez. Pure kalması için context yerine [l10n] alır.
({String title, String narrative}) buildChapterNarrative(
  AppLocalizations l10n,
  Chapter chapter,
) {
  // ---- Başlık (öncelik sırasıyla).
  final String title;
  if (chapter.weekNumber == 1) {
    title = l10n.chapterTitleBeginning;
  } else if (chapter.hadGap) {
    title = l10n.chapterTitleComeback;
  } else if (chapter.xpGainedThisWeek >= leapXpThreshold) {
    title = l10n.chapterTitleLeap;
  } else if (chapter.missionsCompletedThisWeek > 0) {
    title = l10n.chapterTitleDream;
  } else if (chapter.hadNoActivity) {
    title = l10n.chapterTitleQuiet;
  } else if (chapter.longestStreakThisWeek >= 5) {
    title = l10n.chapterTitleSteady;
  } else {
    title = l10n.chapterTitleOnTheRoad;
  }

  // ---- Anlatı.
  if (chapter.hadNoActivity && chapter.weekNumber == 1) {
    return (title: title, narrative: l10n.chapterFirstWeek);
  }

  final parts = <String>[];
  if (chapter.hadNoActivity) {
    parts.add(
      _pickVariant([
        l10n.chapterQuietOpening1,
        l10n.chapterQuietOpening2,
      ], chapter.id),
    );
  } else if (chapter.xpGainedThisWeek >= leapXpThreshold) {
    parts.add(
      _pickVariant([
        l10n.chapterHighOpening1,
        l10n.chapterHighOpening2,
      ], chapter.id),
    );
  } else if (chapter.xpGainedThisWeek >= 100) {
    parts.add(
      _pickVariant([
        l10n.chapterMidOpening1,
        l10n.chapterMidOpening2,
      ], chapter.id),
    );
  } else {
    parts.add(
      _pickVariant([
        l10n.chapterLowOpening1,
        l10n.chapterLowOpening2,
      ], chapter.id),
    );
  }
  if (chapter.hadGap) {
    parts.add(
      _pickVariant([l10n.chapterComeback1, l10n.chapterComeback2], chapter.id),
    );
  }
  final improvedTitle = chapter.mostImprovedGoalTitle;
  final improvedDelta = chapter.mostImprovedGoalProgressDelta;
  if (improvedTitle != null && improvedDelta != null) {
    parts.add(
      l10n.chapterImproved(improvedTitle, (improvedDelta * 100).round()),
    );
  }
  if (chapter.missionsCompletedThisWeek > 0) {
    parts.add(l10n.chapterMissions(chapter.missionsCompletedThisWeek));
  }

  return (title: title, narrative: parts.join(' '));
}

String _pickVariant(List<String> options, String seed) =>
    options[seed.hashCode.abs() % options.length];

/// History kaydındaki değeri sayıya çevirir (level'da seçenek indeksi).
double? _entryValue(Goal goal, double? numericValue, String? levelValue) {
  if (goal.type == MetricType.numeric) return numericValue;
  if (levelValue == null) return null;
  final index = MetricTemplates.byId(
    goal.metricTemplateId,
  ).levelOptions.indexOf(levelValue);
  return index < 0 ? null : index.toDouble();
}
