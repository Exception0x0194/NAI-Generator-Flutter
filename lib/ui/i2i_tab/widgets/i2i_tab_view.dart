import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/i2i_tab/view_models/i2i_tab_viewmodel.dart';
import 'package:nai_casrand/ui/vibe_config/widgets/vibe_view.dart';
import 'package:nai_casrand/ui/vibe_config/view_models/vibe_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

class I2iTabView extends StatelessWidget {
  final I2iTabViewmodel viewmodel;

  const I2iTabView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final addVibeImage = Icon(
      Icons.add_photo_alternate_outlined,
      size: 100.0,
      color: Colors.grey.withAlpha(127),
    );
    final addVibeDropArea = InkWell(
        onTap: () => viewmodel.addNewVibe(),
        child: SizedBox(
          width: 340.0,
          height: 150.0,
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
                  Text(context.tr('drag_and_drop_image_notice')),
                ],
              ),
            ),
          ),
        ));

    final content = ChangeNotifierProvider.value(
        value: viewmodel,
        child: Consumer<I2iTabViewmodel>(builder: (context, viewmodel, child) {
          return Column(
            children: [
              // Added vibe configs
              ...viewmodel.vibeConfigList.asMap().map((idx, config) {
                return MapEntry(
                    idx,
                    Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: ExpansionTile(
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () => viewmodel.removeVibeConfigAt(idx),
                          ),
                          initiallyExpanded: true,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: Text('Config #$idx'),
                          children: [
                            VibeConfigView(
                                key: Key(config.imageB64),
                                viewmodel: VibeConfigViewmodel(config: config))
                          ],
                        )));
              }).values,
              // Add more configs
              if (viewmodel.vibeConfigList.length < 5)
                DropRegion(
                  formats: Formats.standardFormats,
                  onDropOver: (_) => DropOperation.copy,
                  onPerformDrop: (event) =>
                      viewmodel.handleVibeDropEvent(event),
                  child: addVibeDropArea,
                )
            ],
          );
        }));

    return SingleChildScrollView(
      child: content,
    );
  }
}
