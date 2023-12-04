import 'package:flutter/material.dart';
import 'package:flutter_persistent_value_notifier/flutter_persistent_value_notifier.dart';

class DoubleValue extends ValueNotifier<double> {
  DoubleValue(super.value);
}

final sliderValue = PersistentValueNotifier<double>(
  initialValue: 0,
  sharedPreferencesKey: 'slider-value',
);
final breakValue = DoubleValue(0);

class DateTimeValue extends ValueNotifier<DateTime?> {
  DateTimeValue(super.value);
}

final startTime = DateTimeValue(null);
final endTime = DateTimeValue(null);

class CommitData extends InheritedWidget {
  const CommitData({
    super.key,
    this.start,
    this.end,
    this.breakBetween,
    required super.child,
  });

  final DateTime? start;
  final DateTime? end;
  final double? breakBetween;

  Duration calculdateTime() {
    final endTime = end ?? DateTime.now();
    if (start != null) {
      return endTime.difference(start!) -
          Duration(minutes: breakValue.value.toInt());
    }
    return Duration.zero;
  }

  static CommitData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CommitData>()!;

  @override
  bool updateShouldNotify(CommitData oldWidget) {
    return start != oldWidget.start ||
        end != oldWidget.end ||
        breakBetween != oldWidget.breakBetween;
  }
}
