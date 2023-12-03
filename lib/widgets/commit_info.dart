import 'package:flutter/material.dart';

import '../areas/commit_time.dart';
import '../states/time_commit_info_states.dart';

class CommitInfo extends StatefulWidget {
  const CommitInfo({
    super.key,
  });

  @override
  State<CommitInfo> createState() => _CommitInfoState();
}

class _CommitInfoState extends State<CommitInfo> {
  bool _isAdd = true;

  void add() {
    if (!_isAdd) {
      setState(() {
        _isAdd = true;
      });
    }
    breakValue.value += sliderValue.value;
  }

  void subtract() {
    if (_isAdd) {
      setState(() {
        _isAdd = false;
      });
    }
    final value = breakValue.value - sliderValue.value;
    breakValue.value = value < 0 ? 0 : value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          onHover: (hover) {
            if (hover && _isAdd) {
              setState(() {
                _isAdd = false;
              });
            }
          },
          onTap: subtract,
          child: SizedBox(
            width: 80,
            child: !_isAdd
                ? Row(
                    children: [
                      TextButton(
                        onPressed: subtract,
                        child: const Text('-'),
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Builder(builder: (context) {
                      final breakVal = CommitData.of(context).breakBetween;
                      return Text('${breakVal?.toInt() ?? 0} min');
                    }),
                  ),
          ),
        ),
        const CommitTime(),
        InkWell(
          onHover: (hover) {
            if (hover && !_isAdd) {
              setState(() {
                _isAdd = true;
              });
            }
          },
          onTap: add,
          child: SizedBox(
            width: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_isAdd)
                  TextButton(
                    onPressed: add,
                    child: const Text('+'),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Builder(builder: (context) {
                      final breakVal = CommitData.of(context).breakBetween;
                      return Text('${breakVal?.toInt() ?? 0} min');
                    }),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
