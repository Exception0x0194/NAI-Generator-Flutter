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
        EditableListTile(
          title: "Width",
          currentValue: widget.config.width.toString(),
          onEditComplete: (value) => setState(() =>
              widget.config.width = int.tryParse(value) ?? widget.config.width),
          keyboardType: TextInputType.number,
        ),
        EditableListTile(
          title: "Height",
          currentValue: widget.config.height.toString(),
          onEditComplete: (value) => setState(() => widget.config.height =
              int.tryParse(value) ?? widget.config.height),
          keyboardType: TextInputType.number,
        ),
        EditableListTile(
          title: "Scale",
          currentValue: widget.config.scale.toString(),
          onEditComplete: (value) => setState(() => widget.config.scale =
              double.tryParse(value) ?? widget.config.scale),
          keyboardType: TextInputType.number,
        ),
        EditableListTile(
          title: "CFG Rescale",
          currentValue: widget.config.cfgRescale.toString(),
          onEditComplete: (value) => setState(() => widget.config.cfgRescale =
              double.tryParse(value) ?? widget.config.cfgRescale),
          keyboardType: TextInputType.number,
        ),
        _buildSamplerSelector(),
        _buildSwitchTile("SM", widget.config.sm, (newValue) {
          setState(() => widget.config.sm = newValue);
        }),
        _buildSwitchTile("SM Dyn", widget.config.smDyn, (newValue) {
          setState(() => widget.config.smDyn = newValue);
        }),
        EditableListTile(
          title: "UC",
          currentValue: widget.config.negativePrompt,
          onEditComplete: (value) =>
              setState(() => widget.config.negativePrompt = value),
          keyboardType: TextInputType.text,
        ),
        // ListTile(
        //   title: const Text('UC'),
        //   subtitle: Padding(
        //       padding: const EdgeInsets.only(left: 20.0),
        //       child: ListTile(
        //         subtitle: Text(widget.config.negativePrompt),
        //         onTap: () {
        //           _editUC();
        //         },
        //       )),
        // )
      ],
    );
  }

  Widget _buildSwitchTile(
      String title, bool currentValue, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      onChanged: onChanged,
      subtitle: Text(currentValue ? "Enabled" : "Disabled"),
    );
  }

  Widget _buildSamplerSelector() {
    return ListTile(
      title: const Text('Sampler'),
      trailing: DropdownButton<String>(
        value: widget.config.sampler,
        onChanged: (String? newValue) {
          setState(() {
            widget.config.sampler = newValue!;
          });
        },
        items: <String>['k_euler', 'k_euler_ancestral', 'k_dpmpp_2s_ancestral']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        underline: Container(), // 移除下划线
      ),
    );
  }

  void _editUC() {
    TextEditingController controller =
        TextEditingController(text: widget.config.negativePrompt);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit UC'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.multiline,
            maxLines: null, // 允许无限行
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  widget.config.negativePrompt = controller.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }
}
