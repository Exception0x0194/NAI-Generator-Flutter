import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../generated/l10n.dart';
import '../models/info_manager.dart';
import '../models/vibe_config.dart';
import '../widgets/i2i_config_widget.dart';
import '../widgets/vibe_config_widget.dart';

class I2IConfigScreen extends StatefulWidget {
  const I2IConfigScreen({super.key});

  @override
  I2IConfigScreenState createState() => I2IConfigScreenState();
}

class I2IConfigScreenState extends State<I2IConfigScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _addNewVibeConfig() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    var newConfig = VibeConfig.createWithFile(bytes, 1.0, 0.3);
    var img = Image.memory(bytes);
    setState(() {
      InfoManager().vibeConfig.add(newConfig);
    });
  }

  void _removeVibeConfig(int index) {
    setState(() {
      InfoManager().vibeConfig.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).i2i_config),
      ),
      body: ListView(
        children: [
          ExpansionTile(
              title: Text('Image to Image'),
              leading: Icon(Icons.screen_rotation),
              initiallyExpanded: true,
              children: [I2IConfigWidget(config: InfoManager().i2iConfig)]),
          ExpansionTile(
            title: const Text('Vibe Transfer'),
            leading: Icon(Icons.photo_library_outlined),
            initiallyExpanded: true,
            children: [
              ...InfoManager().vibeConfig.asMap().map((idx, config) {
                return MapEntry(
                    idx,
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ExpansionTile(
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () {
                              _removeVibeConfig(idx);
                            },
                          ),
                          initiallyExpanded: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text('Config #$idx'),
                          children: [VibeConfigWidget(config: config)],
                        )));
              }).values,
              if (InfoManager().vibeConfig.length < 5)
                Row(
                  children: [
                    Expanded(
                        child: IconButton(
                      onPressed: _addNewVibeConfig,
                      icon: Icon(Icons.add_photo_alternate_outlined),
                    ))
                  ],
                )
            ],
          ),
        ],
      ),
    );
  }
}
