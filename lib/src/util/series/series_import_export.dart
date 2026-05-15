import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/locale_keys.g.dart';
import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../../model/series/series_type.dart';
import '../../providers/series_data_provider.dart';
import '../../providers/series_provider.dart';
import '../../providers/series_providers.dart';
import '../../store/migration/db_migration.dart';
import '../../store/migration/import_migration.dart';
import '../../widgets/administration/settings/settings_controller.dart';
import '../../widgets/controls/layout/single_child_scroll_view_with_scrollbar.dart';
import '../../widgets/controls/overlay/progress_overlay.dart';
import '../date_time_utils.dart';
import '../dialogs.dart';
import '../ex.dart';
import '../json_reader.dart';
import '../json_utils.dart';
import '../logging/flutter_simple_logging.dart';
import '../theme_utils.dart';

class SeriesImportExport {
  static Future<String> _readPickedFileAsString(PlatformFile file) async {
    final bytes = file.bytes;
    if (bytes != null) {
      return utf8.decode(bytes);
    }

    return file.xFile.readAsString(); // utf8
  }

  static Future<String> _buildSeriesExportCSV(SeriesDef seriesDef, BuildContext context) async {
    var seriesDataProvider = context.read<SeriesDataProvider>();
    await seriesDataProvider.fetchDataIfNotYetLoaded(seriesDef);
    var seriesData = seriesDataProvider.seriesData(seriesDef);
    if (seriesData == null) throw Ex("Failed to export series - no series data found for series '${seriesDef.name}'!"); // should never happen

    List<List<dynamic>> exportList = [];
    exportList.add(seriesDef.toCSVHeaderList());
    exportList.addAll(seriesData.toCSVLists(seriesDef));
    final csv = const ListToCsvConverter().convert(exportList);
    return csv;
  }

  static Future<Map<String, dynamic>> _buildSeriesExportJson(SeriesDef seriesDef, BuildContext context) async {
    var seriesDataProvider = context.read<SeriesDataProvider>();
    await seriesDataProvider.fetchDataIfNotYetLoaded(seriesDef);
    var seriesData = seriesDataProvider.seriesData(seriesDef);
    if (seriesData == null) throw Ex("Failed to export series - no series data found for series '${seriesDef.name}'!"); // should never happen

    Map<String, dynamic> json = {
      "seriesDef": seriesDef.toJson(),
      "seriesData": seriesData.toJson(exportUuid: false), // do not export value uuids - create new on import
      // type & version - could be used for parsing
      'type': 'seriesExport',
      'version': DbMigration.latestVersion,
    };
    return json;
  }

  static Future<Map<String, dynamic>> _buildAllSeriesExportJson(BuildContext context) async {
    List<Map<String, dynamic>> seriesList = [];
    Map<String, dynamic> json = {
      "series": seriesList,
      // type & version - could be used for parsing
      'type': 'multiSeriesExport',
      'version': DbMigration.latestVersion,
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

  static String _clearSeriesNameForExport(SeriesDef seriesDef) {
    var res = seriesDef.name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), ''); //remove underscore at start/end
    // fallback uuid
    if (res.isEmpty) res = seriesDef.uuid;
    return res;
  }

  static Future<void> _exportSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    try {
      bool exported = await JsonUtils.exportJsonFile(json, 'xtracker_${_clearSeriesNameForExport(seriesDef)}_${DateTimeUtils.formatExportDateTime()}.json');
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

  static Future<void> _exportSeriesDefCSV(SeriesDef seriesDef, BuildContext context) async {
    String json = await _buildSeriesExportCSV(seriesDef, context);
    try {
      var enc = const Utf8Encoder();
      Uint8List bytes = enc.convert(json);
      // https://pub.dev/packages/file_picker
      var selectedFile = await FilePicker.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'xtracker_${_clearSeriesNameForExport(seriesDef)}_${DateTimeUtils.formatExportDateTime()}.csv',
        type: FileType.custom,
        allowedExtensions: ["csv"],
        bytes: bytes,
      );
      var exported = selectedFile != null || kIsWeb; // in web no file select - just download
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
      bool shared = await JsonUtils.shareJsonFile(json, 'xtracker_${_clearSeriesNameForExport(seriesDef)}_${DateTimeUtils.formatExportDateTime()}.json');
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
      bool exported = await JsonUtils.exportJsonFile(json, 'xtracker_series_${DateTimeUtils.formatExportDateTime()}.json');
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
      bool shared = await JsonUtils.shareJsonFile(json, 'xtracker_series_${DateTimeUtils.formatExportDateTime()}.json');
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
  ///
  /// - throws [TypeError] in case of null values or not available properties in json
  /// - throws [Ex] in case of unexpected json
  static Future<bool> _importSeries(JsonReader json, String fileName, SeriesProviders seriesProviders) async {
    if (json.asReader("type").getString() == "seriesExport") {
      // check version...
      var seriesDef = SeriesDef.fromJson(json.asReader("seriesDef"));
      seriesDef.validate();
      SimpleLogging.i("Importing series and data for ${seriesDef.toLogString()} ...");
      var jSeriesData = json.asReader("seriesData");
      SeriesData seriesData;
      switch (seriesDef.seriesType) {
        case SeriesType.bloodPressure:
          seriesData = SeriesData.fromJsonBloodPressureData(jSeriesData, seriesDefUuid: seriesDef.uuid);
        case SeriesType.dailyCheck:
          seriesData = SeriesData.fromJsonDailyCheckData(jSeriesData, seriesDefUuid: seriesDef.uuid);
        case SeriesType.dailyLife:
          seriesData = SeriesData.fromJsonDailyLifeData(jSeriesData, seriesDefUuid: seriesDef.uuid);
        case SeriesType.habit:
          seriesData = SeriesData.fromJsonHabitData(jSeriesData, seriesDefUuid: seriesDef.uuid);
        case SeriesType.custom:
          seriesData = SeriesData.fromJsonCustomData(jSeriesData, seriesDefUuid: seriesDef.uuid);
        case SeriesType.monthly:
          seriesData = SeriesData.fromJsonMonthlyData(jSeriesData, seriesDefUuid: seriesDef.uuid);
      }

      if (seriesDef.uuid != seriesData.seriesDefUuid) {
        throw Ex(
          "Import failed - seriesDef.uuid and seriesData.seriesDefUuid mismatch in file: $fileName",
          localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [fileName]),
        );
      }

      await seriesProviders.seriesProvider.delete(seriesDef, seriesProviders);
      await seriesProviders.seriesProvider.save(seriesDef);
      await seriesProviders.seriesDataProvider.addValues(seriesDef, seriesData.data, seriesProviders.seriesCurrentValueProvider);
      SimpleLogging.i("Import for ${seriesDef.toLogString()} finished.");
      return true;
    } else {
      throw Ex(
        "Import failed - unexpected data structure in file: $fileName",
        localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [fileName]),
      );
    }
  }

  /// import series with data
  static Future<void> _importJsonFile(BuildContext context, SeriesProviders seriesProviders) async {
    FilePickerResult? result;
    try {
      // https://pub.dev/packages/file_picker
      result = await FilePicker.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        withData: kIsWeb,
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
    final files = result.files;
    int numSelectedFiles = files.length;

    List<String> failures = [];
    for (var file in files) {
      try {
        if (!file.name.endsWith(".json")) {
          throw Ex(
            "Import failed - unexpected file: ${file.name}",
            localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedFile.tr(args: [file.name]),
          );
        }
        SimpleLogging.i("importing '${file.name}' ...");
        var fileContent = await _readPickedFileAsString(file);
        var decoded = jsonDecode(fileContent);

        // migration
        decoded = ImportMigration.migrate(decoded, file.name);

        var json = JsonReader(decoded);

        var jType = json.asReader("type");
        if (jType.getString() == "multiSeriesExport") {
          // check version...
          for (var jSeries in json.asReader("series").asReaders()) {
            if (await _importSeries(jSeries, file.name, seriesProviders)) {
              successfulImports++;
            }
          }
        } else if (jType.getString() == "seriesExport") {
          if (await _importSeries(json, file.name, seriesProviders)) {
            successfulImports++;
          }
        } else {
          throw JsonParseException("Unexpected property value '${jType.getString()}' at ${jType.pathString}");
        }
      } catch (ex, st) {
        SimpleLogging.w("Series import failed - unexpected data structure in file: ${file.name}\n$ex", stackTrace: st);
        if (ex is Ex) {
          if (ex.localizedMessage != null) {
            failures.add(ex.localizedToString());
          } else {
            failures.add(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
          }
        } else {
          failures.add(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
        }
      }
    }

    overlay.remove();

    if (context.mounted && failures.isNotEmpty) {
      await Dialogs.simpleOkDialog(
        failures.join("\n\n"),
        context,
        title: LocaleKeys.seriesManagement_importExport_alert_import_title.tr(),
      );
    }

    if (successfulImports > 0) {
      SimpleLogging.i('Successfully imported $successfulImports series.');
      if (context.mounted) {
        Dialogs.showSnackBar(
          LocaleKeys.seriesManagement_importExport_snackbar_importSuccessfulXofY.tr(args: [successfulImports.toString(), numSelectedFiles.toString()]),
          context,
        );
      }
    }
  }

  /// import series with data from csv list
  /// - csv list with only data lists (header has to be removed)
  /// - throws [Ex] in case of unexpected data
  static Future<void> _importSeriesCSV(List<List<dynamic>> csv, String fileName, SeriesDef seriesDef, SeriesProviders seriesProviders) async {
    SimpleLogging.i("Importing series and data for ${seriesDef.toLogString()} ...");
    SeriesData seriesData;
    switch (seriesDef.seriesType) {
      case SeriesType.bloodPressure:
        seriesData = SeriesData.fromCSVBloodPressureData(seriesDef, csv);
      case SeriesType.dailyCheck:
        seriesData = SeriesData.fromCSVDailyCheckData(seriesDef, csv);
      case SeriesType.dailyLife:
        seriesData = SeriesData.fromCSVDailyLifeData(seriesDef, csv);
      case SeriesType.habit:
        seriesData = SeriesData.fromCSVHabitData(seriesDef, csv);
      case SeriesType.custom:
        seriesData = SeriesData.fromCSVCustomData(seriesDef, csv);
      case SeriesType.monthly:
        seriesData = SeriesData.fromCSVMonthlyData(seriesDef, csv);
    }

    await seriesProviders.seriesDataProvider.delete(seriesDef, seriesProviders.seriesCurrentValueProvider);
    await seriesProviders.seriesDataProvider.fetchData(seriesDef);
    await seriesProviders.seriesDataProvider.addValues(seriesDef, seriesData.data, seriesProviders.seriesCurrentValueProvider);
    SimpleLogging.i("Import for ${seriesDef.toLogString()} finished.");
  }

  // import series data from csv
  static Future<void> _importCSVFile(BuildContext context, SeriesDef seriesDef, SeriesProviders seriesProviders) async {
    FilePickerResult? result;
    try {
      // https://pub.dev/packages/file_picker
      result = await FilePicker.pickFiles(
        allowMultiple: false,
        type: FileType.any,
        withData: kIsWeb,
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
    final files = result.files;
    int numSelectedFiles = files.length;

    List<String> failures = [];

    if (files.length != 1) {
      throw Ex("Invalid amount of selected files");
    }

    for (var file in files) {
      try {
        if (!file.name.endsWith(".csv")) {
          throw Ex(
            "Import failed - unexpected file: ${file.name}",
            localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedFile.tr(args: [file.name]),
          );
        }

        SimpleLogging.i("importing '${file.name}' for series '${seriesDef.name}' ...");

        var fileContent = await _readPickedFileAsString(file);

        final csv = const CsvToListConverter().convert(fileContent);
        // remove empty lines
        csv.removeWhere((line) => line.isEmpty || line.length == 1 && ("" == line[0] || null == line[0]));
        if (csv.isEmpty) {
          throw Ex(
            "Series data import failed - unexpected (empty) data in file: ${file.name}",
            localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]),
          );
        }
        if (csv.length < 2) {
          throw Ex(
            "Series data import failed - unexpected data (invalid amount of lines) in file: ${file.name}",
            localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]),
          );
        }
        // check if first line matches series header
        var headerList = seriesDef.toCSVHeaderList();
        var csvHeaderList = csv.removeAt(0);
        bool headerEquals = csvHeaderList.length == headerList.length;
        if (headerEquals) {
          for (var i = 0; i < headerList.length; ++i) {
            var hVal = headerList[i];
            var csvVal = csvHeaderList[i];
            if (hVal != csvVal.toString()) {
              headerEquals = false;
              break;
            }
          }
        }
        if (!headerEquals) {
          throw Ex(
            "Series data import failed - unexpected data (header mismatch) in file: ${file.name}",
            localizedMessage: LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]),
          );
        }

        await _importSeriesCSV(csv, file.name, seriesDef, seriesProviders);
        successfulImports++;
      } catch (ex, st) {
        SimpleLogging.w(ex.toString(), stackTrace: st);
        if (ex is Ex) {
          failures.add(ex.localizedToString());
        } else {
          failures.add(LocaleKeys.seriesManagement_importExport_alert_unexpectedDataStructure.tr(args: [file.name]));
        }
      }
    }

    overlay.remove();

    if (context.mounted && failures.isNotEmpty) {
      await Dialogs.simpleOkDialog(
        failures.join("\n\n"),
        context,
        title: LocaleKeys.seriesManagement_importExport_alert_import_title.tr(),
      );
    }

    if (successfulImports > 0) {
      SimpleLogging.i('Successfully imported $successfulImports series.');
      if (context.mounted) {
        Dialogs.showSnackBar(
          LocaleKeys.seriesManagement_importExport_snackbar_importSuccessfulXofY.tr(args: [successfulImports.toString(), numSelectedFiles.toString()]),
          context,
        );
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
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSeriesCSVTip.tr()),
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
                await _exportSeriesDefCSV(seriesDef, context);
              },
              icon: Icon(Icons.download_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_exportSingleSeriesCSV.tr()),
            ),
            _LabelMedium(LocaleKeys.seriesManagement_importExport_label_exportSingleSeriesCSV.tr()),
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

          // all series csv tip
          if (seriesDef == null) _LabelMedium(LocaleKeys.seriesManagement_importExport_label_importSeriesCSVTip.tr()),
          // import single series csv data
          if (seriesDef != null) ...[
            ElevatedButton.icon(
              onPressed: () async {
                await _importCSVFile(context, seriesDef, seriesProviders);
              },
              icon: Icon(Icons.upload_outlined, size: ThemeUtils.iconSizeScaled),
              label: Text(LocaleKeys.seriesManagement_importExport_btn_importSeriesCSV.tr()),
            ),
            _LabelMedium(
              LocaleKeys.seriesManagement_importExport_label_importSeriesCSV.tr(
                args: [
                  seriesDef.name,
                  const ListToCsvConverter().convert([seriesDef.toCSVHeaderList()]),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    await Dialogs.simpleOkDialog(
      dialogContent,
      context,
      title: LocaleKeys.seriesManagement_importExport_title.tr(),
      buttonText: LocaleKeys.commons_dialog_btn_cancel.tr(),
    );
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
