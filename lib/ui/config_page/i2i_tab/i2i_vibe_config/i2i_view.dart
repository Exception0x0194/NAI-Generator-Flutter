import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/config_page/i2i_tab/i2i_vibe_config/i2i_viewmodel.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:nai_casrand/ui/core/widgets/slider_list_tile.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class I2iView extends StatelessWidget {
  final I2iVibeViewmodel viewmodel;

  I2iView({required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildImageWidget(context),

        Row(children: [
          Expanded(child: _buildSizeTile(context)),
          Expanded(child: _buildPresetTile(context)),
        ]),
        Row(children: [
          Expanded(child: _buildStrengthTile(context)),
          Expanded(child: _buildNoiseTile(context)),
        ]),
        // Prompt override settings
        CheckboxListTile(
            title: Text(context.tr('override_random_prompts')),
            secondary: const Icon(Icons.edit_note),
            value: viewmodel.config.overridePromptEnabled,
            onChanged: (value) => viewmodel.setOverridePromptEnabled(value)),
        viewmodel.config.overridePromptEnabled
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EditableListTile(
                    title: context.tr('override_prompt'),
                    currentValue: viewmodel.config.overridePrompt,
                    confirmOnSubmit: true,
                    onEditComplete: (value) =>
                        viewmodel.setOverridePrompt(value)))
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildImageWidget(BuildContext context) {
    // Image
    final Widget image;
    if (viewmodel.config.imageB64 == null) {
      image = Icon(Icons.add_photo_alternate_outlined,
          size: viewmodel.imageSize, color: Colors.grey.withAlpha(127));
    } else {
      image = Image.memory(
        base64Decode(viewmodel.config.imageB64!),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    final dropArea = InkWell(
        onTap: viewmodel.addImage(context),
        child: SizedBox(
            width: viewmodel.imageSize + 40.0,
            height: viewmodel.imageSize + 40.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Colors.grey.withAlpha(127), width: 2.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(child: image),
                    Text(context.tr('drag_and_drop_image_notice'))
                  ],
                ),
              ),
            )));

    // Buttons
    final buttons = Row(children: [
      if (viewmodel.config.imageB64 != null)
        Expanded(
            child: IconButton(
                onPressed: viewmodel.removeImage,
                icon: const Icon(Icons.delete_outline)))
    ]);

    void readFailureEvent() {
      showWarningBar(context, 'No metadta found in imported picture.');
    }

    void readSuccessEvent(Map<String, dynamic> parameters) {
      showInfoBar(context, 'Found metadata in imported picture.');
      _showImportMetadataDialog(context, parameters);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropRegion(
          formats: Formats.standardFormats,
          onDropOver: (_) => DropOperation.copy,
          onPerformDrop: (event) => viewmodel.handleDragEvent(
            event,
            readSuccessEvent,
            readFailureEvent,
          ),
          child: dropArea,
        ),
        buttons,
      ],
    );
  }

  void _showImportMetadataDialog(
      BuildContext context, Map<String, dynamic> parameters) {
    // TODO
  }

  Widget _buildSizeTile(BuildContext context) {
    return ListTile(
      title: Text(context.tr('image_size')),
      leading: const Icon(Icons.photo_size_select_large),
      subtitle: Text(viewmodel.getSizeChangeText()),
      onTap: () => _showI2ISizeDialog(context),
    );
  }

  void _showI2ISizeDialog(BuildContext context) {}

  Widget _buildPresetTile(BuildContext context) {
    final presetLevel = viewmodel.getEnhancePresetValue();
    final presetTile = SliderListTile(
      title: context.tr('enhance_presets') +
          context.tr('colon') +
          presetLevel.toInt().toString(),
      leading: const Icon(Icons.tune),
      sliderValue: presetLevel,
      min: 1,
      max: 5,
      divisions: 4,
      onChanged: (value) => viewmodel.setPreset(value),
    );
    return presetTile;
  }

  Widget _buildStrengthTile(BuildContext context) {
    return SliderListTile(
      title:
          'Strength${context.tr('colon')}${viewmodel.config.strength.toStringAsFixed(2)}',
      leading: const Icon(Icons.grain),
      sliderValue: viewmodel.config.strength,
      min: 0.0,
      max: 1.0,
      divisions: 100,
      onChanged: (value) => viewmodel.setStrength(value),
    );
  }

  Widget _buildNoiseTile(BuildContext context) {
    return SliderListTile(
      title:
          'Noise${context.tr('colon')}${viewmodel.config.noise.toStringAsFixed(2)}',
      leading: const Icon(Icons.waves),
      sliderValue: viewmodel.config.noise,
      min: 0.0,
      max: 1.0,
      divisions: 100,
      onChanged: (value) => viewmodel.setNoise(value),
    );
  }
}
