import 'package:easy_localization/easy_localization.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../providers/series_provider.dart';
import '../../util/dialogs.dart';
import '../../util/logging/flutter_simple_logging.dart';
import '../../util/pending_app_actions.dart';
import '../administration/settings/settings_controller.dart';
import 'series_actions.dart';
import 'series_export_check.dart';

class PendingAppActionExecutor {
  /// Executes an action selected manually from the in-app message list.
  static Future<void> execute(
    BuildContext context,
    PendingAppAction action, {
    required SettingsController settingsController,
  }) async {
    if (!context.mounted) {
      return;
    }

    switch (action.type) {
      case PendingAppActionType.seriesValue:
        await _executeSeriesValueAction(context, action);
      case PendingAppActionType.backupReminder:
        await SeriesExportCheck.showReminderDialog(context, settingsController);
      case PendingAppActionType.debugDummy:
        Dialogs.showSnackBar(LocaleKeys.seriesDashboard_pendingActions_snackbar_testActionExecuted.tr(), context);
    }
  }

  /// Executes a series action explicitly requested by a Quick Action or notification tap.
  static Future<void> executeDirectSeriesAction(BuildContext context, PendingAppAction action) async {
    if (!action.isDirectSeriesAction) {
      SimpleLogging.w(
        'Ignored invalid direct app action. actionId=${action.id}, type=${action.type.name}, '
        'executeAutomatically=${action.executeAutomatically}, source=${action.seriesSource?.name}',
      );
      return;
    }

    if (!context.mounted) {
      return;
    }
    await _executeSeriesValueAction(context, action);
  }

  static Future<void> _executeSeriesValueAction(BuildContext context, PendingAppAction action) async {
    var seriesUuid = action.seriesUuid;
    if (seriesUuid == null) {
      SimpleLogging.w('Ignored pending series action without series uuid. actionId=${action.id}');
      return;
    }

    var seriesDef = context.read<SeriesProvider>().series.where((seriesDef) => seriesDef.uuid == seriesUuid).firstOrNull;
    if (seriesDef == null) {
      SimpleLogging.w('Ignored pending series action for missing series uuid: $seriesUuid');
      Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_loadFailed.tr(), context);
      return;
    }

    try {
      await SeriesActions.triggerValueAction(context, seriesDef);
    } catch (err) {
      SimpleLogging.w('Could not execute pending series action for ${seriesDef.toLogString()}', error: err);
      if (context.mounted) {
        Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_loadFailed.tr(), context);
      }
    }
  }
}
