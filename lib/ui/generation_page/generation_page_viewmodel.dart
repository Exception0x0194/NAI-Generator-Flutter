import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:nai_casrand/data/models/info_chip_content.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

const infoCardContentListLength = 200;

class GenerationPageViewmodel extends ChangeNotifier {
  PayloadConfig payloadConfig;
  int cardsPerCol = 1;

  List<Command<void, InfoCardContent>> commandList = [];

  GenerationPageViewmodel({required this.payloadConfig});

  void addCommand(Command<void, InfoCardContent> command) {
    // Make sure only one command running
    if (commandList.isNotEmpty && commandList.last.isExecuting.value) return;
    // Make sure list is not longer than expected
    while (commandList.length >= infoCardContentListLength) {
      commandList.removeAt(0);
    }
    // Push command into list and run command
    commandList.add(command);
    command();
    notifyListeners();
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

    addCommand(Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    ));
  }

  void addTestPromptInfoCardContent() {
    // Sync command but wrapped as async
    commandFunc() async {
      await Future.delayed(Duration(milliseconds: 500));
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

    addCommand(Command.createAsyncNoParam(
      commandFunc,
      initialValue: InfoCardContent.fromEmpty(),
    ));
  }

  void setCardsPerCol(int value) {
    cardsPerCol = value;
    notifyListeners();
  }
}
