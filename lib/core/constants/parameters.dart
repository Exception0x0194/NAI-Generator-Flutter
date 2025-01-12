import 'package:nai_casrand/data/models/param_config.dart';

const defaultSizes = [
  GenerationSize(width: 704, height: 1472),
  GenerationSize(width: 832, height: 1216),
  GenerationSize(width: 1024, height: 1024),
  GenerationSize(width: 1216, height: 832),
  GenerationSize(width: 1472, height: 704),
];
const models = [
  'nai-diffusion-4-curated-preview',
  'nai-diffusion-3',
  'nai-diffusion-furry-3'
];
const samplers = [
  'k_euler',
  'k_euler_ancestral',
  'k_dpmpp_2s_ancestral',
  'k_dpmpp_2m_sde',
  'k_dpmpp_sde',
  'k_dpmpp_2m',
  'ddim_v3'
];
const samplersV4 = [
  'k_euler',
  'k_euler_ancestral',
  'k_dpmpp_2s_ancestral',
  'k_dpmpp_2m_sde',
  'k_dpmpp_sde',
  'k_dpmpp_2m',
];
const noiseSchedules = [
  'native',
  'karras',
  'exponential',
  'polyexponential',
];
const noiseSchedulesV4 = [
  'karras',
  'exponential',
  'polyexponential',
];
const defaultUC =
    'lowres, {bad}, error, fewer, extra, missing, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract], bad anatomy, bad hands';
