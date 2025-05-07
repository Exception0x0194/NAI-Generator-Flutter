import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // For BuildContext and SnackBar
import 'package:get_it/get_it.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:super_drag_and_drop/src/drop.dart';

import '../../../core/constants/image_formats.dart';
import '../../../data/models/vibe_config_v4.dart';

class VibeConfigV4ListViewmodel extends ChangeNotifier {
  // Access the singleton list from GetIt
  List<VibeConfigV4> get vibeList => GetIt.I<PayloadConfig>().vibeConfigListV4;

  // Method to add a new config from a picked file
  Future<void> pickAndAddNewConfig(BuildContext context,
      {double initialReferenceStrength = 0.2}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png'],
        withData: true, // Crucial to get bytes directly
      );

      if (result != null && result.files.single.bytes != null) {
        PlatformFile file = result.files.single;
        String fileName = file.name;
        Uint8List fileBytes = file.bytes!;

        // Attempt to create VibeConfigV4 from the file bytes
        final newConfig = VibeConfigV4.fromPngBytes(
          fileName,
          fileBytes,
          initialReferenceStrength, // Provide an initial strength
        );

        vibeList.add(newConfig);
        notifyListeners(); // Notify UI to rebuild

        if (!context.mounted) return;
        showInfoBar(context, 'Added ${newConfig.fileName}');
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

  Future<void> handleVibeDropEvent(PerformDropEvent event) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;
    reader.getFile(imageFormat, (file) async {
      final data = await file.readAll();
      vibeList.add(VibeConfigV4.fromPngBytes(
        file.fileName ?? 'Unnamed Vibe',
        data,
        0.3,
      ));
    });
    notifyListeners();
  }
}
