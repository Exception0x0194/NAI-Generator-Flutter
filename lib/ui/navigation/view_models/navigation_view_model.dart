import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:get_it/get_it.dart';
import 'package:nai_casrand/data/models/payload_config.dart';
import 'package:nai_casrand/data/services/config_service.dart';

class NavigationViewModel extends ChangeNotifier {
  int currentPageIndex = 0;

  void changeIndex(int value) {
    // If leaving from prompt page or settings page, save the config
    if (currentPageIndex == 1 || currentPageIndex == 2) {
      final config = GetIt.instance<PayloadConfig>();
      final service = GetIt.instance<ConfigService>();
      service.saveConfig(json.encode(config));
    }
    currentPageIndex = value;
    notifyListeners();
  }

  Future<Uint8List?> decryptAsset(String assetPath) async {
    const keyBase64 = String.fromEnvironment("ASSET_KEY_BASE64");
    const ivBase64 = String.fromEnvironment("ASSET_IV_BASE64");
    final key = encrypt.Key.fromBase64(keyBase64);
    final iv = encrypt.IV.fromBase64(ivBase64);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    try {
      final assetByteData = await rootBundle.load(assetPath);
      final encryptedBase64 = assetByteData.buffer.asUint8List();
      final decryptedBase64 =
          encrypter.decrypt(encrypt.Encrypted(encryptedBase64), iv: iv);
      final decryptedBytes = base64Decode(decryptedBase64);
      return decryptedBytes;
    } catch (exception) {
      return null;
    }
  }
}
