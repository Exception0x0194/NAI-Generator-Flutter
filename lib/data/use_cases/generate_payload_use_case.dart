import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/data/models/vibe_config.dart';

const Map<int, String> xMapping = {
  0: 'X',
  1: 'A',
  2: 'B',
  3: 'C',
  4: 'D',
  5: 'E',
};

const Map<int, double> doubleMapping = {
  0: 0.0,
  1: 0.1,
  2: 0.3,
  3: 0.5,
  4: 0.7,
  5: 0.9
};

class PayloadGenerationResult {
  Map<String, dynamic> payload;
  String comment;
  String suggestedFileName;

  PayloadGenerationResult({
    required this.payload,
    required this.comment,
    required this.suggestedFileName,
  });
}

class GeneratePayloadUseCase {
  final PromptConfig rootPromptConfig;
  final List<CharacterConfig> characterConfigList;
  final List<VibeConfig> vibeConfigList;
  final ParamConfig paramConfig;

  final String? fileNameKey;

  GeneratePayloadUseCase({
    required this.rootPromptConfig,
    required this.characterConfigList,
    required this.vibeConfigList,
    required this.paramConfig,
    this.fileNameKey,
  });

  PayloadGenerationResult call() {
    final paramPayload = paramConfig.getPayload();

    final basePromptResult = rootPromptConfig.getPrmpts();
    String payloadComment = basePromptResult.toComment();
    final configPromptResultList =
        characterConfigList.map((elem) => elem.getPrompt()).toList();

    // Character prompts
    final characterPrompts = [];
    final v4CharPosCaptions = [];
    final v4CharNegCaptions = [];
    for (final (index, result) in configPromptResultList.indexed) {
      final posAsString = '${xMapping[result.center.x]}${result.center.y}';
      final posAsDouble = {
        'x': doubleMapping[result.center.x]!,
        'y': doubleMapping[result.center.y]!,
      };
      payloadComment +=
          '\n\nCharacter#$index at $posAsString:\n${result.comment}';
      characterPrompts.add({
        'prompt': result.caption,
        'uc': result.uc,
        'center': posAsDouble,
      });
      v4CharPosCaptions.add({
        'char_caption': result.caption,
        'centers': posAsDouble,
      });
      v4CharNegCaptions.add({
        'char_caption': result.uc,
        'centers': posAsDouble,
      });
    }
    final v4Prompt = {
      'caption': {
        'base_caption': basePromptResult.toPrompt(),
        'char_captions': v4CharPosCaptions,
      },
      'use_coords': !paramConfig.autoPosition,
      'use_order': true,
    };
    final v4NegPrompt = {
      'caption': {
        'base_caption': paramConfig.negativePrompt,
        'char_captions': v4CharNegCaptions,
      },
      'use_coords': !paramConfig.autoPosition,
      'use_order': true,
    };
    paramPayload['v4_prompt'] = v4Prompt;
    paramPayload['v4_negative_prompt'] = v4NegPrompt;
    paramPayload['characterPrompts'] = characterPrompts;

    return PayloadGenerationResult(
      comment: payloadComment,
      suggestedFileName: fileNameKey != null
          ? basePromptResult.findPromptWithKey(fileNameKey!) ?? ''
          : '',
      payload: {
        'input': basePromptResult.toPrompt(),
        'model': paramConfig.model,
        'action': 'generation',
        'parameters': paramPayload,
      },
    );
  }
}
