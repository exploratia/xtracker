import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_current_value_provider.dart';
import '../../../providers/series_data_provider.dart';
import '../../../providers/series_providers.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/series/series_import_export.dart';
import '../../../util/theme_utils.dart';
import '../../administration/settings/settings_controller.dart';

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
              tooltip: LocaleKeys.seriesDefRenderer_action_importExportSeries_tooltip.tr(),
              onPressed: () async => SeriesImportExport.showImportExportDlg(context, seriesDef: seriesDef, settingsController: settingsController),
              iconSize: ThemeUtils.iconSizeScaled,
              icon: const Icon(Icons.import_export_outlined),
            ),
            _ClearSeriesDataBtn(seriesDef: seriesDef),
            _DeleteSeriesBtn(seriesDef: seriesDef),
          ],
        ),
      ),
    );
  }
}

class _DeleteSeriesBtn extends StatelessWidget {
  const _DeleteSeriesBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    SeriesProviders seriesProviders = SeriesProviders.readOf(context);

    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        LocaleKeys.seriesDefRenderer_query_deleteSeries.tr(args: [seriesDef.name]),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (res == true) {
        try {
          await seriesProviders.seriesProvider.delete(seriesDef, seriesProviders);
        } catch (err) {
          SimpleLogging.w("Failed to delete ${seriesDef.toLogString()}.", error: err);
          if (context.mounted) {
            Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_deleteFailed.tr(), context);
          }
        }
      }
    }

    return IconButton(
      tooltip: LocaleKeys.seriesDefRenderer_action_deleteSeries_tooltip.tr(),
      onPressed: deleteHandler,
      iconSize: ThemeUtils.iconSizeScaled,
      icon: const Icon(Icons.close_outlined),
    );
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
      tooltip: LocaleKeys.seriesDefRenderer_action_editSeries_tooltip.tr(),
      onPressed: editHandler,
      iconSize: ThemeUtils.iconSizeScaled,
      icon: const Icon(Icons.edit_outlined),
    );
  }
}

class _ClearSeriesDataBtn extends StatelessWidget {
  const _ClearSeriesDataBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    SeriesDataProvider seriesDataProvider = context.read<SeriesDataProvider>();
    SeriesCurrentValueProvider seriesCurrentValueProvider = context.read<SeriesCurrentValueProvider>();

    handler() async {
      var result = await Dialogs.simpleYesNoDialog(
        LocaleKeys.seriesDefRenderer_query_deleteSeriesData.tr(args: [seriesDef.name]),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (result == true) {
        await seriesDataProvider.delete(seriesDef, seriesCurrentValueProvider);
      }
    }

    return IconButton(
      tooltip: LocaleKeys.seriesDefRenderer_action_deleteSeriesValues_tooltip.tr(),
      onPressed: handler,
      iconSize: ThemeUtils.iconSizeScaled,
      icon: const Icon(Icons.highlight_remove_outlined),
    );
  }
}
