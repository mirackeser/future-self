import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/services/services.dart';
import '../../../../l10n/app_localizations.dart';
import '../onboarding_providers.dart';

enum _AuthMode { signUp, signIn }

/// E-posta ile kayıt / giriş ekranı.
///
/// Hatalar [AuthFailure] mesajı olarak alanın altında gösterilir;
/// kullanıcı ekranda kalır. Başarıda dashboard'a gidilir.
class EmailAuthScreen extends ConsumerStatefulWidget {
  const EmailAuthScreen({super.key});

  @override
  ConsumerState<EmailAuthScreen> createState() => _EmailAuthScreenState();
}

class _EmailAuthScreenState extends ConsumerState<EmailAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  _AuthMode _mode = _AuthMode.signUp;
  String? _errorMessage;
  bool _busy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.continueWithEmail)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<_AuthMode>(
                segments: [
                  ButtonSegment(
                    value: _AuthMode.signUp,
                    label: Text(l10n.signUp),
                  ),
                  ButtonSegment(
                    value: _AuthMode.signIn,
                    label: Text(l10n.signIn),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (selection) => setState(() {
                  _mode = selection.first;
                  _errorMessage = null;
                }),
              ),
              const SizedBox(height: 24),
              TextField(
                key: const ValueKey('emailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: InputDecoration(labelText: l10n.emailLabel),
              ),
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('passwordField'),
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.passwordLabel),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _errorMessage!,
                    style: textTheme.bodySmall?.copyWith(color: scheme.error),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: FilledButton(
                  key: const ValueKey('submitButton'),
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          _mode == _AuthMode.signUp ? l10n.signUp : l10n.signIn,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      setState(
        () => _errorMessage =
            AppLocalizations.of(context)!.emailPasswordRequired,
      );
      return;
    }

    setState(() {
      _busy = true;
      _errorMessage = null;
    });
    final onboardingFlow = ref.read(onboardingInProgressProvider.notifier);
    // Kayıtta bayrak baştan açılır ki auth event'inin tetiklediği
    // redirect akışı dashboard'a süpürmesin.
    if (_mode == _AuthMode.signUp) onboardingFlow.start();
    try {
      final service = ref.read(authServiceProvider);
      final isNewUser = _mode == _AuthMode.signUp
          ? await service.signUpWithEmail(email, password)
          : await service.signInWithEmail(email, password);
      if (mounted) {
        // Yeni hesap kişiselleştirme adımlarına, mevcut hesap dashboard'a.
        context.go(
          isNewUser ? AppRoutes.onboardingWelcome : AppRoutes.dashboard,
        );
      }
    } on AuthFailure catch (e) {
      onboardingFlow.finish();
      if (mounted) setState(() => _errorMessage = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
