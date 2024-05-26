import 'package:flutter/material.dart';
import 'editable_list_tile.dart'; // 确保引入了我们前面定义的EditableListTile
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
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: ExpansionTile(
                title: const Text('Custom Size'),
                leading: const Icon(Icons.back_hand),
                dense: true,
                children: [
                  EditableListTile(
                    leading: const Icon(Icons.swap_horiz),
                    title: "Width",
                    currentValue: widget.config.width.toString(),
                    onEditComplete: (value) => setState(() => widget.config
                        .width = int.tryParse(value) ?? widget.config.width),
                    keyboardType: TextInputType.number,
                  ),
                  EditableListTile(
                    leading: const Icon(Icons.swap_vert),
                    title: "Height",
                    currentValue: widget.config.height.toString(),
                    onEditComplete: (value) => setState(() => widget.config
                        .height = int.tryParse(value) ?? widget.config.height),
                    keyboardType: TextInputType.number,
                  ),
                ])),
        EditableListTile(
          leading: const Icon(Icons.numbers),
          title: "Scale",
          currentValue: widget.config.scale.toString(),
          onEditComplete: (value) => setState(() => widget.config.scale =
              double.tryParse(value) ?? widget.config.scale),
          keyboardType: TextInputType.number,
        ),
        EditableListTile(
          leading: const Icon(Icons.numbers),
          title: "CFG Rescale",
          currentValue: widget.config.cfgRescale.toString(),
          onEditComplete: (value) => setState(() => widget.config.cfgRescale =
              double.tryParse(value) ?? widget.config.cfgRescale),
          keyboardType: TextInputType.number,
        ),
        SelectableListTile(
            leading: const Icon(Icons.search),
            title: 'Sampler',
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
        _buildSwitchTile("SM", widget.config.sm, (newValue) {
          setState(() => widget.config.sm = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        _buildSwitchTile("SM Dyn", widget.config.smDyn, (newValue) {
          setState(() => widget.config.smDyn = newValue);
        }, const Icon(Icons.keyboard_double_arrow_right)),
        _buildRandomSeedTile(),
        EditableListTile(
          leading: const Icon(Icons.do_not_disturb),
          title: "UC",
          currentValue: widget.config.negativePrompt,
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
      subtitle: Text(currentValue ? "Enabled" : "Disabled"),
    );
  }

  Widget _buildSizeSelector() {
    return SelectableListTile(
      title: 'Image Size',
      currentValue: _getSizeString(),
      options: const ['832 x 1216', '1024 x 1024', '1216 x 832'],
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
          "Use Random Seed",
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
              padding: EdgeInsets.only(left: 20),
              child: (EditableListTile(
                  title: 'Seed',
                  currentValue: widget.config.seed.toString(),
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
