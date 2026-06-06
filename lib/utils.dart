import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';

int getFolderSize(Directory dir) {
  int size = 0;
  if (!dir.existsSync()) return 0;

  final entities = dir.listSync(followLinks: false, recursive: true);
  for (var entry in entities) {
    // print(entry);
    if (!entry.isFile) continue;
    size += entry.size;
  }
  return size;
}

// 🧰 Safe Directory Deletion Helper
void deleteDir(String path) {
  try {
    final dir = Directory(path);
    if (dir.existsSync()) {
      dir.deleteSync(
        recursive: true,
      ); // Dangerous but effective (rm -rf equivalent)
      print('🗑️  Deleted: $path');
    }
  } catch (e) {
    print('❌ Error deleting $path: $e');
  }
}
