// 文件路径：lib/screens/settings_screen.dart
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/info_manager.dart';
import '../widgets/param_config_widget.dart';
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
      appBar: AppBar(
        title: const Text('User Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('NAI API Key'),
            subtitle: Text(InfoManager().apiKey),
            onTap: () {
              _editApiKey();
            },
          ),
          Padding(
              padding: const EdgeInsets.only(left: 20, right: 80),
              child: ParamConfigWidget(config: InfoManager().paramConfig))
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
                await _saveJsonConfig();
              },
              tooltip: 'Export to file',
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

  _saveJsonConfig() {
    saveStringToFile(json.encode(InfoManager().toJson()),
        '${generateRandomFileName()}.json');
  }
}
