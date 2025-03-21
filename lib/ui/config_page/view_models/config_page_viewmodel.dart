import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';

class ConfigPageViewmodel {
  PayloadConfig get payloadConfig => GetIt.I();

  ConfigPageViewmodel();
}
