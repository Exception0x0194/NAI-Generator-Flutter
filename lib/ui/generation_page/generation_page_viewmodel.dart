import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nai_casrand/data/models/info_chip_content.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:lorem_ipsum/lorem_ipsum.dart';

const infoCardContentListLength = 200;

class GenerationPageViewmodel extends ChangeNotifier {
  PayloadConfig payloadConfig;
  int cardsPerCol = 1;

  List<InfoCardContent> infoCardContentList = [];

  GenerationPageViewmodel({required this.payloadConfig});

  void addInfoCardContent(InfoCardContent content) {
    while (infoCardContentList.length >= infoCardContentListLength) {
      infoCardContentList.removeAt(0);
    }
    infoCardContentList.add(content);
    notifyListeners();
  }

  void addLoremInfoCardContent() async {
    final random = Random();
    final bytes =
        Uint8List.sublistView(await rootBundle.load('assets/appicon.png'));
    final content = InfoCardContent(
      title: '#${infoCardContentList.length}: ${loremIpsum(
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
    addInfoCardContent(content);
  }

  void addTestPromptInfoCardContent() {
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
    final content = InfoCardContent(
        title: 'Test Prompt',
        info: payloadResult.comment,
        additionalInfo: additionalInfo);
    addInfoCardContent(content);
  }

  void setCardsPerCol(int value) {
    cardsPerCol = value;
    notifyListeners();
  }
}
