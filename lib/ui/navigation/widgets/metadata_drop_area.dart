import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/core/constants/image_formats.dart';
import 'package:nai_casrand/core/constants/parameters.dart';
import 'package:nai_casrand/data/services/image_service.dart';
import 'package:nai_casrand/ui/core/utils/flushbar.dart';
import 'package:nai_casrand/ui/navigation/view_models/metadata_drop_area_viewmodel.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';
import 'package:image/image.dart' as img;

class MetadataDropArea extends StatefulWidget {
  final viewmodel =
      MetadataDropAreaViewmodel(); // viewmodel 保持 final 并在 createState 中传递
  final WidgetBuilder childBuilder;

  MetadataDropArea({super.key, required this.childBuilder});

  @override
  State<MetadataDropArea> createState() => _MetadataDropAreaState();
}

class _MetadataDropAreaState extends State<MetadataDropArea> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewmodel,
      builder: (context, _) => DropRegion(
        formats: Formats.standardFormats,
        onDropOver: (_) => DropOperation.copy,
        onDropEnter: (_) {
          if (_isDragging) return;
          setState(() {
            _isDragging = true;
          });
        },
        onDropLeave: (_) {
          if (!_isDragging) return;
          setState(() {
            _isDragging = false;
          });
        },
        onPerformDrop: (event) => _handleDropEvent(context, event),
        child: Stack(
          // 使用 Stack 来叠加遮罩层
          children: [
            widget.childBuilder(context),
            getMask(context),
          ],
        ),
      ),
    );
  }

  Widget getMask(context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _isDragging ? 0.8 : 0.0, // 半透明度
          duration: const Duration(milliseconds: 500),
          child: Container(
            color: Theme.of(context).disabledColor,
            child: Center(
              child: Text(
                tr('drop_to_read_metadata'), // 提示文字
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium!.color, // 文字颜色
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleDropEvent(
    BuildContext context,
    PerformDropEvent event,
  ) async {
    setState(() {
      _isDragging = false; // 拖拽结束后移除遮罩
    });
    try {
      final item = event.session.items.first;
      final reader = item.dataReader;
      if (reader == null) throw Exception('Could not get reader.');
      reader.getFile(imageFormat, (file) async {
        final data = await file.readAll();
        final image = img.decodeImage(data);
        if (image == null) throw Exception('Error decoding image.');
        final metadataString = await ImageService().extractMetadata(image);
        if (metadataString == null) throw Exception('Could not read metadata.');
        final jsonData = json.decode(metadataString) as Map<String, dynamic>;
        final commentData =
            json.decode(jsonData['Comment']) as Map<String, dynamic>;
        final source = jsonData['Source'] ?? '';
        final String? model = sourceToModel[source];
        final String? prompt = jsonData['Description'];
        final toolTip = Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: Text(tr('tap_to_paste_parameters')),
        );
        final promptTile = prompt != null
            ? ListTile(
                title: Text(tr('prompt')),
                subtitle: Text(prompt),
                onTap: () =>
                    widget.viewmodel.setOverridePrompt(context, prompt),
              )
            : const SizedBox.shrink();
        final modelTile = model != null
            ? ListTile(
                title: Text(tr('generation_model')),
                subtitle: Text(model),
                onTap: () => widget.viewmodel.setModel(model),
              )
            : const SizedBox.shrink();
        final sizeTile = ListTile(
          title: Text(tr('image_size')),
          subtitle: Text(
            '${commentData['width']} × ${commentData['height']}',
          ),
          dense: true,
          onTap: () => widget.viewmodel.loadSingleImageMetadata(
            context,
            {'width': commentData['width'], 'height': commentData['height']},
            tr('image_size'),
          ),
        );
        final tiles = commentKeys.map((key) {
          final value = commentData[key];
          if (value == null) return const SizedBox.shrink();
          return ListTile(
            title: Text(key),
            subtitle: Text(
              value.toString(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            dense: true,
            onTap: () => widget.viewmodel
                .loadSingleImageMetadata(context, {key: value}, key),
          );
        }).toList();
        if (!context.mounted) return;
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(tr('metadata_found')),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  toolTip,
                  promptTile,
                  modelTile,
                  sizeTile,
                  ...tiles,
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(tr('cancel')),
              ),
              TextButton(
                  onPressed: () {
                    widget.viewmodel.loadAllMetadata(
                      context,
                      commentData,
                      prompt,
                      model,
                    );
                    Navigator.pop(context);
                  },
                  child: Text(tr('import_all_metadata_from_image')))
            ],
          ),
        );
      });
    } catch (e) {
      if (!context.mounted) return;
      showErrorBar(context,
          '${tr('import_metadata_from_image')}${tr('failed')}${tr('colon')}$e');
    }
  }
}
