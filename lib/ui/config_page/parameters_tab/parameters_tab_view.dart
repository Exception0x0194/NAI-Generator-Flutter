import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/data/models/param_config.dart';
import 'package:nai_casrand/ui/config_page/parameters_tab/parameters_tab_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

const samplers = [
  'k_euler',
  'k_euler_ancestral',
  'k_dpmpp_2s_ancestral',
  'k_dpmpp_2m_sde',
  'k_dpmpp_sde',
  'k_dpmpp_2m',
  'ddim_v3'
];
const noiseSchedules = ['native', 'karras', 'exponential', 'polyexponential'];
const defaultUC =
    'lowres, {bad}, error, fewer, extra, missing, worst quality, jpeg artifacts, bad quality, watermark, unfinished, displeasing, chromatic aberration, signature, extra digits, artistic error, username, scan, [abstract], bad anatomy, bad hands';

class ParametersTabView extends StatelessWidget {
  final ParametersTabViewmodel viewmodel;

  const ParametersTabView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = ChangeNotifierProvider.value(
        value: viewmodel,
        child: Consumer<ParametersTabViewmodel>(
            builder: (context, viewmodel, child) {
          return Column(
            children: [
              _buildSizeSelector(context),
              // Steps
              SliderListTile(
                  title: context.tr('sampling_steps') +
                      context.tr('colon') +
                      viewmodel.config.steps.toString(),
                  sliderValue: viewmodel.config.steps.toDouble(),
                  leading: const Icon(Icons.repeat),
                  min: 0,
                  max: 28,
                  divisions: 28,
                  onChanged: (value) => viewmodel.setSteps(value)),
              // CFG
              SliderListTile(
                title: context.tr('scale') +
                    context.tr('colon') +
                    viewmodel.config.scale.toStringAsFixed(1),
                sliderValue: viewmodel.config.scale,
                leading: const Icon(Icons.numbers),
                min: 0,
                max: 10,
                divisions: 100,
                onChanged: (value) => viewmodel.setScale(value),
              ),
              SliderListTile(
                leading: const Icon(Icons.numbers),
                title: context.tr('cfg_rescale') +
                    context.tr('colon') +
                    viewmodel.config.cfgRescale.toStringAsFixed(2),
                min: 0,
                max: 1,
                divisions: 20,
                sliderValue: viewmodel.config.cfgRescale,
                onChanged: (value) => viewmodel.setCfgRescale(value),
              ),
              // Sampler
              SelectableListTile(
                  leading: const Icon(Icons.search),
                  title: context.tr('sampler'),
                  currentValue: viewmodel.config.sampler,
                  options: samplers,
                  onSelectComplete: (value) => viewmodel.setSampler(value)),
              SelectableListTile(
                  leading: const Icon(Icons.search),
                  title: context.tr('noise_scheduler'),
                  currentValue: viewmodel.config.noiseSchedule,
                  options: noiseSchedules,
                  onSelectComplete: (value) =>
                      viewmodel.setNoiseScheduler(value)),
              // SMEA
              _buildSwitchTile(
                context.tr('sm'),
                viewmodel.config.sm,
                (newValue) => viewmodel.setSm(newValue),
                const Icon(Icons.keyboard_double_arrow_right),
              ),
              _buildSwitchTile(
                context.tr('sm_dyn'),
                viewmodel.config.smDyn,
                (newValue) => viewmodel.setSmDyn(newValue),
                const Icon(Icons.keyboard_double_arrow_right),
              ),
              // Variety+
              _buildSwitchTile(
                context.tr('variety_plus'),
                viewmodel.config.varietyPlus,
                (newValue) => viewmodel.setVarietyPlus(newValue),
                const Icon(Icons.add),
              ),
              // Seed
              _buildRandomSeedTile(context),
              // UC
              EditableListTile(
                leading: const Icon(Icons.do_not_disturb),
                title: context.tr('uc'),
                currentValue: viewmodel.config.negativePrompt,
                confirmOnSubmit: true,
                onEditComplete: (value) => viewmodel.setNegativePrompt(value),
                keyboardType: TextInputType.text,
              ),
            ],
          );
        }));
    return SingleChildScrollView(
      child: content,
    );
  }

  Widget _buildSizeSelector(BuildContext context) {
    return ListTile(
      title: Text(context.tr('image_size')),
      subtitle: Text(viewmodel.config.sizes
          .map((elem) => '${elem.width} x ${elem.height}')
          .join(' || ')),
      leading: const Icon(Icons.photo_size_select_large),
      onTap: () => _showSizeSelectionDialog(context),
    );
  }

  Widget _buildRandomSeedTile(BuildContext context) {
    return Column(
      children: [
        _buildSwitchTile(
          context.tr('use_random_seed'),
          viewmodel.config.randomSeed,
          (newValue) => viewmodel.setRandomSeedEnabled(newValue),
          const Icon(Icons.shuffle),
        ),
        if (!viewmodel.config.randomSeed)
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: (EditableListTile(
                  title: context.tr('random_seed'),
                  currentValue: viewmodel.config.seed.toString(),
                  confirmOnSubmit: true,
                  onEditComplete: (value) => viewmodel.setSeed(value))))
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool currentValue,
      ValueChanged<bool> onChanged, Icon? icon) {
    return CheckboxListTile(
      secondary: icon,
      title: Text(title),
      value: currentValue,
      onChanged: (value) => onChanged(value!),
    );
  }

  void _showSizeSelectionDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(tr('edit') + tr('colon') + tr('image_size')),
              content: SizeSelectionView(viewmodel: viewmodel),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
  }
}

class SizeSelectionView extends StatelessWidget {
  final ParametersTabViewmodel viewmodel;

  const SizeSelectionView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final widthController = TextEditingController();
    final heightController = TextEditingController();
    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<ParametersTabViewmodel>(
          builder: (context, viewmodel, child) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Selected:'),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: viewmodel.config.sizes
                        .map((elem) => Chip(
                              label: Text('${elem.width} x ${elem.height}'),
                              onDeleted: () => viewmodel.removeSize(elem),
                            ))
                        .toList(),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Text('Defaults:'),
                  ),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: defaultSizes
                        .map((elem) => OutlinedButton(
                              onPressed: () => viewmodel.addSize(elem),
                              child: Text('${elem.width} x ${elem.height}'),
                            ))
                        .toList(),
                  ),
                  const Divider(),
                  const Text('Manual:'),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widthController,
                          keyboardType: const TextInputType.numberWithOptions(),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 16, right: 16),
                        child: Text('×'),
                      ),
                      Expanded(
                          child: TextField(
                        controller: heightController,
                        keyboardType: const TextInputType.numberWithOptions(),
                      )),
                      const SizedBox(width: 16),
                      IconButton(
                          onPressed: () => viewmodel.addManualSize(
                                widthController.text,
                                heightController.text,
                              ),
                          icon: const Icon(Icons.add))
                    ],
                  )
                ],
              )),
    );
  }
}
