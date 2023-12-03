class CommitDataModel {
  final int id;
  final DateTime start;
  final DateTime end;
  final int breakValue;
  final String action;

  CommitDataModel({
    required this.id,
    required this.start,
    required this.end,
    required this.breakValue,
    required this.action,
  });

  Duration calculdateTime() {
    final endTime = end;
    return endTime.difference(start) - Duration(minutes: breakValue);
  }

  String calculdateTimeString([Duration? duration]) {
    duration ??= calculdateTime();
    final inHrs = duration.inHours;
    return '${inHrs == 0 ? '' : '$inHrs hrs '}${duration.inMinutes % 60} min';
  }

  factory CommitDataModel.fromMap(Map<String, dynamic> map) {
    return CommitDataModel(
      id: map['id'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      breakValue: map['break'],
      action: map['action'],
    );
  }

  static List<CommitDataModel> fromListOfMap(List<Map<String, dynamic>> data) {
    return data.map((item) => CommitDataModel.fromMap(item)).toList();
  }
}
