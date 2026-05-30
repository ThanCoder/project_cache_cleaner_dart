import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';

int getFolderSize(Directory dir) {
  int size = 0;
  final entities = dir.listSync(followLinks: false,recursive: true);
  for (var entry in entities) {
    // print(entry);
    if (!entry.isFile) continue;
    size += entry.size;
  }
  return size;
}
