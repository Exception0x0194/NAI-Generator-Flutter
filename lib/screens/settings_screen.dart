// 文件路径：lib/screens/settings_screen.dart
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../generated/l10n.dart';
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
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _proxyController = TextEditingController();

  @override
  void dispose() {
    _apiKeyController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsets.only(right: 80),
          child: ListView(
            children: [
              // Token settings
              _buildTokenTile(),
              // Param settings
              Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: ParamConfigWidget(config: InfoManager().paramConfig)),
              // Output directory selection, for windows only
              if (!kIsWeb && Platform.isWindows) _buildOutputSelectionTile(),
              // Proxy settings
              if (!kIsWeb) _buildProxyTile(),
              // Batch settings
              _buildBatchTile(),
              // Github link
              _buildLinkTile()
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await _loadJsonConfig();
            },
            tooltip: S.of(context).import_settings_from_file,
            child: const Icon(Icons.file_open),
          ),
          const SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () async {
              await _saveJsonConfig();
            },
            tooltip: S.of(context).export_settings_to_file,
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
      final loadResult = await InfoManager().fromJson(jsonData);
      setState(() {
        if (loadResult) {
          showInfoBar(context,
              '${S.of(context).info_import_file}${S.of(context).succeed}');
        } else {
          showErrorBar(context,
              '${S.of(context).info_import_file}${S.of(context).failed}');
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
      title: Text(S.of(context).github_repo),
      leading: const Icon(Icons.link),
      subtitle: const Text(
          'https://github.com/Exception0x0194/NAI-Generator-Flutter'),
      onTap: () => {
        launchUrl(Uri.parse(
            'https://github.com/Exception0x0194/NAI-Generator-Flutter'))
      },
    );
  }

  _buildBatchTile() {
    final batchCount = InfoManager().batchCount;
    final batchInterval = InfoManager().batchIntervalSec;
    return ExpansionTile(
      leading: const Icon(Icons.schedule),
      title: Text(S.of(context).batch_settings),
      subtitle:
          Text(S.of(context).batch_settings_info(batchCount, batchInterval)),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: EditableListTile(
              leading: const Icon(Icons.checklist),
              title: S.of(context).batch_count,
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
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditableListTile(
                leading: const Icon(Icons.hourglass_empty),
                title: S.of(context).batch_interval,
                currentValue: batchInterval.toString(),
                keyboardType: TextInputType.number,
                confirmOnSubmit: true,
                onEditComplete: (value) => {
                      setState(() {
                        InfoManager().batchIntervalSec =
                            int.tryParse(value) ?? batchInterval;
                      })
                    })),
      ],
    );
  }

  _buildOutputSelectionTile() {
    final outputDirPath = InfoManager().outputFolder == null
        ? '<${S.of(context).system_document_folder}>\\nai_generated'
        : InfoManager().outputFolder!.path;
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(S.of(context).output_folder),
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
        title: S.of(context).proxy_settings,
        currentValue: proxy == '' ? S.of(context).proxy_settings_direct : proxy,
        editValue: proxy,
        notice: S.of(context).proxy_settings_notice,
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
        title: S.of(context).NAI_API_key,
        notice: S.of(context).NAI_API_key_hint,
        currentValue: InfoManager().apiKey,
        confirmOnSubmit: true,
        onEditComplete: (value) {
          setState(() {
            InfoManager().apiKey = value;
          });
        });
  }
}
