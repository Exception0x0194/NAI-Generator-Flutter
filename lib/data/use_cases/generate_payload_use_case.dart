import 'package:easy_localization/easy_localization.dart';
import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
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
  final PayloadConfig payloadConfig;

  GeneratePayloadUseCase({
    required this.payloadConfig,
  });

  ParamConfig get paramConfig => payloadConfig.paramConfig;
  PromptConfig get rootPromptConfig => payloadConfig.rootPromptConfig;
  List<CharacterConfig> get characterConfigList =>
      payloadConfig.characterConfigList;
  List<PromptConfig> get savedConfigList => payloadConfig.savedPromptConfigList;
  List<VibeConfig> get vibeConfigList => payloadConfig.vibeConfigList;
  String get fileNameKey => payloadConfig.settings.fileNamePrefixKey;

  PayloadGenerationResult call() {
    final pattern = RegExp(
      r'__([\p{L}0-9_\-（）().\u4e00-\u9fff\uff00-\uffef]+?)__',
      unicode: true,
    );

    // Get prompt
    final NestedPrompt basePromptResult;
    if (payloadConfig.useOverridePrompt) {
      basePromptResult = NestedPromptString(
        title: tr('override_prompt'),
        content: payloadConfig.overridePrompt,
      );
    } else {
      basePromptResult = rootPromptConfig
          .getPrmpts()
          .replaceVariables(pattern, savedConfigList);
    }
    final basePair = PromptCommentPair(
      prompt: basePromptResult.toPrompt(),
      comment: basePromptResult.toComment(),
    );
    final paramPayload = paramConfig.getPayload();
    String payloadComment = basePair.comment;

    // Get character prompt
    final List<CharacterPromptResult> characterPromptResultList = [];
    if (!payloadConfig.useOverridePrompt ||
        payloadConfig.useCharacterPromptWithOverride) {
      for (final config in characterConfigList) {
        if (!config.enabled) continue;
        characterPromptResultList.add(config.getPrompt());
      }
    }

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
      result.prompt = result.prompt.replaceVariables(pattern, savedConfigList);
      final characterPair = PromptCommentPair(
        prompt: result.prompt.toPrompt(),
        comment: result.prompt.toComment(),
      );
      // characterPair.processPair(savedConfigList);
      payloadComment +=
          '\n\nCharacter#$index at $posAsString:\n${characterPair.comment}';
      characterPrompts.add({
        'prompt': characterPair.prompt,
        'uc': result.uc,
        'center': posAsDouble,
      });
      v4CharPosCaptions.add({
        'char_caption': characterPair.prompt,
        'centers': [posAsDouble],
      });
      v4CharNegCaptions.add({
        'char_caption': result.uc,
        'centers': [posAsDouble],
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
      'legacy_uc': paramConfig.legacyUc,
    };
    paramPayload['v4_prompt'] = v4Prompt;
    paramPayload['v4_negative_prompt'] = v4NegPrompt;
    paramPayload['characterPrompts'] = characterPrompts;

    if (!paramConfig.model.contains('diffusion-4')) {
      final imageB64List = [];
      final referenceStrengthList = [];
      final imformationExtractedList = [];
      for (final vc in vibeConfigList) {
        imageB64List.add(vc.imageB64);
        referenceStrengthList.add(vc.referenceStrength);
        imformationExtractedList.add(vc.infoExtracted);
      }
      paramPayload['reference_image_multiple'] = imageB64List;
      paramPayload['reference_strength_multiple'] = referenceStrengthList;
      paramPayload['reference_information_extracted_multiple'] =
          imformationExtractedList;
    }

    final processedFileName =
        _processFileNameKey(fileNameKey, basePromptResult);

    return PayloadGenerationResult(
      comment: payloadComment,
      suggestedFileName: processedFileName,
      payload: {
        'input': basePair.prompt,
        'model': paramConfig.model,
        'action': 'generate',
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
