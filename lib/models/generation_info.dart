import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';

class GenerationInfo {
  Image? _displayImage;
  Map<String, dynamic> displayInfo;

  int? width, height;

  GenerationInfo({required this.displayInfo, Uint8List? imageBytes}) {
    if (imageBytes != null) {
      _displayImage = Image.memory(imageBytes);
      final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
      width = size.width;
      height = size.height;
    }
  }

  Image? get displayImage {
    return _displayImage;
  }

  void setImage(Uint8List? imageBytes) {
    if (imageBytes == null) {
      _displayImage = null;
      width = height = null;
      return;
    }
    _displayImage = Image.memory(imageBytes);
    final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
    width = size.width;
    height = size.height;
  }
}
