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
                      'Strength: ${widget.config.strength.toString()}; Noise: ${widget.config.noise.toString()}',
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
                  currentValue: widget.config.scale != null
                      ? '${widget.config.scale.toString()}x'
                      : 'None',
                  options: const ['None', '1x', '1.5x'],
                  onSelectComplete: (value) => _setI2IScale(value)))
        ]),

        // Strength
        ListTile(
            title:
                Text('Strength: ${widget.config.strength.toStringAsFixed(2)}'),
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
            title: Text('Noise: ${widget.config.noise.toStringAsFixed(2)}'),
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
    var decodedImage =
        img.decodeImage(bytes); // Assuming img is the correct image library

    if (decodedImage != null) {
      widget.config.inputImage = decodedImage;
      _loadImage();
    }
  }

  void _removeI2IImage() {
    widget.config.inputImage = null;
    _loadImage;
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

  _setI2IScale(String value) {
    setState(() {
      if (value == 'None') {
        widget.config.scale = null;
      } else {
        widget.config.scale = double.parse(value.split('x')[0]);
      }
    });
  }

  void _loadImage() async {
    if (widget.config.inputImage == null) {
      setState(() {
        _widgetImage = Icon(Icons.image_outlined,
            size: widget.imageSize, color: Colors.grey);
      });
    } else {
      var imageBytes = img.encodePng(widget.config.inputImage!);
      var image = Image.memory(imageBytes);
      setState(() {
        _widgetImage = SizedBox(
            width: widget.imageSize, height: widget.imageSize, child: image);
      });
    }
  }
}
