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

class PromptCommentPair {
  String prompt;
  String comment;

  PromptCommentPair({
    required this.prompt,
    required this.comment,
  });

  void processPair(List<PromptConfig> configList) {
    prompt = prompt.replaceAllMapped(
      RegExp(
        r'__([\p{L}0-9_\-（）().\u4e00-\u9fff\uff00-\uffef]+?)__',
        unicode: true,
      ),
      (match) {
        try {
          final config =
              configList.firstWhere((elem) => elem.comment == match[1]);
          final subPrompt = config.getPrmpts();
          comment += '\n__${subPrompt.toComment()}';
          return subPrompt.toPrompt();
        } on StateError catch (_) {
          return '__${match[1]}__';
        }
      },
    );
  }
}

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
  final List<PromptConfig> savedConfigList;
  final List<VibeConfig> vibeConfigList;
  final ParamConfig paramConfig;

  final String? fileNameKey;

  GeneratePayloadUseCase({
    required this.rootPromptConfig,
    required this.characterConfigList,
    required this.savedConfigList,
    required this.vibeConfigList,
    required this.paramConfig,
    this.fileNameKey,
  });

  PayloadGenerationResult call() {
    final paramPayload = paramConfig.getPayload();

    final basePromptResult = rootPromptConfig.getPrmpts();
    final basePair = PromptCommentPair(
      prompt: basePromptResult.toPrompt(),
      comment: basePromptResult.toComment(),
    );
    basePair.processPair(savedConfigList);
    String payloadComment = basePair.comment;
    final characterPromptResultList =
        characterConfigList.map((elem) => elem.getPrompt()).toList();

    // Character prompts
    final characterPrompts = [];
    final v4CharPosCaptions = [];
    final v4CharNegCaptions = [];
    for (final (index, result) in characterPromptResultList.indexed) {
      final posAsString = '${xMapping[result.center.x]}${result.center.y}';
      final posAsDouble = {
        'x': doubleMapping[result.center.x]!,
        'y': doubleMapping[result.center.y]!,
      };
      final characterPair =
          PromptCommentPair(prompt: result.caption, comment: result.comment);
      characterPair.processPair(savedConfigList);
      payloadComment +=
          '\n\nCharacter#$index at $posAsString:\n${characterPair.comment}';
      characterPrompts.add({
        'prompt': characterPair.prompt,
        'uc': result.uc,
        'center': posAsDouble,
      });
      v4CharPosCaptions.add({
        'char_caption': characterPair.prompt,
        'centers': posAsDouble,
      });
      v4CharNegCaptions.add({
        'char_caption': result.uc,
        'centers': posAsDouble,
      });
    }
    final v4Prompt = {
      'caption': {
        'base_caption': basePair.prompt,
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

    final processedFileName = fileNameKey != null
        ? _processFileNameKey(fileNameKey!, basePromptResult)
        : '';

    return PayloadGenerationResult(
      comment: payloadComment,
      suggestedFileName: processedFileName,
      payload: {
        'input': basePair.prompt,
        'model': paramConfig.model,
        'action': 'generation',
        'parameters': paramPayload,
      },
    );
  }

  String _processFileNameKey(
    String rawKey,
    NestedPrompt prompt,
  ) {
    return rawKey.replaceAllMapped(
      // 允许Unicode字符
      RegExp(
        r'__([\p{L}0-9_\-（）().\u4e00-\u9fff\uff00-\uffef]+?)__',
        unicode: true,
      ),
      (match) =>
          prompt.findPromptWithKey(match[1].toString()) ?? '__${match[1]}__',
    );
  }
}
