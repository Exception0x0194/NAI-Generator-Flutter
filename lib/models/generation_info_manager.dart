import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_size_getter/image_size_getter.dart';

class GenerationInfo {
  Uint8List? _imageBytes;
  int width = 0, height = 0;

  Map<String, dynamic> details;

  GenerationInfo({required this.details, Uint8List? imageBytes}) {
    if (imageBytes != null) {
      _imageBytes = imageBytes;
      final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
      width = size.width;
      height = size.height;
    }
  }

  Uint8List? get imageBytes {
    return _imageBytes;
  }

  set imageBytes(Uint8List? imageBytes) {
    if (imageBytes == null) {
      _imageBytes = null;
      return;
    }
    _imageBytes = imageBytes;
    final size = ImageSizeGetter.getSize(MemoryInput(imageBytes));
    width = size.width;
    height = size.height;
  }
}

class GenerationInfoManager extends ChangeNotifier {
  // Info of generated images
  final List<GenerationInfo> _infoList = [];
  int _infoCurIdx = 0;
  int _infoCount = 0;
  final int _maxLength = 200;
  List<GenerationInfo> get generationInfos {
    return [
      ..._infoList.sublist(_infoCurIdx),
      ..._infoList.sublist(0, _infoCurIdx)
    ].reversed.toList();
  }

  int addNewInfo(GenerationInfo newInfo) {
    newInfo.details['idx'] = _infoCount;
    _infoCount++;
    final int ret;
    if (_infoList.length < _maxLength) {
      _infoList.add(newInfo);
      ret = _infoList.length - 1;
    } else {
      _infoList[_infoCurIdx] = newInfo;
      int addedIndex = _infoCurIdx;
      _infoCurIdx = (_infoCurIdx + 1) % _maxLength;
      ret = addedIndex;
    }
    notifyListeners();
    return ret;
  }
}
