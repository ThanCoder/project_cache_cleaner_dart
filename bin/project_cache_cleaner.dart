import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_table/cli_table.dart';
import 'package:dart_core_extensions/dart_core_extensions.dart';
import 'package:project_cache_cleaner/project_cache_cleaner.dart';
import 'package:project_cache_cleaner/types.dart';
import 'package:project_cache_cleaner/utils.dart';

void main(List<String> args) async {
  final homePath = Platform.environment['HOME'];
  bool includeOtherCache = false;
  bool includeEmptyCacheProject = false;
  try {
    final parser = ArgParser();
    parser.addFlag(
      'other-cache',
      abbr: 'c', // စာလုံးတစ်လုံးတည်းပဲ သုံးရပါမယ် (ဥပမာ 'c' သို့မဟုတ် 'o')
      negatable:
          false, // true/false ကို --no- အနေနဲ့ မသုံးချင်လို့ false ထားတာပါ
      help: 'Include Other Cache (default=false)',
    );
    parser.addFlag(
      'include-empty-cache-project',
      abbr: 'e',
      negatable: false,
      help: 'Inclue Empty Cache Project (default=false)',
    );

    // help
    parser.addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Can Use Command.',
    );

    final result = parser.parse(args);
    if (result['help']) {
      print(parser.usage);
      return;
    }
    includeOtherCache = result['other-cache'] ?? false;
    includeEmptyCacheProject = result['include-empty-cache-project'] ?? false;
  } catch (e) {
    print(e);
    return;
  }

  // Screen ကို clear လုပ်ပြီး cursor ကို home position ရွှေ့မယ်
  stdout.write('\x1B[2J\x1B[0;0H');

  print('\nScanning started...');
  print(
    '\nWill Clean Projects Type: ${ProjectType.values.where((e) => e != .none).map((e) => e.name.toCaptalize).join(', ')} \n',
  );
  final stopwatch = Stopwatch()..start();

  final projects = await scanProjectCacheFolder(
    ['$homePath/projects', '$homePath/Documents'],
    includeOtherCache: includeOtherCache,
    includeEmptyCacheProject: includeEmptyCacheProject,
  );

  if (projects.isEmpty) {
    print('✨ No cleanable cache projects found.');
    return;
  }

  final table = Table(header: ["Index", "Name", "Type", 'Size']);
  int allSize = 0;
  int i = 0;
  for (var pro in projects) {
    table.add([i, pro.name, pro.type.name, pro.sizeLable]);
    allSize += pro.size;
    i++;
  }

  print(table);

  print('\nScanning finished in ${stopwatch.elapsedMilliseconds}ms\n');
  print('All Size: ${allSize.fileSizeLabel()}\n');

  // 2. Interactive prompt for deletion
  print('⚠️  Do you want to clean up these cache folders?');
  print(' [1] Clean All (Delete all detected caches)');
  print(' [2] Interactive Mode (Choose project one by one)');
  print(' [3] Clean With Project Index (example 1,2,3,4,5...etc)');
  print(' [4] Cancel & Exit');
  stdout.write('👉 Enter your choice (1/2/3,4): ');

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
  } else if (choice == '3') {
    print('Write Index Number: (example 1,2,3,4,5...etc)');
    final indexListString = stdin.readLineSync()?.trim();
    if (indexListString == null) return;
    final indexList = indexListString.split(',');
    _deleteWithIndex(projects, indexList);
  } else {
    print('👋 Exited without deleting anything.');
  }
}

// 📦 Method 1: Delete all caches at once
void _deleteAllCaches(List<ProjectInfo> projects) {
  print('\n🧹 Cleaning up all caches...');

  for (var project in projects) {
    for (var dirPath in project.dirs) {
      deleteDir(dirPath);
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
        deleteDir(dirPath);
      }
    } else {
      print('➡️  Skipped [${project.name}].');
    }
  }
  print('✨ Selected project cleanups completed!');
}

void _deleteWithIndex(List<ProjectInfo> projects, List<String> indexList) {
  for (var indexStr in indexList) {
    final index = int.tryParse(indexStr);
    if (index == null) continue;
    if (index >= 0 && index < projects.length) {
      for (var dir in projects[index].dirs) {
        deleteDir(dir);
      }
    }
  }
}
