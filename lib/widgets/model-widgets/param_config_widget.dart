import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../editable_list_tile.dart';
import '../slider_list_tile.dart';
import '../../data/models/param_config.dart';

class ParamConfigWidget extends StatefulWidget {
  final ParamConfig config;

  const ParamConfigWidget({super.key, required this.config});

  @override
  ParamConfigWidgetState createState() => ParamConfigWidgetState();
}

class ParamConfigWidgetState extends State<ParamConfigWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSizeSelector(),
        // Steps
        SliderListTile(
            title: context.tr('sampling_steps') +
                context.tr('colon') +
                widget.config.steps.toString(),
            sliderValue: widget.config.steps.toDouble(),
            leading: const Icon(Icons.repeat),
            min: 0,
            max: 28,
            divisions: 28,
            onChanged: (value) {
              setState(() {
                widget.config.steps = value.toInt();
              });
            }),
        // CFG
        SliderListTile(
          title: context.tr('scale') +
              context.tr('colon') +
              widget.config.scale.toStringAsFixed(1),
          sliderValue: widget.config.scale,
          leading: const Icon(Icons.numbers),
          min: 0,
          max: 10,
          divisions: 100,
          onChanged: (value) {
            setState(() {
              widget.config.scale = value;
            });
          },
        ),
        SliderListTile(
          leading: const Icon(Icons.numbers),
          title: context.tr('cfg_rescale') +
              context.tr('colon') +
              widget.config.cfgRescale.toStringAsFixed(2),
          min: 0,
          max: 1,
          divisions: 20,
          sliderValue: widget.config.cfgRescale,
          onChanged: (value) {
            setState(() {
              widget.config.cfgRescale = value;
            });
          },
        ),
        // Sampler
        SelectableListTile(
            leading: const Icon(Icons.search),
            title: context.tr('sampler'),
            currentValue: widget.config.sampler,
            options: samplers,
            onSelectComplete: (value) => {
                  setState(() {
                    widget.config.sampler = value;
                  })
                }),
        SelectableListTile(
            leading: const Icon(Icons.search),
            title: context.tr('noise_scheduler'),
            currentValue: widget.config.noiseSchedule,
            options: noiseSchedules,
            onSelectComplete: (value) => {
                  setState(() {
                    widget.config.noiseSchedule = value;
                  })
                }),
        // SMEA
        _buildSwitchTile(context.tr('sm'), widget.config.sm, (newValue) {
          setState(() => widget.config.sm = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        _buildSwitchTile(context.tr('sm_dyn'), widget.config.smDyn, (newValue) {
          setState(() => widget.config.smDyn = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        // Variety+
        _buildSwitchTile(context.tr('variety_plus'), widget.config.varietyPlus,
            (newValue) {
          setState(() => widget.config.varietyPlus = newValue);
        }, const Icon(Icons.add)),
        // Seed
        _buildRandomSeedTile(),
        // UC
        EditableListTile(
          leading: const Icon(Icons.do_not_disturb),
          title: context.tr('uc'),
          currentValue: widget.config.negativePrompt,
          confirmOnSubmit: true,
          onEditComplete: (value) =>
              setState(() => widget.config.negativePrompt = value),
          keyboardType: TextInputType.text,
        ),
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

  Widget _buildSizeSelector() {
    return ListTile(
      title: Text(context.tr('image_size')),
      subtitle: Text(widget.config.sizes
          .map((elem) => '${elem.width} x ${elem.height}')
          .join(' || ')),
      leading: const Icon(Icons.photo_size_select_large),
      onTap: _showSizeSelectionDialog,
    );
  }

  Widget _buildRandomSeedTile() {
    return Column(
      children: [
        _buildSwitchTile(
          context.tr('use_random_seed'),
          widget.config.randomSeed,
          (newValue) {
            setState(() {
              widget.config.randomSeed = newValue;
            });
          },
          const Icon(Icons.shuffle),
        ),
        if (!widget.config.randomSeed)
          Padding(
              padding: const EdgeInsets.only(left: 20),
              child: (EditableListTile(
                  title: context.tr('random_seed'),
                  currentValue: widget.config.seed.toString(),
                  confirmOnSubmit: true,
                  onEditComplete: (value) => {
                        setState(() {
                          widget.config.seed =
                              int.tryParse(value) ?? widget.config.seed;
                        })
                      })))
      ],
    );
  }

  void _showSizeSelectionDialog() {
    final widthController = TextEditingController();
    final heightController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(tr('edit') + tr('image_size')),
            content: Column(
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
                  children: widget.config.sizes
                      .map((elem) => Chip(
                            label: Text('${elem.width} x ${elem.height}'),
                            onDeleted: () {
                              if (widget.config.sizes.length <= 1) return;
                              widget.config.sizes.remove(elem);
                              setDialogState(() {});
                              setState(() {});
                            },
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
                            onPressed: () {
                              if (widget.config.sizes.contains(elem)) return;
                              widget.config.sizes.add(elem);
                              setDialogState(() {});
                              setState(() {});
                            },
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
                        onPressed: () {
                          var width = int.tryParse(widthController.text);
                          var height = int.tryParse(heightController.text);
                          if (width == null || height == null) return;
                          width = (width / 64).ceil() * 64;
                          height = (height / 64).ceil() * 64;
                          final size =
                              GenerationSize(width: width, height: height);
                          if (widget.config.sizes.contains(size)) return;
                          widget.config.sizes.add(size);
                          setDialogState(() {});
                          setState(() {});
                        },
                        icon: const Icon(Icons.add))
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
