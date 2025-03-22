import 'package:flutter/foundation.dart';
import 'package:flutter_command/flutter_command.dart';
import 'package:nai_casrand/data/models/info_card_content.dart';

class CommandStatus {
  List<Command<void, InfoCardContent>> commandList = [];
  DateTime batchTimestamp = DateTime.now();

  int currentBatchCount = 0;
  int currentTotalCount = 0;

  ValueNotifier<bool> isBatchActive = ValueNotifier(false);
  ValueNotifier<bool> isCoolingDown = ValueNotifier(false);
}
