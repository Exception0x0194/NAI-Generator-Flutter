import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nai_casrand/ui/generation_page/cards/info_card.dart';
import 'package:nai_casrand/ui/generation_page/generation_page_viewmodel.dart';
import 'package:nai_casrand/ui/widgets/slider_list_tile.dart';
import 'package:provider/provider.dart';

class GenerationPageView extends StatelessWidget {
  final GenerationPageViewmodel viewmodel;
  final ScrollController _scrollController = ScrollController();

  GenerationPageView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    final content = ChangeNotifierProvider.value(
      value: viewmodel,
      builder: (context, child) => Consumer<GenerationPageViewmodel>(
        builder: (context, value, child) {
          final itemCount = viewmodel.infoCardContentList.length;
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            controller: _scrollController,
            itemCount: (itemCount / viewmodel.cardsPerCol).ceil(),
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 20.0),
              child: _buildCardColumn(index),
            ),
          );
        },
      ),
    );
    final scroll = Scrollbar(
        controller: _scrollController,
        thickness: 20,
        radius: const Radius.circular(10),
        child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                _scrollController.animateTo(
                  _scrollController.offset + pointerSignal.scrollDelta.dy,
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.linear,
                );
              }
            },
            child: content));
    final buttons = Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: () => _showDisplaySettingsDialog(context),
          tooltip: tr('generation_settings'),
          child: const Icon(Icons.handyman_outlined),
        ),
        SizedBox(height: 20.0),
        FloatingActionButton(
          onPressed: () => viewmodel.addTestPromptInfoCardContent(),
          tooltip: tr('add_info'),
          child: const Icon(Icons.add),
        ),
      ],
    );
    return Scaffold(
      body: scroll,
      floatingActionButton: buttons,
    );
  }

  void _showDisplaySettingsDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(tr('generation_settings')),
              content: DisplaySettingsView(viewmodel: viewmodel),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(tr('confirm')))
              ],
            ));
  }

  Widget _buildCardColumn(int colIndex) {
    final itemCount = viewmodel.infoCardContentList.length;
    final startIndex = itemCount - 1 - colIndex * viewmodel.cardsPerCol;
    final endIndex = max(
      itemCount - (colIndex + 1) * viewmodel.cardsPerCol,
      0,
    );
    List<Widget> cards = [];
    for (int index = startIndex; index >= endIndex; index--) {
      cards.add(Expanded(
          child: InfoCard(content: viewmodel.infoCardContentList[index])));
    }
    return Column(children: cards);
  }
}

class DisplaySettingsView extends StatelessWidget {
  final GenerationPageViewmodel viewmodel;

  const DisplaySettingsView({super.key, required this.viewmodel});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: viewmodel,
        child: Consumer<GenerationPageViewmodel>(
          builder: (context, value, child) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SliderListTile(
                title:
                    '${tr('cards_per_col')}: ${viewmodel.cardsPerCol.toString()}',
                sliderValue: viewmodel.cardsPerCol.toDouble(),
                min: 1.0,
                max: 5.0,
                divisions: 4,
                onChanged: (value) => viewmodel.setCardsPerCol(value.toInt()),
              ),
            ],
          ),
        ));
  }
}
