import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:nai_casrand/core/constants/image_formats.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/utils/metadata.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import 'package:nai_casrand/data/models/i2i_config.dart';

class I2iVibeViewmodel extends ChangeNotifier {
  I2IConfig config;
  ParamConfig paramConfig;

  I2iVibeViewmodel({required this.config, required this.paramConfig});

  double get imageSize => 300.0;

  void setOverridePromptEnabled(bool? value) {
    if (value == null) return;
    config.overridePromptEnabled = value;
    notifyListeners();
  }

  void setOverridePrompt(String value) {
    config.overridePrompt = value;
    notifyListeners();
  }

  void removeImage() {
    config.imageB64 = null;
    notifyListeners();
  }

  addImage(BuildContext context) {}

  handleDragEvent(
    PerformDropEvent event,
    Function(Map<String, dynamic>) paramReadSuccessEvent,
    Function paramReadFailureEvent,
  ) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;
    reader.getFile(imageFormat, (file) async {
      final bytes = await file.readAll();
      await loadImageBytes(
        bytes,
        paramReadSuccessEvent,
        paramReadFailureEvent,
      );
      notifyListeners();
    });
  }

  Future<void> loadImageBytes(
    Uint8List bytes,
    Function(Map<String, dynamic>) paramReadSuccessEvent,
    Function paramReadFailureEvent,
  ) async {
    // Import image into I2I config
    config.setImage(bytes);

    // Skip metadata reading for images > 5M
    if (bytes.length > 5e6) return;

    // Try parse and import metadata
    final image = img.decodeImage(bytes);
    Map<String, dynamic>? parameters;
    try {
      final metadataString = await extractMetadata(image!);
      final Map<String, dynamic> metadata = json.decode(metadataString!);
      parameters = json.decode(metadata['Comment']);
    } catch (err) {
      paramReadFailureEvent();
      return;
    }
    if (parameters != null) {
      paramReadSuccessEvent(parameters);
    }
  }

  String getSizeChangeText() {
    final sizes = paramConfig.sizes
        .map((elem) => '${elem.width} x ${elem.height}')
        .join(" || ");
    final srcWidth = config.width;
    final srcHeight = config.height;
    final targetSize = '[$sizes]';
    final currentSize =
        config.imageB64 == null ? 'N/A' : '$srcWidth x $srcHeight';
    return '$currentSize → $targetSize';
  }

  double getEnhancePresetValue() {
    final s = config.strength;
    if (s <= 0.2) return 1;
    if (s <= 0.4) return 2;
    if (s <= 0.5) return 3;
    if (s <= 0.6) return 4;
    return 5;
  }

  void setPreset(double value) {
    final result = [
      [0.2, 0],
      [0.4, 0],
      [0.5, 0],
      [0.6, 0],
      [0.7, 0.1]
    ][value.toInt() - 1];
    config.strength = result[0].toDouble();
    config.noise = result[1].toDouble();
    notifyListeners();
  }

  void setStrength(double value) {
    config.strength = value;
    notifyListeners();
  }

  void setNoise(double value) {
    config.noise = value;
    notifyListeners();
  }
}
