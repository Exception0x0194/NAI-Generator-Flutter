import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nai_casrand/widgets/editable_list_tile.dart';

import '../models/i2i_config.dart';
import '../generated/l10n.dart';

class I2IConfigWidget extends StatefulWidget {
  final I2IConfig config;

  final double imageSize = 300;

  const I2IConfigWidget({super.key, required this.config});

  @override
  I2IConfigWidgetState createState() => I2IConfigWidgetState();
}

class I2IConfigWidgetState extends State<I2IConfigWidget> {
  late Widget _widgetImage;

  @override
  void initState() {
    super.initState();
    widget.config.addListener(_loadImage);
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image
        _widgetImage,
        // Buttons
        widget.config.imgB64 != null
            ? Row(children: [
                Expanded(
                    child: IconButton(
                        onPressed: _addI2IImage,
                        icon: const Icon(Icons.cached))),
                Expanded(
                    child: IconButton(
                        onPressed: _removeI2IImage,
                        icon: const Icon(Icons.delete_outline)))
              ])
            : Row(children: [
                Expanded(
                    child: IconButton(
                        onPressed: _addI2IImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined)))
              ]),
        // Presets
        ListTile(
          title: Text(S.of(context).enhance_presets),
          leading: const Icon(Icons.tune),
          subtitle: Slider(
            value: _getEnhancePresetValue(),
            min: 1,
            max: 5,
            divisions: 4,
            label:
                'Strength: ${widget.config.strength}; Noise: ${widget.config.noise}',
            onChanged: (value) {
              setState(() {
                var result = [
                  [0.2, 0],
                  [0.4, 0],
                  [0.5, 0],
                  [0.6, 0],
                  [0.7, 0.1]
                ][value.toInt() - 1];
                widget.config.strength = result[0].toDouble();
                widget.config.noise = result[1].toDouble();
              });
            },
          ),
        ),
        Row(
          children: [
            // Strength
            Expanded(
                child: ListTile(
                    title: Text(
                        'Strength: ${widget.config.strength.toStringAsFixed(2)}'),
                    leading: const Icon(Icons.grain),
                    dense: true,
                    subtitle: Slider(
                      value: widget.config.strength,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: widget.config.strength.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() {
                          widget.config.strength = value;
                        });
                      },
                    ))),
            // Noise
            Expanded(
                child: ListTile(
                    title: Text(
                        'Noise: ${widget.config.noise.toStringAsFixed(2)}'),
                    leading: const Icon(Icons.water),
                    dense: true,
                    subtitle: Slider(
                      value: widget.config.noise,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: widget.config.noise.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() {
                          widget.config.noise = value;
                        });
                      },
                    )))
          ],
        ),
        // SMEA override settings
        SwitchListTile(
            title: Text(S.of(context).enhance_override_smea),
            secondary: const Icon(Icons.keyboard_double_arrow_right),
            value: widget.config.overrideSmea,
            onChanged: (value) => setState(() {
                  widget.config.overrideSmea = value;
                })),
        // Prompt override settings
        SwitchListTile(
            title: Text(S.of(context).override_random_prompts),
            secondary: const Icon(Icons.edit_note),
            value: widget.config.overridePromptEnabled,
            onChanged: (value) {
              setState(() {
                widget.config.overridePromptEnabled = value;
              });
            }),
        widget.config.overridePromptEnabled
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EditableListTile(
                    title: S.of(context).override_prompt,
                    currentValue: widget.config.overridePrompt,
                    onEditComplete: (value) {
                      setState(() {
                        widget.config.overridePrompt = value;
                      });
                    }))
            : const SizedBox.shrink(),
      ],
    );
  }

  // void _downloadI2IImage() {
  //   saveBlob(img.encodePng(widget.config.inputImage!),
  //       'nai-generator-I2I-${generateRandomFileName()}.png');
  //   showInfoBar(
  //       context, '${S.of(context).vibe_export}${S.of(context).succeed}');
  // }

  void _addI2IImage() async {
    var picker = ImagePicker();
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var bytes = await pickedFile.readAsBytes();
    widget.config.imgB64 = base64Encode(bytes);
    _loadImage();
  }

  void _removeI2IImage() {
    widget.config.imgB64 = null;
    _loadImage();
  }

  void _loadImage() {
    if (widget.config.imgB64 == null) {
      setState(() {
        _widgetImage = const SizedBox.shrink();
      });
    } else {
      setState(() {
        _widgetImage = SizedBox(
            width: widget.imageSize,
            height: widget.imageSize,
            child: Image.memory(base64Decode(widget.config.imgB64!)));
      });
    }
  }

  double _getEnhancePresetValue() {
    var s = widget.config.strength;
    if (s <= 0.2) return 1;
    if (s <= 0.4) return 2;
    if (s <= 0.5) return 3;
    if (s <= 0.6) return 4;
    return 5;
  }
}
