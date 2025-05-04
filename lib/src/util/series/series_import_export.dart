import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../model/series/data/series_data.dart';
import '../../model/series/series_def.dart';
import '../date_time_utils.dart';

class SeriesImportExport {
  static Future<String?> exportSeries(SeriesDef seriesDef, SeriesData seriesData) async {
    Map<String, dynamic> json = {
      "seriesDef": seriesDef.toJson(),
      "seriesData": seriesData.toJson(exportUuid: false), // do not export value uuids - create new on import
      // type & version - could be used for parsing
      'type': 'seriesExport',
      'version': SeriesDef.seriesDefVersionByType(seriesDef),
    };

    var enc = const Utf8Encoder();
    Uint8List bytes = enc.convert(jsonEncode(json));

    // https://pub.dev/packages/file_picker
    String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Please select an output file:',
        fileName: 'xtracker_series_${seriesDef.uuid}_${DateTimeUtils.formateExportDateTime()}.json',
        type: FileType.custom,
        allowedExtensions: ["json"],
        bytes: bytes);
    return outputFile;
  }
}
