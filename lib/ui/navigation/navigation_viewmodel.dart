import 'package:flutter/material.dart';

class NavigationViewModel extends ChangeNotifier {
  int currentIndex = 0;

  void changeIndex(value) {
    currentIndex = value;
    notifyListeners();
  }
}
