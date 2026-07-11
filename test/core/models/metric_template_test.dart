import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/core/models/models.dart';

void main() {
  group('MetricTemplates kataloğu', () {
    test("id'ler benzersiz", () {
      final ids = MetricTemplates.all.map((t) => t.id);
      expect(ids.toSet().length, MetricTemplates.all.length);
    });

    test('her kategorinin en az bir varsayılan şablonu var', () {
      for (final category in Category.values) {
        expect(
          MetricTemplates.defaultsFor(category),
          isNotEmpty,
          reason: '${category.label} için varsayılan şablon yok',
        );
      }
    });

    test('numeric şablonların tümünde direction tanımlı', () {
      final numerics =
          MetricTemplates.all.where((t) => t.type == MetricType.numeric);
      expect(numerics, isNotEmpty);
      for (final template in numerics) {
        expect(
          template.direction,
          isNotNull,
          reason: '${template.id} numeric ama direction yok',
        );
      }
    });

    test('numeric olmayan şablonlarda direction yok', () {
      final others =
          MetricTemplates.all.where((t) => t.type != MetricType.numeric);
      for (final template in others) {
        expect(
          template.direction,
          isNull,
          reason: '${template.id} numeric değil ama direction tanımlı',
        );
      }
    });

    test('azalması iyi olan metrikler decreasing', () {
      expect(
        MetricTemplates.byId('health_weight').direction,
        MetricDirection.decreasing,
      );
      expect(
        MetricTemplates.byId('finance_debt').direction,
        MetricDirection.decreasing,
      );
    });

    test('artması iyi olan metrikler increasing', () {
      for (final id in [
        'health_exercise',
        'career_salary',
        'finance_savings',
        'finance_gold',
        'finance_crypto',
      ]) {
        expect(
          MetricTemplates.byId(id).direction,
          MetricDirection.increasing,
          reason: '$id increasing olmalı',
        );
      }
    });

    test('level şablonlarında seçenekler tanımlı, diğerlerinde boş', () {
      for (final template in MetricTemplates.all) {
        if (template.type == MetricType.level) {
          expect(
            template.levelOptions.length,
            greaterThanOrEqualTo(2),
            reason: '${template.id} level ama seçenekleri eksik',
          );
        } else {
          expect(
            template.levelOptions,
            isEmpty,
            reason: '${template.id} level değil ama levelOptions dolu',
          );
        }
      }
    });

    test('defaultsFor ve addableFor kategoriyi tam bölümlüyor', () {
      for (final category in Category.values) {
        final defaults = MetricTemplates.defaultsFor(category);
        final addables = MetricTemplates.addableFor(category);
        final combined = {...defaults, ...addables};

        expect(
          combined.length,
          MetricTemplates.all
              .where((t) => t.category == category)
              .length,
        );
        expect(defaults.toSet().intersection(addables.toSet()), isEmpty);
      }
    });
  });
}
