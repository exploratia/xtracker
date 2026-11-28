import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/navigation/navigation_item.dart';
import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../widgets/administration/notification_info_view.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/controls/appbar/gradient_app_bar.dart';
import '../../widgets/controls/provider/data_provider_loader.dart';
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
  Future<void> _refreshSeries() async {
    try {
      await context.read<SeriesProvider>().fetchData();
    } catch (e, st) {
      SimpleLogging.w('Failure on refresh notification info.', error: e, stackTrace: st);
      if (mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_loadFailed.tr(), context);
      }
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
      bodyBuilder: (context) => DataProviderLoader(
        obtainDataProviderFuture: context.read<SeriesProvider>().fetchDataIfNotYetLoaded(),
        child: Consumer<SeriesProvider>(
          builder: (_, seriesProvider, _) => NotificationInfoView(
            series: seriesProvider.series,
            onRefreshCallback: _refreshSeries,
          ),
        ),
      ),
    );
  }
}
