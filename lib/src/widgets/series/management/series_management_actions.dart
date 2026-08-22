import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_current_value_provider.dart';
import '../../../providers/series_data_provider.dart';
import '../../../providers/series_providers.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/motion_utils.dart';
import '../../../util/series/series_import_export.dart';
import '../../../util/theme_utils.dart';
import '../../administration/settings/settings_controller.dart';
import '../../controls/popupmenu/icon_popup_menu.dart';

class SeriesManagementActions extends StatelessWidget {
  const SeriesManagementActions({super.key, required this.seriesDef, required this.settingsController});

  final SeriesDef seriesDef;
  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: ThemeUtils.screenPadding),
        child: Wrap(
          runAlignment: WrapAlignment.center,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _EditSeriesBtn(seriesDef: seriesDef),
            IconButton(
              iconSize: ThemeUtils.iconSizeScaled,
              tooltip: LocaleKeys.seriesDefRenderer_action_importExportSeries_tooltip.tr(),
              onPressed: () async => SeriesImportExport.showImportExportDlg(context, seriesDef: seriesDef, settingsController: settingsController),
              icon: const Icon(Icons.import_export_outlined),
            ),
            _SeriesMoreActionsMenu(seriesDef: seriesDef),
          ],
        ),
      ),
    );
  }
}

class _SeriesMoreActionsMenu extends StatelessWidget {
  const _SeriesMoreActionsMenu({required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: LocaleKeys.seriesDefRenderer_action_more_tooltip.tr(),
      child: IconPopupMenu(
        icon: const Icon(Icons.more_vert_outlined),
        menuEntries: [
          IconPopupMenuEntry(
            const Icon(Icons.highlight_remove_outlined),
            () => _clearSeriesData(context),
            LocaleKeys.seriesDefRenderer_action_deleteSeriesValues_tooltip.tr(),
          ),
          IconPopupMenuEntry(
            const Icon(Icons.close_outlined),
            () => _deleteSeries(context),
            LocaleKeys.seriesDefRenderer_action_deleteSeries_tooltip.tr(),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSeries(BuildContext context) async {
    SeriesProviders seriesProviders = SeriesProviders.readOf(context);

    bool? res = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesDefRenderer_query_deleteSeries.tr(args: [seriesDef.name]),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (res == true && context.mounted) {
      try {
        await seriesProviders.seriesProvider.delete(
          seriesDef,
          seriesProviders,
          removalDelay: MotionUtils.resolve(context, SeriesMutation.removalDelay),
        );
      } catch (err) {
        SimpleLogging.w("Failed to delete ${seriesDef.toLogString()}.", error: err);
        if (context.mounted) {
          Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_deleteFailed.tr(), context);
        }
      }
    }
  }

  Future<void> _clearSeriesData(BuildContext context) async {
    SeriesDataProvider seriesDataProvider = context.read<SeriesDataProvider>();
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();

    var result = await Dialogs.simpleYesNoDialog(
      LocaleKeys.seriesDefRenderer_query_deleteSeriesData.tr(args: [seriesDef.name]),
      context,
      title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
    );
    if (result == true) {
      await seriesDataProvider.delete(seriesDef, seriesCurrentValueProvider);
    }
  }
}

class _EditSeriesBtn extends StatelessWidget {
  const _EditSeriesBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    editHandler() async {
      /* SeriesDef? editedSeriesDef = */
      await SeriesDef.editSeries(seriesDef, context);
    }

    return IconButton(
      iconSize: ThemeUtils.iconSizeScaled,
      tooltip: LocaleKeys.seriesDefRenderer_action_editSeries_tooltip.tr(),
      onPressed: editHandler,
      icon: const Icon(Icons.edit_outlined),
    );
  }
}
