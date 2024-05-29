class GlobalSettings {
  static final GlobalSettings _instance = GlobalSettings._internal();
  factory GlobalSettings() {
    return _instance;
  }
  GlobalSettings._internal();

  // For generation screen
  bool showInfoForImg = true;
  double infoHeight = 1.0;

  // For config screen
  bool showCompactPromptView = false;
}
