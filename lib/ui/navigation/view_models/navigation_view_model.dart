import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

enum AppState { idle, generating, coolingDown }

class NavigationViewModel extends ChangeNotifier {
  int currentPageIndex = 0;

  ValueNotifier<AppState> appState = ValueNotifier(AppState.idle);

  void changeIndex(value) {
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
