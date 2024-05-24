import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:simple_file_saver/simple_file_saver.dart';


Future<void> saveBlob(Uint8List bytes, String fileName) async {
  await SimpleFileSaver.saveFile(
      fileInfo: FileSaveInfo.fromBytes(
        bytes: bytes,
        basename: fileName,
        extension: '',
      ),
      saveAs: false);
}

Future<void> saveStringToFile(String content, String fileName) async {
  // String? path = await FilePicker.platform
  //     .saveFile(fileName: fileName, bytes: utf8.encode(content));
  await SimpleFileSaver.saveFile(
      fileInfo: FileSaveInfo.fromBytes(
        bytes: utf8.encode(content),
        basename: fileName,
        extension: '',
      ),
      saveAs: true);
}

String generateRandomFileName() {
  const length = 6;
  const lettersAndDigits = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();

  return List.generate(length,
          (index) => lettersAndDigits[random.nextInt(lettersAndDigits.length)])
      .join();
}
