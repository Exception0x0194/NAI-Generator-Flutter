import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nai_casrand/models/info_manager.dart';
import 'package:nai_casrand/models/utils.dart';

import '../models/generation_info.dart';
import '../generated/l10n.dart';

class GenerationInfoWidget extends StatelessWidget {
  final GenerationInfo info;
  final bool showInfoForImg;

  const GenerationInfoWidget(
      {super.key, required this.info, required this.showInfoForImg});

  @override
  Widget build(BuildContext context) {
    if (info.type == 'img') {
      return _buildImgWidget(context);
    } else {
      return LayoutBuilder(builder: ((context, constraints) {
        return _buildInfoWidget(context);
      }));
    }
  }

  Widget _buildInfoWidget(BuildContext context, {bool margined = true}) {
    return Container(
      width: 300,
      decoration: margined
          ? BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
            )
          : null,
      margin: margined
          ? const EdgeInsets.symmetric(vertical: 8, horizontal: 8)
          : null,
      child: Stack(children: [
        ListView(children: [
          ListTile(
            title: Text('Log #${info.info['idx'].toString()}'),
            subtitle: Text(info.info['log'] ?? ''),
          )
        ]),
        _buildButtons(context),
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
              info.img!,
              LayoutBuilder(builder: ((context, constraints) {
                var aspect = info.info['width']! / info.info['height']!;
                var width = aspect * constraints.maxHeight;
                return SizedBox(
                    width: width,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: ListTile(
                                  title: Text(info.info['filename']!),
                                  dense: true)),
                          if (!showInfoForImg) _buildButtons(context)
                        ]));
              })),
            ],
          ),
          if (showInfoForImg) _buildInfoWidget(context, margined: false)
        ]));
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
        right: 0,
        top: 0,
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.rectangle),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (info.type == 'img')
                IconButton(
                  icon: const Icon(Icons.brush),
                  onPressed: () => {_showI2IConfigDialog(context)},
                ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => {_showInfoDialog(context, info.info)},
              ),
              IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () {
                  copyToClipboard(info.info['log'] ?? '');
                  showInfoBar(context, 'Copied info.');
                },
              ),
            ])));
  }

  void _showInfoDialog(BuildContext context, Map<String, dynamic> info) {
    const keysToShow = ['filename', 'log', 'prompt', 'seed'];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Info Details'),
          content: SingleChildScrollView(
            child: ListBody(
              children:
                  keysToShow.where((key) => info.containsKey(key)).map((key) {
                return Stack(
                  children: [
                    ListTile(
                      title: Text(key),
                      subtitle: Text(info[key].toString()),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          copyToClipboard(info[key].toString());
                          Navigator.of(context)
                              .pop(); // Optional: close the dialog after copying
                          showInfoBar(context, 'Copied $key to clipboard.');
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
            title: Text(S.of(context).set_enhancement_parameters),
            content: SingleChildScrollView(
              child: ListBody(children: [
                ExpansionTile(
                    title: Text(S.of(context).enhance_scale),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(children: [
                            ListTile(
                              title: const Text('1.0x'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setI2IConfig(
                                    context, 1.0, once, ovverridePrompt);
                              },
                            ),
                            ListTile(
                              title: const Text('1.5x'),
                              onTap: () {
                                Navigator.of(context).pop();
                                _setI2IConfig(
                                    context, 1.5, once, ovverridePrompt);
                              },
                            )
                          ]))
                    ]),
                // SwitchListTile(
                //     title: Text(S.of(context).enhance_only_once),
                //     dense: true,
                //     value: once,
                //     onChanged: (value) {
                //       setDialogState(() => once = value);
                //     }),
                SwitchListTile(
                    title: Text(S.of(context).enhance_override_prompts),
                    dense: true,
                    value: ovverridePrompt,
                    onChanged: (value) {
                      setDialogState(() => ovverridePrompt = value);
                    }),
                SwitchListTile(
                    title: Text(S.of(context).enhance_override_smea),
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
      InfoManager().i2iConfig.overridePrompt = info.info['prompt'];
    }
    int targetWidth = (scale * info.info['width'] / 64).ceil() * 64;
    int targetHeight = (scale * info.info['height'] / 64).ceil() * 64;
    // InfoManager().i2iConfig.width = targetWidth;
    // InfoManager().i2iConfig.height = targetHeight;
    InfoManager().paramConfig.width = targetWidth;
    InfoManager().paramConfig.height = targetHeight;
    InfoManager().i2iConfig.imgB64 = base64Encode(info.info['bytes']);

    showInfoBar(context, S.of(context).i2i_conifgs_set);
  }
}
