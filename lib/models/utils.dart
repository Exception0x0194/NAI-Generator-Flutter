import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_save/image_save.dart';

Future<void> saveBlob(Uint8List bytes, String fileName) async {
  if (kIsWeb) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    var _ = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    ImageSave.saveImage(bytes, fileName, albumName: 'nai-generated');
  }
}

Future<void> saveStringToFile(String content, String fileName) async {
  if (kIsWeb) {
    final bytes = Uint8List.fromList(utf8.encode(content));
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    var _ = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    FilePicker.platform
        .saveFile(fileName: fileName, bytes: utf8.encode(content));
  }
}

String generateRandomFileName() {
  const length = 6;
  const lettersAndDigits = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();

  return List.generate(length,
          (index) => lettersAndDigits[random.nextInt(lettersAndDigits.length)])
      .join();
}
