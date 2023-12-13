import 'dart:math';

import 'package:chrono_time_keeper/flavors.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DB extends ChangeNotifier {
  DB._();
  static final DB instance = DB._();

  late final Database db;

  Future<void> open() async {
    String dbName =
        F.appFlavor == Flavor.dev ? 'chrono_db_dev.db' : 'chrono_db.db';
    if (F.appFlavor == Flavor.dev) await deleteDatabase(dbName);
    db = await openDatabase(
      dbName,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
  CREATE TABLE chrono (
    id INTEGER PRIMARY KEY,
    start TIMESTAMP NOT NULL,
    end TIMESTAMP NOT NULL,
    break INTEGER NOT NULL,
    action TEXT NOT NULL
  )
''');
      },
    );
    if (F.appFlavor == Flavor.dev) _populateWithMockData();
    return;
  }

  Future<void> addChrono(
      DateTime start, DateTime end, int breakValue, String action) async {
    await db.insert(
      'chrono',
      {
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'break': breakValue,
        'action': action,
      },
    );

    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getChronoForDay(DateTime day) async {
    String dayStart = DateTime(day.year, day.month, day.day).toIso8601String();
    String nextDayStart =
        DateTime(day.year, day.month, day.day + 1).toIso8601String();

    List<Map<String, dynamic>> records = await db.query(
      'chrono',
      where: 'start >= ? AND start < ?',
      whereArgs: [dayStart, nextDayStart],
      orderBy: 'start DESC',
    );

    return records;
  }

  Future<List<Map<String, dynamic>>> getChronoForActionAndDays(
      String action, int days) async {
    final today = DateTime.now();
    String daysAgoStart =
        DateTime(today.year, today.month, today.day - days).toIso8601String();

    // DateTime.now().subtract(Duration(days: days)).toIso8601String();

    List<Map<String, dynamic>> records = await db.query(
      'chrono',
      where: 'action LIKE ? AND start >= ?',
      whereArgs: ['%$action%', daysAgoStart],
      orderBy: 'start DESC',
    );

    return records;
  }

  Future<List<String>> getMatchingActions(String match) async {
    List<Map<String, dynamic>> records = await db.query(
      'chrono',
      columns: ['DISTINCT action'],
      where: 'action LIKE ?',
      whereArgs: ['%$match%'],
    );

    return records.map((record) => record['action'] as String).toList();
  }

  Future<List<String>> getRecentUniqueActions(int days) async {
    String daysAgoStart =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();

    List<Map<String, dynamic>> records = await db.query(
      'chrono',
      columns: ['DISTINCT action'],
      where: 'start >= ?',
      whereArgs: [daysAgoStart],
      orderBy: 'start DESC',
    );

    return records.map((record) => record['action'] as String).toList();
  }

  Future<void> deleteEntryById(int id) async {
    await db.delete(
      'chrono',
      where: 'id = ?',
      whereArgs: [id],
    );
    notifyListeners();
  }

  static Future<bool> isDateValueWithinAnyEntry(DateTime dateValue) async {
    // Get all entries for the day
    List<Map<String, dynamic>> entries =
        await DB.instance.getChronoForDay(dateValue);

    // Iterate over all entries
    for (var entry in entries) {
      DateTime start = DateTime.parse(entry['start']);
      DateTime end = DateTime.parse(entry['end']);

      // Check if dateValue is within start and end
      if (dateValue.isAfter(start) && dateValue.isBefore(end)) {
        return true;
      }
    }

    // If no matching entry was found, return false
    return false;
  }

  Future<void> _populateWithMockData() async {
    var rng = Random();
    var now = DateTime.now();
    var actions = ['Action 1', 'Action 2', 'Action 3', 'Action 4', 'Action 5'];
    for (var i = 0; i < 30; i++) {
      var day = now.subtract(Duration(days: i));
      var startOfDay = DateTime(day.year, day.month, day.day);
      var endOfDay = startOfDay.add(const Duration(days: 1));
      var start = startOfDay;
      var entriesCount =
          rng.nextInt(6) + 1; // Random number of entries between 1 and 6
      for (var j = 0; j < entriesCount; j++) {
        if (start.isAfter(endOfDay)) {
          break;
        }
        var duration = Duration(minutes: rng.nextInt(10) + 60);
        var end = start.add(duration);
        if (end.isAfter(endOfDay)) {
          break;
        }
        var action = actions[rng.nextInt(actions.length)]; // Random action
        await addChrono(start, end, rng.nextInt(10), action);
        // Add a gap between the end of the current entry and the start of the next one
        start = end.add(Duration(minutes: rng.nextInt(10) + 10));
      }
    }
  }
}
