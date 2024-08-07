import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import '../models/info_manager.dart';
import '../models/utils.dart';
import '../widgets/editable_list_tile.dart';
import '../models/i2i_config.dart';
import '../generated/l10n.dart';
import '../utils/metadata.dart';

class I2IConfigWidget extends StatefulWidget {
  final I2IConfig config;

  final double imageSize = 300;

  const I2IConfigWidget({super.key, required this.config});

  @override
  I2IConfigWidgetState createState() => I2IConfigWidgetState();
}

class I2IConfigWidgetState extends State<I2IConfigWidget> {
  late Widget _widgetImage;
  int _imageHeight = 0, _imageWidth = 0;

  @override
  void initState() {
    super.initState();
    widget.config.addListener(_loadImage);
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Image
        _widgetImage,
        // Buttons
        widget.config.imgB64 != null
            ? Row(children: [
                Expanded(
                    child: IconButton(
                        onPressed: _addI2IImage,
                        icon: const Icon(Icons.cached))),
                Expanded(
                    child: IconButton(
                        onPressed: _removeI2IImage,
                        icon: const Icon(Icons.delete_outline)))
              ])
            : Row(children: [
                Expanded(
                    child: IconButton(
                        onPressed: _addI2IImage,
                        icon: const Icon(Icons.add_photo_alternate_outlined)))
              ]),
        Row(children: [
          // Presets
          Expanded(
              child: ListTile(
            title: Text(S.of(context).enhance_presets),
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
            title: Text(S.of(context).enhance_override_smea),
            secondary: const Icon(Icons.keyboard_double_arrow_right),
            value: widget.config.overrideSmea,
            onChanged: (value) => setState(() {
                  widget.config.overrideSmea = value!;
                })),
        // Prompt override settings
        CheckboxListTile(
            title: Text(S.of(context).override_random_prompts),
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
                    title: S.of(context).override_prompt,
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

  // void _downloadI2IImage() {
  //   saveBlob(img.encodePng(widget.config.inputImage!),
  //       'nai-generator-I2I-${generateRandomFileName()}.png');
  //   showInfoBar(
  //       context, '${S.of(context).vibe_export}${S.of(context).succeed}');
  // }

  Widget _buildSizeTile() {
    var width = InfoManager().paramConfig.width;
    var height = InfoManager().paramConfig.height;
    return ListTile(
      title: Text(S.of(context).image_size),
      leading: const Icon(Icons.photo_size_select_large),
      subtitle: Text(S.of(context).i2i_image_size(
          '$width x $height',
          widget.config.imgB64 == null
              ? 'N/A'
              : '$_imageWidth x $_imageHeight')),
      onTap: _showI2ISizeDialog,
    );
  }

  void _showI2ISizeDialog() {
    if (widget.config.imgB64 == null) return;
    var widthController =
        TextEditingController(text: InfoManager().paramConfig.width.toString());
    var heightController = TextEditingController(
        text: InfoManager().paramConfig.height.toString());
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(S.of(context).edit + S.of(context).image_size),
            content: SingleChildScrollView(
              child: ListBody(children: [
                Align(
                    alignment: Alignment.topRight,
                    child: Text(S.of(context).available_in_settings)),
                ExpansionTile(
                    title: Text(S.of(context).enhance_scale),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Column(
                              children: getPossibleScaleFactors(
                                      _imageWidth, _imageHeight)
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
                    title: Text(S.of(context).custom_size),
                    initiallyExpanded: true,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                      title: Text(S.of(context).width),
                                      subtitle: TextField(
                                          controller: widthController,
                                          keyboardType: TextInputType.number))),
                              Expanded(
                                  child: ListTile(
                                      title: Text(S.of(context).height),
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
                  child: Text(S.of(context).cancel)),
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
                  child: Text(S.of(context).confirm))
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

    widget.config.imgB64 = base64Encode(bytes);
    _loadImage();
  }

  void _removeI2IImage() {
    widget.config.imgB64 = null;
    _loadImage();
  }

  void _loadImage() {
    if (widget.config.imgB64 == null) {
      setState(() {
        _widgetImage = const SizedBox.shrink();
      });
    } else {
      var image = Image.memory(base64Decode(widget.config.imgB64!));
      image.image
          .resolve(const ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        setState(() {
          _imageWidth = info.image.width;
          _imageHeight = info.image.height;
        });
      }));
      setState(() {
        _widgetImage = SizedBox(
            width: widget.imageSize, height: widget.imageSize, child: image);
      });
    }
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
    int targetWidth = (scale * _imageWidth / 64).ceil() * 64;
    int targetHeight = (scale * _imageHeight / 64).ceil() * 64;
    setState(() {
      InfoManager().paramConfig.width = targetWidth;
      InfoManager().paramConfig.height = targetHeight;
    });
  }

  void _showImportMetadataDialog(Map<String, dynamic> parameters) {
    String prompt, uc;
    // Supposedly seed is not needed in I2I
    // int seed;
    Map<String, dynamic> param;
    try {
      prompt = parameters['prompt'];
      uc = parameters['uc'];
      // seed = parameters['seed'];
      param = parameters
        ..remove('prompt')
        ..remove('uc')
        ..remove('seed');
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
              context, S.of(context).pasted_parameter(S.of(context).prompt));
        }
      });
    }

    pasteUC() {
      InfoManager().paramConfig.loadJson({'negative_prompt': uc});
      if (mounted) {
        showInfoBar(context, S.of(context).pasted_parameter(S.of(context).uc));
      }
    }

    pasteParam() {
      setState(() {
        final loaded = InfoManager().paramConfig.loadJson(param);
        if (mounted) {
          showInfoBar(context, S.of(context).loaded_parameters_count(loaded));
        }
      });
    }
    // pasteSeed() {
    //   InfoManager().paramConfig.loadJson({'seed': seed});
    //   if (mounted) showInfoBar(context, 'Imported Seed.');
    // }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(S.of(context).metadata_found),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).tap_to_paste_parameters),
                  ListTile(
                      title: Text(S.of(context).prompt),
                      subtitle: Text(
                        prompt,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: pastePrompt),
                  ListTile(
                      title: Text(S.of(context).uc),
                      subtitle: Text(
                        uc,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: pasteUC),
                  ListTile(
                      title: Text(S.of(context).parameters),
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
                    child: Text(S.of(context).paste_all)),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(S.of(context).confirm))
              ],
            ));
  }
}
