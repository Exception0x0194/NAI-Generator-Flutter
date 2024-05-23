import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

Future<void> saveBlob(List<int> bytes, String filename) async {
  if (kIsWeb) {
    // Web平台使用Blob进行下载
    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    var _ = html.AnchorElement(href: url)
      ..setAttribute("download", filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    // 移动/桌面平台使用文件系统
    saveBlobToExternalStorage(bytes, filename);
  }
}

Future<void> saveStringToFile(String content, String fileName) async {
  if (kIsWeb) {
    // Web平台使用Blob进行下载
    final bytes = Uint8List.fromList(utf8.encode(content));
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    var _ = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else {
    // 移动/桌面平台使用文件系统
    final directory = await getApplicationDocumentsDirectory(); // 获取文档目录的路径
    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
  }
}

Future<String> getExternalFilePath() async {
  final directory = await getExternalStorageDirectory(); // 获取外部存储目录的路径
  if (directory == null) {
    return "";
  }
  final targetPath = Directory('${directory.path}/Download/nai_output');
  if (!await targetPath.exists()) {
    await targetPath.create(recursive: true); // 如果路径不存在，则创建
  }
  return targetPath.path;
}

Future<void> saveBlobToExternalStorage(List<int> bytes, String filename) async {
  final path = await getExternalFilePath();
  final file = File('$path/$filename');
  await file.writeAsBytes(bytes);
}

String generateRandomFileName() {
  const length = 6;
  const lettersAndDigits = 'abcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();

  return List.generate(length,
          (index) => lettersAndDigits[random.nextInt(lettersAndDigits.length)])
      .join();
}
