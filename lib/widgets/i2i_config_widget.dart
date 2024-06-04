import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:nai_casrand/widgets/editable_list_tile.dart';

import '../models/i2i_config.dart';
import '../models/utils.dart';
import '../generated/l10n.dart';

class I2IConfigWidget extends StatefulWidget {
  final I2IConfig config;

  final double imageSize = 300;

  const I2IConfigWidget({super.key, required this.config});

  @override
  I2IConfigWidgetState createState() => I2IConfigWidgetState();
}

class I2IConfigWidgetState extends State<I2IConfigWidget> {
  late double _strength;
  late double _noise;
  late Widget _widgetImage;

  @override
  void initState() {
    super.initState();
    _strength = widget.config.strength;
    _noise = widget.config.noise;
    _widgetImage = widget.config.inputImage != null
        ? SizedBox(
            width: widget.imageSize,
            height: widget.imageSize,
            child: Image.memory(img.encodePng(widget.config.inputImage!)))
        : Icon(
            Icons.image_outlined,
            size: widget.imageSize,
            color: Colors.grey,
          );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _widgetImage,
        Row(children: [
          Expanded(
              child: IconButton(
                  onPressed: _addI2IImage, icon: const Icon(Icons.add))),
          if (widget.config.inputImage != null)
            Expanded(
                child: IconButton(
                    onPressed: _removeI2IImage,
                    icon: const Icon(Icons.delete_outline)))
        ]),

        // Presets
        Row(mainAxisSize: MainAxisSize.min, children: [
          Expanded(
              child: SelectableListTile(
                  title: 'Enhance Presets',
                  currentValue:
                      'Strength: ${_strength.toString()}; Noise: ${_noise.toString()}',
                  options: const [
                    'Strength: 0.2; Noise: 0',
                    'Strength: 0.4; Noise: 0',
                    'Strength: 0.5; Noise: 0',
                    'Strength: 0.6; Noise: 0',
                    'Strength: 0.7; Noise: 0.1'
                  ],
                  onSelectComplete: (value) => _setI2IPreset(value))),
          Expanded(
              child: SelectableListTile(
                  title: 'Scale',
                  currentValue: '1x',
                  options: const ['1x', '1.5x'],
                  onSelectComplete: (value) => _setI2IScale(value)))
        ]),

        // Strength
        ListTile(
            title: Text('Strength: ${_strength.toStringAsFixed(2)}'),
            subtitle: Slider(
              value: _strength,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: _strength.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _strength = value;
                  widget.config.strength = value; // Update the config
                });
              },
            )),
        // Noise
        ListTile(
            title: Text('Noise: ${_noise.toStringAsFixed(2)}'),
            subtitle: Slider(
              value: _noise,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: _noise.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _noise = value;
                  widget.config.noise = value; // Update the config
                });
              },
            )),
        // Prompt overwrite settings
        SwitchListTile(
            title: const Text('Overwrite Prompts'),
            value: widget.config.isOverwritten,
            onChanged: (value) {
              setState(() {
                widget.config.isOverwritten = value;
              });
            }),
        widget.config.isOverwritten
            ? EditableListTile(
                title: 'Overwritten Prompts',
                currentValue: widget.config.overwrittenPrompt,
                onEditComplete: (value) {
                  setState(() {
                    widget.config.overwrittenPrompt = value;
                  });
                })
            : const SizedBox.shrink(),
      ],
    );
  }

  void _downloadI2IImage() {
    saveBlob(img.encodePng(widget.config.inputImage!),
        'nai-generator-I2I-${generateRandomFileName()}.png');
    showInfoBar(
        context, '${S.of(context).vibe_export}${S.of(context).succeed}');
  }

  void _addI2IImage() async {
    var picker = ImagePicker();
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var bytes = await pickedFile.readAsBytes();
    setState(() {
      widget.config.inputImage = img.decodeImage(bytes);
      _widgetImage = SizedBox(
          width: widget.imageSize,
          height: widget.imageSize,
          child: Image.memory(bytes));
    });
  }

  void _removeI2IImage() {
    setState(() {
      widget.config.inputImage = null;
      _widgetImage = Icon(
        Icons.image_outlined,
        size: widget.imageSize,
        color: Colors.grey,
      );
    });
  }

  _setI2IPreset(String value) {
    var parts = value.split('; ');
    setState(() {
      widget.config.strength =
          double.parse(parts[0].substring('Strength: '.length - 1));
      widget.config.noise =
          double.parse(parts[1].substring('Noise: '.length - 1));
      _strength = widget.config.strength;
      _noise = widget.config.noise;
    });
  }

  _setI2IScale(String value) {}
}
