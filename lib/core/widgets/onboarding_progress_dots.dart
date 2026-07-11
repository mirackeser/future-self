import 'package:flutter/material.dart';

/// Onboarding adım göstergesi — aktif nokta hap şeklinde uzar.
class OnboardingProgressDots extends StatelessWidget {
  const OnboardingProgressDots({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  /// 0 tabanlı aktif adım indeksi.
  final int currentStep;

  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < totalSteps; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: i == currentStep ? 20 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: i == currentStep
                    ? scheme.primary
                    : scheme.outlineVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}
