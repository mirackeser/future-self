import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/model_labels.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/services.dart';
import '../../../core/widgets/celebration_overlay.dart';
import '../../../l10n/app_localizations.dart';
import '../../challenges/presentation/challenges_providers.dart';
import '../../chapters/presentation/chapters_providers.dart';
import '../../goals/presentation/goals_providers.dart';
import '../../goals/presentation/widgets/quick_update_sheet.dart';

/// Ana ekran: kullanıcı durumu, bugünkü ilerleme, Future Self Status
/// ve dikkat bekleyen ilk 3 hedef.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    // Geçen haftanın bölümünü arka planda üretir (oturum başına bir kez;
    // sonuç beklenmez, hata uygulamayı etkilemez).
    ref.watch(weeklyChapterTriggerProvider);

    // Level atlama kutlaması: önceki emisyonun level'ı ile karşılaştır.
    // İlk yüklemede previous verisiz (loading) olduğu için tetiklenmez;
    // sadece gerçek bir artış anında çalışır.
    ref.listen(userProgressStreamProvider, (previous, next) {
      final before = previous?.value;
      final after = next.value;
      if (before != null && after != null && after.level > before.level) {
        CelebrationOverlay.celebrate(
          context,
          AppLocalizations.of(context)!.levelUpCelebration(after.level),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: goalsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                AppLocalizations.of(context)!.goalsLoadError('$e'),
              ),
            ),
          ),
          data: (goals) => _DashboardBody(goals: goals),
        ),
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.goals});

  final List<Goal> goals;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressStreamProvider).value ??
        const UserProgress();
    final now = DateTime.now();
    final completedCount = completedGoalsCount(goals);

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        _Header(progress: progress),
        const SizedBox(height: 24),
        if (goals.isEmpty)
          const _EmptyState()
        else ...[
          _TodayProgressCard(goals: goals, progress: progress, now: now),
          const SizedBox(height: 12),
          const _WeeklyChallengeCard(),
          _StatusCard(
            text: futureSelfStatus(
              AppLocalizations.of(context)!,
              goals,
              progress,
              now,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                AppLocalizations.of(context)!.activeGoals,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => context.push(AppRoutes.goalsAdd),
                icon: const Icon(Icons.add),
                tooltip: AppLocalizations.of(context)!.addGoal,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final goal in topActiveGoals(goals)) ...[
            _GoalCard(goal: goal),
            const SizedBox(height: 12),
          ],
          if (completedCount > 0)
            _CompletedGoalsEntry(count: completedCount),
        ],
      ],
    );
  }
}

/// Tamamlanan (%100) hedef sayısı — dashboard'daki giriş kartı için.
int completedGoalsCount(List<Goal> goals) =>
    goals.where((g) => (g.progressPercent ?? 0) >= 1.0).length;

/// Dashboard'da gösterilecek hedefler: tamamlananlar hariç, en uzun
/// süredir güncellenmeyen 3 hedef (hiç güncellenmemişler önce) — ihmal
/// edilen hedef dikkat çeksin.
///
/// Pure kalması için top-level (testlerde doğrudan çağrılabilir);
/// freeText hedeflerin yüzdesi olmadığından her zaman aktif sayılır.
List<Goal> topActiveGoals(List<Goal> goals) {
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  final active = goals
      .where((g) => (g.progressPercent ?? 0) < 1.0)
      .toList()
    ..sort(
      (a, b) => (a.lastProgressUpdateAt ?? epoch)
          .compareTo(b.lastProgressUpdateAt ?? epoch),
    );
  return active.take(3).toList();
}

/// Basit kural tabanlı durum metni; gerçek AI üretimi Coach'a gelecek.
///
/// Pure kalması için context yerine [l10n] alır (testlerde
/// lookupAppLocalizations ile sağlanabilir).
String futureSelfStatus(
  AppLocalizations l10n,
  List<Goal> goals,
  UserProgress progress,
  DateTime now,
) {
  if (goals.isEmpty) {
    return l10n.statusNoGoals;
  }
  final touchedLast7Days = goals
      .where(
        (g) =>
            g.lastProgressUpdateAt != null &&
            now.difference(g.lastProgressUpdateAt!).inDays < 7,
      )
      .length;
  if (touchedLast7Days == 0) {
    return l10n.statusQuietWeek;
  }
  if (progress.currentStreak >= 3) {
    return l10n.statusStreak(progress.currentStreak);
  }
  return l10n.statusProgress(touchedLast7Days);
}

class _Header extends ConsumerWidget {
  const _Header({required this.progress});

  final UserProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(firebaseServiceProvider).currentUser;
    final name = user?.displayName?.trim().isNotEmpty == true
        ? user!.displayName!.trim()
        : user?.email?.split('@').first ?? l10n.defaultUserName;

    return Row(
      children: [
        InkWell(
          onTap: () => _showProfileSheet(context, user?.email),
          customBorder: const CircleBorder(),
          child: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            foregroundColor: scheme.primary,
            child: Text(name.characters.first.toUpperCase()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: textTheme.titleMedium),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    l10n.levelXp(progress.level, progress.totalXp),
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress.xpIntoCurrentLevel /
                          progress.xpForNextLevel,
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProfileSheet(BuildContext context, String? email) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => _ProfileSheet(email: email),
    );
  }
}

/// Profil/ayarlar sheet'i: hesap bilgisi ve çıkış.
class _ProfileSheet extends ConsumerWidget {
  const _ProfileSheet({required this.email});

  final String? email;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.person_outline, size: 20, color: scheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    email ?? l10n.noEmailInfo,
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              l10n.languageLabel,
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'tr', label: Text(l10n.languageTurkish)),
                ButtonSegment(value: 'en', label: Text(l10n.languageEnglish)),
              ],
              selected: {ref.watch(localeProvider).languageCode},
              onSelectionChanged: (selection) => ref
                  .read(localeProvider.notifier)
                  .setLocale(Locale(selection.first)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => _signOut(context, ref),
                child: Text(l10n.signOut),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => _deleteAccount(context, ref),
              style: TextButton.styleFrom(foregroundColor: scheme.error),
              child: Text(l10n.deleteAccountAction),
            ),
          ],
        ),
      ),
    );
  }

  /// Onay dialog'unu açar; silme başarılıysa sheet'i kapatıp hesap
  /// ekranına döner (deleted=1 parametresi orada SnackBar gösterir).
  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    // Dialog auth kullanıcısını sildiğinde context unmounted olabilir;
    // router ve sheet navigator'ı önceden yakalanır.
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);

    final deleted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (deleted != true) return;

    navigator.pop();
    router.go('${AppRoutes.onboardingAccount}?deleted=1');
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    // Router'ı sheet kapanmadan önce yakala; sheet'in context'i
    // pop sonrası unmounted olur.
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    await ref.read(authServiceProvider).signOut();
    // Hesabı zaten var: kategori/metrik adımları yerine giriş ekranı.
    router.go(AppRoutes.onboardingAccount);
  }
}

/// Hesap silme onayı: geri alınamazlık uyarısı + "SİL" yazma koşulu.
///
/// Silme sürerken buton spinner'a döner; requires-recent-login gelirse
/// yönteme göre yeniden doğrulama yapılıp son adım tekrarlanır.
/// Başarıda `true` ile kapanır.
class _DeleteAccountDialog extends ConsumerStatefulWidget {
  const _DeleteAccountDialog();

  @override
  ConsumerState<_DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<_DeleteAccountDialog> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _confirmed {
    final l10n = AppLocalizations.of(context)!;
    return _controller.text.trim() == l10n.deleteAccountConfirmWord;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deleteAccountDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.deleteAccountDialogBody, style: textTheme.bodyMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            enabled: !_busy,
            autocorrect: false,
            decoration: InputDecoration(
              hintText:
                  l10n.deleteAccountConfirmHint(l10n.deleteAccountConfirmWord),
              border: const OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ],
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_busy)
              const SizedBox(
                height: 40,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              )
            else
              FilledButton(
                onPressed: _confirmed ? _delete : null,
                style: FilledButton.styleFrom(
                  backgroundColor: scheme.error,
                  foregroundColor: scheme.onError,
                ),
                child: Text(l10n.deleteAccountConfirmButton),
              ),
            const SizedBox(height: 4),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _errorMessage = null;
    });

    try {
      await ref.read(accountDeletionServiceProvider).deleteAccount();
      if (mounted) Navigator.of(context).pop(true);
    } on RequiresRecentLoginException catch (e) {
      await _reauthenticateAndRetry(e.method);
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(l10n.deleteAccountFailed);
    }
  }

  /// Veri silinmiş durumda; yönteme göre yeniden doğrulayıp sadece
  /// auth kullanıcısını silen son adımı tekrarlar.
  Future<void> _reauthenticateAndRetry(ReauthMethod method) async {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.read(authServiceProvider);

    try {
      final bool verified;
      switch (method) {
        case ReauthMethod.password:
          final password = await showDialog<String>(
            context: context,
            builder: (_) => const _PasswordPromptDialog(),
          );
          if (password == null || !mounted) {
            _showError(null);
            return;
          }
          await auth.reauthenticateWithPassword(password);
          verified = true;
        case ReauthMethod.google:
          verified = await auth.reauthenticateWithGoogle();
        case ReauthMethod.apple:
          verified = await auth.reauthenticateWithApple();
      }
      if (!verified) {
        _showError(null); // kullanıcı iptal etti; hata değil
        return;
      }
      await ref.read(accountDeletionServiceProvider).deleteAuthUser();
      if (mounted) Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      _showError(e.message);
    } catch (_) {
      _showError(l10n.deleteAccountFailed);
    }
  }

  void _showError(String? message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _errorMessage = message;
    });
  }
}

/// Şifreyle yeniden doğrulama için şifre isteyen mini dialog;
/// girilen şifreyle (iptalde null) kapanır.
class _PasswordPromptDialog extends StatefulWidget {
  const _PasswordPromptDialog();

  @override
  State<_PasswordPromptDialog> createState() => _PasswordPromptDialogState();
}

class _PasswordPromptDialogState extends State<_PasswordPromptDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.reauthPasswordTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.reauthPasswordBody),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            obscureText: true,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.passwordLabel,
              border: const OutlineInputBorder(),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n.reauthConfirmButton),
        ),
      ],
    );
  }

  void _submit() {
    if (_controller.text.isEmpty) return;
    Navigator.of(context).pop(_controller.text);
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.goals,
    required this.progress,
    required this.now,
  });

  final List<Goal> goals;
  final UserProgress progress;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final today = DateTime(now.year, now.month, now.day);
    final updatedToday = goals.where((g) {
      final at = g.lastProgressUpdateAt;
      return at != null && !DateTime(at.year, at.month, at.day).isBefore(today);
    }).length;
    final percent = updatedToday / goals.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.todayProgress, style: textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.percentOnly((percent * 100).round()),
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LinearProgressIndicator(value: percent, minHeight: 8),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  l10n.goalsProgressedCount(updatedToday),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.local_fire_department,
                  size: 16,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  l10n.dayStreak(progress.currentStreak),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () => _showFreezeInfo(context),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      l10n.freezeIndicator(progress.freezesAvailable),
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFreezeInfo(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.freezeDialogTitle),
        content: Text(l10n.freezeDialogBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.gotIt),
          ),
        ],
      ),
    );
  }
}

/// Bu haftanın meydan okuması; tamamlanınca başarı tonuna döner.
class _WeeklyChallengeCard extends ConsumerWidget {
  const _WeeklyChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final status = ref.watch(weeklyChallengeProvider).value;
    if (status == null) return const SizedBox.shrink();

    final challenge = status.challenge;
    final completed = challenge.isClaimed ||
        status.progress >= challenge.targetValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: completed ? scheme.tertiaryContainer : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    completed ? Icons.emoji_events : Icons.flag_circle_outlined,
                    size: 20,
                    color: completed
                        ? scheme.onTertiaryContainer
                        : scheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.weeklyChallengeTitle,
                      style: textTheme.labelLarge?.copyWith(
                        color: completed ? scheme.onTertiaryContainer : null,
                      ),
                    ),
                  ),
                  Text(
                    l10n.plusXp(challenge.xpReward),
                    style: textTheme.labelLarge?.copyWith(
                      color: completed
                          ? scheme.onTertiaryContainer
                          : scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                completed
                    ? l10n.challengeCompleted(challenge.xpReward)
                    : challenge.displayTitle(context),
                style: textTheme.bodyMedium?.copyWith(
                  color: completed ? scheme.onTertiaryContainer : null,
                ),
              ),
              if (!completed) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: challenge.targetValue == 0
                            ? 0
                            : status.progress / challenge.targetValue,
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${status.progress}/${challenge.targetValue}',
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, size: 20, color: scheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.goal});

  final Goal goal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final percent = goal.progressPercent;
    final estimated = goal.estimatedCompletion();

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.goalDetailPath(goal.id)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(goal.icon, size: 24, color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.displayTitle(context),
                      style: textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    if (percent != null) ...[
                      LinearProgressIndicator(value: percent, minHeight: 6),
                      const SizedBox(height: 6),
                      Text(
                        // %100'de tahmini tarih anlamsız; tamamlandı yazılır.
                        percent >= 1.0
                            ? l10n.goalCompleted
                            : estimated == null
                                ? l10n.percentOnly((percent * 100).round())
                                : l10n.percentWithEstimate(
                                    (percent * 100).round(),
                                    DateFormat('d.M.y').format(estimated),
                                  ),
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ] else
                      Text(
                        l10n.inProgress,
                        style: textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => showQuickUpdateSheet(context, goal),
                icon: const Icon(Icons.bolt),
                color: scheme.primary,
                tooltip: l10n.quickUpdate,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tamamlanan hedefler listesine giden küçük giriş satırı.
class _CompletedGoalsEntry extends StatelessWidget {
  const _CompletedGoalsEntry({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: () => context.push(AppRoutes.goalsCompleted),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.emoji_events_outlined, size: 20,
                  color: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.completedGoalsEntry(count),
                  style: textTheme.titleSmall,
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(Icons.flag_outlined, size: 48, color: scheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text(l10n.noGoalsYet, style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            l10n.noGoalsYetSubtitle,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push(AppRoutes.goalsAdd),
            icon: const Icon(Icons.add),
            label: Text(l10n.addGoal),
          ),
        ],
      ),
    );
  }
}
