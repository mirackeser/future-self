import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/services.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../../l10n/app_localizations.dart';
import '../onboarding_providers.dart';

/// Onboarding 4/4 — Bildirim izni; akışın son adımı.
///
/// İzin kabul de edilse reddedilse de (veya "Şimdi değil" ile
/// atlansa da) onboarding hedefleri kaydedilip dashboard'a geçilir.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: scheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        size: 32,
                        color: scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      l10n.notificationsTitle,
                      style: textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.notificationsSubtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    _ReminderRow(
                      icon: Icons.wb_sunny,
                      label: l10n.morningMotivation,
                    ),
                    const SizedBox(height: 12),
                    _ReminderRow(
                      icon: Icons.local_fire_department,
                      label: l10n.streakReminders,
                    ),
                    const SizedBox(height: 12),
                    _ReminderRow(
                      icon: Icons.bedtime,
                      label: l10n.eveningSummary,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () => _requestPermissionAndContinue(context, ref),
                  child: Text(l10n.allowNotifications),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _completeOnboarding(context, ref),
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onSurfaceVariant,
                ),
                child: Text(l10n.notNow),
              ),
              const SizedBox(height: 16),
              const OnboardingProgressDots(currentStep: 3),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissionAndContinue(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Sonuç loglanır ama akışı etkilemez (bkz. FirebaseService).
    await ref.read(firebaseServiceProvider).requestNotificationPermission();
    if (context.mounted) {
      await _completeOnboarding(context, ref);
    }
  }

  /// Akışın sonu: hedefler yazılır, bayrak kapanır, dashboard açılır.
  Future<void> _completeOnboarding(BuildContext context, WidgetRef ref) async {
    await saveOnboardingGoals(ref);
    ref.read(onboardingInProgressProvider.notifier).finish();
    if (context.mounted) {
      context.go(AppRoutes.dashboard);
    }
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
