import 'package:chrono_time_keeper/flavors.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class DB extends ChangeNotifier {
  DB._();
  static final DB instance = DB._();

  late final Database db;

  Future<void> open() async {
    db = await openDatabase(
        F.appFlavor != Flavor.dev ? 'chrono_db_dev.db' : 'chrono_db.db',
        version: 1, onCreate: (db, version) async {
      await db.execute('''
  CREATE TABLE chrono (
    id INTEGER PRIMARY KEY,
    start TIMESTAMP NOT NULL,
    end TIMESTAMP NOT NULL,
    break INTEGER NOT NULL,
    action TEXT NOT NULL
  )
''');
    });
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
}
