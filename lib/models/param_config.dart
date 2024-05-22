import 'dart:math';

class ParamConfig {
  int width;
  int height;
  double scale;
  String sampler;
  int steps;
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

  void setParams({
    int? width,
    int? height,
    double? scale,
    double? cfgRescale,
    bool? sm,
    bool? smDyn,
    String? sampler,
    String? negativePrompt,
  }) {
    if (width != null) this.width = width;
    if (height != null) this.height = height;
    if (scale != null) this.scale = scale;
    if (cfgRescale != null) this.cfgRescale = cfgRescale;
    if (sm != null) this.sm = sm;
    if (smDyn != null) this.smDyn = smDyn;
    if (sampler != null) this.sampler = sampler;
    if (negativePrompt != null) this.negativePrompt = negativePrompt;
  }

  Map<String, dynamic> toJson() {
    seed = Random().nextInt(999999999);
    return {
      'width': width,
      'height': height,
      'scale': scale,
      'sampler': sampler,
      'steps': steps,
      'seed': seed,
      'n_samples': nSamples,
      'ucPreset': ucPreset,
      'qualityToggle': qualityToggle,
      'sm': sm,
      'sm_dyn': smDyn, // 转换camelCase为snake_case
      'dynamic_thresholding': dynamicThresholding,
      'controlnet_strength': controlNetStrength,
      'legacy': legacy,
      'add_original_image': addOriginalImage,
      'uncond_scale': uncondScale,
      'cfg_rescale': cfgRescale,
      'noise_schedule': noiseSchedule,
      'negative_prompt': negativePrompt,
    };
  }
}
