import 'package:flutter/material.dart';

class ValueIncrementor extends StatelessWidget {
  const ValueIncrementor({
    super.key,
    required this.onRight,
    required this.onLeft,
    required this.onTap,
    required this.valueInText,
  });

  final void Function()? onLeft;
  final void Function()? onRight;
  final void Function()? onTap;
  final Text valueInText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: onLeft,
          child: const Text('<'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: GestureDetector(
            onTap: onTap,
            child: valueInText,
          ),
        ),
        TextButton(
          onPressed: onRight,
          child: const Text('>'),
        ),
      ],
    );
  }
}
