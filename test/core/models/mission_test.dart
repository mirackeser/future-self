import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';

Mission buildMission({
  required DateTime createdAt,
  DateTime? lastActivityAt,
  bool isCompleted = false,
}) {
  return Mission(
    id: 'm1',
    userId: 'u1',
    title: 'Japonya gezisi',
    createdAt: createdAt,
    lastActivityAt: lastActivityAt,
    isCompleted: isCompleted,
  );
}

void main() {
  final now = DateTime.now();

  group('needsGentleReminder', () {
    test('14+ gündür aktivitesiz açık mission hatırlatılır', () {
      final mission = buildMission(
        createdAt: now.subtract(const Duration(days: 20)),
      );
      expect(mission.needsGentleReminder, isTrue);
    });

    test('tam 14. günde de hatırlatılır (sınır dahil)', () {
      final mission = buildMission(
        createdAt: now.subtract(const Duration(days: 14, hours: 1)),
      );
      expect(mission.needsGentleReminder, isTrue);
    });

    test('yakın zamanda not eklendiyse hatırlatılmaz', () {
      final mission = buildMission(
        createdAt: now.subtract(const Duration(days: 60)),
        lastActivityAt: now.subtract(const Duration(days: 3)),
      );
      expect(mission.needsGentleReminder, isFalse);
    });

    test('tamamlanmış mission asla hatırlatılmaz', () {
      final mission = buildMission(
        createdAt: now.subtract(const Duration(days: 60)),
        isCompleted: true,
      );
      expect(mission.needsGentleReminder, isFalse);
    });

    test('13 günde henüz hatırlatılmaz', () {
      final mission = buildMission(
        createdAt: now.subtract(const Duration(days: 13)),
      );
      expect(mission.needsGentleReminder, isFalse);
    });
  });

  test('daysSinceLastActivity not yokken createdAt\'i kullanır', () {
    final mission = buildMission(
      createdAt: now.subtract(const Duration(days: 10)),
    );
    expect(mission.daysSinceLastActivity, 10);

    final withActivity = buildMission(
      createdAt: now.subtract(const Duration(days: 10)),
      lastActivityAt: now.subtract(const Duration(days: 2)),
    );
    expect(withActivity.daysSinceLastActivity, 2);
  });
}
