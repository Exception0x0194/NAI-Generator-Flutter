import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'editable_list_tile.dart';
import 'slider_list_tile.dart';
import '../models/param_config.dart';

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
        // Manual Size
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ExpansionTile(
                title: Text(context.tr('custom_size')),
                leading: const Icon(Icons.back_hand),
                dense: true,
                children: [
                  EditableListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: context.tr('width'),
                    currentValue: widget.config.width.toString(),
                    confirmOnSubmit: true,
                    onEditComplete: (value) => setState(() {
                      int? result = int.tryParse(value);
                      if (result == null) return;
                      widget.config.width = (result / 64).round() * 64;
                    }),
                    keyboardType: TextInputType.number,
                  ),
                  EditableListTile(
                    leading: const Icon(Icons.swap_vert),
                    title: context.tr('height'),
                    currentValue: widget.config.height.toString(),
                    confirmOnSubmit: true,
                    onEditComplete: (value) => setState(() {
                      int? result = int.tryParse(value);
                      if (result == null) return;
                      widget.config.height = (result / 64).round() * 64;
                    }),
                    keyboardType: TextInputType.number,
                  ),
                ])),
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
    return SelectableListTile(
      title: context.tr('image_size'),
      currentValue: _getSizeString(),
      options: defaultSizes,
      onSelectComplete: (value) => {_setSize(value)},
      leading: const Icon(Icons.photo_size_select_large),
    );
  }

  String _getSizeString() {
    return '${widget.config.width.toString()} x ${widget.config.height.toString()}';
  }

  void _setSize(String value) {
    List<String> parts = value.split(' x ');
    if (parts.length == 2) {
      int? width = int.tryParse(parts[0]);
      int? height = int.tryParse(parts[1]);
      if (width != null && height != null) {
        setState(() {
          widget.config.width = width;
          widget.config.height = height;
        });
      }
    }
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
}
