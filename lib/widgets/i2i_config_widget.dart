import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:super_clipboard/super_clipboard.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:easy_localization/easy_localization.dart';

import '../models/info_manager.dart';
import '../models/utils.dart';
import '../widgets/editable_list_tile.dart';
import '../models/i2i_config.dart';
import '../utils/metadata.dart';

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

class I2IConfigWidget extends StatefulWidget {
  final I2IConfig config;
  final double imageSize = 300;

  const I2IConfigWidget({super.key, required this.config});

  @override
  I2IConfigWidgetState createState() => I2IConfigWidgetState();
}

class I2IConfigWidgetState extends State<I2IConfigWidget> {
  @override
  void initState() {
    super.initState();
    widget.config.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image and buttons
        _buildImageWidget(),

        Row(children: [
          // Presets
          Expanded(
              child: ListTile(
            title: Text(context.tr('enhance_presets')),
            leading: const Icon(Icons.tune),
            subtitle: Slider(
              value: _getEnhancePresetValue(),
              min: 1,
              max: 5,
              divisions: 4,
              label:
                  'Strength: ${widget.config.strength}; Noise: ${widget.config.noise}',
              onChanged: (value) {
                setState(() {
                  var result = [
                    [0.2, 0],
                    [0.4, 0],
                    [0.5, 0],
                    [0.6, 0],
                    [0.7, 0.1]
                  ][value.toInt() - 1];
                  widget.config.strength = result[0].toDouble();
                  widget.config.noise = result[1].toDouble();
                });
              },
            ),
          )),
          // Size config
          Expanded(
            child: _buildSizeTile(),
          )
        ]),
        Row(
          children: [
            // Strength
            Expanded(
                child: ListTile(
                    title: Text(
                        'Strength: ${widget.config.strength.toStringAsFixed(2)}'),
                    leading: const Icon(Icons.grain),
                    subtitle: Slider(
                      value: widget.config.strength,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: widget.config.strength.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() {
                          widget.config.strength = value;
                        });
                      },
                    ))),
            // Noise
            Expanded(
                child: ListTile(
                    title: Text(
                        'Noise: ${widget.config.noise.toStringAsFixed(2)}'),
                    leading: const Icon(Icons.water),
                    subtitle: Slider(
                      value: widget.config.noise,
                      min: 0.0,
                      max: 1.0,
                      divisions: 100,
                      label: widget.config.noise.toStringAsFixed(2),
                      onChanged: (value) {
                        setState(() {
                          widget.config.noise = value;
                        });
                      },
                    )))
          ],
        ),
        // SMEA override settings
        CheckboxListTile(
            title: Text(context.tr('enhance_override_smea')),
            secondary: const Icon(Icons.keyboard_double_arrow_right),
            value: widget.config.overrideSmea,
            onChanged: (value) => setState(() {
                  widget.config.overrideSmea = value!;
                })),
        // Prompt override settings
        CheckboxListTile(
            title: Text(context.tr('override_random_prompts')),
            secondary: const Icon(Icons.edit_note),
            value: widget.config.overridePromptEnabled,
            onChanged: (value) {
              setState(() {
                widget.config.overridePromptEnabled = value!;
              });
            }),
        widget.config.overridePromptEnabled
            ? Padding(
                padding: const EdgeInsets.only(left: 20),
                child: EditableListTile(
                    title: context.tr('override_prompt'),
                    currentValue: widget.config.overridePrompt,
                    confirmOnSubmit: true,
                    onEditComplete: (value) {
                      setState(() {
                        widget.config.overridePrompt = value;
                      });
                    }))
            : const SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSizeTile() {
    final dstWidth = InfoManager().paramConfig.width;
    final dstHeight = InfoManager().paramConfig.height;
    final srcWidth = widget.config.width;
    final srcHeight = widget.config.height;
    return ListTile(
      title: Text(context.tr('image_size')),
      leading: const Icon(Icons.photo_size_select_large),
      subtitle: Text(
        context.tr('i2i_image_size', namedArgs: {
          'current_size': '$dstWidth x $dstHeight',
          'i2i_size':
              widget.config.imageB64 == null ? 'N/A' : '$srcWidth x $srcHeight'
        }),
      ),
      onTap: _showI2ISizeDialog,
    );
  }

  void _showI2ISizeDialog() {
    if (widget.config.imageB64 == null) return;
    final srcWidth = widget.config.width;
    final srcHeight = widget.config.height;
    var widthController =
        TextEditingController(text: InfoManager().paramConfig.width.toString());
    var heightController = TextEditingController(
        text: InfoManager().paramConfig.height.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(context.tr('edit') + context.tr('image_size')),
            content: SingleChildScrollView(
              child: ListBody(children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Text(context.tr('available_in_settings'))),
                ExpansionTile(
                    title: Text(context.tr('enhance_scale')),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                              children:
                                  getPossibleScaleFactors(srcWidth, srcHeight)
                                      .map((value) {
                            return ListTile(
                              title: Text('${value}x'), // 显示倍率值
                              onTap: () {
                                Navigator.of(context).pop();
                                _setSizeByScale(context, value);
                              },
                            );
                          }).toList()))
                    ]),
                ExpansionTile(
                    title: Text(context.tr('custom_size')),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                      title: Text(context.tr('width')),
                                      subtitle: TextField(
                                          controller: widthController,
                                          keyboardType: TextInputType.number))),
                              Expanded(
                                  child: ListTile(
                                      title: Text(context.tr('height')),
                                      subtitle: TextField(
                                          controller: heightController,
                                          keyboardType: TextInputType.number)))
                            ],
                          ))
                    ])
              ]),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('cancel'))),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      int? widthResult = int.tryParse(widthController.text);
                      int? heightResult = int.tryParse(heightController.text);
                      if (widthResult == null || heightResult == null) return;
                      InfoManager().paramConfig.width =
                          (widthResult / 64).round() * 64;
                      InfoManager().paramConfig.height =
                          (heightResult / 64).round() * 64;
                    });
                  },
                  child: Text(context.tr('confirm')))
            ],
          );
        });
      },
    );
  }

  void _addI2IImage() async {
    var picker = ImagePicker();
    var pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    var bytes = await pickedFile.readAsBytes();
    await loadImageBytes(bytes);
    setState(() {});
  }

  void _removeI2IImage() {
    widget.config.imageB64 = null;
    setState(() {});
  }

  double _getEnhancePresetValue() {
    var s = widget.config.strength;
    if (s <= 0.2) return 1;
    if (s <= 0.4) return 2;
    if (s <= 0.5) return 3;
    if (s <= 0.6) return 4;
    return 5;
  }

  void _setSizeByScale(BuildContext context, double scale) {
    final srcWidth = widget.config.width;
    final srcHeight = widget.config.height;
    int targetWidth = (scale * srcWidth / 64).ceil() * 64;
    int targetHeight = (scale * srcHeight / 64).ceil() * 64;
    setState(() {
      InfoManager().paramConfig.width = targetWidth;
      InfoManager().paramConfig.height = targetHeight;
    });
  }

  void _showImportMetadataDialog(Map<String, dynamic> parameters) {
    String prompt, uc;
    // Supposedly seed is not needed in I2I
    // int seed;
    Map<String, dynamic> param = {};
    const keys = [
      'steps',
      'height',
      'width',
      'sampler',
      'scale',
      'cfg_rescale',
      'uncond_scale',
      'sm',
      'sm_dyn'
    ];
    try {
      prompt = parameters['prompt'];
      uc = parameters['uc'];
      // seed = parameters['seed'];
      for (String key in keys) {
        param[key] = parameters[key];
      }
    } catch (err) {
      if (!mounted) return;
      showErrorBar(context, 'Error reading metadata: ${err.toString()}');
      return;
    }
    pastePrompt() {
      setState(() {
        widget.config.overridePromptEnabled = true;
        widget.config.overridePrompt = prompt;
        if (mounted) {
          showInfoBar(
              context, context.tr('pasted_parameter') + (context.tr('prompt')));
        }
      });
    }

    pasteUC() {
      InfoManager().paramConfig.loadJson({'negative_prompt': uc});
      if (mounted) {
        showInfoBar(
            context, context.tr('pasted_parameter') + (context.tr('uc')));
      }
    }

    pasteParam() {
      setState(() {
        final loaded = InfoManager().paramConfig.loadJson(param);
        if (mounted) {
          showInfoBar(
              context,
              context.tr('loaded_parameters_count',
                  namedArgs: {'num': loaded.toString()}));
        }
      });
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('metadata_found')),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.tr('tap_to_paste_parameters')),
                  ListTile(
                      title: Text(context.tr('prompt')),
                      subtitle: Text(
                        prompt,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: pastePrompt),
                  ListTile(
                      title: Text(context.tr('uc')),
                      subtitle: Text(
                        uc,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: pasteUC),
                  ListTile(
                      title: Text(context.tr('parameters')),
                      subtitle: Text(
                        json.encode(param),
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: pasteParam),
                  // ListTile(
                  //     title: Text('Seed'),
                  //     subtitle: Text(
                  //       seed.toString(),
                  //       maxLines: 5,
                  //       overflow: TextOverflow.ellipsis,
                  //     ),
                  //     onTap: pasteSeed)
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      pastePrompt();
                      pasteUC();
                      pasteParam();
                    },
                    child: Text(context.tr('paste_all'))),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(context.tr('confirm')))
              ],
            ));
  }

  Widget _buildImageWidget() {
    // Image
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
        onTap: _addI2IImage,
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

    // Buttons
    final buttons = Row(children: [
      if (widget.config.imageB64 != null)
        Expanded(
            child: IconButton(
                onPressed: _removeI2IImage,
                icon: const Icon(Icons.delete_outline)))
    ]);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        DropRegion(
          formats: Formats.standardFormats,
          onDropOver: (_) => DropOperation.copy,
          onPerformDrop: (event) async {
            final item = event.session.items.first;
            final reader = item.dataReader!;
            reader.getFile(imageFormat, (file) async {
              final bytes = await file.readAll();
              await loadImageBytes(bytes);
              setState(() {});
            });
          },
          child: dropArea,
        ),
        buttons,
      ],
    );
  }

  Future<void> loadImageBytes(Uint8List bytes) async {
    // Import image into I2I config
    widget.config.setImage(bytes);

    // Skip metadata reading for images > 5M
    if (bytes.length > 5e6) return;

    // Try parse and import metadata
    final image = img.decodeImage(bytes);
    Map<String, dynamic>? parameters;
    try {
      final metadataString = await extractMetadata(image!);
      final Map<String, dynamic> metadata = json.decode(metadataString!);
      parameters = json.decode(metadata['Comment']);
    } catch (err) {
      if (!mounted) return;
      showWarningBar(context, 'No metadta found in imported picture.');
    }
    if (parameters != null) {
      _showImportMetadataDialog(parameters);
    }
  }
}
