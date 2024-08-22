import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/info_manager.dart';
import '../models/utils.dart';
import '../models/generation_info.dart';

class GenerationInfoWidget extends StatelessWidget {
  final GenerationInfo info;
  final bool showInfoForImg;

  late final Image? displayImage;

  GenerationInfoWidget(
      {super.key, required this.info, required this.showInfoForImg}) {
    if (info.imageBytes != null) {
      displayImage = Image.memory(info.imageBytes!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (info.imageBytes != null) {
      return _buildImgWidget(context);
    } else {
      return LayoutBuilder(builder: ((context, constraints) {
        return _buildInfoWidget(context);
      }));
    }
  }

  Widget _buildInfoWidget(BuildContext context) {
    return Container(
      width: 300,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Stack(children: [
        ListView(children: [
          ListTile(
            title: Text('Log #${info.displayInfo['idx'].toString()}'),
            subtitle: Text(info.displayInfo['log'] ?? ''),
          )
        ]),
        Align(alignment: Alignment.topRight, child: _buildButtons(context)),
      ]),
    );
  }

  Widget _buildImgWidget(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey, width: 1),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Stack(
            children: [
              displayImage!,
              LayoutBuilder(builder: ((context, constraints) {
                var aspect = info.width! / info.height!;
                var width = aspect * constraints.maxHeight;
                return SizedBox(
                    width: width,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: ListTile(
                                  title: Text(
                                    info.displayInfo['filename']!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  dense: true)),
                          if (!showInfoForImg) _buildButtons(context)
                        ]));
              })),
            ],
          ),
          if (showInfoForImg) _buildInfoWidget(context)
        ]));
  }

  Widget _buildButtons(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2), shape: BoxShape.rectangle),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (info.imageBytes != null)
            IconButton(
              icon: const Icon(Icons.brush),
              onPressed: () => {_showI2IConfigDialog(context)},
            ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              copyToClipboard(info.displayInfo['log'] ?? '');
              showInfoBar(context, 'Copied info.');
            },
          ),
        ]));
  }

  void _showInfoDialog(BuildContext context) {
    final items = info.displayInfo.entries;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children: items.map((item) {
                return Stack(
                  children: [
                    ListTile(
                      title: Text(item.key),
                      subtitle: Text(item.value.toString()),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          copyToClipboard(item.value.toString());
                          Navigator.of(context)
                              .pop(); // Optional: close the dialog after copying
                          showInfoBar(
                              context, 'Copied ${item.key} to clipboard.');
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  void _showI2IConfigDialog(BuildContext context) {
    bool once = true;
    bool ovverridePrompt = true;
    bool overrideSmea = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(context.tr('set_enhancement_parameters')),
            content: SingleChildScrollView(
              child: ListBody(children: [
                ExpansionTile(
                    title: Text(context.tr('enhance_scale')),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                              children: getPossibleScaleFactors(
                                      info.width!, info.height!)
                                  .map((value) {
                            return ListTile(
                              title: Text('${value}x'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setI2IConfig(
                                    context, value, once, ovverridePrompt);
                              },
                            );
                          }).toList()))
                    ]),
                SwitchListTile(
                    title: Text(context.tr('enhance_override_prompts')),
                    dense: true,
                    value: ovverridePrompt,
                    onChanged: (value) {
                      setDialogState(() => ovverridePrompt = value);
                    }),
                SwitchListTile(
                    title: Text(context.tr('enhance_override_smea')),
                    dense: true,
                    value: overrideSmea,
                    onChanged: (value) {
                      setDialogState(() => overrideSmea = value);
                    }),
              ]),
            ),
          );
        });
      },
    );
  }

  void _setI2IConfig(
      BuildContext context, double scale, bool once, bool overridePrompt) {
    if (overridePrompt) {
      InfoManager().i2iConfig.overridePromptEnabled = true;
      InfoManager().i2iConfig.overridePrompt = info.displayInfo['prompt'];
    }
    int targetWidth = (scale * info.width! / 64).ceil() * 64;
    int targetHeight = (scale * info.height! / 64).ceil() * 64;
    // InfoManager().i2iConfig.width = targetWidth;
    // InfoManager().i2iConfig.height = targetHeight;
    InfoManager().paramConfig.width = targetWidth;
    InfoManager().paramConfig.height = targetHeight;
    InfoManager().i2iConfig.setImage(info.imageBytes!);

    showInfoBar(context, context.tr('i2i_conifgs_set'));
  }
}
