import 'dart:math';

import '../../core/constants/defaults.dart';
import 'generation_size.dart';

class ParamConfig {
  List<GenerationSize> sizes;
  int nSamples;

  int steps;
  String sampler;
  String noiseSchedule;
  double scale;
  double cfgRescale;
  bool sm;
  bool smDyn;
  bool varietyPlus;

  bool randomSeed;
  int seed;

  bool dynamicThresholding;
  double controlNetStrength;
  double uncondScale;

  bool qualityToggle;
  int ucPreset;
  String negativePrompt;

  bool legacy;
  bool addOriginalImage;

  String model = 'nai-diffusion-4-curated-preview';

  bool autoPosition;

  ParamConfig({
    this.model = 'nai-diffusion-4-curated-preview',
    this.sizes = const [GenerationSize(height: 1216, width: 832)],
    this.scale = 6.5,
    this.sampler = 'k_euler_ancestral',
    this.steps = 28,
    this.randomSeed = true,
    this.seed = 0,
    this.nSamples = 1,
    this.ucPreset = 2,
    this.qualityToggle = false,
    this.sm = true,
    this.smDyn = true,
    this.dynamicThresholding = false,
    this.controlNetStrength = 1.0,
    this.legacy = false,
    this.addOriginalImage = false,
    this.uncondScale = 1.0,
    this.cfgRescale = 0.1,
    this.noiseSchedule = 'native',
    this.varietyPlus = false,
    this.negativePrompt = defaultUC,
    this.autoPosition = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'model': model,
      'sizes': sizes.map((elem) => elem.toJson()).toList(),
      'scale': scale,
      'sampler': sampler,
      'steps': steps,
      'n_samples': nSamples,
      'ucPreset': ucPreset,
      'qualityToggle': qualityToggle,
      'sm': sm,
      'sm_dyn': smDyn,
      'random_seed': randomSeed,
      'dynamic_thresholding': dynamicThresholding,
      'controlnet_strength': controlNetStrength,
      'legacy': legacy,
      'add_original_image': addOriginalImage,
      'uncond_scale': uncondScale,
      'cfg_rescale': cfgRescale,
      'noise_schedule': noiseSchedule,
      'negative_prompt': negativePrompt,
      'reference_image_multiple': [],
      'reference_information_extracted_multiple': [],
      'reference_strength_multiple': [],
      'variety_plus': varietyPlus,
      'auto_position': autoPosition,
    };
  }

  /// Different from toJson(), some fields in payload need to be calculated from other params.
  Map<String, dynamic> getPayload() {
    bool? preferBrownian;
    bool? deliberateEulerAncestralBug;
    if (sampler == 'k_euler_ancestral' && noiseSchedule != 'native') {
      preferBrownian = true;
      deliberateEulerAncestralBug = false;
    }
    double? skipCfgAboveSigma;
    final selectedSize = sizes[Random().nextInt(sizes.length)];
    final width = selectedSize.width;
    final height = selectedSize.height;
    if (varietyPlus) {
      final w = width / 8;
      final h = height / 8;
      final v = pow(4.0 * w * h / 63232, 0.5);
      skipCfgAboveSigma = 19.0 * v;
    }
    // var payload = {
    //   'width': width,
    //   'height': height,
    //   'scale': scale,
    //   'sampler': sampler,
    //   'steps': steps,
    //   'n_samples': nSamples,
    //   'ucPreset': ucPreset,
    //   'qualityToggle': qualityToggle,
    //   'sm': sm,
    //   'sm_dyn': smDyn,
    //   'seed': randomSeed ? Random().nextInt(1 << 32 - 1) : seed,
    //   'dynamic_thresholding': dynamicThresholding,
    //   'controlnet_strength': controlNetStrength,
    //   'legacy': legacy,
    //   'add_original_image': addOriginalImage,
    //   'uncond_scale': uncondScale,
    //   'cfg_rescale': cfgRescale,
    //   'noise_schedule': noiseSchedule,
    //   'negative_prompt': negativePrompt,
    //   'reference_image_multiple': [],
    //   'reference_information_extracted_multiple': [],
    //   'reference_strength_multiple': [],
    //   'prefer_brownian': preferBrownian,
    //   'skip_cfg_above_sigma': skipCfgAboveSigma,
    //   'deliberate_euler_ancestral_bug': deliberateEulerAncestralBug,
    // };
    var payload = {
      "params_version": 3,
      "width": width,
      "height": height,
      "scale": scale,
      "sampler": sampler,
      "steps": steps,
      "n_samples": nSamples,
      "ucPreset": 2,
      "qualityToggle": false,
      'sm': sm,
      'sm_dyn': smDyn,
      "dynamic_thresholding": dynamicThresholding,
      "controlnet_strength": controlNetStrength,
      "legacy": legacy,
      "add_original_image": true,
      "cfg_rescale": cfgRescale,
      "noise_schedule": noiseSchedule,
      "skip_cfg_above_sigma": skipCfgAboveSigma,
      "use_coords": true,
      "seed": randomSeed ? Random().nextInt(1 << 32 - 1) : seed,
      "characterPrompts": [],
      "v4_prompt": {},
      "v4_negative_prompt": {},
      "negative_prompt": negativePrompt,
      "reference_image_multiple": [],
      "reference_information_extracted_multiple": [],
      "reference_strength_multiple": [],
      "deliberate_euler_ancestral_bug": deliberateEulerAncestralBug,
      "prefer_brownian": preferBrownian
    };
    payload['legacy_v3_extend'] = false;
    payload.removeWhere((k, v) => v == null);
    if (model.contains('diffusion-4')) {
      payload.remove('sm');
      payload.remove('sm_dyn');
    }
    return payload;
  }

  factory ParamConfig.fromJson(Map<String, dynamic> json) {
    return ParamConfig(
      model: json['model'] ?? 'nai-diffusion-4-curated-preview',
      sizes: (json['sizes'] as List<dynamic>?)
              ?.map((elem) => GenerationSize.fromJson(elem))
              .toList() ??
          const [GenerationSize(height: 1216, width: 832)],
      scale: json['scale'],
      sampler: json['sampler'],
      steps: json['steps'],
      nSamples: json['n_samples'],
      ucPreset: json['ucPreset'] ?? 0,
      qualityToggle: json['qualityToggle'] ?? false,
      sm: json['sm'],
      smDyn: json['sm_dyn'],
      dynamicThresholding: json['dynamic_thresholding'],
      varietyPlus: json['variety_plus'] ?? false,
      controlNetStrength: json['controlnet_strength'] is int
          ? (json['controlnet_strength'] as int).toDouble()
          : json['controlnet_strength'],
      legacy: json['legacy'],
      addOriginalImage: json['add_original_image'],
      uncondScale: json['uncond_scale'] is int
          ? (json['uncond_scale'] as int).toDouble()
          : json['uncond_scale'],
      cfgRescale: json['cfg_rescale'] is int
          ? (json['cfg_rescale'] as int).toDouble()
          : json['cfg_rescale'],
      noiseSchedule: json['noise_schedule'],
      negativePrompt: json['negative_prompt'],
      autoPosition: json['auto_position'] ?? false,
    );
  }

  int loadJson(Map<String, dynamic> json) {
    int loadCount = 0;
    if (json.containsKey('width') && json.containsKey('height')) {
      final width = json['width'];
      final height = json['height'];
      sizes = [GenerationSize(width: width, height: height)];
      loadCount += 2;
    }
    if (json.containsKey('scale')) {
      scale = json['scale'];
      loadCount++;
    }
    if (json.containsKey('sampler')) {
      sampler = json['sampler'];
      loadCount++;
    }
    if (json.containsKey('steps')) {
      steps = json['steps'];
      loadCount++;
    }
    if (json.containsKey('n_samples')) {
      nSamples = json['n_samples'];
      loadCount++;
    }
    if (json.containsKey('ucPreset')) {
      ucPreset = json['ucPreset'];
      loadCount++;
    }
    if (json.containsKey('qualityToggle')) {
      qualityToggle = json['qualityToggle'];
      loadCount++;
    }
    if (json.containsKey('sm')) {
      sm = json['sm'];
      loadCount++;
    }
    if (json.containsKey('sm_dyn')) {
      smDyn = json['sm_dyn'];
      loadCount++;
    }
    if (json.containsKey('dynamic_thresholding')) {
      dynamicThresholding = json['dynamic_thresholding'];
      loadCount++;
    }
    if (json.containsKey('controlnet_strength')) {
      controlNetStrength = json['controlnet_strength'] is int
          ? (json['controlnet_strength'] as int).toDouble()
          : json['controlnet_strength'];
      loadCount++;
    }
    if (json.containsKey('legacy')) {
      legacy = json['legacy'];
      loadCount++;
    }
    if (json.containsKey('add_original_image')) {
      addOriginalImage = json['add_original_image'];
      loadCount++;
    }
    if (json.containsKey('uncond_scale')) {
      uncondScale = json['uncond_scale'] is int
          ? (json['uncond_scale'] as int).toDouble()
          : json['uncond_scale'];
      loadCount++;
    }
    if (json.containsKey('cfg_rescale')) {
      cfgRescale = json['cfg_rescale'] is int
          ? (json['cfg_rescale'] as int).toDouble()
          : json['cfg_rescale'];
      loadCount++;
    }
    if (json.containsKey('noise_schedule')) {
      noiseSchedule = json['noise_schedule'];
      loadCount++;
    }
    if (json.containsKey('negative_prompt')) {
      negativePrompt = json['negative_prompt'];
      loadCount++;
    }
    if (json.containsKey('seed')) {
      seed = json['seed'];
      randomSeed = false;
      loadCount++;
    }
    return loadCount;
  }
}
