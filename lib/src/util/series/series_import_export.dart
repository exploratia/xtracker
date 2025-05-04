import 'dart:convert';

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
import '../../widgets/layout/single_child_scroll_view_with_scrollbar.dart';
import '../date_time_utils.dart';
import '../dialogs.dart';
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

  static Future<void> _exportJsonFile(Map<String, dynamic> json, String fileName) async {
    var enc = const Utf8Encoder();
    Uint8List bytes = enc.convert(jsonEncode(json));

    // https://pub.dev/packages/file_picker
    await FilePicker.platform
        .saveFile(dialogTitle: 'Please select an output file:', fileName: fileName, type: FileType.custom, allowedExtensions: ["json"], bytes: bytes);
  }

  static Future<void> exportSeriesDef(SeriesDef seriesDef, BuildContext context) async {
    Map<String, dynamic>? json = await _buildSeriesExportJson(seriesDef, context);
    await _exportJsonFile(json, 'xtracker_series_${seriesDef.uuid}_${DateTimeUtils.formateExportDateTime()}.json');
  }

  /// export all series with data
  static Future<void> _exportSeries(BuildContext context) async {
    try {
      Map<String, dynamic> json = await _buildAllSeriesExportJson(context);
      await _exportJsonFile(json, 'xtracker_multi_series_export_${DateTimeUtils.formateExportDateTime()}.json');
      if (context.mounted) Dialogs.showSnackBar(LocaleKeys.series_management_importExport_dialog_msg_exportSuccessful.tr(), context);
    } catch (ex) {
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  /// import series with data from json
  static Future<void> _importSeries(Map<String, dynamic> json, BuildContext context) async {
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
        case SeriesType.monthly:
          // TODO: Handle this case.
          throw UnimplementedError();
        case SeriesType.free:
          // TODO: Handle this case.
          throw UnimplementedError();
      }
      await seriesProvider.delete(seriesDef, context);
      await seriesProvider.save(seriesDef);
      if (context.mounted) await seriesDataProvider.addValues(seriesDef, seriesData.data, context);
    } else {
      throw Exception(LocaleKeys.series_management_importExport_dialog_msg_error_unexpectedFileOrDataStructure.tr());
    }
  }

  /// import series with data
  static Future<void> _importJsonFile(BuildContext context) async {
    try {
      // https://pub.dev/packages/file_picker
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result != null) {
        // PlatformFile file = result.files.first;
        // print(file.name);
        // print(file.bytes);
        // print(file.size); // check file size?
        // print(file.extension);
        // print(file.path);

        for (var file in result.xFiles) {
          var fileContent = await file.readAsString(); // utf8
          var json = jsonDecode(fileContent) as Map<String, dynamic>;

          if (json["type"] as String == "multiSeriesExport") {
            // check version...
            List<dynamic> seriesList = json["series"] as List<dynamic>;
            for (var seriesJson in seriesList) {
              if (seriesJson is Map<String, dynamic>) {
                if (context.mounted) await _importSeries(seriesJson, context);
              } else {
                throw Exception(LocaleKeys.series_management_importExport_dialog_msg_error_unexpectedDataStructure.tr());
              }
            }
          } else if (json["type"] as String == "seriesExport") {
            if (context.mounted) await _importSeries(json, context);
          } else {
            throw Exception(LocaleKeys.series_management_importExport_dialog_msg_error_unexpectedFileOrDataStructure.tr());
          }
        }

        if (context.mounted) Dialogs.showSnackBar(LocaleKeys.series_management_importExport_dialog_msg_importSuccessful.tr(), context);
      } else {
        // User canceled the picker
      }
    } catch (ex, st) {
      SimpleLogging.w(ex.toString(), stackTrace: st);
      if (context.mounted) Dialogs.showSnackBar(ex.toString(), context);
    }
    if (context.mounted) Navigator.of(context).pop();
  }

  static Future<void> showImportExportDlg(BuildContext context) async {
    final themeData = Theme.of(context);
    Widget dialogContent = SingleChildScrollViewWithScrollbar(
      useScreenPadding: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
              onPressed: () async {
                await _exportSeries(context);
              },
              child: Text(LocaleKeys.series_management_importExport_dialog_btn_exportSeries.tr())),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.series_management_importExport_dialog_label_exportSeries.tr()),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.series_management_importExport_dialog_label_exportSeriesTip.tr()),
          const Divider(),
          ElevatedButton(
              onPressed: () async {
                await _importJsonFile(context);
              },
              child: Text(LocaleKeys.series_management_importExport_dialog_btn_importSeries.tr())),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.series_management_importExport_dialog_label_importSeries.tr()),
          Text(style: themeData.textTheme.labelMedium, LocaleKeys.series_management_importExport_dialog_label_importSeriesTip.tr()),
        ],
      ),
    );
    await Dialogs.simpleOkDialog(dialogContent, context,
        title: LocaleKeys.series_management_importExport_dialog_tile.tr(), buttonText: LocaleKeys.commons_dialog_btn_cancel.tr());
  }
}
