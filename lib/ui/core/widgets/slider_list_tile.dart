import 'package:flutter/material.dart';

class SliderListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(title),
          leading: leading,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 10,
            child: Slider(
                value: sliderValue.clamp(min, max),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (value) => onChanged(value)),
          ),
        )
      ],
    );
  }
}

class RangeListTile extends StatelessWidget {
  final String title;
  final double sliderStart;
  final double sliderEnd;
  final double min;
  final double max;
  final int divisions;
  final Function(double, double) onChanged;
  final Widget? leading;

  const RangeListTile({
    super.key,
    required this.title,
    required this.sliderStart,
    required this.sliderEnd,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          title: Text(title),
          leading: leading,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 10,
            child: RangeSlider(
                values: RangeValues(
                    sliderStart.clamp(min, max), sliderEnd.clamp(min, max)),
                min: min,
                max: max,
                divisions: divisions,
                onChanged: (range) => onChanged(range.start, range.end)),
          ),
        )
      ],
    );
  }
}
