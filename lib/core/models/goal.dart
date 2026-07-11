import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'category.dart';
import 'metric_template.dart';

/// Future Self Engine'in çekirdek varlığı: kullanıcının bir hedefi.
///
/// Sayısal ve level hedefler [initialValue]/[currentValue]/[targetValue]
/// üzerinden ilerleme yüzdesi üretir (level hedeflerde bu alanlar seviye
/// indeksleridir, görünen adlar [currentLevel]/[targetLevel]'da durur).
/// freeText hedeflerin yüzdesi yoktur; UI "devam ediyor" gösterir.
class Goal {
  const Goal({
    required this.id,
    required this.userId,
    required this.category,
    required this.title,
    required this.metricTemplateId,
    required this.type,
    required this.createdAt,
    this.direction,
    this.initialValue,
    this.currentValue,
    this.targetValue,
    this.currentLevel,
    this.targetLevel,
    this.targetText,
    this.xpReward = defaultXpReward,
    this.streakCount = 0,
    this.totalXpEarned = 0,
    this.lastProgressUpdateAt,
  });

  static const int defaultXpReward = 50;

  final String id;
  final String userId;
  final Category category;
  final String title;
  final String metricTemplateId;
  final MetricType type;
  final MetricDirection? direction;

  /// Hedef oluşturulduğu andaki değer — ilerleme buna göre hesaplanır.
  final double? initialValue;
  final double? currentValue;
  final double? targetValue;
  final String? currentLevel;
  final String? targetLevel;
  final String? targetText;
  final DateTime createdAt;
  final int xpReward;
  final int streakCount;

  /// Bu hedeften şimdiye kadar kazanılan toplam XP.
  final int totalXpEarned;
  final DateTime? lastProgressUpdateAt;

  IconData get icon => category.icon;

  /// 0..1 arası ilerleme; freeText ya da eksik değerlerde null.
  ///
  /// (current - initial) / (target - initial) — decreasing hedeflerde
  /// pay ve payda birlikte işaret değiştirdiği için formül iki yönde
  /// de doğru çalışır.
  double? get progressPercent {
    if (type == MetricType.freeText) return null;
    final initial = initialValue;
    final current = currentValue;
    final target = targetValue;
    if (initial == null || current == null || target == null) return null;

    final span = target - initial;
    if (span == 0) return 1.0;
    return ((current - initial) / span).clamp(0.0, 1.0);
  }

  /// Şu ana kadarki hıza göre kaba tamamlanma tahmini.
  ///
  /// İlerleme hızı = yüzde / geçen gün; kalan yüzde bu hızla projekte
  /// edilir. İlerleme yoksa (veya freeText ise) tahmin de yok.
  DateTime? estimatedCompletion({DateTime? now}) {
    final clock = now ?? DateTime.now();
    final progress = progressPercent;
    if (progress == null || progress <= 0) return null;
    if (progress >= 1) return clock;

    final elapsedDays = clock.difference(createdAt).inDays.clamp(1, 36500);
    final remainingDays = (elapsedDays * (1 - progress) / progress).ceil();
    return clock.add(Duration(days: remainingDays));
  }

  Goal copyWith({
    double? currentValue,
    String? currentLevel,
    int? streakCount,
    DateTime? lastProgressUpdateAt,
  }) {
    return Goal(
      id: id,
      userId: userId,
      category: category,
      title: title,
      metricTemplateId: metricTemplateId,
      type: type,
      direction: direction,
      initialValue: initialValue,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue,
      currentLevel: currentLevel ?? this.currentLevel,
      targetLevel: targetLevel,
      targetText: targetText,
      createdAt: createdAt,
      xpReward: xpReward,
      streakCount: streakCount ?? this.streakCount,
      totalXpEarned: totalXpEarned,
      lastProgressUpdateAt: lastProgressUpdateAt ?? this.lastProgressUpdateAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'category': category.name,
      'title': title,
      'metricTemplateId': metricTemplateId,
      'type': type.name,
      'direction': direction?.name,
      'initialValue': initialValue,
      'currentValue': currentValue,
      'targetValue': targetValue,
      'currentLevel': currentLevel,
      'targetLevel': targetLevel,
      'targetText': targetText,
      'createdAt': Timestamp.fromDate(createdAt),
      'xpReward': xpReward,
      'streakCount': streakCount,
      'totalXpEarned': totalXpEarned,
      'lastProgressUpdateAt': lastProgressUpdateAt == null
          ? null
          : Timestamp.fromDate(lastProgressUpdateAt!),
    };
  }

  factory Goal.fromMap(String id, Map<String, dynamic> map) {
    return Goal(
      id: id,
      userId: map['userId'] as String,
      category: Category.values.byName(map['category'] as String),
      title: map['title'] as String,
      metricTemplateId: map['metricTemplateId'] as String,
      type: MetricType.values.byName(map['type'] as String),
      direction: map['direction'] == null
          ? null
          : MetricDirection.values.byName(map['direction'] as String),
      initialValue: (map['initialValue'] as num?)?.toDouble(),
      currentValue: (map['currentValue'] as num?)?.toDouble(),
      targetValue: (map['targetValue'] as num?)?.toDouble(),
      currentLevel: map['currentLevel'] as String?,
      targetLevel: map['targetLevel'] as String?,
      targetText: map['targetText'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      xpReward: map['xpReward'] as int? ?? defaultXpReward,
      streakCount: map['streakCount'] as int? ?? 0,
      totalXpEarned: map['totalXpEarned'] as int? ?? 0,
      lastProgressUpdateAt:
          (map['lastProgressUpdateAt'] as Timestamp?)?.toDate(),
    );
  }
}
