import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/config_page/i2i_tab/i2i_vibe_config/vibe_viewmodel.dart';
import 'package:provider/provider.dart';

class VibeView extends StatelessWidget {
  final VibeViewmodel viewmodel;

  const VibeView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final widgetImage = SizedBox(
      height: 200.0,
      width: 200.0,
      child: Image.memory(base64Decode(viewmodel.config.imageB64)),
    );
    return ChangeNotifierProvider.value(
        value: viewmodel,
        child: Consumer<VibeViewmodel>(builder: (context, viewmodel, child) {
          return Row(
            children: [
              widgetImage,
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Info Extracted
                  ListTile(
                      title: Text(
                          'Infomation Extracted: ${viewmodel.config.infoExtracted.toStringAsFixed(2)}'),
                      subtitle: Row(children: [
                        Expanded(
                            child: Slider(
                          value: viewmodel.config.infoExtracted.clamp(0.0, 1.0),
                          min: 0.0,
                          max: 1.0,
                          divisions: 100,
                          onChanged: (value) =>
                              viewmodel.setInfoExtracted(value),
                        )),
                        IconButton(
                            onPressed: () =>
                                _showEditInfoExtractedDialog(context),
                            icon: const Icon(Icons.construction))
                      ])),
                  // Reference Strength
                  ListTile(
                      title: Text(
                          'Reference Strength: ${viewmodel.config.referenceStrength.toStringAsFixed(2)}'),
                      subtitle: Row(children: [
                        Expanded(
                            child: Slider(
                          value: viewmodel.config.referenceStrength
                              .clamp(0.0, 1.0),
                          min: 0.0,
                          max: 1.0,
                          divisions: 100,
                          onChanged: (value) =>
                              viewmodel.setReferenceStrength(value),
                        )),
                        IconButton(
                            onPressed: () =>
                                _showEditReferenceStrengthDialog(context),
                            icon: const Icon(Icons.construction))
                      ])),
                ],
              ))
            ],
          );
        }));
  }

  void _showEditReferenceStrengthDialog(BuildContext context) {}

  void _showEditInfoExtractedDialog(BuildContext context) {}
}
