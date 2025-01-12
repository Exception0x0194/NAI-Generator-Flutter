import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:saver_gallery/saver_gallery.dart';

class FileService {
  Future<void> savePictureToFile(
    Uint8List bytes,
    String fileName,
    String saveDir,
  ) async {
    if (kIsWeb) {
      // Web: download file as blob
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      var _ = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else if (Platform.isWindows) {
      // Windows: create save path and write file
      final Directory targetDir;
      if (saveDir.isEmpty) {
        targetDir = Directory(
            '${(await getApplicationDocumentsDirectory()).path}\\nai-generated');
      } else {
        targetDir = Directory(saveDir);
      }
      if (!await targetDir.exists()) targetDir.create();
      final file = File('${targetDir.path}\\$fileName');
      await file.writeAsBytes(bytes);
    } else if (Platform.isAndroid) {
      // Android: save as photo in Pictures/
      await _requestAlbumPermission();
      await SaverGallery.saveImage(
        bytes,
        name: fileName,
        androidRelativePath: "Pictures/nai-generated",
        androidExistNotSave: false,
      );
    }
  }

  Future<void> saveStringToFile(
    String content,
    String fileName,
  ) async {
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
      await FilePicker.platform.saveFile(
        fileName: fileName,
        bytes: utf8.encode(content),
      );
    }
  }

  String generateRandomString() {
    const length = 6;
    const lettersAndDigits = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();

    return List.generate(
        length,
        (index) =>
            lettersAndDigits[random.nextInt(lettersAndDigits.length)]).join();
  }

  String generateTimestampString(DateTime time) {
    return '${time.year}'
        '${time.month.toString().padLeft(2, '0')}'
        '${time.day.toString().padLeft(2, '0')}'
        '${time.hour.toString().padLeft(2, '0')}'
        '${time.minute.toString().padLeft(2, '0')}'
        '${time.second.toString().padLeft(2, '0')}';
  }

  Future<bool> _requestAlbumPermission() async {
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
}
