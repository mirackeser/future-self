import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/chapters/domain/chapter_generator.dart';
import 'package:future_self/l10n/app_localizations.dart';

// 2026-07-06 pazartesi; hafta 6-12 Temmuz (ISO 2026-W28).
final _weekStart = DateTime(2026, 7, 6);
final _weekEnd = DateTime(2026, 7, 12);
final _l10n = lookupAppLocalizations(const Locale('tr'));

Goal buildGoal(
  String id, {
  String title = 'Kilo',
  MetricType type = MetricType.numeric,
  double? initialValue = 85,
  double? targetValue = 75,
}) {
  return Goal(
    id: id,
    userId: 'u1',
    category: Category.health,
    title: title,
    metricTemplateId: 'health_weight',
    type: type,
    initialValue: initialValue,
    currentValue: initialValue,
    targetValue: targetValue,
    createdAt: DateTime(2026, 1, 1),
  );
}

GoalHistoryEntry entry(DateTime timestamp, {double? prev, double? next}) {
  return GoalHistoryEntry(
    previousValue: prev,
    newValue: next,
    timestamp: timestamp,
  );
}

Chapter generate({
  int weekNumber = 5,
  Map<String, List<GoalHistoryEntry>> historyByGoal = const {},
  List<Goal> goals = const [],
  int xp = 0,
  int longestStreak = 0,
  int missions = 0,
}) {
  return generateChapter(
    weekNumber: weekNumber,
    startDate: _weekStart,
    endDate: _weekEnd,
    weekHistoryByGoal: historyByGoal,
    goals: goals,
    xpGainedThisWeek: xp,
    longestStreakThisWeek: longestStreak,
    missionsCompletedThisWeek: missions,
  );
}

/// Anlatı testleri için ham bölüm kurucu.
Chapter rawChapter({
  int weekNumber = 5,
  int xp = 0,
  int longestStreak = 0,
  int missions = 0,
  bool hadGap = false,
  bool hadNoActivity = false,
  String? improvedTitle,
  double? improvedDelta,
}) {
  return Chapter(
    id: '2026-W28',
    weekNumber: weekNumber,
    startDate: _weekStart,
    endDate: _weekEnd,
    xpGainedThisWeek: xp,
    longestStreakThisWeek: longestStreak,
    missionsCompletedThisWeek: missions,
    hadGap: hadGap,
    hadNoActivity: hadNoActivity,
    mostImprovedGoalTitle: improvedTitle,
    mostImprovedGoalProgressDelta: improvedDelta,
  );
}

void main() {
  group('hafta yardımcıları', () {
    test('isoWeekIdFor doğru kimlik üretir', () {
      expect(isoWeekIdFor(DateTime(2026, 1, 1)), '2026-W01');
      expect(isoWeekIdFor(_weekStart), '2026-W28');
      expect(isoWeekIdFor(DateTime(2026, 7, 12)), '2026-W28');
    });

    test('longestConsecutiveActivityDays ardışık günleri sayar', () {
      expect(longestConsecutiveActivityDays(const []), 0);
      expect(
        longestConsecutiveActivityDays([
          DateTime(2026, 7, 6, 9),
          DateTime(2026, 7, 7, 21),
          DateTime(2026, 7, 8, 12),
          DateTime(2026, 7, 10),
        ]),
        3,
      );
    });
  });

  group('generateChapter — ham veri (anlatı asla yazılmaz)', () {
    test('verisiz hafta: hadNoActivity true, geri dönüş yok', () {
      final chapter = generate(weekNumber: 1);

      expect(chapter.id, '2026-W28');
      expect(chapter.hadNoActivity, isTrue);
      expect(chapter.hadGap, isFalse);
      expect(chapter.mostImprovedGoalId, isNull);
      expect(chapter.mostImprovedGoalTitle, isNull);
    });

    test('boşluktan sonra devam eden haftada hadGap true', () {
      final goal = buildGoal('g1');
      final chapter = generate(
        historyByGoal: {
          'g1': [
            entry(DateTime(2026, 7, 6), prev: 85, next: 84),
            // 7-8 Temmuz boş, 9'unda dönüş.
            entry(DateTime(2026, 7, 9), prev: 84, next: 83),
          ],
        },
        goals: [goal],
        xp: 100,
      );

      expect(chapter.hadGap, isTrue);
      expect(chapter.hadNoActivity, isFalse);
    });

    test('en çok ilerleyen hedefin başlığı ve deltası ham veride', () {
      final weight = buildGoal('g1', title: 'Kilo');
      final savings = buildGoal(
        'g2',
        title: 'Birikim',
        initialValue: 0,
        targetValue: 1000,
      );
      final chapter = generate(
        historyByGoal: {
          // Kilo: 85 → 80, aralık 10 → +%50
          'g1': [
            entry(DateTime(2026, 7, 6), prev: 85, next: 82),
            entry(DateTime(2026, 7, 7), prev: 82, next: 80),
          ],
          // Birikim: 0 → 100, aralık 1000 → +%10
          'g2': [entry(DateTime(2026, 7, 7), prev: 0, next: 100)],
        },
        goals: [weight, savings],
        xp: 150,
      );

      expect(chapter.mostImprovedGoalId, 'g1');
      expect(chapter.mostImprovedGoalTitle, 'Kilo');
      expect(chapter.mostImprovedGoalProgressDelta, closeTo(0.5, 0.0001));
    });

    test('toMap anlatı/başlık içermez', () {
      final map = generate(weekNumber: 3, xp: 100).toMap();
      expect(map.containsKey('narrativeText'), isFalse);
      expect(map.containsKey('title'), isFalse);
      expect(map['hadGap'], isFalse);
    });
  });

  group('buildChapterNarrative — dile göre canlı üretim', () {
    test('verisiz ilk hafta: Başlangıç + yolculuk mesajı', () {
      final result = buildChapterNarrative(
        _l10n,
        rawChapter(weekNumber: 1, hadNoActivity: true),
      );

      expect(result.title, _l10n.chapterTitleBeginning);
      expect(result.narrative, _l10n.chapterFirstWeek);
    });

    test('verisiz normal hafta: Sakin Hafta + sakin açılış', () {
      final result =
          buildChapterNarrative(_l10n, rawChapter(hadNoActivity: true));

      expect(result.title, _l10n.chapterTitleQuiet);
      expect(
        [_l10n.chapterQuietOpening1, _l10n.chapterQuietOpening2]
            .any(result.narrative.contains),
        isTrue,
      );
    });

    test('geri dönüş: başlık + özel cümle', () {
      final result = buildChapterNarrative(
        _l10n,
        rawChapter(xp: 100, hadGap: true),
      );

      expect(result.title, _l10n.chapterTitleComeback);
      expect(
        [_l10n.chapterComeback1, _l10n.chapterComeback2]
            .any(result.narrative.contains),
        isTrue,
      );
    });

    test('yüksek XP: Sıçrama + güçlü açılış', () {
      final result = buildChapterNarrative(_l10n, rawChapter(xp: 350));

      expect(result.title, _l10n.chapterTitleLeap);
      expect(
        [_l10n.chapterHighOpening1, _l10n.chapterHighOpening2]
            .any(result.narrative.contains),
        isTrue,
      );
    });

    test('mission: Bir Hayal Daha + kutlama cümlesi', () {
      final result =
          buildChapterNarrative(_l10n, rawChapter(xp: 120, missions: 2));

      expect(result.title, _l10n.chapterTitleDream);
      expect(result.narrative, contains(_l10n.chapterMissions(2)));
    });

    test('en çok ilerleyen hedef övülür', () {
      final result = buildChapterNarrative(
        _l10n,
        rawChapter(xp: 150, improvedTitle: 'Kilo', improvedDelta: 0.5),
      );

      expect(result.narrative, contains(_l10n.chapterImproved('Kilo', 50)));
    });

    test('yüksek streak (kesintisiz, orta XP): İstikrar', () {
      final result =
          buildChapterNarrative(_l10n, rawChapter(xp: 150, longestStreak: 6));
      expect(result.title, _l10n.chapterTitleSteady);
    });

    test('aynı bölüm aynı dilde hep aynı anlatıyı verir (determinizm)', () {
      final chapter = rawChapter(xp: 50, hadGap: true);
      final first = buildChapterNarrative(_l10n, chapter);
      final second = buildChapterNarrative(_l10n, chapter);

      expect(first.narrative, second.narrative);
      expect(first.title, second.title);
    });
  });
}
