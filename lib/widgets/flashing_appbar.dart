import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:nai_casrand/widgets/editable_list_tile.dart';

import '../models/info_manager.dart';

enum AppState { idle, generatingFree, generatingCost, batchWaiting }

class FlashingAppBar extends StatefulWidget implements PreferredSizeWidget {
  const FlashingAppBar({super.key});

  @override
  FlashingAppBarState createState() => FlashingAppBarState();

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight); // 默认的AppBar高度
}

class FlashingAppBarState extends State<FlashingAppBar>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<Color?>? _colorAnimation;
  Color _staticColor = Colors.transparent;
  AppState _status = AppState.idle;
  String _currentTitle = '';

  @override
  void initState() {
    super.initState();

    InfoManager().addListener(() => refreshDisplay());

    _animationController = AnimationController(
      duration: const Duration(seconds: 1), // 控制闪烁速度
      vsync: this,
    );

    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.yellow,
    ).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _animationController!.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _animationController!.forward();
        }
      });

    refreshDisplay(); // 初始化状态
  }

  @override
  void dispose() {
    _animationController?.dispose();
    InfoManager().removeListener(() => refreshDisplay());
    super.dispose();
  }

  void refreshDisplay() {
    AppState newState;
    if (InfoManager().isGenerating) {
      int width = InfoManager().paramConfig.width;
      int height = InfoManager().paramConfig.height;
      const int freePixels = 1024 * 1024;
      if (width * height > freePixels) {
        newState = AppState.generatingCost;
      } else {
        newState = AppState.generatingFree;
      }
    } else {
      newState = AppState.idle;
    }
    if (InfoManager().isCoolingDown) {
      newState = AppState.batchWaiting;
    }

    // Change display only on status is changed
    if (newState == _status) return;
    _status = newState;

    switch (_status) {
      case AppState.idle:
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.transparent;
        break;
      case AppState.generatingFree:
        _colorAnimation =
            ColorTween(begin: Colors.transparent, end: Colors.yellow)
                .animate(_animationController!);
        _animationController!.forward();
        break;
      case AppState.generatingCost:
        _colorAnimation = ColorTween(begin: Colors.transparent, end: Colors.red)
            .animate(_animationController!);
        _animationController!.forward();
        break;
      case AppState.batchWaiting:
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_status) {
      case AppState.idle:
        _currentTitle = context.tr('appbar_idle');
        break;
      case AppState.generatingFree:
        _currentTitle = context.tr('appbar_regular');
        break;
      case AppState.generatingCost:
        _currentTitle = context.tr('appbar_warning');
        break;
      case AppState.batchWaiting:
        _currentTitle = context.tr('appbar_cooldown');
        break;
    }
    final titleBar = Row(children: [
      InkWell(
          onTap: () => _showDebugDialog(context), child: Text(_currentTitle)),
      const Spacer(),
      IconButton(
          onPressed: _showLanguageDialog, icon: const Icon(Icons.translate)),
    ]);
    return AppBar(
      title: titleBar,
      backgroundColor: _colorAnimation?.value ??
          _staticColor, // Use static color for default
    );
  }

  void _showDebugDialog(BuildContext context) {
    final apiPathController =
        TextEditingController(text: InfoManager().debugApiPath);
    onEditComplete(BuildContext context, String value) {
      Navigator.of(context).pop();
      setState(() {
        InfoManager().debugApiPath = value;
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  title: const Text('Debug settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Welcome message version
                      EditableListTile(
                          title: 'Welcome message version',
                          currentValue: InfoManager().welcomeMessageVersion,
                          onEditComplete: (value) {
                            setDialogState(() {
                              InfoManager().welcomeMessageVersion = value;
                            });
                          }),
                      // Debug API Switch
                      SwitchListTile(
                          title: const Text('Enable debug API path'),
                          value: InfoManager().debugApiEnabled,
                          onChanged: (value) {
                            setDialogState(() {
                              InfoManager().debugApiEnabled = value;
                            });
                          }),
                      // Debug API Path
                      Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: TextField(
                            controller: apiPathController,
                            keyboardType: TextInputType.text,
                            enabled: InfoManager().debugApiEnabled,
                            maxLines: 1,
                            onSubmitted: (value) =>
                                onEditComplete(context, value),
                            autofocus: true,
                          )),
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>
                          onEditComplete(context, apiPathController.text),
                      child: Text(context.tr('confirm')),
                    ),
                  ],
                ));
      },
    );
  }

  void _showLanguageDialog() {
    final locales = context.supportedLocales;
    String getLocaleName(Locale locale) {
      if (locale.countryCode == null) {
        return locale.languageCode;
      } else {
        return '${locale.languageCode}-${locale.countryCode}';
      }
    }

    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text('Select language...'),
                content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: locales
                        .map((l) => ListTile(
                              title: Text(getLocaleName(l)),
                              onTap: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  context.setLocale(l);
                                });
                              },
                            ))
                        .toList()),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(context.tr('confirm')))
                ]));
  }
}
