import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_router.dart';

/// Future Self mektupları için yerel bildirimler.
///
/// Zamanlama "şimdi + kalan süre" olarak kurulur; böylece cihazın
/// timezone kimliğine bağımlılık yoktur (DST geçişinde en fazla ~1
/// saatlik kayma olabilir, mektup için kabul edilebilir).
class LocalNotificationsService {
  LocalNotificationsService._();

  static final LocalNotificationsService instance =
      LocalNotificationsService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const String _notificationTitle = 'Geçmişten bir mektup geldi';

  static const AndroidNotificationDetails _androidDetails =
      AndroidNotificationDetails(
    'letters',
    'Future Self Mektupları',
    channelDescription: 'Geçmişteki senden gelen mektuplar',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const NotificationDetails _details = NotificationDetails(
    android: _androidDetails,
    iOS: DarwinNotificationDetails(),
  );

  /// Plugin + timezone verisini başlatır ve uygulama bildirimle soğuk
  /// açıldıysa ilgili mektuba yönlendirir. İzin İSTEMEZ (izin, mektup
  /// mühürlenirken istenir). main() içinde bir kez çağrılır.
  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      await _plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // İzinler burada değil, requestPermission ile istenir.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
        onDidReceiveNotificationResponse: (response) =>
            _navigateToLetter(response.payload),
      );

      // Uygulama bildirime tıklanarak (kapalıyken) açıldıysa.
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        final payload = launchDetails?.notificationResponse?.payload;
        if (payload != null) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _navigateToLetter(payload),
          );
        }
      }
      _initialized = true;
    } catch (e, stackTrace) {
      log(
        'Yerel bildirimler başlatılamadı',
        name: 'LocalNotificationsService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Bildirim izni ister; sistem zaten izin verdiyse (örn. Firebase
  /// Messaging onboarding'i üzerinden) tekrar sormaz.
  Future<void> requestPermission() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final enabled = await android.areNotificationsEnabled() ?? false;
        if (!enabled) await android.requestNotificationsPermission();
        return;
      }
      // iOS: izin zaten belirlenmişse sistem yeni bir pencere açmaz.
      await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    } catch (e) {
      log('Bildirim izni istenemedi: $e', name: 'LocalNotificationsService');
    }
  }

  /// Mektup bildirimini [deliveryDate] için zamanlar, bildirim id döner.
  Future<int> scheduleLetterNotification({
    required String letterId,
    required DateTime deliveryDate,
    required String previewText,
  }) async {
    await init();
    final id = _newNotificationId();
    final delay = deliveryDate.difference(DateTime.now());
    await _plugin.zonedSchedule(
      id,
      _notificationTitle,
      previewText,
      tz.TZDateTime.now(tz.local).add(delay.isNegative ? Duration.zero : delay),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: letterId,
    );
    return id;
  }

  /// Anlık bildirim (hedef tamamlanınca teslim edilen mektuplar).
  Future<int> showLetterDeliveredNow({
    required String letterId,
    required String previewText,
  }) async {
    await init();
    final id = _newNotificationId();
    await _plugin.show(id, _notificationTitle, previewText, _details,
        payload: letterId);
    return id;
  }

  Future<void> cancelNotification(int notificationId) =>
      _plugin.cancel(notificationId);

  static int _newNotificationId() =>
      DateTime.now().millisecondsSinceEpoch.remainder(0x7FFFFFFF);

  static void _navigateToLetter(String? letterId) {
    if (letterId == null || letterId.isEmpty) return;
    final context = rootNavigatorKey.currentContext;
    if (context == null) return;
    GoRouter.of(context).push(AppRoutes.letterRevealPath(letterId));
  }
}

final localNotificationsServiceProvider =
    Provider<LocalNotificationsService>((ref) {
  return LocalNotificationsService.instance;
});
