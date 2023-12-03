import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

extension WidgetModifierListExtension on List<Widget> {
  List<Widget> wrapWithExpanded([List<int> indexes = const []]) =>
      mapIndexed<Widget>(
        (i, w) =>
            indexes.isEmpty || indexes.contains(i) ? Expanded(child: w) : w,
      ).toList();

  List<Widget> wrapWithPadding(EdgeInsets padding,
          [List<int> indexes = const []]) =>
      mapIndexed<Widget>(
        (i, w) => indexes.isEmpty || indexes.contains(i)
            ? Padding(padding: padding, child: w)
            : w,
      ).toList();

  List<Widget> inBetweenSizedBox([double? width, double? height]) {
    final list = [...this].cast<Widget>(); // ! important
    for (var i = length - 1; i > 0; i--) {
      list.insert(i, SizedBox(width: width, height: height));
    }
    return list;
  }
}
