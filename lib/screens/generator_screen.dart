import 'package:flutter/material.dart';
import 'package:nai_casrand/widgets/generation_info_widget.dart';

import '../models/utils.dart';
import '../models/info_manager.dart';

import '../widgets/blinking_icon.dart';

class PromptGenerationScreen extends StatefulWidget {
  const PromptGenerationScreen({super.key});

  @override
  PromptGenerationScreenState createState() => PromptGenerationScreenState();
}

class PromptGenerationScreenState extends State<PromptGenerationScreen> {
  final PageController _pageController = PageController();
  double _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading:
              InfoManager().isRequesting ? BlinkingIcon() : SizedBox.shrink(),
          title: const Text('Generation'),
        ),
        body: Center(
          child: _buildResponsiveLayout(),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        floatingActionButton: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton(
                  onPressed: _generatePrompt,
                  tooltip: 'Generate one prompt',
                  child: const Icon(Icons.edit)),
              const SizedBox(
                height: 20,
              ),
              FloatingActionButton(
                  onPressed: _toggleGeneration,
                  tooltip: 'Toggle generation',
                  child: InfoManager().isGenerating
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow))
            ],
          ),
        ));
  }

  void _generatePrompt() async {
    InfoManager().generatePrompt();
  }

  void _toggleGeneration() async {
    setState(() {
      InfoManager().isGenerating = !InfoManager().isGenerating;
    });
    if (InfoManager().isGenerating) {
      InfoManager().generateImage();
    }
  }

  Widget _buildResponsiveLayout() {
    return Column(
      children: [
        Expanded(
          child: InfoManager().imgInfos.isEmpty
              ? const Center(child: Text('Waiting for generations...'))
              : PageView.builder(
                  controller: _pageController,
                  itemCount: InfoManager().imgInfos.length,
                  itemBuilder: (context, index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ImgInfoWidget(
                            imgInfo: InfoManager().imgInfos[index]));
                  },
                ),
        ),
        if (InfoManager().imgInfos.length > 1)
          Padding(
              padding: EdgeInsets.only(right: 100),
              child: Slider(
                value: _currentPage,
                min: 0,
                max: (InfoManager().imgInfos.length - 1).toDouble(),
                divisions: InfoManager().imgInfos.length - 1,
                label: 'Page ${_currentPage.round()}',
                onChanged: (value) {
                  setState(() {
                    _currentPage = value;
                    _pageController.jumpToPage(value.toInt());
                  });
                },
              )),
      ],
    );
    // GridView.custom(
    //     gridDelegate: SliverWovenGridDelegate.count(
    //       crossAxisCount: 4,
    //       mainAxisSpacing: 8,
    //       crossAxisSpacing: 8,
    //       pattern: [
    //         WovenGridTile(1),
    //         WovenGridTile(
    //           5 / 7,
    //           crossAxisRatio: 0.9,
    //           alignment: AlignmentDirectional.centerEnd,
    //         ),
    //       ],
    //     ),
    //     childrenDelegate: SliverChildBuilderDelegate(
    //       (context, index) {
    //         return ImgInfoWidget(imgInfo: InfoManager().imgInfos[index]);
    //       },
    //       childCount: 20, // 设置你的网格项数量
    //     ));
    // var size = MediaQuery.of(context).size;
    // bool useRow = size.width > size.height; // 当屏幕宽度大于高度时使用Row

    // var content = [
    //   InfoManager().img == null
    //       ? const SizedBox.shrink()
    //       : Expanded(
    //           flex: 3,
    //           child: Container(
    //             padding: const EdgeInsets.all(20),
    //             child: InfoManager().img!,
    //           ),
    //         ),
    //   Expanded(
    //     flex: 1,
    //     child: Padding(
    //       padding: const EdgeInsets.all(20),
    //       child: Stack(
    //         children: [
    //           ListTile(
    //             title: const Text("Log"),
    //             subtitle: SingleChildScrollView(
    //               reverse: true,
    //               child: Text(InfoManager().log),
    //             ),
    //             dense: true,
    //           ),
    //           Align(
    //             alignment: Alignment.topRight,
    //             child: IconButton(
    //               onPressed: _dumpLog,
    //               icon: const Icon(Icons.download),
    //               tooltip: 'Dump logs',
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // ];

    // if (useRow) {
    //   return Padding(
    //       padding: const EdgeInsets.all(20),
    //       child: Row(
    //         children: content,
    //       ));
    // } else {
    //   return Padding(
    //       padding: const EdgeInsets.all(20),
    //       child: Column(
    //         children: content,
    //       ));
    // }
  }

  void _dumpLog() {
    saveStringToFile(
        InfoManager().log, 'nai-generator-log-${generateRandomFileName()}.txt');
  }
}
