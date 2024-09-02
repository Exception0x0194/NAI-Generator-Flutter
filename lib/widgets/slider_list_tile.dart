import 'package:flutter/material.dart';

class SliderListTile extends StatefulWidget {
  final String title;
  final double sliderValue;
  final double min;
  final double max;
  final int divisions;
  final Function(double) onChanged;
  final Widget? leading;

  const SliderListTile({
    super.key,
    required this.title,
    required this.sliderValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.leading,
  });

  @override
  State<StatefulWidget> createState() => _SliderListTileState();
}

class _SliderListTileState extends State<SliderListTile> {
  late double currentValue;

  @override
  void initState() {
    currentValue = widget.sliderValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(widget.title),
          leading: widget.leading,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 10,
            child: Slider(
                value: currentValue.clamp(widget.min, widget.max),
                min: widget.min,
                max: widget.max,
                divisions: widget.divisions,
                onChanged: (value) {
                  setState(() {
                    currentValue = value;
                    widget.onChanged(value);
                  });
                }),
          ),
        )
      ],
    );
  }
}
