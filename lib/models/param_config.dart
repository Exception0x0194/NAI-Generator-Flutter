import 'dart:math';

class ParamConfig {
  int width;
  int height;
  double scale;
  String sampler;
  int steps;
  bool randomSeed;
  int seed;
  int nSamples;
  int ucPreset;
  bool qualityToggle;
  bool sm;
  bool smDyn;
  bool dynamicThresholding;
  double controlNetStrength;
  bool legacy;
  bool addOriginalImage;
  double uncondScale;
  double cfgRescale;
  String noiseSchedule;
  String negativePrompt;

  ParamConfig({
    this.width = 832,
    this.height = 1216,
    this.scale = 6.5,
    this.sampler = 'k_euler_ancestral',
    this.steps = 28,
    this.randomSeed = true,
    this.seed = 0,
    this.nSamples = 1,
    this.ucPreset = 0,
    this.qualityToggle = true,
    this.sm = true,
    this.smDyn = true,
    this.dynamicThresholding = false,
    this.controlNetStrength = 1.0,
    this.legacy = false,
    this.addOriginalImage = false,
    this.uncondScale = 1.0,
    this.cfgRescale = 0.1,
    this.noiseSchedule = 'native',
    this.negativePrompt =
        'lowres, {bad}, error, fewer, extra, missing, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract], bad anatomy, bad hands',
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'scale': scale,
      'sampler': sampler,
      'steps': steps,
      'n_samples': nSamples,
      'ucPreset': ucPreset,
      'qualityToggle': qualityToggle,
      'sm': sm,
      'sm_dyn': smDyn, // 转换camelCase为snake_case
      'seed': randomSeed ? Random().nextInt(999999999) : seed,
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
      'reference_strength_multiple': []
    };
  }

  factory ParamConfig.fromJson(Map<String, dynamic> json) {
    return ParamConfig(
      width: json['width'],
      height: json['height'],
      scale: json['scale'],
      sampler: json['sampler'],
      steps: json['steps'],
      nSamples: json['n_samples'],
      ucPreset: json['ucPreset'],
      qualityToggle: json['qualityToggle'],
      sm: json['sm'],
      smDyn: json['sm_dyn'], // 注意名字已转换为snake_case
      dynamicThresholding: json['dynamic_thresholding'],
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
      negativePrompt:
          json['negative_prompt'], // Assuming this field is a String
    );
  }
}
