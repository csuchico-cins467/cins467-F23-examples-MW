import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

const String tableCount = 'counts';
const String columnId = '_id';
const String columnCount = 'count';

class CountObject {
  int id = 0;
  late int count;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{columnCount: count, columnId: id};
    return map;
  }

  CountObject();

  CountObject.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    count = map[columnCount];
  }
}

class CounterStorage {
  late Database db;
  CounterStorage();

  Future<void> open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableCount (
  $columnId integer primary key autoincrement,
  $columnCount integer not null)
''');
    });
  }

  Future<CountObject> insert(CountObject co) async {
    co.id = await db.insert(tableCount, co.toMap());
    return co;
  }

  Future<CountObject> getCount(int id) async {
    List<Map<String, dynamic>> maps = await db.query(tableCount,
        columns: [columnId, columnCount],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      Map first = maps.first;
      return CountObject.fromMap(first);
    }
    CountObject co = CountObject();
    co.count = 0;
    co.id = id;
    co = await insert(co);
    return co;

    // return null;
  }

  Future<int> update(CountObject co) async {
    return await db.update(tableCount, co.toMap(),
        where: '$columnId = ?', whereArgs: [co.id]);
  }

  Future close() async => db.close();

  Future<bool> writeCounter(int counter) async {
    try {
      await open("counter2.db");
      CountObject co = CountObject();
      co.count = counter;
      co.id = 0;
      await update(co);
      await close();
      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return false;
  }

  Future<int> readCounter() async {
    try {
      await open("counter2.db");
      CountObject co = await getCount(0);
      await close();
      return co.count;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return -1;
  }
}
