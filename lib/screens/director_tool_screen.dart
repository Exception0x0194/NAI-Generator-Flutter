import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import "package:super_clipboard/super_clipboard.dart";
import 'package:easy_localization/easy_localization.dart';

import '../models/director_tool_config.dart';
import '../models/info_manager.dart';
import '../widgets/editable_list_tile.dart';
import '../generated/l10n.dart';

const imageFormat = SimpleFileFormat(
  // JPG, PNG, GIF, WEBP, BMP
  uniformTypeIdentifiers: [
    'public.jpeg',
    'public.png',
    'com.compuserve.gif',
    'org.webmproject.webp',
    'com.microsoft.bmp'
  ],
  windowsFormats: ['JFIF', 'PNG', 'GIF', 'image/webp', 'image/bmp'],
  mimeTypes: [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp'
  ],
);

class DirectorToolScreen extends StatefulWidget {
  DirectorToolScreen({super.key});

  final DirectorToolConfig config = InfoManager().directorToolConfig;
  final emotionTypes = [
    'neutral',
    'happy',
    'sad',
    'angry',
    'scared',
    'surprised',
    'tired',
    'excited',
    'nervous',
    'thinking',
    'confused',
    'shy',
    'disgusted',
    'smug',
    'bored',
    'laughing',
    'irritated',
    'aroused',
    'embarrassed',
    'worried',
    'love',
    'determined',
    'hurt',
    'playful'
  ];
  final toolTypes = [
    'bg-removal',
    'lineart',
    'sketch',
    'colorize',
    'emotion',
    'declutter',
  ];
  final displayedToolTypes = [
    'Remove BG',
    'Line Art',
    'Sketch',
    'Colorize',
    'Emotion',
    'Declutter',
  ];
  final imageSize = 300.0;

  @override
  State<StatefulWidget> createState() => DirectorToolScreenState();
}

class DirectorToolScreenState extends State<DirectorToolScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ExpansionTile(
          leading: const Icon(Icons.open_in_new),
          title: const Text('Director Tools'),
          initiallyExpanded: true,
          children: [
            _buildImageTile(),
            _buildTypeSelectionTile(),
            if (widget.config.withPrompt) ...[
              _buildPromptTile(),
              _buildDefryTile()
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeSelectionTile() {
    return Column(children: [
      // Tool type selection
      SelectableListTile(
          title: context.tr('director_tool_type'),
          leading: const Icon(Icons.handyman),
          currentValue: widget.config.type,
          options: widget.toolTypes,
          options_text: widget.displayedToolTypes,
          onSelectComplete: (value) => setState(() {
                widget.config.type = value;
              })),
      // Emition selection (if required)
      widget.config.type == 'emotion'
          ? Padding(
              padding: const EdgeInsets.only(left: 20),
              child: _buildEmotionSelectionTile())
          : const SizedBox.shrink()
    ]);
  }

  Widget _buildDefryTile() {
    return Column(
      children: [
        ListTile(
          title: const Text('Defry'),
          subtitle: Text(widget.config.defry.toString()),
          leading: const Icon(Icons.tune),
        ),
        Padding(
            padding: const EdgeInsets.only(left: 40),
            child: SizedBox(
                height: 30,
                child: Slider(
                    value: widget.config.defry.toDouble(),
                    min: 0,
                    max: 5,
                    divisions: 5,
                    onChanged: (value) => setState(() {
                          widget.config.defry = value.toInt();
                        }))))
      ],
    );
  }

  Widget _buildImageTile() {
    final Widget image;
    if (widget.config.imageB64 == null) {
      image = Icon(Icons.add_photo_alternate_outlined,
          size: widget.imageSize, color: Colors.grey.withAlpha(127));
    } else {
      image = Image.memory(
        base64Decode(widget.config.imageB64!),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      );
    }
    final dropArea = InkWell(
        onTap: _addDirectorImage,
        child: SizedBox(
            width: widget.imageSize + 40.0,
            height: widget.imageSize + 40.0,
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

    return Column(children: [
      DropRegion(
        formats: Formats.standardFormats,
        onDropOver: (_) => DropOperation.copy,
        onPerformDrop: (event) async {
          final item = event.session.items.first;
          final reader = item.dataReader!;
          reader.getFile(imageFormat, (file) async {
            final data = await file.readAll();
            widget.config.imageB64 = base64Encode(data);
            setState(() {});
          });
        },
        child: dropArea,
      ),
      Row(
        children: [
          if (widget.config.imageB64 != null)
            Expanded(
                child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeDirectorImage(),
            )),
        ],
      ),
    ]);
  }

  void _addDirectorImage() async {
    var picker = ImagePicker();
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var bytes = await pickedFile.readAsBytes();
    widget.config.imageB64 = base64Encode(bytes);
    setState(() {});
  }

  void _removeDirectorImage() {
    widget.config.imageB64 = null;
    setState(() {});
  }

  Widget _buildEmotionSelectionTile() {
    showEmotionSelectionDialog() {
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                    title: Text('${context.tr('edit')} emotions:'),
                    content: SingleChildScrollView(
                      child: Column(
                          children: widget.emotionTypes
                              .map((e) => CheckboxListTile(
                                  title: Text(e),
                                  value: widget.config.emotions.contains(e),
                                  dense: true,
                                  onChanged: (bool? value) {
                                    setDialogState(() {
                                      if (value == null) return;
                                      if (value) {
                                        widget.config.emotions.add(e);
                                      } else if (widget.config.emotions.length >
                                          1) {
                                        widget.config.emotions.remove(e);
                                      }
                                    });
                                    setState(() {});
                                  }))
                              .toList()),
                    ),
                    actions: [
                      TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: Text(context.tr('confirm')))
                    ],
                  )));
    }

    return ListTile(
        leading: const Icon(Icons.add_reaction_outlined),
        title: const Text('Emotion'),
        subtitle: Text(widget.config.emotions.join(', ')),
        onTap: () => showEmotionSelectionDialog());
  }

  Widget _buildPromptTile() {
    return Column(
      children: [
        CheckboxListTile(
            title: Text(context.tr('override_random_prompts')),
            secondary: const Icon(Icons.edit_note),
            value: widget.config.overrideEnabled,
            onChanged: (value) => setState(() {
                  widget.config.overrideEnabled = value!;
                })),
        widget.config.overrideEnabled
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EditableListTile(
                    title: context.tr('override_prompt'),
                    currentValue: widget.config.overridePrompt,
                    confirmOnSubmit: true,
                    onEditComplete: (value) => setState(() {
                          widget.config.overridePrompt = value;
                        })))
            : const SizedBox.shrink()
      ],
    );
  }
}
