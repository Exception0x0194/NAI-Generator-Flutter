import 'package:flutter/foundation.dart';
import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';

class PromptTabViewmodel extends ChangeNotifier {
  PromptConfig promptConfig;
  List<CharacterConfig> characterConfigList;

  PromptTabViewmodel(
      {required this.promptConfig, required this.characterConfigList});

  void reorderCharacter(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    var item = characterConfigList.removeAt(oldIndex);
    characterConfigList.insert(newIndex, item);
    notifyListeners();
  }

  void removeCharacter(int index) {
    characterConfigList.removeAt(index);
    notifyListeners();
  }

  void addCharacter() {
    if (characterConfigList.length >= 5) return;
    characterConfigList.add(CharacterConfig.fromEmpty());
    notifyListeners();
  }
}
