import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../model/series/series_def.dart';
import '../../store/stores.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../widgets/administration/notification_info_view.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/responsive/screen_builder.dart';

class NotificationInfoScreen extends StatefulWidget {
  static NavigationItem navItem = NavigationItem(
    iconData: Icons.notifications_active_outlined,
    routeName: '/notification_info_screen',
    titleBuilder: () => LocaleKeys.notificationInfo_title.tr(),
  );

  final SettingsController settingsController;

  const NotificationInfoScreen({super.key, required this.settingsController});

  @override
  State<NotificationInfoScreen> createState() => _NotificationInfoScreenState();
}

class _NotificationInfoScreenState extends State<NotificationInfoScreen> {
  List<SeriesDef> _series = const [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _loadSeries();
  }

  Future<void> _loadSeries() async {
    try {
      var series = await Stores.storeSeriesDef.getAllSeries();
      if (!mounted) return;
      setState(() {
        _series = series;
        _loading = false;
        _loadFailed = false;
      });
    } catch (err, st) {
      SimpleLogging.w('Could not load notification info.', error: err, stackTrace: st);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder.withStandardNavBuilders(
      navItem: NotificationInfoScreen.navItem,
      showWallpaper: widget.settingsController.showWallpaper,
      appBarBuilder: (context) => GradientAppBar.build(
        context,
        addLeadingBackBtn: true,
        title: Text(NotificationInfoScreen.navItem.titleBuilder()),
      ),
      bodyBuilder: (context) {
        if (_loading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_loadFailed) {
          return Center(child: Text(LocaleKeys.notificationInfo_label_loadFailed.tr()));
        }
        return NotificationInfoView(series: _series);
      },
    );
  }
}
