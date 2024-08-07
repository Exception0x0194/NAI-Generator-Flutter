import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nai_casrand/models/info_manager.dart';

import '../models/director_tool_config.dart';
import '../widgets/editable_list_tile.dart';
import '../generated/l10n.dart';

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
  Image? _widgetImage;

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
          title: S.of(context).director_tool_type,
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
    return Column(children: [
      _widgetImage != null
          ? Padding(
              padding: const EdgeInsets.all(10),
              child: SizedBox(
                  width: widget.imageSize,
                  height: widget.imageSize,
                  child: _widgetImage),
            )
          : const SizedBox.shrink(),
      Row(
        children: [
          Expanded(
              child: IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: () => _addDirectorImage(),
          )),
          widget.config.imageB64 == null
              ? const SizedBox.shrink()
              : Expanded(
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
    _loadImage();
  }

  void _removeDirectorImage() {
    setState(() {
      widget.config.imageB64 = null;
      _loadImage();
    });
  }

  void _loadImage() {
    if (widget.config.imageB64 == null) {
      setState(() {
        _widgetImage = null;
      });
    } else {
      var image = Image.memory(
        base64Decode(widget.config.imageB64!),
        filterQuality: FilterQuality.medium,
        fit: BoxFit.contain,
      );
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          widget.config.width = info.image.width;
          widget.config.height = info.image.height;
        });
      }));
      setState(() {
        _widgetImage = image;
      });
    }
  }

  Widget _buildEmotionSelectionTile() {
    showEmotionSelectionDialog() {
      showDialog(
          context: context,
          builder: (context) => StatefulBuilder(
              builder: (context, setDialogState) => AlertDialog(
                    title: Text('${S.of(context).edit} emotions:'),
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
                          child: Text(S.of(context).confirm))
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
            title: Text(S.of(context).override_random_prompts),
            secondary: const Icon(Icons.edit_note),
            value: widget.config.overrideEnabled,
            onChanged: (value) => setState(() {
                  widget.config.overrideEnabled = value!;
                })),
        widget.config.overrideEnabled
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EditableListTile(
                    title: S.of(context).override_prompt,
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
