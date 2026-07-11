import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:future_self/features/onboarding/presentation/onboarding_providers.dart';

void main() {
  group('MetricEntriesNotifier', () {
    late ProviderContainer container;
    late MetricEntriesNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      addTearDown(container.dispose);
      notifier = container.read(metricEntriesProvider.notifier);
    });

    test('değerler templateId altında birikir', () {
      notifier.setCurrentValue('health_weight', '85');
      notifier.setTargetValue('health_weight', '75');

      final entry = container.read(metricEntriesProvider)['health_weight'];
      expect(entry?.currentValue, '85');
      expect(entry?.targetValue, '75');
    });

    test('boş/boşluk değer null olarak saklanıyor', () {
      notifier.setCurrentValue('health_weight', '85');
      notifier.setCurrentValue('health_weight', '  ');

      final entry = container.read(metricEntriesProvider)['health_weight'];
      expect(entry?.currentValue, isNull);
    });

    test('addTemplate boş entry oluşturur, mevcut entry üzerine yazmaz', () {
      notifier.setTargetValue('finance_gold', '50');
      notifier.addTemplate('finance_gold');

      final entry = container.read(metricEntriesProvider)['finance_gold'];
      expect(entry?.targetValue, '50');

      notifier.addTemplate('finance_crypto');
      expect(
        container.read(metricEntriesProvider).containsKey('finance_crypto'),
        isTrue,
      );
    });
  });
}
