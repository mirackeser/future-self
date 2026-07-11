/// onboarding özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../goals/data/goals_repository.dart';

/// Onboarding'de seçilen hayat kategorileri.
class SelectedCategoriesNotifier extends Notifier<Set<Category>> {
  @override
  Set<Category> build() => const {};

  /// Kategoriyi seçili değilse ekler, seçiliyse çıkarır.
  void toggle(Category category) {
    final next = {...state};
    if (!next.add(category)) {
      next.remove(category);
    }
    state = next;
  }
}

final selectedCategoriesProvider =
    NotifierProvider<SelectedCategoriesNotifier, Set<Category>>(
  SelectedCategoriesNotifier.new,
);

/// Mevcut durum ekranında girilen metrik değerleri, templateId → entry.
///
/// Varsayılan şablonlar map'te kayıt olmadan da ekranda görünür; kayıt
/// ilk değer girildiğinde oluşur. Eklenebilir şablonlar ise
/// [addTemplate] ile boş bir entry olarak eklenince görünür olur.
class MetricEntriesNotifier extends Notifier<Map<String, UserMetricEntry>> {
  @override
  Map<String, UserMetricEntry> build() => const {};

  /// Eklenebilir bir şablonu ekrana dahil eder.
  void addTemplate(String templateId) {
    if (state.containsKey(templateId)) return;
    state = {...state, templateId: UserMetricEntry(templateId: templateId)};
  }

  void setCurrentValue(String templateId, String value) {
    final entry = state[templateId];
    state = {
      ...state,
      templateId: UserMetricEntry(
        templateId: templateId,
        currentValue: _normalize(value),
        targetValue: entry?.targetValue,
      ),
    };
  }

  void setTargetValue(String templateId, String value) {
    final entry = state[templateId];
    state = {
      ...state,
      templateId: UserMetricEntry(
        templateId: templateId,
        currentValue: entry?.currentValue,
        targetValue: _normalize(value),
      ),
    };
  }

  static String? _normalize(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

final metricEntriesProvider =
    NotifierProvider<MetricEntriesNotifier, Map<String, UserMetricEntry>>(
  MetricEntriesNotifier.new,
);

/// Yeni hesap sonrası onboarding adımları (welcome → kategoriler →
/// mevcut durum → bildirimler) sürerken true.
///
/// Router redirect'i bunu okur: bayrak kapalıyken oturum açık bir
/// kullanıcı hiçbir onboarding rotasına giremez. Kayıt denemesi
/// başlarken açılır ki auth event'i akışı dashboard'a süpürmesin;
/// iptal/hata/mevcut kullanıcıda ve akışın sonunda kapanır.
class OnboardingFlowNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void start() => state = true;

  void finish() => state = false;
}

final onboardingInProgressProvider =
    NotifierProvider<OnboardingFlowNotifier, bool>(OnboardingFlowNotifier.new);

/// Onboarding'de toplanan kategori + metrik state'ini hedeflere çevirip
/// Firestore'a yazar. Giriş başarısının hemen ardından çağrılır.
///
/// Kayıt hatası kullanıcıyı dashboard'dan alıkoymamalı: hata loglanır,
/// fırlatılmaz.
Future<void> saveOnboardingGoals(WidgetRef ref) async {
  try {
    final entries = ref.read(metricEntriesProvider).values.toList();
    final categories = ref.read(selectedCategoriesProvider);
    await ref
        .read(goalsRepositoryProvider)
        .createGoalsFromOnboarding(entries, categories);
  } catch (e, stackTrace) {
    log(
      'Onboarding hedefleri kaydedilemedi',
      name: 'onboarding',
      error: e,
      stackTrace: stackTrace,
    );
  }
}
