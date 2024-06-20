import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import 'editable_list_tile.dart';
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
                title: Text(S.of(context).custom_size),
                leading: const Icon(Icons.back_hand),
                dense: true,
                children: [
                  EditableListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: S.of(context).width,
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
                    title: S.of(context).height,
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
        // CFG
        EditableListTile(
          leading: const Icon(Icons.numbers),
          title: S.of(context).scale,
          currentValue: widget.config.scale.toString(),
          confirmOnSubmit: true,
          onEditComplete: (value) => setState(() => widget.config.scale =
              double.tryParse(value) ?? widget.config.scale),
          keyboardType: TextInputType.number,
        ),
        EditableListTile(
          leading: const Icon(Icons.numbers),
          title: S.of(context).cfg_rescale,
          currentValue: widget.config.cfgRescale.toString(),
          confirmOnSubmit: true,
          onEditComplete: (value) => setState(() => widget.config.cfgRescale =
              double.tryParse(value) ?? widget.config.cfgRescale),
          keyboardType: TextInputType.number,
        ),
        // Sampler
        SelectableListTile(
            leading: const Icon(Icons.search),
            title: S.of(context).sampler,
            currentValue: widget.config.sampler,
            options: const [
              'k_euler',
              'k_euler_ancestral',
              'k_dpmpp_2s_ancestral',
              'k_dpmpp_sde'
            ],
            onSelectComplete: (value) => {
                  setState(() {
                    widget.config.sampler = value;
                  })
                }),
        // SMEA
        _buildSwitchTile(S.of(context).sm, widget.config.sm, (newValue) {
          setState(() => widget.config.sm = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        _buildSwitchTile(S.of(context).sm_dyn, widget.config.smDyn, (newValue) {
          setState(() => widget.config.smDyn = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        // Seed
        _buildRandomSeedTile(),
        // UC
        EditableListTile(
          leading: const Icon(Icons.do_not_disturb),
          title: S.of(context).uc,
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
    return SwitchListTile(
      secondary: icon,
      title: Text(title),
      value: currentValue,
      onChanged: onChanged,
      subtitle:
          Text(currentValue ? S.of(context).enabled : S.of(context).disabled),
    );
  }

  Widget _buildSizeSelector() {
    return SelectableListTile(
      title: S.of(context).image_size,
      currentValue: _getSizeString(),
      options: const [
        '832 x 1216',
        '1024 x 1024',
        '1216 x 832',
        '1024 x 1536',
        '1472 x 1472',
        '1536 x 1024',
      ],
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
          S.of(context).use_random_seed,
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
                  title: S.of(context).random_seed,
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
