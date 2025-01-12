import 'dart:async';
import 'dart:math';

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
import 'package:nai_casrand/data/services/postprocess_service.dart';

const infoCardContentListLength = 200;

class GenerationPageViewmodel extends ChangeNotifier {
  PayloadConfig payloadConfig;
  ValueNotifier<int> colNum = ValueNotifier(2);

  CommandStatus get commandStatus => GetIt.instance<CommandStatus>();
  List<Command<void, InfoCardContent>> get commandList =>
      commandStatus.commandList;
  ValueNotifier<int> get commandIdx => commandStatus.commandIdx;

  Command<void, InfoCardContent>? currentCommand;

  GenerationPageViewmodel({required this.payloadConfig});

  void setCardsPerCol(int value) {
    colNum.value = value;
  }

  void addAndRunCommand(Command<void, InfoCardContent> command) {
    // Make sure list is not longer than expected
    while (commandList.length >= infoCardContentListLength) {
      commandList.removeAt(0);
    }
    // Push command into list and run command
    commandList.add(command);
    commandIdx.value++;
    command();
  }

  void addLoremInfoCardContent() async {
    // Async command as image requires loading
    commandFunc() async {
      await Future.delayed(Duration(milliseconds: 500));
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
      final payloadResult = payloadConfig.getPayload();
      final additionalInfo = digestPayloadResult(payloadResult);
      return InfoCardContent(
          title: 'Test Prompt',
          info: payloadResult.comment,
          additionalInfo: additionalInfo);
    }

    // Skip the check of active command (because command is sync)
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
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
      final payloadResult = payloadConfig.getPayload();
      final request = ApiRequest(
        endpoint: endpoint,
        proxy: payloadConfig.settings.proxy,
        headers: payloadConfig.getHeaders(),
        payload: payloadResult.payload,
      );
      try {
        final response = await ApiService().fetchData(request);
        // Even if response status is not 2xx, postprocess could throw correct exception.
        var imageBytes = PostprocessService().processResponse(response.data);
        // Add custom metadata
        if (payloadConfig.settings.metadataEraseEnabled) {
          final metadataString = payloadConfig.settings.customMetadataEnabled
              ? payloadConfig.settings.customMetadataContent
              : '';
          imageBytes = await PostprocessService()
              .embedMetadata(imageBytes, metadataString);
        }
        // Save image
        final fileName = 'nai-generated-'
            '${FileService().generateTimestampString(commandStatus.batchTimestamp)}-'
            '${commandStatus.currentTotalCount}-'
            '${FileService().generateRandomString()}.png';
        FileService().savePictureToFile(
          imageBytes,
          fileName,
          payloadConfig.settings.outputFolderPath,
        );
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
          additionalInfo: {},
        );
      }
    }

    // Create command and attach post-command operations
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
    command.isExecuting.addListener(() {
      // Only update after execution
      if (command.isExecuting.value) return;

      commandStatus.currentBatchCount++;
      commandStatus.currentTotalCount++;
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
  Map<String, dynamic> digestPayloadResult(PayloadResult payloadResult) {
    final additionalInfo = payloadResult.payload;
    final additionalInfoParam =
        additionalInfo['parameters']! as Map<String, dynamic>;
    for (final key in [
      'reference_image_multiple',
      'reference_information_extracted_multiple',
      'reference_strength_multiple'
    ]) {
      additionalInfoParam.remove(key);
    }
    additionalInfo.remove('parameters');
    additionalInfo.addAll(additionalInfoParam);
    return additionalInfo;
  }
}
