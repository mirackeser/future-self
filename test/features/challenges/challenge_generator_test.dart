import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/localization/model_labels.dart';
import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/challenges/domain/challenge_generator.dart';
import 'package:future_self/l10n/app_localizations.dart';

final _l10n = lookupAppLocalizations(const Locale('tr'));

void main() {
  group('pickChallengeForWeek', () {
    test('aynı hafta + kullanıcı hep aynı challenge', () {
      final first = pickChallengeForWeek('2026-W28', 'user-1');
      final second = pickChallengeForWeek('2026-W28', 'user-1');

      expect(first.type, second.type);
      expect(first.xpReward, second.xpReward);
    });

    test('seçim hash sözleşmesine uyar ve spec değerlerini taşır', () {
      const weekId = '2026-W28';
      const uid = 'user-1';
      final expectedType = ChallengeType.values[
          '$weekId$uid'.hashCode.abs() % ChallengeType.values.length];

      final challenge = pickChallengeForWeek(weekId, uid);

      expect(challenge.type, expectedType);
      expect(challenge.id, weekId);
      expect(challenge.isClaimed, isFalse);
      final spec = challengeSpecs[expectedType]!;
      expect(challenge.targetValue, spec.targetValue);
      expect(challenge.xpReward, spec.xpReward);
    });

    test('farklı hafta/kullanıcı farklı tip verebilir', () {
      final base = pickChallengeForWeek('2026-W28', 'user-1');
      ChallengeType? differing;
      for (var i = 0; i < 100; i++) {
        final other = pickChallengeForWeek('2026-W${28 + i}', 'user-1');
        if (other.type != base.type) {
          differing = other.type;
          break;
        }
      }
      expect(differing, isNotNull);
    });

    test('her tipin spec tanımı ve yerelleştirilmiş başlığı var', () {
      for (final type in ChallengeType.values) {
        expect(challengeSpecs[type], isNotNull, reason: type.name);
        final challenge = WeeklyChallenge(
          id: '2026-W28',
          type: type,
          targetValue: 1,
          xpReward: 10,
        );
        expect(challenge.displayTitleWith(_l10n), isNotEmpty,
            reason: type.name);
      }
    });

    test('displayTitle type\'tan o anki dile göre üretilir', () {
      const challenge = WeeklyChallenge(
        id: '2026-W28',
        type: ChallengeType.tenPercentOnAnyGoal,
        targetValue: 1,
        xpReward: 80,
      );
      expect(challenge.displayTitleWith(_l10n), _l10n.challengeTenPercent);
      final en = lookupAppLocalizations(const Locale('en'));
      expect(challenge.displayTitleWith(en), en.challengeTenPercent);
    });
  });

  group('entryProgressDelta', () {
    final goal = Goal(
      id: 'g1',
      userId: 'u1',
      category: Category.health,
      title: 'Kilo',
      metricTemplateId: 'health_weight',
      type: MetricType.numeric,
      initialValue: 85,
      currentValue: 85,
      targetValue: 75,
      createdAt: DateTime(2026, 1, 1),
    );

    test('%10 ve üzeri fark doğru hesaplanır (decreasing dahil)', () {
      // 85→84: aralık 10, fark 1 → %10
      final delta = entryProgressDelta(
        goal,
        GoalHistoryEntry(
          previousValue: 85,
          newValue: 84,
          timestamp: DateTime(2026, 7, 8),
        ),
      );
      expect(delta, closeTo(0.10, 0.0001));
    });

    test('değer eksikse null', () {
      expect(
        entryProgressDelta(
          goal,
          GoalHistoryEntry(newValue: 84, timestamp: DateTime(2026, 7, 8)),
        ),
        isNull,
      );
    });
  });
}
