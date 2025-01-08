import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';

class PromptTabViewmodel {
  PromptConfig promptConfig;
  List<CharacterConfig> characterConfigList;

  PromptTabViewmodel(
      {required this.promptConfig, required this.characterConfigList});
}
