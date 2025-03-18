import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nai_casrand/core/constants/defaults.dart';
import 'package:nai_casrand/core/constants/parameters.dart';
import 'package:nai_casrand/data/services/image_service.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/parameters_config/view_models/parameters_config_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;

class ParametersConfigView extends StatelessWidget {
  final ParametersConfigViewmodel viewmodel;

  const ParametersConfigView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = ListenableBuilder(
      listenable: viewmodel,
      builder: (context, _) => Column(
        children: [
          _buildModelSelector(context),
          if (viewmodel.isV4) _buildAutoPositionTile(context),
          if (viewmodel.isV4) _buildLegacyUcTile(context),
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
              options: viewmodel.isV4 ? samplersV4 : samplers,
              onSelectComplete: (value) => viewmodel.setSampler(value)),
          SelectableListTile(
              leading: const Icon(Icons.search),
              title: context.tr('noise_scheduler'),
              currentValue: viewmodel.config.noiseSchedule,
              options: viewmodel.isV4 ? noiseSchedulesV4 : noiseSchedules,
              onSelectComplete: (value) => viewmodel.setNoiseScheduler(value)),
          // SMEA
          if (!viewmodel.isV4)
            _buildSwitchTile(
              context.tr('sm'),
              viewmodel.config.sm,
              (newValue) => viewmodel.setSm(newValue),
              const Icon(Icons.keyboard_double_arrow_right),
            ),
          if (!viewmodel.isV4)
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
      ),
    );

    final fab = FloatingActionButton(
      tooltip: tr('import_metadata_from_image'),
      onPressed: () => _showImportMetadataDialog(context),
      child: const Icon(Icons.image_outlined),
    );
    return Scaffold(
      floatingActionButton: fab,
      body: SingleChildScrollView(
        child: content,
      ),
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

  Widget _buildModelSelector(BuildContext context) {
    return SelectableListTile(
      title: tr('generation_model'),
      leading: const Icon(Icons.auto_awesome_outlined),
      currentValue: viewmodel.config.model,
      options: models,
      onSelectComplete: (value) => viewmodel.setModel(value),
    );
  }

  Widget _buildAutoPositionTile(BuildContext context) {
    return CheckboxListTile(
      title: Text(tr('auto_position')),
      secondary: const Icon(Icons.not_listed_location_outlined),
      value: viewmodel.config.autoPosition,
      onChanged: (value) => viewmodel.setAutoPosition(value),
    );
  }

  Widget _buildLegacyUcTile(BuildContext context) {
    return CheckboxListTile(
      title: const Text('Legacy Prompt Conditioning Mode'),
      secondary: const Icon(Icons.do_not_disturb),
      value: viewmodel.config.legacyUc,
      onChanged: (value) => viewmodel.setLegacyUc(value),
    );
  }

  Future _showImportMetadataDialog(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result == null) return;
    final image = img.decodeImage(await result.readAsBytes());
    if (image == null) return;
    final metadataString = await ImageService().extractMetadata(image);
    if (!context.mounted) return;
    if (metadataString == null) {
      showErrorBar(context, tr('metadata_not_found'));
      return;
    }
    try {
      final jsonData = json.decode(metadataString) as Map<String, dynamic>;
      final commentData =
          json.decode(jsonData['Comment']) as Map<String, dynamic>;
      final sizeTile = ListTile(
        title: Text(tr('image_size')),
        subtitle: Text(
          '${commentData['width']} × ${commentData['height']}',
        ),
        dense: true,
        trailing: IconButton(
            onPressed: () => viewmodel.loadImageMetadata(
                  context,
                  {
                    'width': commentData['width'],
                    'height': commentData['height']
                  },
                ),
            icon: const Icon(Icons.copy)),
      );
      final tiles = commentKeys.map((key) {
        final value = commentData[key];
        if (value == null) return const SizedBox.shrink();
        return ListTile(
          title: Text(key),
          subtitle: Text(value.toString()),
          dense: true,
          trailing: IconButton(
            onPressed: () => viewmodel.loadImageMetadata(context, {key: value}),
            icon: const Icon(Icons.copy),
          ),
        );
      }).toList();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(tr('metadata_found')),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [sizeTile, ...tiles],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(tr('cancel')),
            ),
            TextButton(
                onPressed: () {
                  viewmodel.loadImageMetadata(context, commentData);
                  Navigator.pop(context);
                },
                child: Text(tr('import_all_metadata_from_image')))
          ],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      showErrorBar(
          context, '${tr('import_metadata_from_image')}${tr('failed')}');
    }
  }
}

class SizeSelectionView extends StatelessWidget {
  final ParametersConfigViewmodel viewmodel;

  const SizeSelectionView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final widthController = TextEditingController();
    final heightController = TextEditingController();
    return ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<ParametersConfigViewmodel>(
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
