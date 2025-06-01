import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/api_request.dart';
import 'package:nai_casrand/data/models/command_status.dart';
import 'package:nai_casrand/data/models/info_card_content.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';
import 'package:nai_casrand/data/services/api_service.dart';
import 'package:nai_casrand/data/services/file_service.dart';
import 'package:nai_casrand/data/services/image_service.dart';
import 'package:nai_casrand/data/use_cases/generate_payload_use_case.dart';

const infoCardContentListLength = 200;

class GenerationPageViewmodel extends ChangeNotifier {
  PayloadConfig get payloadConfig => GetIt.I<PayloadConfig>();
  CommandStatus get commandStatus => GetIt.I<CommandStatus>();
  List<Command<void, InfoCardContent>> get commandList =>
      commandStatus.commandList;
  int get colNum => payloadConfig.settings.generationPageColumnCount;

  Command<void, InfoCardContent>? currentCommand;

  PayloadGenerationResult? _cachedPayloadResult;
  int _cacheRetriesCount = 0;

  void setCardsPerCol(int value) {
    payloadConfig.settings.generationPageColumnCount = value;
    notifyListeners();
  }

  void addAndRunCommand(Command<void, InfoCardContent> command) {
    // Make sure list is not longer than expected
    while (commandList.length >= infoCardContentListLength) {
      commandList.removeAt(0);
    }
    // Push command into list and run command
    commandList.add(command);
    command();
  }

  void addLoremInfoCardContent() async {
    // Async command as image requires loading
    commandFunc() async {
      await Future.delayed(const Duration(milliseconds: 500));
      final random = Random();
      final bytes =
          Uint8List.sublistView(await rootBundle.load('assets/appicon.png'));
      return InfoCardContent(
        title: '#${commandList.length}: ${loremIpsum(
          words: random.nextInt(3) + 3,
          initWithLorem: true,
        )}',
        info: loremIpsum(
          words: random.nextInt(300),
          initWithLorem: true,
        ),
        additionalInfo: {"Random Seed": random.nextInt(1 << 31)},
        imageBytes: random.nextInt(2) == 1 ? null : bytes,
      );
    }

    // Skip if active command exists
    if (currentCommand != null && currentCommand!.isExecuting.value) return;
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
    currentCommand = command;
    addAndRunCommand(command);
  }

  void addTestPromptInfoCardContent() {
    // Sync command but wrapped as async
    commandFunc() async {
      final payloadResult =
          GeneratePayloadUseCase(payloadConfig: payloadConfig)();
      final additionalInfo = digestPayloadResult(payloadResult);
      return InfoCardContent(
          title: tr('test_prompt'),
          info: payloadResult.comment,
          additionalInfo: additionalInfo);
    }

    // Skip the check of active command (because command is sync)
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
    command.isExecuting.addListener(() {
      if (command.isExecuting.value) return;
      notifyListeners();
    });
    addAndRunCommand(command);
  }

  void nextCommand() {
    // Stop if batch is inactive or cooling down
    if (!commandStatus.isBatchActive.value) return;
    if (commandStatus.isCoolingDown.value) return;

    // Skip if active command exists
    if (currentCommand != null && currentCommand!.isExecuting.value) return;

    // Generate, postprocess and save image
    commandFunc() async {
      final endpoint = payloadConfig.settings.debugApiEnabled
          ? payloadConfig.settings.debugApiPath
          : 'https://image.novelai.net/ai/generate-image';

      // Check whether cached payload exists, use cache if exists
      PayloadGenerationResult payloadResult;
      if (_cachedPayloadResult != null && _cacheRetriesCount < 3) {
        // Use cached payload, increment counter
        payloadResult = _cachedPayloadResult!;
        _cacheRetriesCount++;
      } else {
        // Generate new payload
        payloadResult = GeneratePayloadUseCase(payloadConfig: payloadConfig)();
        _cachedPayloadResult = payloadResult; // Cache generated payload
        _cacheRetriesCount = 0;
      }

      final request = ApiRequest(
        endpoint: endpoint,
        proxy: payloadConfig.settings.proxy,
        headers: payloadConfig.getHeaders(),
        payload: payloadResult.payload,
      );
      try {
        final response = await ApiService().fetchData(request);
        // Even if response status is not 2xx, postprocess could throw correct exception.
        var imageBytes = ImageService().processResponse(response.data);
        // Add custom metadata
        if (payloadConfig.settings.metadataEraseEnabled) {
          final metadataString = payloadConfig.settings.customMetadataEnabled
              ? payloadConfig.settings.customMetadataContent
              : '';
          imageBytes =
              await ImageService().embedMetadata(imageBytes, metadataString);
        }
        // Save image
        final filePrefix = payloadResult.suggestedFileName.isNotEmpty
            ? _getSafeFileName(payloadResult.suggestedFileName)
            : '';
        final fileName = [
          FileService().generateTimestampString(commandStatus.batchTimestamp),
          commandStatus.currentTotalCount.toString().padLeft(6, '0'),
          filePrefix,
          '${FileService().generateRandomString()}.png',
        ].join('-');
        FileService().savePictureToFile(
          imageBytes,
          fileName,
          payloadConfig.settings.outputFolderPath,
        );
        // Reset cache after successful generation
        _cachedPayloadResult = null;
        // Only increment total count after successful generation
        commandStatus.currentTotalCount++;
        return InfoCardContent(
          title: fileName,
          info: payloadResult.comment,
          additionalInfo: digestPayloadResult(payloadResult),
          imageBytes: imageBytes,
        );
      } catch (e) {
        return InfoCardContent(
          title: 'Error occurred in generation process.',
          info: e.toString(),
          additionalInfo: digestPayloadResult(payloadResult),
        );
      }
    }

    // Create command and attach post-command operations
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
    command.isExecuting.addListener(() {
      notifyListeners();
      // Only update after execution
      if (command.isExecuting.value) return;

      commandStatus.currentBatchCount++;
      if (commandStatus.currentTotalCount >=
              payloadConfig.settings.numberOfRequests &&
          payloadConfig.settings.numberOfRequests != 0) {
        stopBatch();
        return;
      } else if (commandStatus.currentBatchCount >=
          payloadConfig.settings.batchCount) {
        setCooldown();
        return;
      } else {
        nextCommand();
      }
    });

    // Execute command
    currentCommand = command;
    addAndRunCommand(command);
  }

  void startBatch() {
    commandStatus.currentBatchCount = 0;
    commandStatus.currentTotalCount = 0;
    commandStatus.isBatchActive.value = true;
    commandStatus.batchTimestamp = DateTime.now();
    nextCommand();
  }

  void stopBatch() {
    commandStatus.isBatchActive.value = false;
  }

  void setCooldown() {
    commandStatus.isCoolingDown.value = true;
    Timer(
      Duration(seconds: payloadConfig.settings.batchIntervalSec),
      () {
        commandStatus.isCoolingDown.value = false;
        commandStatus.currentBatchCount = 0;
        nextCommand();
      },
    );
  }

  void toggleBatch() {
    if (commandStatus.isBatchActive.value) {
      stopBatch();
    } else {
      startBatch();
    }
  }

  /// Make PayloadResult into readable Map<String, dynamic> for better visualization
  Map<String, dynamic> digestPayloadResult(
      PayloadGenerationResult payloadResult) {
    // 明确将 payload 转换为可空动态类型
    final additionalInfo = Map<String, dynamic>.from(payloadResult.payload);

    // 使用 Map.from 确保 parameters 的类型为 Map<String, dynamic>
    final additionalInfoParam = Map<String, dynamic>.from(
      additionalInfo['parameters']! as Map,
    );

    // 移除不需要的键
    for (final key in [
      'reference_image_multiple',
      'reference_information_extracted_multiple',
      'reference_strength_multiple'
    ]) {
      additionalInfoParam.remove(key);
    }

    additionalInfo.remove('parameters');

    // 合并时使用显式类型转换
    additionalInfo.addAll(additionalInfoParam.cast<String, dynamic>());

    return additionalInfo;
  }

  void clearCommandList() {
    // Remove finished commands in list
    commandList.removeWhere((command) => !command.isExecuting.value);
    notifyListeners();
  }

  String _getSafeFileName(String fileName) {
    String safeName = fileName.replaceAll(RegExp(r'[<>"/\\|?*{}\[\]]'), '');
    safeName = safeName.replaceAll(RegExp(r'[:]'), '_');
    return safeName.substring(0, min(200, safeName.length));
  }

  void setOverride(bool? value) {
    if (value == null) return;
    payloadConfig.useOverridePrompt = value;
    notifyListeners();
  }

  void setCharacterOverride(bool? value) {
    if (value == null) return;
    payloadConfig.useCharacterPromptWithOverride = value;
    notifyListeners();
  }

  void setOverridePrompt(String value) {
    payloadConfig.overridePrompt = value;
    notifyListeners();
  }

  void setUC(String value) {
    payloadConfig.paramConfig.negativePrompt = value;
    notifyListeners();
  }
}
