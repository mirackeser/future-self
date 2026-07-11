import 'category.dart';

/// Metrik değerinin nasıl girildiği.
enum MetricType { numeric, level, freeText }

/// Sayısal metriklerde "iyi" yön.
enum MetricDirection {
  /// Hedef > şimdi iyidir (birikim, maaş, egzersiz sıklığı).
  increasing,

  /// Hedef < şimdi iyidir (kilo verme, kart borcu).
  decreasing,
}

/// Bir kategori için önceden tanımlı metrik şablonu.
///
/// [direction] sadece [MetricType.numeric], [levelOptions] sadece
/// [MetricType.level] için anlamlıdır. [isDefault] olanlar mevcut durum
/// ekranında hazır gelir; diğerleri "+ Metrik ekle" ile eklenir.
class MetricTemplate {
  const MetricTemplate({
    required this.id,
    required this.category,
    required this.label,
    required this.type,
    this.unit,
    this.direction,
    this.levelOptions = const [],
    this.isDefault = false,
  });

  final String id;
  final Category category;
  final String label;
  final MetricType type;
  final String? unit;
  final MetricDirection? direction;
  final List<String> levelOptions;
  final bool isDefault;
}

/// Önceden tanımlı şablon kataloğu.
abstract final class MetricTemplates {
  static const List<String> _careerLevels = [
    'Öğrenci',
    'Junior',
    'Mid',
    'Senior',
    'Yönetici',
    'Girişimci',
  ];

  static const List<String> _languageLevels = [
    'A1',
    'A2',
    'B1',
    'B2',
    'C1',
    'C2',
  ];

  static const List<MetricTemplate> all = [
    // Sağlık
    MetricTemplate(
      id: 'health_weight',
      category: Category.health,
      label: 'Kilo',
      type: MetricType.numeric,
      unit: 'kg',
      direction: MetricDirection.decreasing,
      isDefault: true,
    ),
    MetricTemplate(
      id: 'health_exercise',
      category: Category.health,
      label: 'Egzersiz sıklığı',
      type: MetricType.numeric,
      unit: 'gün/hafta',
      direction: MetricDirection.increasing,
    ),
    MetricTemplate(
      id: 'health_free',
      category: Category.health,
      label: 'Serbest hedef',
      type: MetricType.freeText,
    ),
    // Kariyer
    MetricTemplate(
      id: 'career_level',
      category: Category.career,
      label: 'Seviye',
      type: MetricType.level,
      levelOptions: _careerLevels,
      isDefault: true,
    ),
    MetricTemplate(
      id: 'career_position',
      category: Category.career,
      label: 'Hedef pozisyon',
      type: MetricType.freeText,
      isDefault: true,
    ),
    MetricTemplate(
      id: 'career_salary',
      category: Category.career,
      label: 'Maaş',
      type: MetricType.numeric,
      unit: 'TL',
      direction: MetricDirection.increasing,
    ),
    // Finans
    MetricTemplate(
      id: 'finance_savings',
      category: Category.finance,
      label: 'Birikim',
      type: MetricType.numeric,
      unit: 'TL',
      direction: MetricDirection.increasing,
      isDefault: true,
    ),
    MetricTemplate(
      id: 'finance_gold',
      category: Category.finance,
      label: 'Altın',
      type: MetricType.numeric,
      unit: 'gram',
      direction: MetricDirection.increasing,
    ),
    MetricTemplate(
      id: 'finance_crypto',
      category: Category.finance,
      label: 'Kripto',
      type: MetricType.numeric,
      unit: 'TL',
      direction: MetricDirection.increasing,
    ),
    MetricTemplate(
      id: 'finance_debt',
      category: Category.finance,
      label: 'Kart borcu',
      type: MetricType.numeric,
      unit: 'TL',
      direction: MetricDirection.decreasing,
    ),
    // Öğrenme
    MetricTemplate(
      id: 'learning_language',
      category: Category.learning,
      label: 'Dil seviyesi',
      type: MetricType.level,
      levelOptions: _languageLevels,
      isDefault: true,
    ),
    MetricTemplate(
      id: 'learning_topic',
      category: Category.learning,
      label: 'Konu / kurs',
      type: MetricType.freeText,
    ),
    // İlişkiler
    MetricTemplate(
      id: 'relationships_free',
      category: Category.relationships,
      label: 'Serbest hedef',
      type: MetricType.freeText,
      isDefault: true,
    ),
    // Maneviyat
    MetricTemplate(
      id: 'spirituality_free',
      category: Category.spirituality,
      label: 'Serbest hedef',
      type: MetricType.freeText,
      isDefault: true,
    ),
    // Kişisel Gelişim
    MetricTemplate(
      id: 'growth_free',
      category: Category.personalGrowth,
      label: 'Serbest hedef',
      type: MetricType.freeText,
      isDefault: true,
    ),
  ];

  /// Kategorinin mevcut durum ekranında hazır gelen şablonları.
  static List<MetricTemplate> defaultsFor(Category category) =>
      all.where((t) => t.category == category && t.isDefault).toList();

  /// Kategoriye "+ Metrik ekle" ile eklenebilecek şablonlar.
  static List<MetricTemplate> addableFor(Category category) =>
      all.where((t) => t.category == category && !t.isDefault).toList();

  static MetricTemplate byId(String id) =>
      all.firstWhere((t) => t.id == id);

  /// Katalogda karşılığı olmayan id'ler için null (byId fırlatır).
  static MetricTemplate? byIdOrNull(String id) {
    for (final template in all) {
      if (template.id == id) return template;
    }
    return null;
  }
}
