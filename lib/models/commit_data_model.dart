import 'package:flutter/material.dart';

class CommitDataModel {
  final int id;
  final DateTimeRange timeRange;
  final int breakValue;
  final String action;

  CommitDataModel({
    required this.id,
    required this.timeRange,
    required this.breakValue,
    required this.action,
  });

  Duration calculateTime() {
    final endTime = timeRange.end;
    return endTime.difference(timeRange.start) - Duration(minutes: breakValue);
  }

  String calculateTimeString([Duration? duration]) {
    duration ??= calculateTime();
    final inHrs = duration.inHours;
    return '${inHrs == 0 ? '' : '$inHrs hrs '}${duration.inMinutes % 60} min';
  }

  factory CommitDataModel.fromMap(Map<String, dynamic> map) {
    return CommitDataModel(
      id: map['id'],
      timeRange: DateTimeRange(
          start: DateTime.parse(map['start']), end: DateTime.parse(map['end'])),
      breakValue: map['break'],
      action: map['action'],
    );
  }

  static List<DateTimeRange> dateRangeFromListOfMap(
      List<Map<String, dynamic>> data) {
    return data
        .map(
          (map) => DateTimeRange(
            start: DateTime.parse(map['start']),
            end: DateTime.parse(map['end']),
          ),
        )
        .toList();
  }

  static List<CommitDataModel> fromListOfMap(List<Map<String, dynamic>> data) {
    return data.map((item) => CommitDataModel.fromMap(item)).toList();
  }
}
