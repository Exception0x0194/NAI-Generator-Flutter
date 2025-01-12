import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nai_casrand/core/constants/image_formats.dart';
import 'package:nai_casrand/data/models/vibe_config.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class I2iTabViewmodel extends ChangeNotifier {
  List<VibeConfig> vibeConfigList;

  I2iTabViewmodel({
    required this.vibeConfigList,
  });

  void removeVibeConfigAt(int idx) {
    vibeConfigList.removeAt(idx);
    notifyListeners();
  }

  void addNewVibe() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    var newConfig = VibeConfig.fromBytes(bytes, 1.0, 0.3);
    vibeConfigList.add(newConfig);
    notifyListeners();
  }

  Future<void> handleVibeDropEvent(PerformDropEvent event) async {
    final item = event.session.items.first;
    final reader = item.dataReader!;
    reader.getFile(imageFormat, (file) async {
      final data = await file.readAll();
      vibeConfigList.add(VibeConfig.fromBytes(data, 1, 0.3));
    });
    notifyListeners();
  }
}
