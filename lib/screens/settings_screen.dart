// 文件路径：lib/screens/settings_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import '../models/info_manager.dart';
import '../widgets/param_config_widget.dart';
import '../widgets/editable_list_tile.dart';
import '../models/utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final children = [
      // Token settings
      _buildTokenTile(),
      // Param settings
      Padding(
          padding: const EdgeInsets.only(left: 20),
          child: ParamConfigWidget(config: InfoManager().paramConfig)),
      // Batch settings
      _buildBatchTile(),
      // Erase metadata / add fake metadata
      _buildEraseMetadataTile(),
      // Output directory selection, for windows only
      if (!kIsWeb && Platform.isWindows) _buildOutputSelectionTile(),
      // Proxy settings
      if (!kIsWeb) _buildProxyTile(),
    ]
        .map((e) => Padding(
              padding: const EdgeInsets.only(right: 60),
              child: e,
            ))
        .toList();
    return Scaffold(
      body: ListView(
        children: children,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () => _showInfoPage(),
            tooltip: context.tr('app_info'),
            child: const Icon(Icons.info),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () async {
              await _loadJsonConfig();
            },
            tooltip: context.tr('import_settings_from_file'),
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () async {
              await _saveJsonConfig();
            },
            tooltip: context.tr('export_settings_to_file'),
            child: const Icon(Icons.save),
          ),
        ],
      ),
    );
  }

  Future<void> _loadJsonConfig() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      var fileContent = utf8.decode(result.files.single.bytes!);
      Map<String, dynamic> jsonData = json.decode(fileContent);
      setState(() {
        try {
          InfoManager().fromJson(jsonData);
          showInfoBar(context,
              '${context.tr('info_import_file')}${context.tr('succeed')}');
        } catch (error) {
          showErrorBar(context,
              '${context.tr('info_import_file')}${context.tr('failed')}: ${error.toString()}');
        }
      });
    }
  }

  _saveJsonConfig() {
    saveStringToFile(json.encode(InfoManager().toJson()),
        'nai-generator-config-${generateRandomFileName()}.json');
  }

  _buildLinkTile() {
    return ListTile(
      title: Text(context.tr('github_repo')),
      leading: const Icon(Icons.link),
      subtitle: const Text(String.fromEnvironment("GITHUB_REPO_LINK")),
      onTap: () => {
        launchUrl(Uri.parse(const String.fromEnvironment("GITHUB_REPO_LINK")))
      },
    );
  }

  _buildBatchTile() {
    final batchCount = InfoManager().batchCount;
    final batchInterval = InfoManager().batchIntervalSec;
    final numberOfRequests = InfoManager().numberOfRequests;
    final numberOfRequestsStr =
        numberOfRequests == 0 ? '∞' : numberOfRequests.toString();
    return ExpansionTile(
      leading: const Icon(Icons.schedule),
      title: Text(context.tr('batch_settings')),
      subtitle: Text(context.tr('batch_settings_info', namedArgs: {
        'batch_count': batchCount.toString(),
        'interval': batchInterval.toString(),
        'number_of_requests': numberOfRequestsStr
      })),
      children: [
        // Batch count
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: EditableListTile(
              leading: const Icon(Icons.checklist),
              title: context.tr('batch_count'),
              currentValue: batchCount.toString(),
              keyboardType: TextInputType.number,
              confirmOnSubmit: true,
              onEditComplete: (value) => {
                    setState(() {
                      InfoManager().batchCount =
                          int.tryParse(value) ?? batchCount;
                    })
                  }),
        ),
        // Batch interval
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditableListTile(
                leading: const Icon(Icons.hourglass_empty),
                title: context.tr('batch_interval'),
                currentValue: batchInterval.toString(),
                keyboardType: TextInputType.number,
                confirmOnSubmit: true,
                onEditComplete: (value) => {
                      setState(() {
                        InfoManager().batchIntervalSec =
                            int.tryParse(value) ?? batchInterval;
                      })
                    })),
        // Number of requests
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditableListTile(
              leading: const Icon(Icons.alarm),
              title: context.tr('image_number_to_generate'),
              currentValue:
                  numberOfRequests == 0 ? '∞' : numberOfRequests.toString(),
              editValue: numberOfRequests.toString(),
              notice: '0 → ∞',
              onEditComplete: (value) {
                setState(() {
                  InfoManager().numberOfRequests =
                      int.tryParse(value) ?? numberOfRequests;
                });
              },
              keyboardType: TextInputType.number,
              confirmOnSubmit: true,
            )),
      ],
    );
  }

  _buildOutputSelectionTile() {
    final outputDirPath = InfoManager().outputFolder == null
        ? '<${context.tr('system_document_folder')}>\\nai_generated'
        : InfoManager().outputFolder!.path;
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(context.tr('output_folder')),
      subtitle: Text(outputDirPath),
      onTap: () async {
        final pickResult = await FilePicker.platform.getDirectoryPath();
        if (pickResult == null) return;
        setState(() {
          InfoManager().outputFolder = Directory(pickResult);
        });
      },
    );
  }

  _buildProxyTile() {
    final proxy = InfoManager().proxy;
    return EditableListTile(
        leading: const Icon(Icons.route),
        title: context.tr('proxy_settings'),
        currentValue: proxy == '' ? context.tr('proxy_settings_direct') : proxy,
        editValue: proxy,
        notice: context.tr('proxy_settings_notice'),
        confirmOnSubmit: true,
        onEditComplete: (value) {
          isValidProxy(String input) {
            if (input == '') return true;
            final ipPortRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}:\d{1,5}$');
            if (!ipPortRegex.hasMatch(value)) return false;
            return true;
          }

          // Check whether input is legal
          if (!isValidProxy(value)) return;
          setState(() {
            InfoManager().proxy = value;
          });
        });
  }

  _buildTokenTile() {
    return EditableListTile(
        leading: const Icon(Icons.token_outlined),
        title: context.tr('NAI_API_key'),
        notice: context.tr('NAI_API_key_hint'),
        currentValue: InfoManager().apiKey,
        confirmOnSubmit: true,
        onEditComplete: (value) {
          setState(() {
            InfoManager().apiKey = value;
          });
        });
  }

  _buildEraseMetadataTile() {
    List<Widget> tiles = [
      CheckboxListTile(
          secondary: const Icon(Icons.delete_sweep),
          title: Text(context.tr('metadata_erase_enabled')),
          value: InfoManager().metadataEraseEnabled,
          onChanged: (value) {
            setState(() {
              InfoManager().metadataEraseEnabled = value!;
            });
          })
    ];
    tiles.add(InfoManager().metadataEraseEnabled
        ? Padding(
            padding: const EdgeInsets.only(left: 20),
            child: CheckboxListTile(
                secondary: const Icon(Icons.edit_note),
                title: Text(context.tr('custom_metadata_enabled')),
                value: InfoManager().customMetadataEnabled,
                onChanged: (value) {
                  setState(() {
                    InfoManager().customMetadataEnabled = value!;
                  });
                }))
        : const SizedBox.shrink());
    tiles.add(InfoManager().metadataEraseEnabled &&
            InfoManager().customMetadataEnabled
        ? Padding(
            padding: const EdgeInsets.only(left: 30),
            child: ListTile(
              title: Text(context.tr('custom_metadata_content')),
              subtitle: Text(
                InfoManager().customMetadataContent,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _showEditCustomMetadataContentDialog(),
            ))
        : const SizedBox.shrink());

    return Column(children: tiles);
  }

  _showEditCustomMetadataContentDialog() {
    var textController =
        TextEditingController(text: InfoManager().customMetadataContent);
    const exampleContent1 =
        '{"Description": "👻👻👻", "Software": "NovelAI", "Source": "Stable Diffusion XL 9CC2F394", "Generation time": "11.4514", "Comment": "{\\"prompt\\": \\"👻👻👻\\", \\"steps\\": 28, \\"height\\": 1024, \\"width\\": 1024, \\"scale\\": 5, \\"uncond_scale\\": 1.0, \\"cfg_rescale\\": 0.0, \\"seed\\": \\"\\", \\"n_samples\\": 1, \\"hide_debug_overlay\\": false, \\"noise_schedule\\": \\"native\\", \\"legacy_v3_extend\\": false, \\"reference_information_extracted_multiple\\": [], \\"reference_strength_multiple\\": [], \\"sampler\\": \\"k_euler_ancestral\\", \\"controlnet_strength\\": 1.0, \\"controlnet_model\\": null, \\"dynamic_thresholding\\": false, \\"dynamic_thresholding_percentile\\": 0.999, \\"dynamic_thresholding_mimic_scale\\": 10.0, \\"sm\\": false, \\"sm_dyn\\": false, \\"skip_cfg_below_sigma\\": 0.0, \\"lora_unet_weights\\": null, \\"lora_clip_weights\\": null, \\"uc\\": \\"\\", \\"request_type\\": \\"PromptGenerateRequest\\", \\"signed_hash\\": \\"\\"}"}';
    onEditComplete() {
      Navigator.of(context).pop();
      InfoManager().customMetadataContent = textController.text;
    }

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: Text(context.tr('edit') +
                      context.tr('custom_metadata_content')),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(context.tr('edit_custom_metadata_content_hint')),
                      TextField(
                        controller: textController,
                        maxLines: 10,
                        onSubmitted: (value) {
                          setState(() {
                            onEditComplete();
                          });
                        },
                      )
                    ],
                  ),
                  actions: [
                    Row(children: [
                      TextButton(
                          onPressed: () => setDialogState(() {
                                textController.text = exampleContent1;
                              }),
                          child: const Text('👻')),
                      const Spacer(),
                      TextButton(
                          onPressed: Navigator.of(context).pop,
                          child: Text(context.tr('cancel'))),
                      TextButton(
                          onPressed: () {
                            setState(() {
                              onEditComplete();
                            });
                          },
                          child: Text(context.tr('confirm'))),
                    ])
                  ],
                )));
  }

  _showInfoPage() async {
    final packageInfo = await PackageInfo.fromPlatform();
    const appName = 'NAI CasRand';
    final appVersion = packageInfo.version;
    final iconImage = Image.asset(
      'assets/appicon.png',
      width: 64,
      height: 64,
      filterQuality: FilterQuality.medium,
    );

    if (!mounted) return;
    showAboutDialog(
        context: context,
        applicationName: appName,
        applicationVersion: appVersion,
        applicationIcon: iconImage,
        children: [
          // Github link
          _buildLinkTile(),
          // Donation link
          _buildDonationLink()
        ]);
  }

  _buildDonationLink() {
    return ListTile(
      title: Text(context.tr('donation_link')),
      subtitle: Text(context.tr('donation_link_subtitle')),
      leading: const Icon(Icons.favorite_border),
      onTap: _showDonationQRCode,
    );
  }

  void _showDonationQRCode() async {
    final qrCode1Bytes = await decryptAsset('assets/qrcode1.jpg');
    final qrCode2Bytes = await decryptAsset('assets/qrcode2.jpg');
    if (qrCode1Bytes == null || qrCode2Bytes == null || !mounted) return;

    const qrCodeSize = 200.0;
    final qrCode1 = Image.memory(
      qrCode1Bytes,
      width: qrCodeSize,
      height: qrCodeSize,
      filterQuality: FilterQuality.medium,
    );
    final qrCode2 = Image.memory(
      qrCode2Bytes,
      width: qrCodeSize,
      height: qrCodeSize,
      filterQuality: FilterQuality.medium,
    );
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(context.tr('donation_link_subtitle')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  qrCode1,
                  const SizedBox(
                    width: 20,
                    height: 20,
                  ),
                  qrCode2,
                ],
              ),
            ));
  }

  Future<Uint8List?> decryptAsset(String assetPath) async {
    const keyBase64 = String.fromEnvironment("ASSET_KEY_BASE64");
    const ivBase64 = String.fromEnvironment("ASSET_IV_BASE64");
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    try {
      final assetByteData = await rootBundle.load(assetPath);
      final encryptedBase64 = assetByteData.buffer.asUint8List();
      final decryptedBase64 =
          encrypter.decrypt(encrypt.Encrypted(encryptedBase64), iv: iv);
      final decryptedBytes = base64Decode(decryptedBase64);
      return decryptedBytes;
    } catch (exception) {
      return null;
    }
  }
}
