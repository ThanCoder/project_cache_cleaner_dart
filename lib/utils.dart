import 'dart:io';

import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:project_cache_cleaner/types.dart';

// 📦 Method 1: Delete all caches at once
void deleteAllCaches(List<ProjectInfo> projects) {
  print('\n🧹 Cleaning up all caches...');

  for (var project in projects) {
    for (var dirPath in project.cacheFolders) {
      deleteDir(dirPath);
    }
  }
  print('✨ All target caches have been successfully cleared!');
}

// 📦 Method 2: Ask one by one
void deleteInteractive(List<ProjectInfo> projects) {
  print('\n🔎 Interactive Cleanup Mode -');

  for (var project in projects) {
    stdout.write(
      '❓ Delete cache for [${project.name}] (${project.totalCacheSizeLable})? (y/N): ',
    );
    final ans = stdin.readLineSync()?.trim().toLowerCase();

    if (ans == 'y' || ans == 'yes') {
      for (var dirPath in project.cacheFolders) {
        deleteDir(dirPath);
      }
    } else {
      print('➡️  Skipped [${project.name}].');
    }
  }
  print('✨ Selected project cleanups completed!');
}

void deleteWithIndex(List<ProjectInfo> projects, List<String> indexList) {
  for (var indexStr in indexList) {
    final index = int.tryParse(indexStr);
    if (index == null) continue;
    if (index >= 0 && index < projects.length) {
      for (var dir in projects[index].cacheFolders) {
        deleteDir(dir);
      }
    }
  }
}

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
  } on PathAccessException catch (_) {
    print('⚠️ Admin Need Permission...');

    // ၂။ Permission Error တက်လာရင် Linux Command ကို 'sudo' ခံပြီး ဖျက်ခိုင်းမယ်
    // (pkexec က Terminal မှာ စကားဝှက် ရိုက်ဖို့ Window လေး ကျလာစေမှာ ဖြစ်ပါတယ်)
    final result = Process.runSync('pkexec', ['rm', '-rf', path]);

    if (result.exitCode == 0) {
      print('Successfully force deleted: $path');
    } else {
      print('❌ Erroe Deleting: Worng Password Or Not Access Permission');
    }
  } catch (e) {
    print('❌ Error deleting $path: $e');
  }
}
