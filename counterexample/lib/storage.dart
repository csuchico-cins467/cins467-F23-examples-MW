import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CounterStorage {
  const CounterStorage();

  Future<String> get _localPath async {
    final Directory appDocumentsDir = await getApplicationDocumentsDirectory();
    return appDocumentsDir.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File("$path/counter.txt");
  }

  Future<bool> writeCounter(int counter) async {
    try {
      final File file = await _localFile;
      String jsonString = json.encode({"counter": counter});
      if (kDebugMode) {
        print(jsonString);
      }
      await file.writeAsString(jsonString);
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
      final File file = await _localFile;
      final String contents = await file.readAsString();
      Map<String, dynamic> countData = json.decode(contents);
      return countData["counter"];
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      bool writeSuccess = await writeCounter(0);
      if (writeSuccess) {
        return 0;
      }
    }
    return -1;
  }
}
