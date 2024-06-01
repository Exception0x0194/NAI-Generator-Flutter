import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../models/vibe_config.dart';

class VibeConfigWidget extends StatefulWidget {
  final VibeConfig config;

  const VibeConfigWidget({super.key, required this.config});

  @override
  VibeConfigWidgetState createState() => VibeConfigWidgetState();
}

class VibeConfigWidgetState extends State<VibeConfigWidget> {
  late double _infoExtracted;
  late double _referenceStrength;
  late Image _widgetImage;

  @override
  void initState() {
    super.initState();
    _infoExtracted = widget.config.infoExtracted;
    _referenceStrength = widget.config.referenceStrength;
    _widgetImage = Image.memory(img.encodePng(widget.config.inputImage));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display the image
        _widgetImage,
        // Slider for infoExtracted
        ListTile(
            title: Text(
                'Infomation Extracted: ${_infoExtracted.toStringAsFixed(2)}'),
            subtitle: Slider(
              value: _infoExtracted,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: _infoExtracted.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _infoExtracted = value;
                  widget.config.infoExtracted = value; // Update the config
                });
              },
            )),
        // Slider for referenceStrength
        ListTile(
            title: Text(
                'Reference Strength: ${_referenceStrength.toStringAsFixed(2)}'),
            subtitle: Slider(
              value: _referenceStrength,
              min: 0.0,
              max: 1.0,
              divisions: 100,
              label: _referenceStrength.toStringAsFixed(2),
              onChanged: (value) {
                setState(() {
                  _referenceStrength = value;
                  widget.config.referenceStrength = value; // Update the config
                });
              },
            )),
      ],
    );
  }
}
