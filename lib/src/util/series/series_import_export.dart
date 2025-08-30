import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../providers/series_data_provider.dart';
import '../../providers/series_provider.dart';
import '../../widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../date_time_utils.dart';
import '../dialogs.dart';
import '../ex.dart';
import '../logging/flutter_simple_logging.dart';

class SeriesImportExport {
  static Future<Map<String, dynamic>> _buildSeriesExportJson(SeriesDef seriesDef, BuildContext context) async {
    var seriesDataProvider = context.read<SeriesDataProvider>();
    await seriesDataProvider.fetchDataIfNotYetLoaded(seriesDef);
    var seriesData = seriesDataProvider.seriesData(seriesDef);
    if (seriesData == null) throw Exception("Failed to export series - no series data found for series '${seriesDef.name}'!"); // should never happen

    Map<String, dynamic> json = {
      "seriesDef": seriesDef.toJson(),
      "seriesData": seriesData.toJson(exportUuid: false), // do not export value uuids - create new on import
      // type & version - could be used for parsing
      'type': 'seriesExport',
      'version': SeriesDef.seriesDefVersionByType(seriesDef),
    };
    return json;
  }

  static Future<Map<String, dynamic>> _buildAllSeriesExportJson(BuildContext context) async {
    List<Map<String, dynamic>> seriesList = [];
    Map<String, dynamic> json = {
      "series": seriesList,
      // type & version - could be used for parsing
      'type': 'multiSeriesExport',
      'version': 1, // initial
    };

    var seriesProvider = context.read<SeriesProvider>();

    await seriesProvider.fetchDataIfNotYetLoaded();
    var series = seriesProvider.series;

    for (var seriesDef in series) {
      if (context.mounted) {
        var seriesJson = await _buildSeriesExportJson(seriesDef, context);
        seriesList.add(seriesJson);
      }
    }

    return json;
  }

  static Future<bool> _exportJsonFile(Map<String, dynamic> json, String fileName) async {
    var enc = const Utf8Encoder();
    Uint8List bytes = enc.convert(jsonEncode(json));

    // https://pub.dev/packages/file_picker
    var selectedFile = await FilePicker.platform
        .saveFile(dialogTitle: 'Please select an output file:', fileName: fileName, type: FileType.custom, allowedExtensions: ["json"], bytes: bytes);
    return selectedFile != null || kIsWeb; // in web no file select - just download
  }

  static Future<bool> _shareJsonFile(Map<String, dynamic> json, String fileName) async {
    var enc = const Utf8Encoder();
    Uint8List bytes = enc.convert(jsonEncode(json));

    XFile file = XFile.fromData(
      bytes,
      name: fileName,
      mimeType: 'application/json',
    );

    final result = await SharePlus.instance.share(ShareParams(files: [file], text: fileName, fileNameOverrides: [fileName]));
    return (result.status == ShareResultStatus.success);
  }

  static Future<void> _exportSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    try {
      bool exported = await _exportJsonFile(json, 'xtracker_series_export_${seriesDef.uuid}_${DateTimeUtils.formateExportDateTime()}.json');
      if (exported) {
        SimpleLogging.i('Successfully exported ${seriesDef.toLogString()}');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.seriesManagement_importExport_snackbar_exportSuccessful.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w("Failed to export ${seriesDef.toLogString()}.", error: ex);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> _shareSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    try {
      bool shared = await _shareJsonFile(json, 'xtracker_series_export_${seriesDef.uuid}_${DateTimeUtils.formateExportDateTime()}.json');
      if (shared) {
        SimpleLogging.i('Successfully shared ${seriesDef.toLogString()}');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.seriesManagement_importExport_snackbar_exportSuccessful.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w('Failed to share series ${seriesDef.toLogString()}.', error: ex);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  /// export all series with data
  static Future<void> _exportSeries(BuildContext context) async {
    try {
      Map<String, dynamic> json = await _buildAllSeriesExportJson(context);
      bool exported = await _exportJsonFile(json, 'xtracker_multi_series_export_${DateTimeUtils.formateExportDateTime()}.json');
      if (exported) {
        SimpleLogging.i('Successfully exported all series.');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.seriesManagement_importExport_snackbar_exportSuccessful.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w('Failed to exported all series!', error: ex);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> _shareSeries(BuildContext context) async {
    try {
      Map<String, dynamic> json = await _buildAllSeriesExportJson(context);
      bool shared = await _shareJsonFile(json, 'xtracker_multi_series_export_${DateTimeUtils.formateExportDateTime()}.json');
      if (shared) {
        SimpleLogging.i('Successfully shared all series.');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.seriesManagement_importExport_snackbar_exportSuccessful.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w('Failed to shared all series!', error: ex);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  /// import series with data from json
  static Future<bool> _importSeries(Map<String, dynamic> json, String fileName, BuildContext context) async {
    if (json["type"] as String == "seriesExport") {
      var seriesProvider = context.read<SeriesProvider>();
      var seriesDataProvider = context.read<SeriesDataProvider>();
      // check version...
      var seriesDef = SeriesDef.fromJson(json["seriesDef"] as Map<String, dynamic>);
      SeriesData seriesData;
      switch (seriesDef.seriesType) {
        case SeriesType.bloodPressure:
          seriesData = SeriesData.fromJsonBloodPressureData(json["seriesData"] as Map<String, dynamic>);
        case SeriesType.dailyCheck:
          seriesData = SeriesData.fromJsonDailyCheckData(json["seriesData"] as Map<String, dynamic>);
        case SeriesType.habit:
          seriesData = SeriesData.fromJsonHabitData(json["seriesData"] as Map<String, dynamic>);
      }
      await seriesProvider.delete(seriesDef, context);
      await seriesProvider.save(seriesDef);
      if (context.mounted) await seriesDataProvider.addValues(seriesDef, seriesData.data, context);
      return true;
    } else {
      throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [fileName]));
    }
  }

  /// import series with data
  static Future<void> _importJsonFile(BuildContext context) async {
    FilePickerResult? result;
    try {
      // https://pub.dev/packages/file_picker
      result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        // allowedExtensions: ['json'], // not possible // https://github.com/miguelpruivo/flutter_file_picker/issues/1717
      );
    } catch (ex, st) {
      SimpleLogging.w(ex.toString(), stackTrace: st);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (result == null) return; // User canceled the picker

    // PlatformFile file = result.files.first;
    // print(file.name);
    // print(file.bytes);
    // print(file.size); // check file size?
    // print(file.extension);
    // print(file.path);

    int successfulImports = 0;
    int numSelectedFiles = result.xFiles.length;

    for (var file in result.xFiles) {
      try {
        if (!file.name.endsWith(".json")) {
          throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedFile.tr(args: [file.name]));
        }

        var fileContent = await file.readAsString(); // utf8
        var json = jsonDecode(fileContent) as Map<String, dynamic>;

        if (json["type"] as String == "multiSeriesExport") {
          // check version...
          List<dynamic> seriesList = json["series"] as List<dynamic>;
          for (var seriesJson in seriesList) {
            if (seriesJson is Map<String, dynamic>) {
              if (context.mounted) {
                if (await _importSeries(seriesJson, file.name, context)) {
                  successfulImports++;
                }
              }
            } else {
              throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
            }
          }
        } else if (json["type"] as String == "seriesExport") {
          if (context.mounted) {
            if (await _importSeries(json, file.name, context)) {
              successfulImports++;
            }
          }
        } else {
          throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
        }
      } catch (ex, st) {
        SimpleLogging.w(ex.toString(), stackTrace: st);
        if (context.mounted) {
          if (ex is Ex) {
            await Dialogs.simpleOkDialog(ex.toString(), context);
          } else {
            await Dialogs.simpleOkDialog(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]), context);
          }
        }
      }
    }

    if (context.mounted && successfulImports > 0) {
      SimpleLogging.i('Successfully imported $successfulImports series.');
      Dialogs.showSnackBar(
          LocaleKeys.seriesManagement_importExport_snackbar_importSuccessfulXofY.tr(args: [successfulImports.toString(), numSelectedFiles.toString()]),
          context);
    }

    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> showImportExportDlg(BuildContext context, {SeriesDef? seriesDef}) async {
    final themeData = Theme.of(context);

    bool exportPossible = context.read<SeriesProvider>().series.isNotEmpty;

    Widget dialogContent = SingleChildScrollViewWithScrollbar(
      useScreenPadding: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // all series
          if (seriesDef == null) ...[
            ElevatedButton.icon(
              onPressed: exportPossible
                  ? () async {
                      await _exportSeries(context);
                    }
                  : null,
              icon: const Icon(Icons.download_outlined),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_exportSeries.tr()),
            ),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_exportSeries.tr()),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_exportSeriesTip.tr()),
            ElevatedButton.icon(
              onPressed: exportPossible
                  ? () async {
                      await _shareSeries(context);
                    }
                  : null,
              icon: const Icon(Icons.share_outlined),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_shareSeries.tr()),
            ),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_shareSeries.tr()),
          ],
          // single series
          if (seriesDef != null) ...[
            ElevatedButton.icon(
              onPressed: () async {
                await _exportSeriesDef(seriesDef, context);
              },
              icon: const Icon(Icons.download_outlined),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_exportSingleSeries.tr()),
            ),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_exportSingleSeries.tr()),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_exportSingleSeriesTip.tr()),
            ElevatedButton.icon(
              onPressed: () async {
                await _shareSeriesDef(seriesDef, context);
              },
              icon: const Icon(Icons.share_outlined),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_shareSingleSeries.tr()),
            ),
            Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_shareSingleSeries.tr()),
          ],

          // import
          const Divider(),
          ElevatedButton.icon(
            onPressed: () async {
              await _importJsonFile(context);
            },
            icon: const Icon(Icons.upload_outlined),
            label: Text(LocaleKeys.seriesManagement_importExport_btn_importSeries.tr()),
          ),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_importSeries.tr()),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.seriesManagement_importExport_label_importSeriesTip.tr()),
        ],
      ),
    );

    await Dialogs.simpleOkDialog(dialogContent, context,
        title: LocaleKeys.seriesManagement_importExport_title.tr(), buttonText: LocaleKeys.commons_dialog_btn_cancel.tr());
  }
}
