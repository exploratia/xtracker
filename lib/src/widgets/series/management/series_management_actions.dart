import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_data_provider.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';
import '../../../util/logging/flutter_simple_logging.dart';
import '../../../util/series/series_import_export.dart';

class SeriesManagementActions extends StatelessWidget {
  const SeriesManagementActions({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _EditSeriesBtn(seriesDef: seriesDef),
            _ExportSeriesDataBtn(seriesDef: seriesDef),
            _ShareSeriesDataBtn(seriesDef: seriesDef),
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
    deleteHandler() async {
      bool? res = await Dialogs.simpleYesNoDialog(
        LocaleKeys.series_dialog_msg_query_deleteSeries.tr(args: [seriesDef.name]),
        context,
        title: LocaleKeys.commons_dialog_title_areYouSure.tr(),
      );
      if (res == true) {
        try {
          if (context.mounted) {
            await context.read<SeriesProvider>().delete(seriesDef, context);
          }
        } catch (err) {
          SimpleLogging.w("Failed to delete ${seriesDef.toLogString()}.", error: err);
          if (context.mounted) {
            Dialogs.simpleErrOkDialog('$err', context);
          }
        }
      }
    }

    return IconButton(onPressed: deleteHandler, icon: const Icon(Icons.close_outlined));
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

    return IconButton(onPressed: editHandler, icon: const Icon(Icons.edit_outlined));
  }
}

class _ClearSeriesDataBtn extends StatelessWidget {
  const _ClearSeriesDataBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    handler() async {
      var result = await Dialogs.simpleYesNoDialog(LocaleKeys.series_data_dialog_msg_query_deleteSeriesData.tr(args: [seriesDef.name]), context);
      if (result != null && result && context.mounted) {
        await context.read<SeriesDataProvider>().delete(seriesDef, context);
      }
    }

    return IconButton(onPressed: handler, icon: const Icon(Icons.highlight_remove_outlined));
  }
}

class _ExportSeriesDataBtn extends StatelessWidget {
  const _ExportSeriesDataBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    handler() async {
      try {
        await SeriesImportExport.exportSeriesDef(seriesDef, context);
      } catch (ex) {
        SimpleLogging.w("Failed to export ${seriesDef.toLogString()}.", error: ex);
        if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
      }
    }

    return IconButton(onPressed: handler, icon: const Icon(Icons.download_outlined));
  }
}

class _ShareSeriesDataBtn extends StatelessWidget {
  const _ShareSeriesDataBtn({
    required this.seriesDef,
  });

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    handler() async {
      try {
        await SeriesImportExport.shareSeriesDef(seriesDef, context);
      } catch (ex) {
        SimpleLogging.w("Failed to share ${seriesDef.toLogString()}.", error: ex);
        if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
      }
    }

    return IconButton(onPressed: handler, icon: const Icon(Icons.share_outlined));
  }
}
