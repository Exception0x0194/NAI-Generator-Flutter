const models = [
  'nai-diffusion-4-full',
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

const List<String> commentKeys = [
  'scale',
  'sampler',
  'steps',
  'n_samples',
  'ucPreset',
  'qualityToggle',
  'sm',
  'sm_dyn',
  'dynamic_thresholding',
  'controlnet_strength',
  'legacy',
  'add_original_image',
  'uncond_scale',
  'cfg_rescale',
  'noise_schedule',
  'negative_prompt',
  'seed',
  'use_coords',
];
