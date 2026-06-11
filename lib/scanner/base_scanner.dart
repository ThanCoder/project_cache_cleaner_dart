import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:project_cache_cleaner/types.dart';
import 'package:project_cache_cleaner/utils.dart';

abstract class BaseScanner {
  String get projectType;
  bool isMatch(String testName);
  List<String> get cacheFolderNames;
  bool shouldQueueSubFolder(String dirname) => !dirname.startsWith('.');

  ProjectInfo? process(
    Directory currentDir,
    List<Directory> subFolders,
    bool includeEmptyCacheProject,
  ) {
    int totalSize = 0;
    List<String> cacheFolders = [];

    for (var folder in subFolders) {
      if (cacheFolderNames.contains(folder.getName())) {
        cacheFolders.add(folder.path);
        totalSize += getFolderSize(folder);
      }
    }
    //
    if (!includeEmptyCacheProject && totalSize == 0) return null;

    return ProjectInfo(
      name: currentDir.getName(),
      type: projectType,
      cacheFolders: cacheFolders,
      totalCacheSize: totalSize,
    );
  }
}


abstract class BaseSystemCacheScanner {
  String get cacheName;
  String get projectType; // သင့် ProjectType Enum သို့မဟုတ် String

  // Home Directory ရဲ့ ဘယ်နေရာမှာ ရှိလဲဆိုတဲ့ နှိုင်းရလမ်းကြောင်း (Relative Path)
  String get relativePath;

  ProjectInfo? process(String homePath) {
    // path တွေကို စနစ်တကျ ဆက်ဖို့ uri သို့မဟုတ် standard path extension သုံးနိုင်ပါတယ်
    final targetPath = Directory(homePath).uri.resolve(relativePath).toFilePath();
    final dir = Directory(targetPath);

    if (!dir.existsSync()) return null;

    final size = getFolderSize(dir);
    if (size == 0) return null; // System cache ကိုတော့ ပုံမှန်အားဖြင့် အလွတ်ဆို မပြချင်လို့ပါ

    return ProjectInfo(
      name: cacheName,
      type: projectType,
      cacheFolders: [targetPath],
      totalCacheSize: size,
    );
  }
}