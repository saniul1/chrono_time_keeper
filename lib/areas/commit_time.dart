import 'dart:async';

import 'package:flutter/material.dart';

import '../states/time_commit_info_states.dart';

class CommitTime extends StatefulWidget {
  const CommitTime({
    super.key,
  });

  @override
  State<CommitTime> createState() => _CommitTimeState();
}

class _CommitTimeState extends State<CommitTime> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTime.addListener(() {
      _timer?.cancel();
      if (startTime.value != null) {
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {});
        });
      }
    });
    endTime.addListener(() {
      if (endTime.value != null) _timer?.cancel();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final duration = CommitData.of(context).calculateTime();
    final inHrs = duration.inHours;
    return Text(
      '${inHrs == 0 ? '' : '$inHrs hrs '}${duration.inMinutes % 60} min ${endTime.value == null ? ' ${duration.inSeconds % 60} sec' : ''}',
    );
  }
}
