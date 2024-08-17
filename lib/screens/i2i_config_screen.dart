import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

// import '../generated/l10n.dart';
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
    final addVibeImage = Icon(
      Icons.add_photo_alternate_outlined,
      size: 100.0,
      color: Colors.grey.withAlpha(127),
    );
    final addVibeDropArea = InkWell(
        onTap: _addNewVibeConfig,
        child: SizedBox(
          width: 340.0,
          height: 140.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withAlpha(127), width: 2.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  addVibeImage,
                  Text(S.of(context).drag_and_drop_image_notice),
                ],
              ),
            ),
          ),
        ));

    return Scaffold(
      body: ListView(
        children: [
          ExpansionTile(
              title: const Text('Image to Image'),
              leading: const Icon(Icons.screen_rotation),
              initiallyExpanded: true,
              children: [I2IConfigWidget(config: InfoManager().i2iConfig)]),
          ExpansionTile(
            title: const Text('Vibe Transfer'),
            leading: const Icon(Icons.photo_library_outlined),
            initiallyExpanded: true,
            children: [
              // Added vibe configs
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
              // Add more configs
              if (InfoManager().vibeConfig.length < 5)
                DropRegion(
                  formats: Formats.standardFormats,
                  onDropOver: (_) => DropOperation.copy,
                  onPerformDrop: (event) async {
                    final item = event.session.items.first;
                    final reader = item.dataReader!;
                    reader.getFile(imageFormat, (file) async {
                      final data = await file.readAll();
                      InfoManager()
                          .vibeConfig
                          .add(VibeConfig.createWithFile(data, 1, 0.3));
                      setState(() {});
                    });
                  },
                  child: addVibeDropArea,
                )
            ],
          ),
        ],
      ),
    );
  }
}
