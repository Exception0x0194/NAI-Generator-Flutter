// 文件路径：lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              title: const Text('NAI API Key'),
              subtitle: Text(InfoManager().apiKey ?? ""),
              onTap: () {
                _editApiKey();
              },
            ),
            const SizedBox(height: 10),
            ListTile(
              title: const Text('Proxy'),
              subtitle: Text(InfoManager().proxy ?? ""),
              onTap: () {
                _editProxy();
              },
            ),
            const SizedBox(height: 20),
            ExpansionTile(
              title: const Text('Param config'),
              children: [
                Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: ParamConfigWidget(config: InfoManager().paramConfig))
              ],
            )
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
}
