// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Future Self';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get add => 'Add';

  @override
  String get continueButton => 'Continue';

  @override
  String get continueShort => 'Continue';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading…';

  @override
  String get error => 'Something went wrong';

  @override
  String get retry => 'Try again';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get close => 'Close';

  @override
  String get done => 'Done';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get deleteAccountAction => 'Delete Account';

  @override
  String get deleteAccountDialogTitle =>
      'Are you sure you want to delete your account?';

  @override
  String get deleteAccountDialogBody =>
      'This action CANNOT be undone. All your goals, history, missions, posts and all of your data will be permanently deleted.';

  @override
  String get deleteAccountConfirmWord => 'DELETE';

  @override
  String deleteAccountConfirmHint(String word) {
    return 'Type \"$word\" to confirm';
  }

  @override
  String get deleteAccountConfirmButton => 'Delete My Account';

  @override
  String get deleteAccountFailed =>
      'Couldn\'t delete your account, please try again.';

  @override
  String get accountDeletedMessage => 'Your account has been deleted.';

  @override
  String get reauthPasswordTitle => 'Confirm your password';

  @override
  String get reauthPasswordBody =>
      'For security, you need to re-enter your password before deleting your account.';

  @override
  String get reauthConfirmButton => 'Verify';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get today => 'Today';

  @override
  String get welcomeTitle => 'Welcome!';

  @override
  String get welcomeSubtitle =>
      'Your account is ready. Now let\'s get to know you — the small steps you take every day will shape your future self.';

  @override
  String get categoriesTitle => 'Which areas do you want to grow in?';

  @override
  String get categoriesSubtitle =>
      'Pick as many as you like — you can change them later.';

  @override
  String get currentStateTitle => 'Where are you right now?';

  @override
  String get currentStateSubtitle =>
      'Enter where you are today and where you want to be. Everything is optional — you can fill it in later.';

  @override
  String get addMetric => 'Add metric';

  @override
  String addMetricFor(String category) {
    return 'Add a metric for $category';
  }

  @override
  String get nowLabel => 'Now';

  @override
  String get targetLabel => 'Target';

  @override
  String get decreasingHint =>
      'Your target should be lower than your current value';

  @override
  String get currentLevelLabel => 'Current level';

  @override
  String get targetLevelLabel => 'Target level';

  @override
  String get freeTextHint => 'What\'s your goal?';

  @override
  String get notificationsTitle => 'Want Future You to check in?';

  @override
  String get notificationsSubtitle =>
      'A few times a day, we\'ll send gentle reminders that help you notice your progress. You can turn them off anytime.';

  @override
  String get morningMotivation => 'Morning motivation';

  @override
  String get streakReminders => 'Streak reminders';

  @override
  String get eveningSummary => 'Evening summary';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get notNow => 'Not now';

  @override
  String get accountTitle => 'Let\'s save your journey';

  @override
  String get accountSubtitle =>
      'Create an account so your progress is never lost.';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithEmail => 'Continue with email';

  @override
  String get orSeparator => 'or';

  @override
  String get termsNotice =>
      'By continuing, you agree to the Terms of Use and Privacy Policy.';

  @override
  String get signUp => 'Sign up';

  @override
  String get signIn => 'Log in';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailPasswordRequired => 'Enter your email and password.';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryCareer => 'Career';

  @override
  String get categoryFinance => 'Finance';

  @override
  String get categoryLearning => 'Learning';

  @override
  String get categoryRelationships => 'Relationships';

  @override
  String get categorySpirituality => 'Spirituality';

  @override
  String get categoryPersonalGrowth => 'Personal Growth';

  @override
  String get templateWeight => 'Weight';

  @override
  String get templateExerciseFrequency => 'Exercise frequency';

  @override
  String get templateFreeGoal => 'Custom goal';

  @override
  String get templateCareerLevel => 'Level';

  @override
  String get templateTargetPosition => 'Target position';

  @override
  String get templateSalary => 'Salary';

  @override
  String get templateSavings => 'Savings';

  @override
  String get templateGold => 'Gold';

  @override
  String get templateCrypto => 'Crypto';

  @override
  String get templateCardDebt => 'Card debt';

  @override
  String get templateLanguageLevel => 'Language level';

  @override
  String get templateTopicCourse => 'Topic / course';

  @override
  String goalsLoadError(String error) {
    return 'Couldn\'t load your goals. Check your connection.\n$error';
  }

  @override
  String get statusNoGoals =>
      'You haven\'t added a goal yet. Start the journey with your first one.';

  @override
  String get statusQuietWeek =>
      'This week has been a bit quiet. Even a small step brings Future You closer.';

  @override
  String statusStreak(int count) {
    return 'You\'re on a $count-day streak — steadier than last week.';
  }

  @override
  String statusProgress(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You\'re doing great. You made progress on $count goals this week.',
      one: 'You\'re doing great. You made progress on 1 goal this week.',
    );
    return '$_temp0';
  }

  @override
  String get defaultUserName => 'Traveler';

  @override
  String levelXp(int level, int xp) {
    return 'Level $level • $xp XP';
  }

  @override
  String get todayProgress => 'Today\'s Progress';

  @override
  String goalsProgressedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count goals progressed',
      one: '1 goal progressed',
    );
    return '$_temp0';
  }

  @override
  String dayStreak(int count) {
    return '$count-day streak';
  }

  @override
  String freezeIndicator(int count) {
    return '🧊 x$count';
  }

  @override
  String get freezeDialogTitle => 'Streak Freeze 🧊';

  @override
  String get freezeDialogBody =>
      'If you miss a day, it protects your streak — you continue as if the day was never skipped. You get 2 freezes every month and they\'re used automatically when needed.';

  @override
  String get gotIt => 'Got it';

  @override
  String get noEmailInfo => 'No email info';

  @override
  String get activeGoals => 'Active Goals';

  @override
  String get weeklyChallengeTitle => 'This Week\'s Challenge';

  @override
  String plusXp(int xp) {
    return '+$xp XP';
  }

  @override
  String challengeCompleted(int xp) {
    return 'Completed! You earned +$xp XP 🎉';
  }

  @override
  String get inProgress => 'In progress';

  @override
  String percentOnly(int percent) {
    return '$percent%';
  }

  @override
  String percentWithEstimate(int percent, String date) {
    return '$percent% • est. $date';
  }

  @override
  String estimatedDate(String date) {
    return 'est. $date';
  }

  @override
  String get goalCompleted => 'Completed';

  @override
  String get completedGoalsTitle => 'Completed Goals';

  @override
  String completedGoalsEntry(int count) {
    return 'Completed Goals ($count)';
  }

  @override
  String completedOnDate(String date) {
    return 'Completed · $date';
  }

  @override
  String get noCompletedGoalsYet => 'No completed goals yet.';

  @override
  String get quickUpdate => 'Quick update';

  @override
  String get noGoalsYet => 'No goals yet';

  @override
  String get noGoalsYetSubtitle =>
      'Future You is waiting. Add your first goal.';

  @override
  String get addGoal => 'Add goal';

  @override
  String get newValueLabel => 'New value';

  @override
  String get freeTextProgressQuestion =>
      'Did you make progress on this goal today?';

  @override
  String recordProgressWithXp(int xp) {
    return 'Record progress (+$xp XP)';
  }

  @override
  String saveWithXp(int xp) {
    return 'Save (+$xp XP)';
  }

  @override
  String get saveFailed => 'Couldn\'t save, try again.';

  @override
  String deleteDialogStreakTitle(int streak) {
    return 'You\'re about to give up your $streak-day streak';
  }

  @override
  String get deleteDialogGenericTitle =>
      'You\'re about to give up your progress';

  @override
  String deleteDialogMessageWithValues(
    String title,
    String from,
    String to,
    int xp,
  ) {
    return 'On \'$title\' you went from $from to $to and earned $xp XP. If you delete this goal, this progress history will be deleted too.';
  }

  @override
  String deleteDialogMessageXpOnly(String title, int xp) {
    return 'You\'ve earned $xp XP on \'$title\' so far. If you delete this goal, this progress history will be deleted too.';
  }

  @override
  String goalLoadError(String error) {
    return 'Couldn\'t load the goal.\n$error';
  }

  @override
  String get goalNotFound => 'Goal not found.';

  @override
  String get deleteGoalTooltip => 'Delete goal';

  @override
  String get keepGoing => 'I want to keep going';

  @override
  String get deleteAnyway => 'Delete anyway';

  @override
  String get deleteFailed => 'Couldn\'t delete, try again.';

  @override
  String nowValue(String value) {
    return 'Now: $value';
  }

  @override
  String targetValueText(String value) {
    return 'Target: $value';
  }

  @override
  String daysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String xpValue(int xp) {
    return '$xp XP';
  }

  @override
  String get streakLabel => 'Streak';

  @override
  String get earnedLabel => 'Earned';

  @override
  String get recordProgress => 'Record progress';

  @override
  String get historyLabel => 'History';

  @override
  String get historyLoadError => 'Couldn\'t load history.';

  @override
  String get noHistoryYet => 'No entries yet';

  @override
  String get progressRecorded => 'Progress recorded';

  @override
  String get addGoalTitle => 'Add Goal';

  @override
  String get whichArea => 'Which area?';

  @override
  String pickMetricFor(String category) {
    return 'Pick a metric for $category';
  }

  @override
  String get alreadyAdded => 'Already added';

  @override
  String get freeTextType => 'Free text';

  @override
  String get addGoalSubmit => 'Add goal';

  @override
  String get goalAdded => 'Goal added.';

  @override
  String get addFailed => 'Couldn\'t add, try again.';

  @override
  String get lifeMissions => 'Life Missions';

  @override
  String get addMission => 'Add mission';

  @override
  String missionsLoadError(String error) {
    return 'Couldn\'t load missions.\n$error';
  }

  @override
  String missionsSummary(int total, int completed) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total missions',
      one: '1 mission',
    );
    return '$_temp0 · $completed completed';
  }

  @override
  String addedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Added $count days ago',
      one: 'Added 1 day ago',
      zero: 'Added today',
    );
    return '$_temp0';
  }

  @override
  String get completedLabel => 'Completed';

  @override
  String completedDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Completed · $count days ago',
      one: 'Completed · 1 day ago',
      zero: 'Completed · today',
    );
    return '$_temp0';
  }

  @override
  String gentleReminder(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You haven\'t touched this goal for $count days — we\'re here to remind you',
      one:
          'You haven\'t touched this goal for 1 day — we\'re here to remind you',
    );
    return '$_temp0';
  }

  @override
  String get noNotesYet => 'No notes yet';

  @override
  String get noMissionsYet => 'No missions yet';

  @override
  String get noMissionsYetSubtitle =>
      'Add the things you want to do in life — big or small, they all count.';

  @override
  String get missionTitleHint => 'What do you want to achieve?';

  @override
  String missionLoadError(String error) {
    return 'Couldn\'t load the mission.\n$error';
  }

  @override
  String get missionNotFound => 'Mission not found.';

  @override
  String addedOn(String date) {
    return 'Added: $date';
  }

  @override
  String get markCompleted => 'Mark as completed';

  @override
  String get markIncomplete => 'Mark as not completed';

  @override
  String get notesLabel => 'Notes';

  @override
  String get missionNoteHint => 'A development, a thought…';

  @override
  String get addNote => 'Add note';

  @override
  String get noteAddFailed => 'Couldn\'t add the note, try again.';

  @override
  String get deleteMissionTitle => 'Delete this mission?';

  @override
  String get deleteMissionConfirm =>
      'Are you sure you want to delete this goal?';

  @override
  String get lifeLessons => 'Life Lessons';

  @override
  String get share => 'Share';

  @override
  String get feedTab => 'Feed';

  @override
  String get savedTab => 'Saved';

  @override
  String lessonsLoadError(String error) {
    return 'Couldn\'t load posts.\n$error';
  }

  @override
  String get noLessonsYet => 'No posts yet';

  @override
  String get noLessonsYetSubtitle =>
      'Share the first lesson — someone might need it.';

  @override
  String get noSavedLessonsYet => 'You haven\'t saved any posts yet';

  @override
  String get noSavedLessonsYetSubtitle =>
      'Posts you save with the bookmark icon will collect here.';

  @override
  String get report => 'Report';

  @override
  String get reportLessonConfirm =>
      'Are you sure you want to report this post?';

  @override
  String get reportCommentConfirm =>
      'Are you sure you want to report this comment?';

  @override
  String get reportThanks => 'Thanks for reporting.';

  @override
  String get deleteLessonTitle => 'Delete this post?';

  @override
  String get deleteLessonConfirm =>
      'Are you sure you want to delete this post? This can\'t be undone.';

  @override
  String get lessonTextHint => 'Share an experience or a regret...';

  @override
  String get anonymousNotice => 'This post will appear anonymously.';

  @override
  String get profanityWarning =>
      'This text seems to contain inappropriate language — please edit it.';

  @override
  String get shareFailed => 'Couldn\'t share, try again.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String lessonLoadError(String error) {
    return 'Couldn\'t load the post.\n$error';
  }

  @override
  String get lessonNotFound => 'Post not found.';

  @override
  String get commentsLoadError => 'Couldn\'t load comments.';

  @override
  String get noCommentsYet => 'No comments yet — write the first one.';

  @override
  String get commentHint => 'Write an anonymous comment…';

  @override
  String get send => 'Send';

  @override
  String get commentSendFailed => 'Couldn\'t send the comment, try again.';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String daysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get coachEmptyMessage =>
      'You don\'t have a goal yet. Once you add your first one, personal thoughts for Future You will appear here.';

  @override
  String coachStreakWithGoal(int count, String title) {
    return 'You\'re on a $count-day streak — this pace could get you to \'$title\' sooner.';
  }

  @override
  String coachStreakGeneric(int count) {
    return 'You\'re on a $count-day streak — this consistency is the best investment in Future You.';
  }

  @override
  String coachNeglected(String title, int days) {
    return '\'$title\' has been waiting for you for $days days. Even a small update brings the momentum back — we\'re here when you\'re ready.';
  }

  @override
  String coachTipRegular1(String title) {
    return 'You\'re keeping the rhythm on \'$title\' — great going.';
  }

  @override
  String coachTipRegular2(String title) {
    return 'You\'ve been really consistent with \'$title\' lately.';
  }

  @override
  String coachTipRegular3(String title) {
    return '\'$title\' is right on track — keep it up.';
  }

  @override
  String coachTipRegular4(String title) {
    return 'The steady steps you\'re taking on \'$title\' are already adding up.';
  }

  @override
  String coachTipRegular5(String title) {
    return 'Your pace on \'$title\' is making Future You\'s job easier.';
  }

  @override
  String coachTipRegular6(String title) {
    return 'Your momentum on \'$title\' is solid; small steps make a big difference.';
  }

  @override
  String coachTipUntouched1(String title) {
    return 'How about taking a small step on \'$title\' today?';
  }

  @override
  String coachTipUntouched2(String title) {
    return '\'$title\' is waiting for you — what do you say?';
  }

  @override
  String coachTipUntouched3(String title) {
    return 'Want to open the first entry for \'$title\' today?';
  }

  @override
  String coachTipUntouched4(String title) {
    return 'Starting is half the battle with \'$title\'.';
  }

  @override
  String coachTipUntouched5(String title) {
    return 'Even a five-minute start counts for \'$title\'.';
  }

  @override
  String coachTipUntouched6(String title) {
    return 'The road to \'$title\' opens with the first step; today is a good day.';
  }

  @override
  String get reflectionQuestion1 =>
      'What was the smallest step you took toward your goals this week?';

  @override
  String get reflectionQuestion2 => 'What motivated you the most this week?';

  @override
  String get reflectionQuestion3 =>
      'What did you do today for your future self?';

  @override
  String get reflectionQuestion4 =>
      'What would you from a year ago be surprised by, seeing you today?';

  @override
  String get reflectionQuestion5 =>
      'What did you notice yourself postponing this week?';

  @override
  String get reflectionQuestion6 =>
      'What drains your energy the most, and what restores it?';

  @override
  String get reflectionQuestion7 =>
      'Which habit might be pulling you away from your goal?';

  @override
  String get reflectionQuestion8 =>
      'If you thanked yourself today, what would it be for?';

  @override
  String get reflectionQuestion9 =>
      'Which of your goals genuinely excites you?';

  @override
  String get reflectionQuestion10 =>
      'What have you learned about yourself in the past month?';

  @override
  String get reflectionQuestion11 =>
      'If you could do one thing differently tomorrow morning, what would it be?';

  @override
  String get reflectionQuestion12 => 'Who or what was good for you this week?';

  @override
  String get reflectionQuestion13 =>
      'Is there something you thought about quitting but kept going with?';

  @override
  String get reflectionQuestion14 =>
      'What advice would you five years from now give to today\'s you?';

  @override
  String get reflectionQuestion15 =>
      'Was there a small moment that made you smile today?';

  @override
  String get reflectionQuestion16 =>
      'Which goal might no longer feel like it\'s truly yours?';

  @override
  String get reflectionQuestion17 =>
      'Was there something you said yes to this week when you should have said no?';

  @override
  String get reflectionQuestion18 => 'When did you last truly rest?';

  @override
  String get reflectionQuestion19 =>
      'If you judged your progress without comparing to anyone, what would you see?';

  @override
  String get reflectionQuestion20 =>
      'What would help you finish what you started today instead of leaving it for tomorrow?';

  @override
  String get reflectionQuestion21 =>
      'What does your future self\'s daily routine look like?';

  @override
  String get reflectionQuestion22 =>
      'Is there a habit you want to drop this month? What would you replace it with?';

  @override
  String get motivationalQuote1 =>
      'Every step you take today is a gift to tomorrow\'s you.';

  @override
  String get motivationalQuote2 =>
      'Your future self is the sum of today\'s decisions.';

  @override
  String get motivationalQuote3 =>
      'Small steps are quiet, but they carry you the farthest.';

  @override
  String get motivationalQuote4 =>
      'There is no perfect day; there is only today.';

  @override
  String get motivationalQuote5 => 'Consistency begins where motivation ends.';

  @override
  String get motivationalQuote6 =>
      'A year from now, you\'ll wish you had started today.';

  @override
  String get motivationalQuote7 =>
      'Moving slowly is infinitely faster than standing still.';

  @override
  String get motivationalQuote8 =>
      'Promises you make to yourself deserve to be kept too.';

  @override
  String get motivationalQuote9 =>
      'Change happens on ordinary days, not in big moments.';

  @override
  String get motivationalQuote10 =>
      'Today\'s 1% is a whole different version of tomorrow.';

  @override
  String get motivationalQuote11 =>
      'The hard part isn\'t starting — it\'s not fearing to start again.';

  @override
  String get motivationalQuote12 =>
      'Future You isn\'t watching you; they\'re walking with you.';

  @override
  String get motivationalQuote13 =>
      'The goal may look far; a step is always one step long.';

  @override
  String get motivationalQuote14 => 'Rest is part of progress too.';

  @override
  String get motivationalQuote15 =>
      'Whatever happened yesterday, today is a fresh entry.';

  @override
  String get motivationalQuote16 =>
      'Your best investment: twenty minutes set aside for yourself.';

  @override
  String get actionTip1 =>
      'Break big goals into small pieces; do only the first piece today.';

  @override
  String get actionTip2 =>
      'Start the day with a single sentence: \"today I will do this.\"';

  @override
  String get actionTip3 =>
      'If it takes less than two minutes, don\'t postpone it — do it now.';

  @override
  String get actionTip4 => 'Write tomorrow\'s plan tonight, in two sentences.';

  @override
  String get actionTip5 =>
      'Give one goal a fixed 15-minute slot on your calendar.';

  @override
  String get actionTip6 =>
      'Review your progress once a week; correct the course a little.';

  @override
  String get actionTip7 =>
      'Put the hard task in your most energetic hour of the day.';

  @override
  String get actionTip8 =>
      'Leave your phone in another room and try a 25-minute focus block.';

  @override
  String get actionTip9 =>
      'Attach a habit to an existing routine: five pages after coffee.';

  @override
  String get actionTip10 =>
      'Finish one thing at 80% today; don\'t keep waiting for perfect.';

  @override
  String get actionTip11 =>
      'Write your goal somewhere visible — what stays in sight stays in mind.';

  @override
  String get actionTip12 =>
      'Can\'t start? Shrink the scope: what\'s the 10-minute version?';

  @override
  String get actionTip13 =>
      'Define a small reward for finishing and keep your word.';

  @override
  String get actionTip14 =>
      'When you lose momentum, return to the easiest step; the chain rebuilds from there.';

  @override
  String get actionTip15 =>
      'Predict one obstacle in advance and write your plan B now.';

  @override
  String get actionTip16 =>
      'End the day with a one-sentence \"what did I learn today\" note.';

  @override
  String get coachTitle => 'Future Self Coach';

  @override
  String get coachSubtitle => 'A few thoughts for today';

  @override
  String coachLoadError(String error) {
    return 'Couldn\'t load the coach.\n$error';
  }

  @override
  String get dailyQuestionTitle => 'Question of the day';

  @override
  String get dailyQuoteTitle => 'Quote of the day';

  @override
  String get dailyTipTitle => 'Tip of the day';

  @override
  String todaysAnswer(String answer) {
    return 'Today\'s answer: $answer';
  }

  @override
  String get answerButton => 'Answer';

  @override
  String get reflectionAnswerHint => 'Write whatever comes to mind…';

  @override
  String get chapterTitleBeginning => 'The Beginning';

  @override
  String get chapterTitleComeback => 'The Comeback';

  @override
  String get chapterTitleLeap => 'The Leap';

  @override
  String get chapterTitleDream => 'One More Dream';

  @override
  String get chapterTitleQuiet => 'A Quiet Week';

  @override
  String get chapterTitleSteady => 'Steady';

  @override
  String get chapterTitleOnTheRoad => 'On the Road';

  @override
  String get chapterFirstWeek =>
      'Your journey is just beginning. The first steps are always the most important — we\'re here when you\'re ready.';

  @override
  String get chapterQuietOpening1 =>
      'This week was quiet — sometimes catching your breath is part of the journey.';

  @override
  String get chapterQuietOpening2 =>
      'It was a calm week; a new week is a new page.';

  @override
  String get chapterLowOpening1 =>
      'You took small but valuable steps this week.';

  @override
  String get chapterLowOpening2 => 'You moved slowly but surely this week.';

  @override
  String get chapterMidOpening1 => 'You kept a good pace this week.';

  @override
  String get chapterMidOpening2 =>
      'You were steady and determined this week; the steps kept stacking up.';

  @override
  String get chapterHighOpening1 =>
      'You were strong this week — Future You will remember it.';

  @override
  String get chapterHighOpening2 =>
      'You practically leaped this week; your effort became visible.';

  @override
  String get chapterComeback1 =>
      'Coming back after a pause is worth more than never stopping.';

  @override
  String get chapterComeback2 =>
      'You continued after a brief pause — that\'s real strength.';

  @override
  String chapterImproved(String title, int percent) {
    return 'You made visible progress on \'$title\' (+$percent%).';
  }

  @override
  String chapterMissions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'You completed $count missions this week — dreams are coming true one by one.',
      one:
          'You completed a mission this week — one more dream from your list came true.',
    );
    return '$_temp0';
  }

  @override
  String get chaptersTitle => 'Chapters';

  @override
  String chaptersLoadError(String error) {
    return 'Couldn\'t load chapters.\n$error';
  }

  @override
  String get noChaptersYet =>
      'No chapters yet — your story will be written here at the end of your first completed week.';

  @override
  String chapterLabel(int number) {
    return 'CHAPTER $number';
  }

  @override
  String get longestStreakLabel => 'Longest streak';

  @override
  String get missionsStatLabel => 'Missions';

  @override
  String featuredGoal(String title) {
    return 'Featured: $title';
  }

  @override
  String chapterEntryTitle(int number, String title) {
    return 'Chapter $number: $title';
  }

  @override
  String get chapterEntrySubtitle => 'Take a look at last week\'s story';

  @override
  String get yourLetters => 'Your Letters';

  @override
  String get writeFirstLetter => 'Write your first letter';

  @override
  String get writeFirstLetterSubtitle =>
      'Leave a note from today for your future self';

  @override
  String lettersWaiting(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letters waiting to be opened',
      one: '1 letter waiting to be opened',
    );
    return '$_temp0';
  }

  @override
  String lettersInJourney(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count letters on their journey',
      one: '1 letter on its journey',
    );
    return '$_temp0';
  }

  @override
  String get letterToFuture => 'Letter to the Future';

  @override
  String get letterHint => 'What do you want to tell your future self?';

  @override
  String get whenToDeliver => 'When should it arrive?';

  @override
  String get inOneMonth => 'In 1 month';

  @override
  String get inThreeMonths => 'In 3 months';

  @override
  String get inSixMonths => 'In 6 months';

  @override
  String get onGoalCompletionChip => 'When a goal completes';

  @override
  String get noActiveGoalForLetter =>
      'You don\'t have an active goal to attach. Add a goal first or pick a fixed date.';

  @override
  String get letterSealNote =>
      'Your letter is sealed; no one (including you) can read it until it\'s time.';

  @override
  String get sealLetter => 'Seal the letter';

  @override
  String get letterSealed => 'Your letter is sealed.';

  @override
  String get sealFailed => 'Couldn\'t seal it, try again.';

  @override
  String get writeLetterTooltip => 'Write a letter';

  @override
  String lettersLoadError(String error) {
    return 'Couldn\'t load letters.\n$error';
  }

  @override
  String get sealedLetter => 'Sealed letter';

  @override
  String get opensToday => 'Opens today';

  @override
  String opensInDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Opens in $count days',
      one: 'Opens in 1 day',
    );
    return '$_temp0';
  }

  @override
  String get opensOnGoalCompletion => 'Opens when your goal completes';

  @override
  String get notYetTime =>
      'It\'s not time yet — patience is part of the journey too.';

  @override
  String get letterArrivedTitle => 'A letter arrived from the past';

  @override
  String get tapToOpen => 'Tap to open';

  @override
  String get noLettersYet => 'No letters yet';

  @override
  String get noLettersYetSubtitle =>
      'Carry today\'s feelings into the future — the you who reads it will be someone entirely new.';

  @override
  String get letterTitle => 'Letter';

  @override
  String letterLoadError(String error) {
    return 'Couldn\'t load the letter.\n$error';
  }

  @override
  String get letterNotFound => 'Letter not found.';

  @override
  String get letterStillSealed =>
      'This letter is still sealed — it will open here when it\'s time.';

  @override
  String letterWrittenOn(String date) {
    return 'Written on $date';
  }

  @override
  String letterWrittenOnWithMonths(String date, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Written on $date — $count months ago',
      one: 'Written on $date — 1 month ago',
    );
    return '$_temp0';
  }

  @override
  String get writeLetterToToday => 'Write a letter to today\'s you';

  @override
  String plusPercent(int percent) {
    return '+$percent%';
  }

  @override
  String get languageLabel => 'Dil / Language';

  @override
  String get languageTurkish => 'Türkçe';

  @override
  String get languageEnglish => 'English';

  @override
  String levelUpCelebration(int level) {
    return 'Level $level! 🎉';
  }

  @override
  String get goalCompletedCelebration => 'Goal Completed! 🏆';

  @override
  String get badgeStreak7 => 'First Spark';

  @override
  String get badgeStreak30 => 'On Fire';

  @override
  String get badgeStreak100 => 'Unstoppable';

  @override
  String get badgeFirstGoal => 'Setting Off';

  @override
  String get badgeFirstGoalCompleted => 'First Victory';

  @override
  String get badgeGoals5 => 'Goal Hunter';

  @override
  String get badgeGoals10 => 'Goal Master';

  @override
  String get badgeFirstMission => 'Dreamer';

  @override
  String get badgeFirstMissionCompleted => 'A Dream Come True';

  @override
  String get badgeMissions5 => 'Dream Collector';

  @override
  String get badgeFirstLesson => 'Speak Up';

  @override
  String get badgeFirstComment => 'Supporter';

  @override
  String get badgeLesson50Likes => 'Inspiration';

  @override
  String get badgeComeback => 'The Comeback';

  @override
  String get badgeEarlyBird => 'Early Bird';

  @override
  String get badgeLevel10 => 'The Ascent';

  @override
  String get badgeLevel25 => 'Legend';

  @override
  String get achievementsTitle => 'Achievements';

  @override
  String get achievementsEntryTitle => 'See Your Achievements';

  @override
  String get achievementsEntrySubtitle => 'Badges and personal records';

  @override
  String get personalRecords => 'Your Personal Records';

  @override
  String get recordLongestStreak => 'Longest streak';

  @override
  String get recordTotalXp => 'Total XP';

  @override
  String get recordCompletedGoals => 'Goals completed';

  @override
  String get recordCompletedMissions => 'Missions completed';

  @override
  String recordFastestGoal(String title) {
    return 'Fastest progressing: $title';
  }

  @override
  String badgesCount(int unlocked, int total) {
    return 'Badges ($unlocked/$total)';
  }

  @override
  String achievementsLoadError(String error) {
    return 'Couldn\'t load achievements.\n$error';
  }

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navMissions => 'Missions';

  @override
  String get navLessons => 'Lessons';

  @override
  String get navCoach => 'Coach';

  @override
  String get challengeThreeDayStreak => 'Record progress on 3 different days';

  @override
  String get challengeTwoGoals => 'Record progress on 2 different goals';

  @override
  String get challengeMissionNote => 'Add a note to a mission';

  @override
  String get challengeReflection => 'Answer the coach\'s question of the day';

  @override
  String get challengeComment => 'Comment on a Life Lessons post';

  @override
  String get challengeTenPercent => 'Make 10% progress on a goal';

  @override
  String get bonusXpTitle => 'Earn bonus XP';

  @override
  String bonusXpSubtitle(int xp) {
    return 'Watch a short ad, earn +$xp XP';
  }

  @override
  String get watchAdAction => 'Watch';

  @override
  String get bonusXpComeBackTomorrow => 'Come back tomorrow';

  @override
  String bonusXpEarned(int xp) {
    return 'You earned +$xp XP!';
  }

  @override
  String get adRewardFailed =>
      'No reward this time — the ad couldn\'t be loaded or wasn\'t completed. You can try again later.';

  @override
  String streakRestoreTitle(int days) {
    return 'Your $days-day streak was reset';
  }

  @override
  String get streakRestoreAction => 'Watch an ad to restore your streak';

  @override
  String streakRestored(int days) {
    return 'Streak restored: $days days';
  }
}
