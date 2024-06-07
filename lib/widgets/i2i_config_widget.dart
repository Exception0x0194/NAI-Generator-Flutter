import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late Widget _widgetImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
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
          if (widget.config.imgB64 != null)
            Expanded(
                child: IconButton(
                    onPressed: _removeI2IImage,
                    icon: const Icon(Icons.delete_outline)))
        ]),

        // Presets
        ListTile(
          title: Text('Enhance Presets'),
          leading: Icon(Icons.tune),
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
        Padding(
            padding: EdgeInsets.only(left: 20),
            child: ExpansionTile(
              title: Text('Manual...'),
              leading: Icon(Icons.back_hand),
              dense: true,
              children: [
                // Strength
                ListTile(
                    title: Text(
                        'Strength: ${widget.config.strength.toStringAsFixed(2)}'),
                    leading: Icon(Icons.grain),
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
                    )),
                // Noise
                ListTile(
                    title: Text(
                        'Noise: ${widget.config.noise.toStringAsFixed(2)}'),
                    leading: Icon(Icons.water),
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
                    ))
              ],
            )),
        // Prompt overwrite settings
        SwitchListTile(
            title: const Text('Override Prompts'),
            value: widget.config.isOverwritten,
            onChanged: (value) {
              setState(() {
                widget.config.isOverwritten = value;
              });
            }),
        widget.config.isOverwritten
            ? EditableListTile(
                title: '',
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

  _setI2IPreset(String value) {
    var parts = value.split('; ');
    setState(() {
      widget.config.strength =
          double.parse(parts[0].substring('Strength: '.length - 1));
      widget.config.noise =
          double.parse(parts[1].substring('Noise: '.length - 1));
    });
  }

  void _loadImage() {
    if (widget.config.imgB64 == null) {
      setState(() {
        _widgetImage = Icon(Icons.image_outlined,
            size: widget.imageSize, color: Colors.grey);
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
