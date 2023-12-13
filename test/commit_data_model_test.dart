import 'package:chrono_time_keeper/models/commit_data_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CommitDataModel', () {
    test('calculateTime returns correct duration', () {
      final start =
          DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
      final end = DateTime.now();
      const breakValue = 15;
      final commit = CommitDataModel(
        id: 1,
        timeRange: DateTimeRange(start: start, end: end),
        breakValue: breakValue,
        action: 'Test Action',
      );

      expect(commit.calculateTime(), const Duration(hours: 2, minutes: 15));
    });

    test('calculateTimeString returns correct string', () {
      final start =
          DateTime.now().subtract(const Duration(hours: 2, minutes: 30));
      final end = DateTime.now();
      const breakValue = 15;
      final commit = CommitDataModel(
        id: 1,
        timeRange: DateTimeRange(start: start, end: end),
        breakValue: breakValue,
        action: 'Test Action',
      );

      expect(commit.calculateTimeString(), '2 hrs 15 min');
    });
  });
}
