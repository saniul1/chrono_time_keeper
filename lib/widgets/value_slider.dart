import 'package:flutter/material.dart';

import '../states/time_commit_info_states.dart';

class ValueSlider extends StatefulWidget {
  const ValueSlider({
    super.key,
  });

  @override
  State<ValueSlider> createState() => _ValueSliderState();
}

class _ValueSliderState extends State<ValueSlider> {
  final _maxValue = 60.0;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          activeTrackColor: Colors.transparent,
          inactiveTrackColor: Colors.transparent,
          trackHeight: 4.0,
          thumbShape: CustomSliderThumbRect(
            thumbHeight: 52,
            min: 0,
            max: _maxValue.toInt(),
          ),
          activeTickMarkColor: Theme.of(context).textTheme.bodyMedium?.color,
          inactiveTickMarkColor: Theme.of(context).textTheme.bodyMedium?.color,
          tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 1.8),
        ),
        child: ValueListenableBuilder(
            valueListenable: sliderValue,
            builder: (context, value, _) {
              return Slider(
                value: value,
                max: _maxValue,
                min: 0,
                divisions: 12,
                onChanged: (val) {
                  sliderValue.value = val;
                },
              );
            }),
      ),
    );
  }
}

class CustomSliderThumbRect extends SliderComponentShape {
  final double thumbHeight;
  final int min;
  final int max;

  const CustomSliderThumbRect({
    required this.thumbHeight,
    required this.min,
    required this.max,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbHeight);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final rRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: center, width: thumbHeight * 1.2, height: thumbHeight * .6),
      Radius.circular(thumbHeight * .4),
    );

    final paint = Paint()
      ..color = sliderTheme.activeTrackColor! //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbHeight * .3,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor,
        height: 1,
      ),
      text: getValue(value),
    );
    TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawRRect(rRect, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
