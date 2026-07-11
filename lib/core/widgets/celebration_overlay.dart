import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Kısa kutlama: konfeti patlaması + büyüyüp solan mesaj + haptic.
///
/// Kök Overlay'e basıldığı için sheet/dialog kapansa da görünür kalır
/// ve dokunuşları engellemez. Aynı anda birden fazla kutlama
/// tetiklenirse basit bir kuyrukla SIRAYLA oynatılır — biri diğerini
/// bastırmaz.
abstract final class CelebrationOverlay {
  static const Duration _duration = Duration(milliseconds: 1800);

  static final List<String> _queue = [];
  static bool _showing = false;

  /// [context] mounted olmalı; overlay hemen yakalanır, sonrasında
  /// context kapansa da kutlama oynar.
  static void celebrate(BuildContext context, String message) {
    final overlay = Overlay.of(context, rootOverlay: true);
    _queue.add(message);
    _drain(overlay);
  }

  static Future<void> _drain(OverlayState overlay) async {
    if (_showing) return;
    _showing = true;
    try {
      while (_queue.isNotEmpty) {
        final message = _queue.removeAt(0);
        await _showOne(overlay, message);
      }
    } finally {
      _showing = false;
    }
  }

  static Future<void> _showOne(OverlayState overlay, String message) async {
    HapticFeedback.mediumImpact();
    final entry = OverlayEntry(
      builder: (_) => _CelebrationView(message: message),
    );
    overlay.insert(entry);
    await Future<void>.delayed(_duration);
    entry.remove();
  }
}

class _CelebrationView extends StatefulWidget {
  const _CelebrationView({required this.message});

  final String message;

  @override
  State<_CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<_CelebrationView> {
  final _confetti =
      ConfettiController(duration: const Duration(milliseconds: 1500));

  @override
  void initState() {
    super.initState();
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return IgnorePointer(
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              maxBlastForce: 25,
              minBlastForce: 8,
              emissionFrequency: 0.05,
              gravity: 0.3,
              colors: [
                scheme.primary,
                scheme.tertiary,
                scheme.secondary,
                scheme.primaryContainer,
              ],
            ),
          ),
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: CelebrationOverlay._duration,
              builder: (context, t, child) {
                // İlk %35'te easeOutBack ile büyür, son %30'da solar.
                final scale =
                    Curves.easeOutBack.transform((t / 0.35).clamp(0.0, 1.0));
                final opacity = t < 0.7 ? 1.0 : 1 - (t - 0.7) / 0.3;
                return Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Transform.scale(scale: scale, child: child),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.message,
                  style: textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
