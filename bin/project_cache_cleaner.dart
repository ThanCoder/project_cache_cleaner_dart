// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'dart:io';

import 'package:cli_table/cli_table.dart';
import 'package:project_cache_cleaner/project_cache_cleaner.dart';
import 'package:project_cache_cleaner/types.dart';
import 'package:project_cache_cleaner/utils.dart';

void main(List<String> arguments) async {
  print('Scanning started...');
  final stopwatch = Stopwatch()..start();

  final projects = await scanProjectCacheFolder([
    '/home/thancoder/projects',
    '/home/thancoder/Documents',
  ]);

  if (projects.isEmpty) {
    print('✨ No cleanable cache projects found.');
    return;
  }

  final table = Table(header: ["Name", "Type", 'Size']);

  for (var pro in projects) {
    table.add([pro.name, pro.type.name, pro.sizeLable]);
  }

  print(table);

  print('\nScanning finished in ${stopwatch.elapsedMilliseconds}ms');

  // 2. Interactive prompt for deletion
  print('⚠️  Do you want to clean up these cache folders?');
  print(' [1] Clean All (Delete all detected caches)');
  print(' [2] Interactive Mode (Choose project one by one)');
  print(' [3] Cancel & Exit');
  stdout.write('👉 Enter your choice (1/2/3): ');

  final choice = stdin.readLineSync()?.trim();

  // 3. Process the user's choice
  if (choice == '1') {
    stdout.write(
      '\n❗ Are you absolutely sure you want to delete ALL caches? (y/N): ',
    );
    final confirm = stdin.readLineSync()?.trim().toLowerCase();
    if (confirm == 'y' || confirm == 'yes') {
      _deleteAllCaches(projects);
    } else {
      print('❌ Deletion cancelled.');
    }
  } else if (choice == '2') {
    _deleteInteractive(projects);
  } else {
    print('👋 Exited without deleting anything.');
  }
}

// 📦 Method 1: Delete all caches at once
void _deleteAllCaches(List<ProjectInfo> projects) {
  print('\n🧹 Cleaning up all caches...');

  for (var project in projects) {
    for (var dirPath in project.dirs) {
      _deleteDir(dirPath);
    }
  }
  print('✨ All target caches have been successfully cleared!');
}

// 📦 Method 2: Ask one by one
void _deleteInteractive(List<ProjectInfo> projects) {
  print('\n🔎 Interactive Cleanup Mode -');

  for (var project in projects) {
    stdout.write(
      '❓ Delete cache for [${project.name}] (${project.sizeLable})? (y/N): ',
    );
    final ans = stdin.readLineSync()?.trim().toLowerCase();

    if (ans == 'y' || ans == 'yes') {
      for (var dirPath in project.dirs) {
        _deleteDir(dirPath);
      }
    } else {
      print('➡️  Skipped [${project.name}].');
    }
  }
  print('✨ Selected project cleanups completed!');
}

// 🧰 Safe Directory Deletion Helper
void _deleteDir(String path) {
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
