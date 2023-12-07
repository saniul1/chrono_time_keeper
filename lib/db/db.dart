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

  Future<void> _populateWithMockData() async {
    if (F.appFlavor == Flavor.dev) {
      // Populate with random data
      var now = DateTime.now();
      var random = Random();
      for (var i = 0; i < 10; i++) {
        var entries =
            random.nextInt(10) + 1; // Random number of entries between 1 and 10
        for (var j = 0; j < entries; j++) {
          var start =
              now.subtract(Duration(days: i, hours: random.nextInt(24)));
          var end = start.add(Duration(hours: random.nextInt(8)));
          var breakValue = random.nextInt(30);
          var action = 'Random Action ${random.nextInt(4)}';
          await db.insert(
            'chrono',
            {
              'start': start.toIso8601String(),
              'end': end.toIso8601String(),
              'break': breakValue,
              'action': action,
            },
          );
        }
      }
    }
  }
}
