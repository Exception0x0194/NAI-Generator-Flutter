import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';

class DebugSettingsView extends StatefulWidget {
  final PayloadConfig payloadConfig = GetIt.instance<PayloadConfig>();

  DebugSettingsView({super.key});

  @override
  State<StatefulWidget> createState() => DebugSettingsViewState();
}

class DebugSettingsViewState extends State<DebugSettingsView> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CheckboxListTile(
            title: Text('Debug API'),
            value: widget.payloadConfig.settings.debugApiEnabled,
            onChanged: (value) => setState(
                  () {
                    if (value == null) return;
                    widget.payloadConfig.settings.debugApiEnabled = value;
                  },
                )),
        EditableListTile(
            title: 'Debug API Endpoint',
            currentValue: widget.payloadConfig.settings.debugApiPath,
            onEditComplete: (value) => setState(
                  () {
                    widget.payloadConfig.settings.debugApiPath = value;
                  },
                ))
      ],
    );
  }
}
