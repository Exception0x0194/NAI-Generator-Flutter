import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/payload_config.dart';

class I2iTabViewmodel extends ChangeNotifier {
  ParamConfig get paramConfig => GetIt.I<PayloadConfig>().paramConfig;
  bool get isV4 => paramConfig.model.contains('-4-');
}
