import 'dart:math';

const toolTypes = [
  DirectorToolType(type: 'bg-removal', name: 'Remove BG'),
  DirectorToolType(type: 'lineart', name: 'Line Art'),
  DirectorToolType(type: 'sketch', name: 'Sketch'),
  DirectorToolType(type: 'colorize', name: 'Colorize'),
  DirectorToolType(type: 'emotion', name: 'Emotion'),
  DirectorToolType(type: 'declutter', name: 'Declutter')
];
const emotions = [
  'neutral',
  'happy',
  'sad',
  'angry',
  'scared',
  'surprised',
  'tired',
  'excited',
  'nervous',
  'thinking',
  'confused',
  'shy',
  'disgusted',
  'smug',
  'bored',
  'laughing',
  'irritated',
  'aroused',
  'embarrassed',
  'worried',
  'love',
  'determined',
  'hurt',
  'playful'
];

class DirectorToolType {
  final String type;
  final String name;

  const DirectorToolType({required this.type, required this.name});
}

class DirectorToolConfig {
  String? imageB64;

  String type = "emotion";
  List<String> emotions = ["neutral"];

  int width = 0;
  int height = 0;

  bool overrideEnabled = false;
  String overridePrompt = "";

  int defry = 0;

  bool get withPrompt {
    return ['colorize', 'emotion'].contains(type);
  }

  Map<String, dynamic> toJson() {
    return {
      "req_type": type,
      "emotion": emotions,
      "defry": defry,
      "width": width,
      "height": height,
      "image": imageB64,
      "override_enabled": overrideEnabled,
      "override_prompt": overridePrompt,
    };
  }

  Map<String, dynamic> getPayload() {
    if (withPrompt) {
      var prompt = type == "emotion"
          ? "${emotions[Random().nextInt(emotions.length)]};;"
          : "";
      if (overrideEnabled) prompt += overridePrompt;
      return {
        "req_type": type,
        "prompt": prompt,
        "defry": defry,
        "width": width,
        "height": height,
        "image": imageB64,
      };
    } else {
      return {
        "req_type": type,
        "width": width,
        "height": height,
        "image": imageB64,
      };
    }
  }

  DirectorToolConfig(
      {required this.type,
      required this.width,
      required this.height,
      required this.defry,
      this.imageB64});
}
