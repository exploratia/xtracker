import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../generated/locale_keys.g.dart';
import '../../../model/series/series_def.dart';
import '../../../providers/series_data_provider.dart';
import '../../../providers/series_provider.dart';
import '../../../util/dialogs.dart';

class SeriesManagementActions extends StatelessWidget {
  const SeriesManagementActions({super.key, required this.seriesDef});

  final SeriesDef seriesDef;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(color: seriesDef.color, width: 2, height: 40),
          _EditSeriesBtn(seriesDef: seriesDef),
          _ExportSeriesDataBtn(seriesDef: seriesDef),
          _ClearSeriesDataBtn(seriesDef: seriesDef),
          _DeleteSeriesBtn(seriesDef: seriesDef),
          if (!kIsWeb)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.drag_handle_outlined),
            ),
          if (kIsWeb) const SizedBox(width: 16),
        ],
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
      var enc = const Utf8Encoder();
      // TODO build json string from series + data / json encode?
      Uint8List bytes = enc.convert('{"a":1"}');

      // https://pub.dev/packages/file_picker
      String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: 'Please select an output file:', fileName: 'output-file.json', type: FileType.custom, allowedExtensions: ["json"], bytes: bytes);

      if (outputFile == null) {
        // User canceled the picker
      }
    }

    return IconButton(onPressed: handler, icon: const Icon(Icons.download_outlined));
  }
}
