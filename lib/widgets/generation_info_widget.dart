import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/generation_info.dart';

class GenerationInfoWidget extends StatelessWidget {
  final GenerationInfo info;

  const GenerationInfoWidget({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: info.type == 'img' ? 600 : 300, // Adjust the width as needed
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(info.type == 'img' ? 'Generated Image' : 'Plain Log'),
              subtitle: Text(info.info),
            ),
            if (info.img != null)
              Expanded(
                child: Container(
                  alignment: Alignment.center,
                  child: info.img,
                ),
              ),
          ],
        ),
        Positioned(
          right: 0,
          child: IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => _copyToClipboard(context),
          ),
        ),
      ]),
    );
  }

  void _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: info.info));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Info copied to clipboard')),
    );
  }
}
