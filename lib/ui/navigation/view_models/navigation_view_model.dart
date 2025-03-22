import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/services/config_service.dart';

class NavigationViewModel extends ChangeNotifier {
  int currentPageIndex = 0;

  void changeIndex(int value) {
    // Save the config
    final config = GetIt.instance<PayloadConfig>();
    final service = GetIt.instance<ConfigService>();
    service.saveConfig(config.toJson());

    currentPageIndex = value;
  }
}
