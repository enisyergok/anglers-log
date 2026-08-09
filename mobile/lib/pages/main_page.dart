import 'dart:async';

import 'package:adair_flutter_lib/managers/subscription_manager.dart';
import 'package:adair_flutter_lib/managers/time_manager.dart';
import 'package:adair_flutter_lib/utils/date_time.dart';
import 'package:adair_flutter_lib/utils/log.dart';
import 'package:adair_flutter_lib/utils/page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mobile/backup_restore_manager.dart';
import 'package:mobile/catch_manager.dart';
import 'package:mobile/mera/mera_map_hud.dart';
import 'package:mobile/mera/mera_records_page.dart';
import 'package:mobile/mera/mera_routes_page.dart';
import 'package:mobile/mera/mera_settings_page.dart';
import 'package:mobile/mera/mera_stats_page.dart';
import 'package:mobile/mera/mera_theme.dart';
import 'package:mobile/notification_manager.dart';
import 'package:mobile/trip_manager.dart';
import 'package:mobile/widgets/fishing_spot_map.dart';

import '../entity_manager.dart';
import '../model/gen/anglers_log.pb.dart';
import '../user_preference_manager.dart';
import '../utils/string_utils.dart';
import '../wrappers/in_app_review_wrapper.dart';
import 'anglers_log_pro_page.dart';
import 'backup_restore_page.dart';

/// Mera Asistanı shell — 5 sekme (mockup ile birebir).
class MainPage extends StatefulWidget {
  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  static const _log = Log('MainPage');
  static const _rateDialogEntityThreshold = 3;

  int _currentBarItem = 0; // Ana Sayfa
  late List<_BarItemModel> _navItems;

  late final StreamSubscription<EntityEvent<Catch>> _catchManagerSub;
  late final StreamSubscription<EntityEvent<Trip>> _tripManagerSub;
  late final StreamSubscription<LocalNotificationType> _notificationManagerSub;

  BackupRestoreManager get _backupRestoreManager =>
      BackupRestoreManager.of(context);

  InAppReviewWrapper get _inAppReviewWrapper => InAppReviewWrapper.of(context);

  late final NotificationManager _notificationManager;

  TripManager get _tripManager => TripManager.of(context);

  NavigatorState get _currentNavState {
    assert(_navItems[_currentBarItem].page?.navigatorKey.currentState != null);
    return _navItems[_currentBarItem].page!.navigatorKey.currentState!;
  }

  @override
  void initState() {
    super.initState();
    _notificationManager = NotificationManager.of(context);

    _navItems = [
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => FishingSpotMap(
            showSearchBar: false,
            showMyLocationButton: true,
            showZoomExtentsButton: false,
            showMapTypeButton: false,
            showGpsTrailButton: false,
            showFishingSpotActionButtons: false,
            children: const [MeraMapHud()],
          ),
        ),
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        title: 'Ana Sayfa',
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const MeraRoutesPage(),
        ),
        icon: Icons.route_outlined,
        activeIcon: Icons.route,
        title: 'Rotalarım',
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const MeraStatsPage(),
        ),
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        title: 'İstatistikler',
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const MeraRecordsPage(),
        ),
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        title: 'Kayıtlarım',
      ),
      _BarItemModel(
        page: _NavigatorPage(
          navigatorKey: GlobalKey<NavigatorState>(),
          builder: (context) => const MeraSettingsPage(),
        ),
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        title: 'Ayarlar',
      ),
    ];

    _catchManagerSub = CatchManager.get.listen(
      EntityListener<Catch>(
        onAdd: (_) {
          if (CatchManager.get.entityCount >= _rateDialogEntityThreshold) {
            _showFeedbackDialogIfNeeded();
          }
        },
      ),
    );
    _tripManagerSub = _tripManager.listen(
      EntityListener<Trip>(
        onAdd: (_) {
          if (_tripManager.entityCount >= _rateDialogEntityThreshold) {
            _showFeedbackDialogIfNeeded();
          }
        },
      ),
    );
    _notificationManagerSub = _notificationManager.stream.listen(
      _onLocalNotification,
    );

    _notificationManager.onDidReceiveNotificationResponse = () {
      if (_backupRestoreManager.isBackupRestorePageShowing) {
        return;
      }
      present(context, BackupPage());
    };

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (UserPreferenceManager.get.autoBackup) {
        await _notificationManager.requestPermission(context);
      }
      _backupRestoreManager.notifySignedOutIfNeeded();
    });
  }

  @override
  void dispose() {
    _catchManagerSub.cancel();
    _tripManagerSub.cancel();
    _notificationManagerSub.cancel();
    _notificationManager.onDidReceiveNotificationResponse = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final popped = await _currentNavState.maybePop();
        if (!popped && context.mounted) {
          // Stay on app; physical back on root does nothing.
        }
      },
      child: Scaffold(
        backgroundColor: MeraColors.bg,
        body: IndexedStack(
          index: _currentBarItem,
          children: _navItems.map((data) => data.page!).toList(),
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: MeraColors.bgElevated,
            border: Border(top: BorderSide(color: MeraColors.cardBorder)),
          ),
          child: SafeArea(
            child: BottomNavigationBar(
              backgroundColor: MeraColors.bgElevated,
              selectedItemColor: MeraColors.green,
              unselectedItemColor: MeraColors.textMuted,
              currentIndex: _currentBarItem,
              type: BottomNavigationBarType.fixed,
              items: [
                for (final data in _navItems)
                  BottomNavigationBarItem(
                    icon: Icon(data.icon),
                    activeIcon: Icon(data.activeIcon),
                    label: data.title,
                  ),
              ],
              onTap: (index) {
                if (_currentBarItem == index) {
                  _currentNavState.popUntil((r) => r.isFirst);
                } else {
                  setState(() => _currentBarItem = index);
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialogIfNeeded() {
    if (SubscriptionManager.get.isFree &&
        isFrequencyTimerReady(
          timerStartedAt: UserPreferenceManager.get.proTimerStartedAt,
          setTimer: UserPreferenceManager.get.setProTimerStartedAt,
          frequency: Duration.millisecondsPerDay * 7,
        )) {
      UserPreferenceManager.get.setProTimerStartedAt(
        TimeManager.get.currentTimestamp,
      );
      AnglersLogProPage.present(context);
      return;
    }

    _inAppReviewWrapper.isAvailable().then((isAvailable) {
      if (isAvailable) {
        _inAppReviewWrapper.requestReview();
        _log.d('Requested review');
      }
    });
  }

  Future<void> _onLocalNotification(_) async {
    await _notificationManager.show(
      id: NotificationManager.idBackup,
      title: Strings.of(context).notificationErrorBackupTitle,
      body: Strings.of(context).notificationErrorBackupBody,
      details: NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationManager.androidChannelIdBackup,
          Strings.of(context).notificationChannelNameBackup,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}

class _BarItemModel {
  final _NavigatorPage? page;
  final IconData icon;
  final IconData activeIcon;
  final String title;

  _BarItemModel({
    required this.page,
    required this.icon,
    required this.activeIcon,
    required this.title,
  });
}

class _NavigatorPage extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget Function(BuildContext) builder;

  const _NavigatorPage({required this.navigatorKey, required this.builder});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) =>
          MaterialPageRoute(settings: settings, builder: builder),
    );
  }
}
