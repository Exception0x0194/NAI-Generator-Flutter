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

  @override
  State<StatefulWidget> createState() => DirectorToolScreenState();
}

class DirectorToolScreenState extends State<DirectorToolScreen> {
  Image? _widgetImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        _buildTypeSelectionTile(),
        _buildDefryTile(),
        _buildImageTile(),
      ]),
    );
  }

  Widget _buildTypeSelectionTile() {
    const toolTypes = ['colorize', 'emotion'];

    return Column(children: [
      // Tool type selection
      SelectableListTile(
          title: 'Tool Type',
          leading: const Icon(Icons.handyman),
          currentValue: widget.config.type,
          options: toolTypes,
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
        SizedBox(
            height: 30,
            child: Slider(
                value: widget.config.defry.toDouble(),
                min: 0,
                max: 5,
                divisions: 5,
                onChanged: (value) => setState(() {
                      widget.config.defry = value.toInt();
                    })))
      ],
    );
  }

  Widget _buildImageTile() {
    return Column(children: [
      Row(
        children: [
          Expanded(
              child: IconButton(
            icon: const Icon(Icons.add_photo_alternate),
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
      Padding(
        padding: const EdgeInsets.all(10),
        child: _widgetImage ?? const SizedBox.shrink(),
      )
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
}
