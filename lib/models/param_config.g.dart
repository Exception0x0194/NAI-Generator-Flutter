// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'param_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ParamConfig _$ParamConfigFromJson(Map<String, dynamic> json) => ParamConfig(
      width: (json['width'] as num?)?.toInt() ?? 832,
      height: (json['height'] as num?)?.toInt() ?? 1216,
      scale: (json['scale'] as num?)?.toDouble() ?? 6.5,
      sampler: json['sampler'] as String? ?? 'k_euler_ancestral',
      steps: (json['steps'] as num?)?.toInt() ?? 28,
      randomSeed: json['randomSeed'] as bool? ?? true,
      seed: (json['seed'] as num?)?.toInt() ?? 0,
      nSamples: (json['nSamples'] as num?)?.toInt() ?? 1,
      ucPreset: (json['ucPreset'] as num?)?.toInt() ?? 0,
      qualityToggle: json['qualityToggle'] as bool? ?? true,
      sm: json['sm'] as bool? ?? true,
      smDyn: json['smDyn'] as bool? ?? true,
      dynamicThresholding: json['dynamicThresholding'] as bool? ?? false,
      controlNetStrength:
          (json['controlNetStrength'] as num?)?.toDouble() ?? 1.0,
      legacy: json['legacy'] as bool? ?? false,
      addOriginalImage: json['addOriginalImage'] as bool? ?? false,
      uncondScale: (json['uncondScale'] as num?)?.toDouble() ?? 1.0,
      cfgRescale: (json['cfg_rescale'] as num?)?.toDouble() ?? 0.1,
      noiseSchedule: json['noiseSchedule'] as String? ?? 'native',
      negativePrompt: json['negativePrompt'] as String? ??
          'lowres, {bad}, error, fewer, extra, missing, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract], bad anatomy, bad hands',
    );

Map<String, dynamic> _$ParamConfigToJson(ParamConfig instance) =>
    <String, dynamic>{
      'width': instance.width,
      'height': instance.height,
      'scale': instance.scale,
      'sampler': instance.sampler,
      'steps': instance.steps,
      'randomSeed': instance.randomSeed,
      'seed': instance.seed,
      'nSamples': instance.nSamples,
      'ucPreset': instance.ucPreset,
      'qualityToggle': instance.qualityToggle,
      'sm': instance.sm,
      'smDyn': instance.smDyn,
      'dynamicThresholding': instance.dynamicThresholding,
      'controlNetStrength': instance.controlNetStrength,
      'legacy': instance.legacy,
      'addOriginalImage': instance.addOriginalImage,
      'uncondScale': instance.uncondScale,
      'cfg_rescale': instance.cfgRescale,
      'noiseSchedule': instance.noiseSchedule,
      'negativePrompt': instance.negativePrompt,
    };
