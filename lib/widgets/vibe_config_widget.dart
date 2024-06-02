import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import '../models/vibe_config.dart';
import '../models/utils.dart';
import '../generated/l10n.dart';

class VibeConfigWidget extends StatefulWidget {
  final VibeConfig config;

  const VibeConfigWidget({super.key, required this.config});

  @override
  VibeConfigWidgetState createState() => VibeConfigWidgetState();
}

class VibeConfigWidgetState extends State<VibeConfigWidget> {
  late double _infoExtracted;
  late double _referenceStrength;
  late Widget _widgetImage;

  @override
  void initState() {
    super.initState();
    _infoExtracted = widget.config.infoExtracted;
    _referenceStrength = widget.config.referenceStrength;
    _widgetImage = SizedBox(
        width: 200,
        height: 200,
        child: Stack(children: [
          Image.memory(
            img.encodePng(widget.config.inputImage),
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadVibeImage,
            ),
          )
        ]));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _widgetImage,
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Info Extracted
            ListTile(
                title: Text(
                    'Infomation Extracted: ${_infoExtracted.toStringAsFixed(2)}'),
                subtitle: Row(children: [
                  Expanded(
                      child: Slider(
                    value: _infoExtracted > 1
                        ? 1
                        : _infoExtracted < 0
                            ? 0
                            : _infoExtracted,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: _infoExtracted.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _infoExtracted = value;
                        widget.config.infoExtracted =
                            value; // Update the config
                      });
                    },
                  )),
                  IconButton(
                      onPressed: _showEditInfoExtractedDialog,
                      icon: const Icon(Icons.construction))
                ])),
            // Reference Strength
            ListTile(
                title: Text(
                    'Reference Strength: ${_referenceStrength.toStringAsFixed(2)}'),
                subtitle: Row(children: [
                  Expanded(
                      child: Slider(
                    value: _referenceStrength > 1
                        ? 1
                        : _referenceStrength < 0
                            ? 0
                            : _referenceStrength,
                    min: 0.0,
                    max: 1.0,
                    divisions: 100,
                    label: _referenceStrength.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() {
                        _referenceStrength = value;
                        widget.config.referenceStrength =
                            value; // Update the config
                      });
                    },
                  )),
                  IconButton(
                      onPressed: _showEditReferenceStrengthDialog,
                      icon: const Icon(Icons.construction))
                ])),
          ],
        ))
      ],
    );
  }

  void _downloadVibeImage() {
    saveBlob(img.encodePng(widget.config.inputImage),
        'nai-generator-vibe-${generateRandomFileName()}.png');
    showInfoBar(
        context, '${S.of(context).vibe_export}${S.of(context).succeed}');
  }

  void _showEditReferenceStrengthDialog() {
    final controller =
        TextEditingController(text: widget.config.referenceStrength.toString());
    void onEditComplete(String value) {
      var n = double.tryParse(value);
      if (n == null) {
        return;
      }
      setState(() {
        widget.config.referenceStrength = n;
        _referenceStrength = n;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${S.of(context).edit}Reference Strength'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(S.of(context).notNecessarily0to1),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                maxLines: null,
                onSubmitted: (_) {
                  Navigator.of(context).pop();
                  onEditComplete(controller.text);
                },
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEditComplete(controller.text);
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }

  void _showEditInfoExtractedDialog() {
    final controller =
        TextEditingController(text: widget.config.infoExtracted.toString());
    void onEditComplete(String value) {
      var n = double.tryParse(value);
      if (n == null) {
        return;
      }
      setState(() {
        widget.config.infoExtracted = n;
        _infoExtracted = n;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('${S.of(context).edit}Information Extracted'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(S.of(context).notNecessarily0to1),
              TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(
                    signed: true, decimal: true),
                maxLines: null,
                onSubmitted: (_) {
                  Navigator.of(context).pop();
                  onEditComplete(controller.text);
                },
                autofocus: true,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onEditComplete(controller.text);
              },
              child: Text(S.of(context).confirm),
            ),
          ],
        );
      },
    );
  }
}
