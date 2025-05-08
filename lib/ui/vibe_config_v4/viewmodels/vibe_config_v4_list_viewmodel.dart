import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For BuildContext and SnackBar
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:super_drag_and_drop/src/drop.dart';

import '../../../data/models/vibe_config_v4.dart';

class VibeConfigV4ListViewmodel extends ChangeNotifier {
  // Access the singleton list from GetIt
  List<VibeConfigV4> get vibeList => GetIt.I<PayloadConfig>().vibeConfigListV4;

  // Method to add a new config from a picked file
  Future<void> pickAndAddNewConfig(BuildContext context,
      {double initialReferenceStrength = 0.2}) async {
    int vibesAddedCount = 0;
    String message;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'naiv4vibe', 'naiv4vibebundle'],
        withData: true, // Crucial to get bytes directly
      );

      if (result != null && result.files.single.bytes != null) {
        PlatformFile file = result.files.single;
        String fileName = file.name;
        Uint8List fileBytes = file.bytes!;
        String? fileExtension = file.extension?.toLowerCase();

        if (fileExtension == 'png') {
          final newConfig = VibeConfigV4.fromPngBytes(
            fileName,
            fileBytes,
            initialReferenceStrength,
          );
          vibeList.add(newConfig);
          vibesAddedCount += 1;
          message = 'Added ${newConfig.fileName} from PNG.';
        } else if (fileExtension == 'naiv4vibe') {
          String jsonString = utf8.decode(fileBytes);
          Map<String, dynamic> jsonData =
              jsonDecode(jsonString) as Map<String, dynamic>;
          final newConfig = VibeConfigV4.fromNaiV4VibeJson(
            fileName, // 原始文件名
            jsonData,
            initialReferenceStrength,
          );
          vibeList.add(newConfig);
          vibesAddedCount += 1;
          message = 'Added ${newConfig.fileName} from .naiv4vibe file.';
        } else if (fileExtension == 'naiv4vibebundle') {
          String jsonString = utf8.decode(fileBytes);
          Map<String, dynamic> bundleJsonData =
              jsonDecode(jsonString) as Map<String, dynamic>;
          final vibesListJson = bundleJsonData['vibes'] as List<dynamic>?;
          if (vibesListJson == null || vibesListJson.isEmpty) {
            throw const FormatException(
                "No vibes found or 'vibes' array is missing in .naiv4vibebundle file.");
          }
          for (var vibeJsonEntry in vibesListJson) {
            if (vibeJsonEntry is Map<String, dynamic>) {
              try {
                final newConfig = VibeConfigV4.fromNaiV4VibeJson(
                  '$fileName#$vibesAddedCount',
                  vibeJsonEntry,
                  initialReferenceStrength,
                );
                vibeList.add(newConfig);
                vibesAddedCount++;
              } catch (e) {
                // Log error for individual vibe parsing and continue with others
                if (kDebugMode) {
                  print(
                      "Error parsing an individual vibe from bundle '$fileName': $e");
                }
              }
            }
          }
          if (vibesAddedCount > 0) {
            message =
                'Added $vibesAddedCount vibes from .naiv4vibebundle file.';
          } else {
            message =
                'No valid vibes successfully imported from .naiv4vibebundle file.';
          }
        } else {
          throw FormatException('Unsupported file type: $fileExtension');
        }

        notifyListeners(); // Notify UI to rebuild
        if (!context.mounted) return;
        showInfoBar(context, message);
      } else {
        // User canceled the picker or file had no data
        if (!context.mounted) return;
        showInfoBar(context, 'File selection canceled or file is empty.');
      }
    } catch (e) {
      // Handle errors from VibeConfigV4.fromPngBytes or file picking
      showErrorBar(context, 'Error adding vibe config: $e');
      if (kDebugMode) {
        print("Error picking/processing file: $e");
      }
    }
  }

  // Method to remove a config
  void removeConfig(VibeConfigV4 configToRemove) {
    final bool removed = vibeList.remove(configToRemove);
    if (removed) {
      notifyListeners(); // Notify UI to rebuild
    }
  }

  void removeConfigAtIndex(int index) {
    if (index >= 0 && index < vibeList.length) {
      vibeList.removeAt(index);
      notifyListeners();
    }
  }

  // Method to handle file drop event
  Future<void> handleVibeDropEvent(
    BuildContext context,
    PerformDropEvent event, {
    double initialReferenceStrength = 0.2,
  }) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;
    reader.getFile(null, (file) async {
      final fileBytes = await file.readAll();
      String fileName = file.fileName ?? 'Imported file';
      String? fileExtension = fileName.split('.').last;

      String message;
      int vibesAddedCount = 0;

      try {
        if (fileExtension == 'png') {
          final newConfig = VibeConfigV4.fromPngBytes(
            fileName,
            fileBytes,
            initialReferenceStrength,
          );
          vibeList.add(newConfig);
          vibesAddedCount += 1;
          message = 'Added ${newConfig.fileName} from PNG.';
        } else if (fileExtension == 'naiv4vibe') {
          String jsonString = utf8.decode(fileBytes);
          Map<String, dynamic> jsonData =
              jsonDecode(jsonString) as Map<String, dynamic>;
          final newConfig = VibeConfigV4.fromNaiV4VibeJson(
            fileName, // 原始文件名
            jsonData,
            initialReferenceStrength,
          );
          vibeList.add(newConfig);
          vibesAddedCount += 1;
          message = 'Added ${newConfig.fileName} from .naiv4vibe file.';
        } else if (fileExtension == 'naiv4vibebundle') {
          String jsonString = utf8.decode(fileBytes);
          Map<String, dynamic> bundleJsonData =
              jsonDecode(jsonString) as Map<String, dynamic>;
          final vibesListJson = bundleJsonData['vibes'] as List<dynamic>?;
          if (vibesListJson == null || vibesListJson.isEmpty) {
            throw const FormatException(
                "No vibes found or 'vibes' array is missing in .naiv4vibebundle file.");
          }
          for (var vibeJsonEntry in vibesListJson) {
            if (vibeJsonEntry is Map<String, dynamic>) {
              try {
                final newConfig = VibeConfigV4.fromNaiV4VibeJson(
                  '$fileName#$vibesAddedCount',
                  vibeJsonEntry,
                  initialReferenceStrength,
                );
                vibeList.add(newConfig);
                vibesAddedCount++;
              } catch (e) {
                // Log error for individual vibe parsing and continue with others
                if (kDebugMode) {
                  print(
                      "Error parsing an individual vibe from bundle '$fileName': $e");
                }
              }
            }
          }
          if (vibesAddedCount > 0) {
            message =
                'Added $vibesAddedCount vibes from .naiv4vibebundle file.';
          } else {
            message =
                'No valid vibes successfully imported from .naiv4vibebundle file.';
          }
        } else {
          throw FormatException('Unsupported file type: $fileExtension');
        }

        notifyListeners(); // Notify UI to rebuild
        if (!context.mounted) return;
        showInfoBar(context, message);
      } catch (e) {
        // Handle errors from VibeConfigV4.fromPngBytes or file picking
        if (!context.mounted) return;
        showErrorBar(context, 'Error adding vibe config: $e');
        if (kDebugMode) {
          print("Error picking/processing file: $e");
        }
      }
    });
  }
}
