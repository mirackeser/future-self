import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';
import 'package:future_self/features/onboarding/presentation/onboarding_providers.dart';
import 'package:future_self/features/onboarding/presentation/screens/categories_screen.dart';
import 'package:future_self/l10n/app_localizations.dart';

void main() {
  group('SelectedCategoriesNotifier', () {
    test('toggle ekler ve tekrar çağrılınca çıkarır', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(selectedCategoriesProvider.notifier);

      expect(container.read(selectedCategoriesProvider), isEmpty);

      notifier.toggle(Category.health);
      notifier.toggle(Category.career);
      expect(
        container.read(selectedCategoriesProvider),
        {Category.health, Category.career},
      );

      notifier.toggle(Category.health);
      expect(container.read(selectedCategoriesProvider), {Category.career});
    });
  });

  group('CategoriesScreen', () {
    Future<void> pumpScreen(WidgetTester tester) {
      return tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            locale: Locale('tr'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: CategoriesScreen(),
          ),
        ),
      );
    }

    FilledButton continueButton(WidgetTester tester) =>
        tester.widget<FilledButton>(find.byType(FilledButton));

    testWidgets('7 kategori listeleniyor, buton başta devre dışı',
        (tester) async {
      await pumpScreen(tester);

      for (final category in Category.values) {
        await tester.scrollUntilVisible(
          find.text(category.label),
          100,
          scrollable: find.byType(Scrollable),
        );
        expect(find.text(category.label), findsOneWidget);
      }
      expect(continueButton(tester).onPressed, isNull);
    });

    testWidgets('kategori seçilince buton aktifleşiyor, kaldırılınca kapanıyor',
        (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Sağlık'));
      await tester.pump();
      expect(continueButton(tester).onPressed, isNotNull);

      await tester.tap(find.text('Sağlık'));
      await tester.pump();
      expect(continueButton(tester).onPressed, isNull);
    });
  });
}
