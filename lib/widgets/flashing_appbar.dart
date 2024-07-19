import 'package:flutter/material.dart';
import '../models/info_manager.dart';
import '../generated/l10n.dart';

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
  String _currentStatus = 'idle';
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
    String newState = 'idle';
    if (InfoManager().isGenerating) {
      int width = InfoManager().paramConfig.width;
      int height = InfoManager().paramConfig.height;
      const int freePixels = 1024 * 1024;
      if (width * height > freePixels) {
        // Burning Anlas
        newState = 'caution';
      } else {
        // Regular generation
        newState = 'regular';
      }
    } else {
      newState = 'idle';
    }
    if (InfoManager().isCoolingDown) {
      newState = 'cooldown';
    }

    if (newState == _currentStatus) return;
    _currentStatus = newState;

    switch (_currentStatus) {
      case 'idle':
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.transparent;
        break;
      case 'regular':
        _colorAnimation =
            ColorTween(begin: Colors.transparent, end: Colors.yellow)
                .animate(_animationController!);
        _animationController!.forward();
        break;
      case 'caution':
        _colorAnimation = ColorTween(begin: Colors.transparent, end: Colors.red)
            .animate(_animationController!);
        _animationController!.forward();
        break;
      case 'cooldown':
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
        _staticColor = Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_currentStatus) {
      case 'idle':
        _currentTitle = S.of(context).appbar_idle;
        break;
      case 'regular':
        _currentTitle = S.of(context).appbar_regular;
        break;
      case 'caution':
        _currentTitle = S.of(context).appbar_warning;
        break;
      case 'cooldown':
        _currentTitle = S.of(context).appbar_cooldown;
        break;
    }
    final titleBar = InkWell(
      onTap: () => _showDebugDialog(context),
      child: Text(_currentTitle),
    );
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
                      child: Text(S.of(context).confirm),
                    ),
                  ],
                ));
      },
    );
  }
}
