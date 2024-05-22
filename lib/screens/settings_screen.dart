// 文件路径：lib/screens/settings_screen.dart
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/info_manager.dart'; // 引用全局状态管理器
import '../widgets/param_config_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _proxyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = InfoManager().apiKey ?? "";
    _proxyController.text = InfoManager().proxy ?? "";
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('NAI API Key'),
            subtitle: Text(InfoManager().apiKey ?? ""),
            onTap: () {
              _editApiKey();
            },
          ),
          ListTile(
            title: const Text('Proxy'),
            subtitle: Text(InfoManager().proxy ?? ""),
            onTap: () {
              _editProxy();
            },
          ),
          ExpansionTile(
            title: const Text('Param config'),
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 20, right: 80),
                  child: ParamConfigWidget(config: InfoManager().paramConfig))
            ],
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () async {
                await _loadJsonConfig();
              },
              tooltip: 'Import from file',
              child: const Icon(Icons.file_open),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () async {
                Map<String, dynamic>? jsonData = await _getJsonFromClipboard();
                if (jsonData == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import failed!')));
                  return;
                }
                setState(() {
                  if (InfoManager().fromJson(jsonData!)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Imported from clipboard.')));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Import failed!')));
                  }
                });
              },
              tooltip: 'Import from clipboard',
              child: const Icon(Icons.file_upload),
            ),
            const SizedBox(height: 20),
            FloatingActionButton(
              onPressed: () {
                _copyConfigToClipboard();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exported to clipboard')));
              },
              tooltip: 'Export to clipboard',
              child: const Icon(Icons.save),
            ),
          ],
        ),
      ),
    );
  }

  void _editApiKey() {
    TextEditingController controller =
        TextEditingController(text: InfoManager().apiKey);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit API Key'),
          content: TextField(
            controller: controller,
            maxLines: null,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  InfoManager().apiKey = controller.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _editProxy() {
    TextEditingController controller =
        TextEditingController(text: InfoManager().proxy);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Proxy'),
          content: TextField(
            controller: controller,
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                setState(() {
                  InfoManager().proxy = controller.text;
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _copyConfigToClipboard() {
    final jsonString = json.encode(InfoManager().toJson());
    Clipboard.setData(ClipboardData(text: jsonString));
  }

  Future<Map<String, dynamic>?> _getJsonFromClipboard() async {
    ClipboardData? clipboardData =
        await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      try {
        final Map<String, dynamic> jsonConfig =
            json.decode(clipboardData.text!);
        return jsonConfig;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> _loadJsonConfig() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String fileContent = utf8.decode(result.files.single.bytes!);
        Map<String, dynamic> jsonData = jsonDecode(fileContent);
        setState(() {
          if (InfoManager().fromJson(jsonData)) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Imported from file')));
          } else {
            throw Exception();
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Import failed!')));
    }
  }
}
