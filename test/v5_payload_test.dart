import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:nai_casrand/core/constants/parameters.dart';
import 'package:nai_casrand/data/models/character_config.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/models/prompt_config.dart';
import 'package:nai_casrand/data/models/vibe_config_v4.dart';
import 'package:nai_casrand/data/use_cases/generate_payload_use_case.dart';

void main() {
  for (final model in ['nai-diffusion-5-full', 'nai-diffusion-5-curated']) {
    test('$model uses modern parameters after switching from V3', () {
      final config = ParamConfig(model: model, sampler: 'ddim_v3');
      final payload = config.getPayload();
      expect(models, contains(model));
      expect(config.usesV4Parameters, isTrue);
      expect(payload, isNot(contains('sm')));
      expect(payload, isNot(contains('sm_dyn')));
      expect(payload['noise_schedule'], 'karras');
      expect(payload['sampler'], 'k_euler_ancestral');
      expect(ParamConfig.fromJson(config.toJson()).model, model);
    });

    test('$model preserves character captions, positions and encoded vibes',
        () {
      final config = PayloadConfig.fromJson(
          jsonDecode(File('assets/json/example.json').readAsStringSync()));
      config.paramConfig.model = model;
      config.paramConfig.autoPosition = false;
      config.paramConfig.negativePrompt = 'bad quality';
      config.rootPromptConfig = PromptConfig(strs: ['scene'], prompts: []);
      config.useOverridePrompt = false;
      config.characterConfigList = [
        CharacterConfig(
          positions: [const Point(2, 3)],
          positivePromptConfig: PromptConfig(strs: ['girl'], prompts: []),
          negativePrompt: 'hat',
          enabled: true,
        )
      ];
      config.vibeConfigListV4 = [
        VibeConfigV4(
          fileName: 'vibe',
          vibeB64: 'encoded-vibe',
          referenceStrength: 0.4,
        )
      ];
      final result = GeneratePayloadUseCase(payloadConfig: config)();
      final parameters = result.payload['parameters'] as Map;
      expect(result.payload['model'], model);
      expect(result.payload['input'], 'scene');
      expect(parameters['v4_prompt']['use_coords'], isTrue);
      expect(parameters['v4_prompt']['caption']['char_captions'], [
        {
          'char_caption': 'girl',
          'centers': [
            {'x': 0.3, 'y': 0.5}
          ],
        }
      ]);
      expect(parameters['v4_negative_prompt']['caption']['base_caption'],
          'bad quality');
      expect(parameters['reference_image_multiple'], ['encoded-vibe']);
      expect(parameters['reference_strength_multiple'], [0.4]);
    });
  }

  test('V3 retains its SMEA parameters and native noise schedule', () {
    final payload = ParamConfig(model: 'nai-diffusion-3').getPayload();
    expect(payload['sm'], isTrue);
    expect(payload['noise_schedule'], 'native');
  });

  test('metadata uses the exact V5 model ID instead of guessing the variant',
      () {
    expect(
        modelFromMetadata('NovelAI Diffusion V5 unknown', {
          'model_name': 'nai-diffusion-5-curated',
        }),
        'nai-diffusion-5-curated');
    expect(modelFromMetadata('NovelAI Diffusion V5 unknown', {}), isNull);
    expect(modelFromMetadata('NovelAI Diffusion V4 79F47848', {}),
        'nai-diffusion-4-full');
  });
}
