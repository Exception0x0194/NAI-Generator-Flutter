import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'package:image_save/image_save.dart';
import 'package:another_flushbar/flushbar.dart';

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
    await FilePicker.platform
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

void copyToClipboard(String content) async {
  await Clipboard.setData(ClipboardData(text: content));
}

void showInfoBar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    leftBarIndicatorColor: Colors.blue.shade300,
    icon: Icon(
      Icons.info_outline,
      size: 28.0,
      color: Colors.blue.shade300,
    ),
    message: message,
  ).show(context);
}

void showErrorBar(BuildContext context, String message) {
  Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(milliseconds: 1500),
    leftBarIndicatorColor: Colors.red.shade500,
    icon: Icon(
      Icons.error_outline,
      size: 28.0,
      color: Colors.red.shade500,
    ),
    message: message,
  ).show(context);
}

String getTimestampDigits(DateTime now) {
  return '${now.year}'
      '${now.month.toString().padLeft(2, '0')}'
      '${now.day.toString().padLeft(2, '0')}'
      '${now.hour.toString().padLeft(2, '0')}'
      '${now.minute.toString().padLeft(2, '0')}'
      '${now.second.toString().padLeft(2, '0')}';
}
