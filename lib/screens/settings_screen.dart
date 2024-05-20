// 文件路径：lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import '../models/info_manager.dart';  // 引用全局状态管理器

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
    _proxyController.text = InfoManager().proxySettings ?? "";
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _proxyController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    InfoManager().setApiKey(_apiKeyController.text);
    InfoManager().setProxySettings(_proxyController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings updated successfully!')),
    );
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
            TextField(
              controller: _apiKeyController,
              decoration: const InputDecoration(
                labelText: 'API Key',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _proxyController,
              decoration: const InputDecoration(
                labelText: 'Proxy Settings',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}
