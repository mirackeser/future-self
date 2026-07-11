/// Kullanıcının bir metrik şablonu için girdiği değerler.
///
/// Tüm alanlar opsiyoneldir. Level tipinde [currentValue]/[targetValue]
/// seçilen seviye string'lerini tutar; freeText tipinde sadece
/// [targetValue] kullanılır.
class UserMetricEntry {
  const UserMetricEntry({
    required this.templateId,
    this.currentValue,
    this.targetValue,
  });

  final String templateId;
  final String? currentValue;
  final String? targetValue;
}
