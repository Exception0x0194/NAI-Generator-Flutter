import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:saver_gallery/saver_gallery.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:image/image.dart' as img;
import 'package:gzip/gzip.dart';

Future<bool> requestAlbumPermission() async {
  bool isGranted;
  if (Platform.isAndroid) {
    final deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.androidInfo;
    final sdkInt = deviceInfo.version.sdkInt;
    isGranted =
        sdkInt < 29 ? await Permission.storage.request().isGranted : true;
  } else {
    isGranted = await Permission.photosAddOnly.request().isGranted;
  }
  return isGranted;
}

Future<void> saveBlob(Uint8List bytes, String fileName,
    {Directory? saveDir}) async {
  if (kIsWeb) {
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    var _ = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  } else if (Platform.isWindows) {
    // Create save path
    final targetDir = saveDir ??
        Directory(
            '${(await getApplicationDocumentsDirectory()).path}\\nai-generated');
    if (!await targetDir.exists()) targetDir.create();
    final file = File('${targetDir.path}\\$fileName'); // 创建文件路径
    await file.writeAsBytes(bytes); // 写入文件
  } else if (Platform.isAndroid) {
    await requestAlbumPermission();
    await SaverGallery.saveImage(
      bytes,
      name: fileName,
      androidRelativePath: "Pictures/nai-generated",
      androidExistNotSave: false,
    );
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
  } else if (Platform.isWindows) {
    final path = await FilePicker.platform.saveFile(fileName: fileName);
    if (path == null) return;
    final file = File(path);
    await file.writeAsBytes(utf8.encode(content));
  } else if (Platform.isAndroid) {
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

List<double> getPossibleScaleFactors(int width, int height,
    {double step = 0.25}) {
  List<double> ret = [];
  const maxPixels = 2048 * 1536;
  for (double f = 1.0;; f += step) {
    int w = (f * width / 64).ceil() * 64;
    int h = (f * height / 64).ceil() * 64;
    if (w * h <= maxPixels) {
      ret.add(f);
    } else {
      break;
    }
  }
  return ret;
}

Future<img.Image> embedMetadata(img.Image image, String metadataString) async {
  final zipper = GZip();
  final magicBytes = utf8.encode("stealth_pngcomp");
  final encodedData = await zipper.compress(utf8.encode(metadataString));
  final bitLength = encodedData.length * 8;
  final bitLengthInBytes = ByteData(4);
  bitLengthInBytes.setInt32(0, bitLength);
  final dataToEmbed = [
    ...magicBytes,
    ...bitLengthInBytes.buffer.asUint8List(),
    ...encodedData
  ];

  var bitIndex = 0;
  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      final byteIndex = (bitIndex / 8).floor();
      if (byteIndex >= dataToEmbed.length) break;
      final bit = (dataToEmbed[byteIndex] >> (7 - bitIndex % 8)) & 1;
      final pixel = image.getPixel(x, y);
      pixel.a = 254 | bit;
      image.setPixel(x, y, pixel);
      bitIndex++;
    }
  }
  return image;
}

Future<String?> extractMetadata(img.Image image) async {
  final magicBytes = utf8.encode("stealth_pngcomp");
  final List<int> extractedBytes = [];
  int bitIndex = 0;
  int byteValue = 0;

  // 读取整个图片中的数据位
  for (var x = 0; x < image.width; x++) {
    for (var y = 0; y < image.height; y++) {
      final pixel = image.getPixel(x, y);
      final alpha = pixel.a as int;
      final bit = (alpha & 1);
      byteValue = (byteValue << 1) | bit;
      if (++bitIndex % 8 == 0) {
        extractedBytes.add(byteValue);
        byteValue = 0;
      }
    }
  }

  // 检查是否包含特定的魔法字节
  final magicByteLength = magicBytes.length;
  if (listEquals(extractedBytes.take(magicByteLength).toList(), magicBytes)) {
    // 读取数据长度
    final bitLengthBytes =
        extractedBytes.sublist(magicByteLength, magicByteLength + 4);
    final bitLength =
        ByteData.sublistView(Uint8List.fromList(bitLengthBytes)).getInt32(0);
    final dataLength = (bitLength / 8).ceil();

    // 读取实际数据并解压缩
    final compressedData = extractedBytes.sublist(
        magicByteLength + 4, magicByteLength + 4 + dataLength);
    final decompressor = GZip();
    final decodedData =
        await decompressor.decompress(Uint8List.fromList(compressedData));
    return utf8.decode(decodedData);
  }

  return null; // 如果没有找到特定的魔法字节
}
