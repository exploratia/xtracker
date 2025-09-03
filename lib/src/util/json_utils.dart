import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

class JsonUtils {
  static Future<bool> exportJsonFile(Map<String, dynamic> json, String fileName) async {
    var enc = const Utf8Encoder();
    Uint8List bytes = enc.convert(jsonEncode(json));

    // https://pub.dev/packages/file_picker
    var selectedFile = await FilePicker.platform
        .saveFile(dialogTitle: 'Please select an output file:', fileName: fileName, type: FileType.custom, allowedExtensions: ["json"], bytes: bytes);
    return selectedFile != null || kIsWeb; // in web no file select - just download
  }

  static Future<bool> shareJsonFile(Map<String, dynamic> json, String fileName) async {
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
}
