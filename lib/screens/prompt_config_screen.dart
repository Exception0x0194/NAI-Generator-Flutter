import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/info_manager.dart';
import '../models/prompt_config.dart';
import '../widgets/prompt_config_widget.dart';

class PromptConfigScreen extends StatefulWidget {
  const PromptConfigScreen({super.key});

  @override
  PromptConfigScreenState createState() => PromptConfigScreenState();
}

class PromptConfigScreenState extends State<PromptConfigScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prompt Configuration'),
      ),
      body: SingleChildScrollView(
        child: PromptConfigWidget(
          config: InfoManager().promptConfig, // 使用全局配置
          indentLevel: 0,
        ),
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
                Map<String, dynamic>? newConfig = await _getJsonFromClipboard();
                try {
                  setState(() {
                    InfoManager().promptConfig =
                        PromptConfig.fromJson(newConfig!, 0);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Imported from clipboard')));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Import failed')));
                }
              },
              tooltip: 'Import from clipboard',
              child: const Icon(Icons.upload),
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

  Future<void> _loadJsonConfig() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        String fileContent = utf8.decode(result.files.single.bytes!);
        Map<String, dynamic> jsonData = jsonDecode(fileContent);
        setState(() {
          InfoManager().promptConfig = PromptConfig.fromJson(jsonData, 0);
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Imported from file')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Imported failed')));
    }
  }

  void _copyConfigToClipboard() {
    final jsonString = json.encode(InfoManager().promptConfig.toJson());
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
}
