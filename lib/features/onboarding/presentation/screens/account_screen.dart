import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../onboarding_providers.dart';

/// Giriş kapısı: hesap oluştur / giriş yap.
///
/// Apple / Google / E-posta seçenekleri. Mevcut kullanıcı (isNewUser
/// false) doğrudan dashboard'a; yeni hesap karşılama + kişiselleştirme
/// adımlarına gider. İptal ekranda tutar, hata SnackBar ile gösterilir.
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // Hesap silme akışı buraya ?deleted=1 ile yönlendirir; bilgi
    // mesajı ilk frame sonrasında (Scaffold hazırken) gösterilir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final deleted =
          GoRouterState.of(context).uri.queryParameters['deleted'] == '1';
      if (!deleted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.accountDeletedMessage),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                l10n.accountTitle,
                style: textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.accountSubtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _signIn(
                            () => ref
                                .read(authServiceProvider)
                                .signInWithApple(),
                          ),
                  icon: const Icon(Icons.apple),
                  label: Text(l10n.continueWithApple),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _signIn(
                            () => ref
                                .read(authServiceProvider)
                                .signInWithGoogle(),
                          ),
                  child: Text(l10n.continueWithGoogle),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      l10n.orSeparator,
                      style: textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => context.push(AppRoutes.onboardingAccountEmail),
                  icon: const Icon(Icons.mail_outline),
                  label: Text(l10n.continueWithEmail),
                ),
              ),
              const Spacer(),
              Text(
                l10n.termsNotice,
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// [flow] iptalde null, yeni hesapta true, mevcut hesapta false döner.
  /// Yeni hesap karşılama adımına, mevcut hesap dashboard'a gider.
  Future<void> _signIn(Future<bool?> Function() flow) async {
    setState(() => _busy = true);
    final onboardingFlow = ref.read(onboardingInProgressProvider.notifier);
    // Bayrak baştan açılır: yeni kullanıcı çıkarsa auth event'inin
    // tetiklediği redirect akışı dashboard'a süpürmesin.
    onboardingFlow.start();
    try {
      final isNewUser = await flow();
      if (isNewUser == null) {
        onboardingFlow.finish(); // iptal
      } else if (isNewUser) {
        if (mounted) context.go(AppRoutes.onboardingWelcome);
      } else {
        onboardingFlow.finish();
        if (mounted) context.go(AppRoutes.dashboard);
      }
    } on AuthFailure catch (e) {
      onboardingFlow.finish();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
