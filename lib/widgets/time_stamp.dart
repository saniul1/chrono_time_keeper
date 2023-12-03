import 'package:flutter/material.dart';

class TimeStamp extends StatefulWidget {
  const TimeStamp({
    super.key,
    required this.setTime,
    required this.buildChild,
  });

  final void Function(bool doubleTap) setTime;
  final Widget Function(BuildContext context) buildChild;

  @override
  State<TimeStamp> createState() => _TimeStampState();
}

class _TimeStampState extends State<TimeStamp> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => widget.setTime(false),
      onDoubleTap: () => widget.setTime(true),
      splashFactory: NoSplash.splashFactory,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: const BoxConstraints(minWidth: 100),
        child: Center(child: widget.buildChild(context)),
      ),
    );
  }
}
