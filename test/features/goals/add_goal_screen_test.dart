import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/goals/presentation/goals_providers.dart';
import 'package:future_self/features/goals/presentation/screens/add_goal_screen.dart';
import 'package:future_self/l10n/app_localizations.dart';

void main() {
  final existingWeightGoal = Goal(
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

  Future<void> pumpScreen(WidgetTester tester, {required List<Goal> goals}) {
    return tester.pumpWidget(
      ProviderScope(
        overrides: [
          goalsStreamProvider.overrideWith((ref) => Stream.value(goals)),
        ],
        child: const MaterialApp(
          locale: Locale('tr'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddGoalScreen(),
        ),
      ),
    );
  }

  testWidgets(
      'zaten eklenmiş şablon pasif görünür ve tıklanınca ilerlemez',
      (tester) async {
    await pumpScreen(tester, goals: [existingWeightGoal]);
    await tester.pumpAndSettle();

    // Adım 1: Sağlık kategorisini seç.
    await tester.tap(find.text('Sağlık'));
    await tester.pumpAndSettle();

    // Kilo şablonu pasif + etiketli.
    expect(find.text('Zaten eklendi'), findsOneWidget);
    final kiloTile = tester.widget<ListTile>(
      find.ancestor(
        of: find.text('Kilo'),
        matching: find.byType(ListTile),
      ),
    );
    expect(kiloTile.enabled, isFalse);

    // Tıklamak 3. adıma geçirmez.
    await tester.tap(find.text('Kilo'));
    await tester.pumpAndSettle();
    expect(find.text('Şimdi'), findsNothing);
    expect(find.text('Hedefi ekle'), findsNothing);
  });

  testWidgets('boş şablon seçilebilir ve değer adımına geçer',
      (tester) async {
    await pumpScreen(tester, goals: [existingWeightGoal]);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sağlık'));
    await tester.pumpAndSettle();

    // Egzersiz sıklığı henüz eklenmemiş → aktif.
    await tester.tap(find.text('Egzersiz sıklığı'));
    await tester.pumpAndSettle();

    expect(find.text('Şimdi'), findsOneWidget);
    expect(find.text('Hedef'), findsOneWidget);

    // Değer girilmeden buton pasif, girilince aktif.
    FilledButton button() => tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Hedefi ekle'),
        );
    expect(button().onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextField, 'Hedef'), '4');
    await tester.pumpAndSettle();
    expect(button().onPressed, isNotNull);
  });

  testWidgets('hedefi olmayan kullanıcıda tüm şablonlar aktif',
      (tester) async {
    await pumpScreen(tester, goals: const []);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sağlık'));
    await tester.pumpAndSettle();

    expect(find.text('Zaten eklendi'), findsNothing);
  });
}
