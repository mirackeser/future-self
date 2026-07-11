/// challenges özelliği — presentation katmanı: Riverpod provider'ları.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/models.dart';
import '../../goals/presentation/goals_providers.dart';
import '../data/challenges_repository.dart';

/// Challenge + hesaplanmış ilerleme.
typedef ChallengeStatus = ({WeeklyChallenge challenge, int progress});

/// Bu haftanın meydan okuması + ilerlemesi; tamamlandıysa ödül otomatik
/// claim edilir.
///
/// goalsStreamProvider watch edildiği için her hedef güncellemesinde
/// (dashboard'un ana aksiyonu) ilerleme yeniden hesaplanır; claim
/// dokümanı güncelleyince stream yeni durumu akıtır.
final weeklyChallengeProvider = StreamProvider<ChallengeStatus?>((ref) async* {
  final repository = ref.watch(challengesRepositoryProvider);
  ref.watch(goalsStreamProvider);

  await repository.getOrCreateCurrentChallenge();

  await for (final challenge in repository.watchThisWeekChallenge()) {
    if (challenge == null) continue;
    final progress = await repository.computeCurrentProgress(challenge);
    final justClaimed =
        await repository.claimIfCompleted(challenge, progress);
    // Claim olduysa doc stream'i isClaimed=true ile yeniden akacak;
    // bu ara durumu yayınlamaya gerek yok.
    if (!justClaimed) {
      yield (challenge: challenge, progress: progress);
    }
  }
});
