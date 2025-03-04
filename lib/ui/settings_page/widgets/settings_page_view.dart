import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/settings_page/view_models/settings_page_viewmodel.dart';
import 'package:nai_casrand/ui/core/widgets/editable_list_tile.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/defaults.dart';

class SettingsPageView extends StatelessWidget {
  final SettingsPageViewmodel viewmodel;

  const SettingsPageView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = ChangeNotifierProvider.value(
      value: viewmodel,
      child: Consumer<SettingsPageViewmodel>(
        builder: (context, viewmodel, child) => Column(
          children: [
            _buildApiKeyTile(),
            _buildBatchTile(),
            _buildEraseMetadataTile(context),
            if (!kIsWeb && Platform.isWindows) _buildOutputSelectionTile(),
            _buildPrefixKeyTile(),
            if (!kIsWeb) _buildProxyTile(),
          ],
        ),
      ),
    );

    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => viewmodel.loadJsonConfig(context),
          tooltip: tr('import_settings_from_file'),
          child: const Icon(Icons.file_open),
        ),
        const SizedBox(height: 20),
        FloatingActionButton(
          onPressed: () => viewmodel.saveJsonConfig(),
          tooltip: tr('export_settings_to_file'),
          child: const Icon(Icons.save),
        ),
      ],
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: content,
      ),
      floatingActionButton: buttons,
    );
  }

  Widget _buildApiKeyTile() {
    return EditableListTile(
        leading: const Icon(Icons.token_outlined),
        title: tr('NAI_API_key'),
        notice: tr('NAI_API_key_hint'),
        currentValue: viewmodel.settings.apiKey,
        confirmOnSubmit: true,
        onEditComplete: (value) => viewmodel.setApiKey(value));
  }

  Widget _buildBatchTile() {
    final displayedNumberOfRequests = viewmodel.settings.numberOfRequests == 0
        ? '∞'
        : viewmodel.settings.numberOfRequests.toString();
    return ExpansionTile(
      leading: const Icon(Icons.schedule),
      title: Text(tr('batch_settings')),
      subtitle: Text(tr('batch_settings_info', namedArgs: {
        'batch_count': viewmodel.settings.batchCount.toString(),
        'interval': viewmodel.settings.batchIntervalSec.toString(),
        'number_of_requests': displayedNumberOfRequests,
      })),
      children: [
        // Batch count
        Padding(
          padding: const EdgeInsets.only(left: 20),
          child: EditableListTile(
              leading: const Icon(Icons.checklist),
              title: tr('batch_count'),
              currentValue: viewmodel.settings.batchCount.toString(),
              keyboardType: TextInputType.number,
              confirmOnSubmit: true,
              onEditComplete: (value) => viewmodel.setBatchCount(value)),
        ),
        // Batch interval
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditableListTile(
                leading: const Icon(Icons.hourglass_empty),
                title: tr('batch_interval'),
                currentValue: viewmodel.settings.batchIntervalSec.toString(),
                keyboardType: TextInputType.number,
                confirmOnSubmit: true,
                onEditComplete: (value) =>
                    viewmodel.setBatchIntervalSet(value))),
        // Number of requests
        Padding(
            padding: const EdgeInsets.only(left: 20),
            child: EditableListTile(
              leading: const Icon(Icons.alarm),
              title: tr('image_number_to_generate'),
              currentValue: displayedNumberOfRequests,
              editValue: viewmodel.settings.numberOfRequests.toString(),
              notice: '0 → ∞',
              onEditComplete: (value) => viewmodel.setNumberOfRequests(value),
              keyboardType: TextInputType.number,
              confirmOnSubmit: true,
            )),
      ],
    );
  }

  Widget _buildEraseMetadataTile(BuildContext context) {
    List<Widget> tiles = [
      CheckboxListTile(
          secondary: const Icon(Icons.delete_sweep),
          title: Text(tr('metadata_erase_enabled')),
          value: viewmodel.settings.metadataEraseEnabled,
          onChanged: (value) => viewmodel.setEraseMetadataEnabled(value))
    ];
    if (viewmodel.settings.metadataEraseEnabled) {
      tiles.add(Padding(
          padding: const EdgeInsets.only(left: 20),
          child: CheckboxListTile(
              secondary: const Icon(Icons.edit_note),
              title: Text(tr('custom_metadata_enabled')),
              value: viewmodel.settings.customMetadataEnabled,
              onChanged: (value) =>
                  viewmodel.setCustomMetadataEnabled(value))));
    }
    if (viewmodel.settings.metadataEraseEnabled &&
        viewmodel.settings.customMetadataEnabled) {
      tiles.add(Padding(
          padding: const EdgeInsets.only(left: 30),
          child: ListTile(
            title: Text(tr('custom_metadata_content')),
            subtitle: Text(
              viewmodel.settings.customMetadataContent,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showEditCustomMetadataDialog(context),
          )));
    }
    return Column(
      children: tiles,
    );
  }

  Widget _buildOutputSelectionTile() {
    if (kIsWeb || Platform.isAndroid) return const SizedBox.shrink();
    final outputDirPath = viewmodel.settings.outputFolderPath == ''
        ? '<${tr('system_document_folder')}>\\nai_generated'
        : viewmodel.settings.outputFolderPath;
    return ListTile(
      leading: const Icon(Icons.folder_outlined),
      title: Text(tr('output_folder')),
      subtitle: Text(outputDirPath),
      onTap: () => viewmodel.pickOutputFolderPath(),
    );
  }

  Widget _buildProxyTile() {
    if (kIsWeb) return const SizedBox.shrink();
    final proxy = viewmodel.settings.proxy;
    return EditableListTile(
      leading: const Icon(Icons.route),
      title: tr('proxy_settings'),
      currentValue: proxy == '' ? tr('proxy_settings_direct') : proxy,
      editValue: proxy,
      notice: tr('proxy_settings_notice'),
      confirmOnSubmit: true,
      onEditComplete: (value) => viewmodel.setProxy(value),
    );
  }

  void _showEditCustomMetadataDialog(context) {
    final controller =
        TextEditingController(text: viewmodel.settings.customMetadataContent);
    submit() {
      viewmodel.setCustomMetadataContent(controller.text);
      Navigator.of(context).pop();
    }

    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                title: Text(
                    tr('edit') + tr('colon') + tr('custom_metadata_content')),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(tr('edit_custom_metadata_content_hint')),
                      TextField(
                        maxLines: null,
                        autofocus: true,
                        controller: controller,
                        onSubmitted: (_) => submit(),
                      )
                    ]),
                actions: [
                  Row(
                    children: [
                      TextButton(
                          onPressed: () => setState(
                              () => controller.text = defaultWatermarkContent),
                          child: const Text('👻')),
                      const Spacer(),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(tr('cancel')),
                      ),
                      TextButton(
                        onPressed: () => submit(),
                        child: Text(tr('confirm')),
                      )
                    ],
                  ),
                ],
              ),
            ));
  }

  Widget _buildPrefixKeyTile() {
    final shownPrefix = viewmodel.settings.fileNamePrefixKey.isNotEmpty
        ? viewmodel.settings.fileNamePrefixKey
        : 'nai-generated';
    return EditableListTile(
      leading: const Icon(Icons.description),
      title: tr('output_file_name_prefix'),
      notice: tr('output_file_name_prefix_hint'),
      editValue: viewmodel.settings.fileNamePrefixKey,
      currentValue: shownPrefix,
      confirmOnSubmit: true,
      onEditComplete: (value) => viewmodel.setFileNamePrefixKey(value),
    );
  }
}
