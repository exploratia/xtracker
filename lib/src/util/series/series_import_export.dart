import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../providers/series_data_provider.dart';
import '../../providers/series_provider.dart';
import '../../providers/series_providers.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../widgets/controls/overlay/progress_overlay.dart';
import '../date_time_utils.dart';
import '../dialogs.dart';
import '../ex.dart';
import '../json_utils.dart';
import '../logging/flutter_simple_logging.dart';
import '../theme_utils.dart';

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

  static Future<void> _exportSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    try {
      bool exported = await JsonUtils.exportJsonFile(json, 'xtracker_series_export_${seriesDef.uuid}_${DateTimeUtils.formatExportDateTime()}.json');
      if (exported) {
        SimpleLogging.i('Successfully exported ${seriesDef.toLogString()}');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_exportSuccess.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w("Failed to export ${seriesDef.toLogString()}.", error: ex);
      if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_exportFailed, context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> _shareSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    try {
      bool shared = await JsonUtils.shareJsonFile(json, 'xtracker_series_export_${seriesDef.uuid}_${DateTimeUtils.formatExportDateTime()}.json');
      if (shared) {
        SimpleLogging.i('Successfully shared ${seriesDef.toLogString()}');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_shareSuccess.tr(), context);
      }
    } catch (ex) {
      SimpleLogging.w('Failed to share series ${seriesDef.toLogString()}.', error: ex);
      if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_shareFailed, context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  /// export all series with data
  static Future<void> _exportSeries(BuildContext context, VoidCallback afterExport) async {
    try {
      Map<String, dynamic> json = await _buildAllSeriesExportJson(context);
      bool exported = await JsonUtils.exportJsonFile(json, 'xtracker_multi_series_export_${DateTimeUtils.formatExportDateTime()}.json');
      if (exported) {
        SimpleLogging.i('Successfully exported all series.');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_exportSuccess.tr(), context);
        afterExport();
      }
    } catch (ex) {
      SimpleLogging.w('Failed to exported all series!', error: ex);
      if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_exportFailed, context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> _shareSeries(BuildContext context, VoidCallback afterExport) async {
    try {
      Map<String, dynamic> json = await _buildAllSeriesExportJson(context);
      bool shared = await JsonUtils.shareJsonFile(json, 'xtracker_multi_series_export_${DateTimeUtils.formatExportDateTime()}.json');
      if (shared) {
        SimpleLogging.i('Successfully shared all series.');
        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.commons_snackbar_shareSuccess.tr(), context);
        afterExport();
      }
    } catch (ex) {
      SimpleLogging.w('Failed to shared all series!', error: ex);
      if (context.mounted) Dialogs.showSnackBarWarning(LocaleKeys.commons_snackbar_shareFailed, context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  /// import series with data from json
  static Future<bool> _importSeries(Map<String, dynamic> json, String fileName, SeriesProviders seriesProviders) async {
    if (json["type"] as String == "seriesExport") {
      // check version...
      var seriesDef = SeriesDef.fromJson(json["seriesDef"] as Map<String, dynamic>);
      SimpleLogging.i("Importing series and data for ${seriesDef.toLogString()} ...");
      SeriesData seriesData;
      switch (seriesDef.seriesType) {
        case SeriesType.bloodPressure:
          seriesData = SeriesData.fromJsonBloodPressureData(json["seriesData"] as Map<String, dynamic>);
        case SeriesType.dailyCheck:
          seriesData = SeriesData.fromJsonDailyCheckData(json["seriesData"] as Map<String, dynamic>);
        case SeriesType.dailyLife:
          seriesData = SeriesData.fromJsonDailyLifeData(json["seriesData"] as Map<String, dynamic>);
        case SeriesType.habit:
          seriesData = SeriesData.fromJsonHabitData(json["seriesData"] as Map<String, dynamic>);
      }
      await seriesProviders.seriesProvider.delete(seriesDef, seriesProviders);
      await seriesProviders.seriesProvider.save(seriesDef);
      await seriesProviders.seriesDataProvider.addValues(seriesDef, seriesData.data, seriesProviders.seriesCurrentValueProvider);
      SimpleLogging.i("Import for ${seriesDef.toLogString()} finished.");
      return true;
    } else {
      throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [fileName]));
    }
  }

  /// import series with data
  static Future<void> _importJsonFile(BuildContext context, SeriesProviders seriesProviders) async {
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
      if (context.mounted) Dialogs.showSnackBar("Failure while choosing import file.", context);
    }
    if (result == null) return; // User canceled the picker

    if (!context.mounted) return;
    // already hide dialog -> the series could be seen while importing
    Navigator.of(context).pop();

    // PlatformFile file = result.files.first;
    // print(file.name);
    // print(file.bytes);
    // print(file.size); // check file size?
    // print(file.extension);
    // print(file.path);

    final overlay = ProgressOverlay.createAndShowProgressOverlay(context);
    int successfulImports = 0;
    int numSelectedFiles = result.xFiles.length;

    for (var file in result.xFiles) {
      try {
        if (!file.name.endsWith(".json")) {
          throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedFile.tr(args: [file.name]));
        }

        SimpleLogging.i("importing ${file.name} ...");
        var fileContent = await file.readAsString(); // utf8
        var json = jsonDecode(fileContent) as Map<String, dynamic>;

        if (json["type"] as String == "multiSeriesExport") {
          // check version...
          List<dynamic> seriesList = json["series"] as List<dynamic>;
          for (var seriesJson in seriesList) {
            if (seriesJson is Map<String, dynamic>) {
              if (await _importSeries(seriesJson, file.name, seriesProviders)) {
                successfulImports++;
              }
            } else {
              throw Ex(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
            }
          }
        } else if (json["type"] as String == "seriesExport") {
          if (await _importSeries(json, file.name, seriesProviders)) {
            successfulImports++;
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

    overlay.remove();

    if (successfulImports > 0) {
      SimpleLogging.i('Successfully imported $successfulImports series.');
      if (context.mounted) {
        Dialogs.showSnackBar(
            LocaleKeys.seriesManagement_importExport_snackbar_importSuccessfulXofY.tr(args: [successfulImports.toString(), numSelectedFiles.toString()]),
            context);
      }
    }
  }

  static Future<void> showImportExportDlg(BuildContext context, {SeriesDef? seriesDef, required SettingsController settingsController}) async {
    SeriesProviders seriesProviders = SeriesProviders.readOf(context);
    bool exportPossible = seriesProviders.seriesProvider.series.isNotEmpty;

    Widget dialogContent = SingleChildScrollViewWithScrollbar(
      useHorizontalScreenPaddingForScrollbar: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: ThemeUtils.verticalSpacing,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // all series
          if (seriesDef == null) ...[
            ListenableBuilder(
              listenable: settingsController,
              builder: (context, child) {
                String lastExport = buildLastExportDateStr(settingsController);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _LabelMedium(LocaleKeys.seriesManagement_importExport_label_latestSeriesExport.tr(args: [lastExport])),
                  ],
                );
              },
            ),
            ElevatedButton.icon(
              onPressed: exportPossible
                  ? () async {
                      await _exportSeries(context, settingsController.updateSeriesExportDate);
                    }
                  : null,
              icon: Icon(Icons.download_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_exportSeries.tr()),
            ),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSeries.tr()),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSeriesTip.tr()),
            ElevatedButton.icon(
              onPressed: exportPossible
                  ? () async {
                      await _shareSeries(context, settingsController.updateSeriesExportDate);
                    }
                  : null,
              icon: Icon(Icons.share_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_shareSeries.tr()),
            ),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_shareSeries.tr()),
          ],
          // single series
          if (seriesDef != null) ...[
            ElevatedButton.icon(
              onPressed: () async {
                await _exportSeriesDef(seriesDef, context);
              },
              icon: Icon(Icons.download_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_exportSingleSeries.tr()),
            ),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSingleSeries.tr()),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSingleSeriesTip.tr()),
            ElevatedButton.icon(
              onPressed: () async {
                await _shareSeriesDef(seriesDef, context);
              },
              icon: Icon(Icons.share_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_shareSingleSeries.tr()),
            ),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_shareSingleSeries.tr()),
          ],

          // import
          const Divider(),
          ElevatedButton.icon(
            onPressed: () async {
              await _importJsonFile(context, seriesProviders);
            },
            icon: Icon(Icons.upload_outlined, size: ThemeUtils.iconSizeScaled),
            label: Text(LocaleKeys.seriesManagement_importExport_btn_importSeries.tr()),
          ),
          _LabelMedium(LocaleKeys.seriesManagement_importExport_label_importSeries.tr()),
          _LabelMedium(LocaleKeys.seriesManagement_importExport_label_importSeriesTip.tr()),
        ],
      ),
    );

    await Dialogs.simpleOkDialog(dialogContent, context,
        title: LocaleKeys.seriesManagement_importExport_title.tr(), buttonText: LocaleKeys.commons_dialog_btn_cancel.tr());
  }

  static String buildLastExportDateStr(SettingsController settingsController) {
    DateTime? lastExportDate = settingsController.seriesExportDate;
    String lastExport = "-";
    if (lastExportDate != null) {
      lastExport = DateTimeUtils.formatDate(lastExportDate);
    }
    return lastExport;
  }
}

class _LabelMedium extends StatelessWidget {
  const _LabelMedium(this.txt);

  final String txt;

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    var txtStyleLabelMedium = themeData.textTheme.labelMedium;
    return Text(style: txtStyleLabelMedium, txt);
  }
}
