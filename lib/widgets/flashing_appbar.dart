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

    if (newState == _currentStatus) return;
    _currentStatus = newState;

    switch (_currentStatus) {
      case 'idle':
        _animationController!.stop();
        _colorAnimation = null;
        _animationController!.value = 0.0;
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
    }
    return AppBar(
      title: Text(_currentTitle),
      backgroundColor: _colorAnimation?.value ??
          Colors.transparent, // Use theme color as default
    );
  }
}
