import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/vibe_config/view_models/vibe_config_viewmodel.dart';

class VibeConfigView extends StatelessWidget {
  final VibeConfigViewmodel viewmodel;
  final VoidCallback? onDelete;

  const VibeConfigView({
    super.key,
    required this.viewmodel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final widgetImage = SizedBox(
        height: 120.0,
        width: 120.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.memory(
            base64Decode(viewmodel.config.imageB64),
          ),
        ));

    return ListenableBuilder(
        listenable: viewmodel,
        builder: (context, child) {
          return Card(
            // Wrap with Card for better visual separation
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widgetImage,
                  const SizedBox(width: 16),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        viewmodel.fileName,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Reference Strength
                      Text(
                          'Strength: ${viewmodel.referenceStrength.toStringAsFixed(2)}'),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value:
                                  viewmodel.referenceStrength.clamp(0.0, 1.0),
                              min: 0.0,
                              max: 1.0,
                              divisions: 100,
                              label: viewmodel.referenceStrength
                                  .toStringAsFixed(2),
                              onChanged: (value) =>
                                  viewmodel.setReferenceStrength(value),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_note), // Changed icon
                            tooltip: "Edit Strength Value",
                            onPressed: () => _showEditReferenceStrengthDialog(
                                context, viewmodel),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      // Info extracted
                      Text(
                          'Information extracted: ${viewmodel.infoExtracted.toStringAsFixed(2)}'),
                      Row(children: [
                        Expanded(
                          child: Slider(
                            value: viewmodel.infoExtracted.clamp(0.0, 1.0),
                            min: 0.0,
                            max: 1.0,
                            divisions: 100,
                            label: viewmodel.infoExtracted.toStringAsFixed(2),
                            onChanged: (value) =>
                                viewmodel.setInfoExtracted(value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_note), // Changed icon
                          tooltip: "Edit Information Extracted",
                          onPressed: () =>
                              _showEditInfoExtractedDialog(context, viewmodel),
                        )
                      ]),
                    ],
                  )),
                  if (onDelete !=
                      null) // Show delete button only if callback is provided
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red[700]),
                      tooltip: "Delete Vibe Config",
                      onPressed: onDelete,
                    ),
                ],
              ),
            ),
          );
        });
  }

  void _showEditReferenceStrengthDialog(
      BuildContext context, VibeConfigViewmodel vm) {
    final TextEditingController controller =
        TextEditingController(text: vm.referenceStrength.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Reference Strength'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Value'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final double? newValue = double.tryParse(controller.text);
                if (newValue != null) {
                  vm.setReferenceStrength(newValue);
                }
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditInfoExtractedDialog(
      BuildContext context, VibeConfigViewmodel vm) {
    final TextEditingController controller =
        TextEditingController(text: vm.referenceStrength.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Edit Information Extracted'),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Value (0.0 to 1.0)'),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                final double? newValue = double.tryParse(controller.text);
                if (newValue != null && newValue >= 0.0 && newValue <= 1.0) {
                  vm.setInfoExtracted(newValue);
                  Navigator.of(dialogContext).pop();
                } else {
                  showErrorBar(context,
                      'Invalid value. Please enter a number between 0.0 and 1.0.');
                }
              },
            ),
          ],
        );
      },
    );
  }
}
