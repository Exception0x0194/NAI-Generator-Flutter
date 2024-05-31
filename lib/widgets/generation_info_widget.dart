import 'package:flutter/material.dart';
import 'package:nai_casrand/models/utils.dart';

import '../models/generation_info.dart';

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
                var width = aspect * constraints.maxHeight - 80;
                return SizedBox(
                  width: width,
                  child: ListTile(title: Text(info.info['filename']!)),
                );
              })),
              if (!showInfoForImg) _buildButtons(context)
            ],
          ),
          if (showInfoForImg) _buildInfoWidget(context, margined: false)
        ]));
  }

  Widget _buildButtons(BuildContext context) {
    return Positioned(
        right: 0,
        top: 0,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
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
        ]));
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
}
