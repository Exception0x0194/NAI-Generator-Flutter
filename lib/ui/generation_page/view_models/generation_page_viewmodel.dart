import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/command_status.dart';
import 'package:nai_casrand/data/models/info_card_content.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

const infoCardContentListLength = 200;

class GenerationPageViewmodel extends ChangeNotifier {
  PayloadConfig payloadConfig;
  ValueNotifier<int> cardsPerCol = ValueNotifier(1);

  CommandStatus get batchStatus => GetIt.instance<CommandStatus>();
  List<Command<void, InfoCardContent>> get commandList =>
      batchStatus.commandList;
  ValueNotifier<int> get commandIdx => batchStatus.commandIdx;

  Command<void, InfoCardContent>? currentCommand;

  GenerationPageViewmodel({required this.payloadConfig});

  void setCardsPerCol(int value) {
    cardsPerCol.value = value;
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
    if (!batchStatus.isBatchActive.value) return;
    if (batchStatus.isCoolingDown.value) return;

    // Skip if active command exists
    if (currentCommand != null && currentCommand!.isExecuting.value) return;

    // Async function that generates result
    commandFunc() async {
      await Future.delayed(Duration(milliseconds: 500));
      final random = Random();
      final bytes =
          Uint8List.sublistView(await rootBundle.load('assets/appicon.png'));
      return InfoCardContent(
        title: '#${commandIdx.value}: ${loremIpsum(
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

    // Create command and attach post-command operations
    final command = Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    );
    command.isExecuting.addListener(() {
      // Only update after execution
      if (command.isExecuting.value) return;

      batchStatus.currentBatchCount++;
      batchStatus.currentTotalCount++;
      if (batchStatus.currentTotalCount >=
              payloadConfig.settings.numberOfRequests &&
          payloadConfig.settings.numberOfRequests != 0) {
        stopBatch();
        return;
      } else if (batchStatus.currentBatchCount >=
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
    batchStatus.currentBatchCount = 0;
    batchStatus.currentTotalCount = 0;
    batchStatus.isBatchActive.value = true;
    nextCommand();
  }

  void stopBatch() {
    batchStatus.isBatchActive.value = false;
  }

  void setCooldown() {
    batchStatus.isCoolingDown.value = true;
    Timer(
      Duration(seconds: payloadConfig.settings.batchIntervalSec),
      () {
        batchStatus.isCoolingDown.value = false;
        batchStatus.currentBatchCount = 0;
        nextCommand();
      },
    );
  }

  void toggleBatch() {
    if (batchStatus.isBatchActive.value) {
      stopBatch();
    } else {
      startBatch();
    }
  }
}
