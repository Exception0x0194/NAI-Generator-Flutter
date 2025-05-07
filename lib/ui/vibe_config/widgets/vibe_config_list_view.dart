import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/vibe_config/view_models/vibe_config_list_viewmodel.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

import '../view_models/vibe_config_viewmodel.dart';
import 'vibe_config_view.dart';

class VibeConfigListView extends StatelessWidget {
  final VibeConfigListViewmodel viewmodel;

  const VibeConfigListView({super.key, required this.viewmodel});

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

    return ListenableBuilder(
      listenable: viewmodel,
      builder: (context, child) {
        return ListView.builder(
          itemCount: viewmodel.vibeList.length + 1,
          itemBuilder: (context, index) {
            if (index < viewmodel.vibeList.length) {
              final config = viewmodel.vibeList[index];
              // Each item needs its own ViewModel instance
              final itemViewModel = VibeConfigViewmodel(config: config);
              return VibeConfigView(
                key: ValueKey(config.imageB64),
                viewmodel: itemViewModel,
                onDelete: () => viewmodel.removeConfigAtIndex(index),
              );
            } else {
              return DropRegion(
                formats: Formats.standardFormats,
                onDropOver: (_) => DropOperation.copy,
                onPerformDrop: (event) => viewmodel.handleVibeDropEvent(event),
                child: addVibeDropArea,
              );
            }
          },
        );
      },
    );
  }
}
